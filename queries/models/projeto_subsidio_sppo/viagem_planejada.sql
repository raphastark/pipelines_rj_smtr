{{
    config(
        materialized="incremental",
        partition_by={"field": "data", "data_type": "date", "granularity": "day"},
        incremental_strategy="insert_overwrite",
    )
}}

{% if var("run_date") <= var("DATA_SUBSIDIO_V6_INICIO") %}

    -- 1. Define datas do período planejado
    with
        data_efetiva as (
            select
                data,
                tipo_dia,
                data_versao_shapes,
                data_versao_trips,
                data_versao_frequencies
            from {{ ref("subsidio_data_versao_efetiva") }}
            where
                data between date_sub("{{ var('run_date') }}", interval 1 day) and date(
                    "{{ var('run_date') }}"
                )
        ),
        -- 2. Puxa dados de distancia quadro no quadro horário
        quadro as (
            select
                e.data,
                e.tipo_dia,
                p.* except (tipo_dia, data_versao, horario_inicio, horario_fim),
                if(
                    horario_inicio is not null
                    and array_length(split(horario_inicio, ":")) = 3,
                    datetime_add(
                        datetime(
                            e.data,
                            parse_time(
                                "%T",
                                concat(
                                    safe_cast(
                                        mod(
                                            safe_cast(
                                                split(horario_inicio, ":")[
                                                    offset(0)
                                                ] as int64
                                            ),
                                            24
                                        ) as int64
                                    ),
                                    ":",
                                    safe_cast(
                                        split(horario_inicio, ":")[offset(1)] as int64
                                    ),
                                    ":",
                                    safe_cast(
                                        split(horario_inicio, ":")[offset(2)] as int64
                                    )
                                )
                            )
                        ),
                        interval div(
                            safe_cast(split(horario_inicio, ":")[offset(0)] as int64),
                            24
                        ) day
                    ),
                    null
                ) as inicio_periodo,
                if(
                    horario_fim is not null
                    and array_length(split(horario_fim, ":")) = 3,
                    datetime_add(
                        datetime(
                            e.data,
                            parse_time(
                                "%T",
                                concat(
                                    safe_cast(
                                        mod(
                                            safe_cast(
                                                split(horario_fim, ":")[
                                                    offset(0)
                                                ] as int64
                                            ),
                                            24
                                        ) as int64
                                    ),
                                    ":",
                                    safe_cast(
                                        split(horario_fim, ":")[offset(1)] as int64
                                    ),
                                    ":",
                                    safe_cast(
                                        split(horario_fim, ":")[offset(2)] as int64
                                    )
                                )
                            )
                        ),
                        interval div(
                            safe_cast(split(horario_fim, ":")[offset(0)] as int64), 24
                        ) day
                    ),
                    null
                ) as fim_periodo
            from data_efetiva e
            inner join
                (
                    select *
                    from {{ ref("subsidio_quadro_horario") }}
                    {% if is_incremental() %}
                        where
                            data_versao
                            in (select data_versao_frequencies from data_efetiva)
                    {% endif %}
                ) p
                on e.data_versao_frequencies = p.data_versao
                and e.tipo_dia = p.tipo_dia
        ),
        -- 3. Trata informação de trips: adiciona ao sentido da trip o sentido
        -- planejado (os shapes/trips circulares são separados em
        -- ida/volta no sigmob)
        trips as (
            select e.data, t.*
            from
                (
                    select *
                    from {{ ref("subsidio_trips_desaninhada") }}
                    {% if is_incremental() %}
                        where
                            data_versao in (select data_versao_trips from data_efetiva)
                    {% endif %}
                ) t
            inner join data_efetiva e on t.data_versao = e.data_versao_trips
        ),
        quadro_trips as (
            select *
            from
                (
                    select distinct
                        * except (trip_id), trip_id as trip_id_planejado, trip_id
                    from quadro
                    where sentido = "I" or sentido = "V"
                )
            union all
            (
                select
                    * except (trip_id),
                    trip_id as trip_id_planejado,
                    concat(trip_id, "_0") as trip_id,
                from quadro
                where sentido = "C"
            )
            union all
            (
                select
                    * except (trip_id),
                    trip_id as trip_id_planejado,
                    concat(trip_id, "_1") as trip_id,
                from quadro
                where sentido = "C"
            )
        ),
        quadro_tratada as (
            select
                q.*,
                t.shape_id as shape_id_planejado,
                case
                    when sentido = "C"
                    then shape_id || "_" || split(q.trip_id, "_")[offset(1)]
                    else shape_id
                end as shape_id,  -- TODO: adicionar no sigmob
            from quadro_trips q
            left join trips t on t.data = q.data and t.trip_id = q.trip_id_planejado
        ),
        -- 4. Trata informações de shapes: junta trips e shapes para resgatar o sentido
        -- planejado (os shapes/trips circulares são separados em
        -- ida/volta no sigmob)
        shapes as (
            select e.data, data_versao as data_shape, shape_id, shape, start_pt, end_pt
            from data_efetiva e
            inner join
                (
                    select *
                    from {{ ref("subsidio_shapes_geom") }}
                    {% if is_incremental() %}
                        where
                            data_versao in (select data_versao_shapes from data_efetiva)
                    {% endif %}
                ) s
                on s.data_versao = e.data_versao_shapes
        )
    -- 5. Junta shapes e trips aos servicos planejados no quadro horário
    select
        p.*,
        s.data_shape,
        s.shape,
        case
            when p.sentido = "C" and split(p.shape_id, "_")[offset(1)] = "0"
            then "I"
            when p.sentido = "C" and split(p.shape_id, "_")[offset(1)] = "1"
            then "V"
            when p.sentido = "I" or p.sentido = "V"
            then p.sentido
        end as sentido_shape,
        safe_cast(null as int64) as partidas_total_planejada,  -- Adaptação para formato da SUBSIDIO_V6
        s.start_pt,
        s.end_pt,
        safe_cast(null as int64) as id_tipo_trajeto,  -- Adaptação para formato da SUBSIDIO_V6
        safe_cast(null as DATE) as feed_start_date,  -- Adaptação para formato da SUBSIDIO_V6
        safe_cast(null as string) as feed_version,  -- Adaptação para formato da SUBSIDIO_V6
        current_datetime("America/Sao_Paulo") as datetime_ultima_atualizacao,  -- Adaptação para formato da SUBSIDIO_V7
        datetime(concat(p.data, "T00:00:00")) as faixa_horaria_inicio,  -- Adaptação para formato da SUBSIDIO_V9
        datetime(concat(p.data, "T23:59:59")) as faixa_horaria_fim,  -- Adaptação para formato da SUBSIDIO_V9
    from quadro_tratada p
    inner join shapes s on p.shape_id = s.shape_id and p.data = s.data

{% else %}
    {% if execute %}
        {% set result = run_query(
            "SELECT tipo_os, feed_version, feed_start_date, tipo_dia FROM "
            ~ ref("subsidio_data_versao_efetiva")
            ~ " WHERE data BETWEEN DATE_SUB(DATE('"
            ~ var("run_date")
            ~ "'), INTERVAL 2 DAY) AND DATE_SUB(DATE('"
            ~ var("run_date")
            ~ "'), INTERVAL 1 DAY) ORDER BY data"
        ) %}
        {% set tipo_oss = result.columns[0].values() %}
        {% set feed_versions = result.columns[1].values() %}
        {% set feed_start_dates = result.columns[2].values() %}
        {% set tipo_dias = result.columns[3].values() %}
    {% endif %}

    with
        -- 1. Define datas do período planejado
        data_versao_efetiva as (
            select data, tipo_dia, subtipo_dia, feed_version, feed_start_date, tipo_os,
            from {{ ref("subsidio_data_versao_efetiva") }}
            -- `rj-smtr.projeto_subsidio_sppo.subsidio_data_versao_efetiva`
            where
                data
                between date_sub("{{ var('run_date') }}", interval 2 day) and date_sub(
                    "{{ var('run_date') }}", interval 1 day
                )
        ),
        ordem_servico_trips_shapes as (
            select *
            from  {{ ref("ordem_servico_trips_shapes_gtfs") }}
                -- `rj-smtr.gtfs.ordem_servico_trips_shapes`
            where feed_start_date in ("{{ feed_start_dates | join('", "') }}")
        ),
        dia_atual as (
            select
                feed_version,
                feed_start_date,
                feed_end_date,
                tipo_os,
                tipo_dia,
                servico,
                vista,
                consorcio,
                sentido,
                partidas_total_planejada,
                distancia_planejada,
                distancia_total_planejada,
                inicio_periodo,
                fim_periodo,
                faixa_horaria_inicio,
                faixa_horaria_fim,
                trip_id_planejado,
                trip_id,
                shape_id,
                shape_id_planejado,
                sentido_shape,
                id_tipo_trajeto,
            from ordem_servico_trips_shapes
            where
                tipo_os = "{{ tipo_oss[1] }}"
                and feed_version = "{{ feed_versions[1] }}"
                and feed_start_date = date("{{ feed_start_dates[1] }}")
                and tipo_dia = "{{ tipo_dias[1] }}"
        ),
        -- 2. Busca partidas e quilometragem da faixa horaria (dia anterior)
        dia_anterior as (
            select
                "{{ feed_versions[1] }}" as feed_version,
                date("{{ feed_start_dates[1] }}") as feed_start_date,
                ts.feed_end_date,
                "{{ tipo_oss[1] }}" as tipo_os,
                "{{ tipo_dias[1] }}" as tipo_dia,
                -- Alteração referente ao Processo.rio MTR-CAP-2025/06098
                case
                    when "{{ var('run_date') }}" = "2025-06-02"
                    and ts.servico = "864"
                        then "LECD122"
                    when "{{ var('run_date') }}" = "2025-06-02"
                            and ts.servico = "LECD108"
                                then "LECD112"
                else ts.servico
                end as servico,
                ts.vista,
                ts.consorcio,
                ts.sentido,
                ts.partidas_total_planejada,
                coalesce(
                    da.distancia_planejada, ts.distancia_planejada
                ) as distancia_planejada,
                ts.distancia_total_planejada,
                coalesce(da.inicio_periodo, ts.inicio_periodo) as inicio_periodo,
                coalesce(da.fim_periodo, ts.fim_periodo) as fim_periodo,
                "00:00:00" as faixa_horaria_inicio,
                "02:59:59" as faixa_horaria_fim,
                coalesce(
                    da.trip_id_planejado, ts.trip_id_planejado
                ) as trip_id_planejado,
                coalesce(da.trip_id, ts.trip_id) as trip_id,
                ts.shape_id,
                ts.shape_id_planejado,
                ts.sentido_shape,
                ts.id_tipo_trajeto,
            from ordem_servico_trips_shapes as ts
            left join
                (
                    select distinct
                        servico,
                        sentido,
                        shape_id,
                        distancia_planejada,
                        inicio_periodo,
                        fim_periodo,
                        trip_id_planejado,
                        trip_id
                    from dia_atual
                ) as da
                on
                (
                    da.servico = ts.servico
                    -- Alteração referente ao Processo.rio MTR-CAP-2025/06098
                    {% if var("run_date") == "2025-06-02" %}
                        or (ts.servico = "864" and da.servico = "LECD122")
                        or (ts.servico = "LECD108" and da.servico = "LECD112")
                    {% endif %}
                )
                and da.shape_id = ts.shape_id
                and da.sentido = ts.sentido
            where
                ts.faixa_horaria_inicio = "24:00:00"
                and ts.tipo_os = "{{ tipo_oss[0] }}"
                and ts.feed_version = "{{ feed_versions[0] }}"
                and ts.feed_start_date = date("{{ feed_start_dates[0] }}")
                and ts.tipo_dia = "{{ tipo_dias[0] }}"
        ),
        combina_trips_shapes as (
            select
                feed_version,
                feed_start_date,
                feed_end_date,
                tipo_os,
                tipo_dia,
                servico,
                vista,
                consorcio,
                sentido,
                partidas_total_planejada,
                distancia_planejada,
                distancia_total_planejada,
                inicio_periodo,
                split(inicio_periodo, ":") as inicio_periodo_parts,
                fim_periodo,
                split(fim_periodo, ":") as fim_periodo_parts,
                faixa_horaria_inicio,
                split(faixa_horaria_inicio, ":") as faixa_horaria_inicio_parts,
                faixa_horaria_fim,
                split(faixa_horaria_fim, ":") as faixa_horaria_fim_parts,
                trip_id_planejado,
                trip_id,
                shape_id,
                shape_id_planejado,
                sentido_shape,
                id_tipo_trajeto,
            from dia_atual
            union all
            select
                feed_version,
                feed_start_date,
                feed_end_date,
                tipo_os,
                tipo_dia,
                servico,
                vista,
                consorcio,
                sentido,
                partidas_total_planejada,
                distancia_planejada,
                distancia_total_planejada,
                inicio_periodo,
                split(inicio_periodo, ":") as inicio_periodo_parts,
                fim_periodo,
                split(fim_periodo, ":") as fim_periodo_parts,
                faixa_horaria_inicio,
                split(faixa_horaria_inicio, ":") as faixa_horaria_inicio_parts,
                faixa_horaria_fim,
                split(faixa_horaria_fim, ":") as faixa_horaria_fim_parts,
                trip_id_planejado,
                trip_id,
                shape_id,
                shape_id_planejado,
                sentido_shape,
                id_tipo_trajeto,
            from dia_anterior
        ),
        data_trips_shapes as (
            select
                d.data,
                case
                    when subtipo_dia is not null
                    then concat(o.tipo_dia, " - ", subtipo_dia)
                    else o.tipo_dia
                end as tipo_dia,
                servico,
                vista,
                consorcio,
                sentido,
                partidas_total_planejada,
                distancia_planejada,
                distancia_total_planejada,
                if(
                    inicio_periodo is not null
                    and array_length(inicio_periodo_parts) = 3,
                    datetime(d.data) + make_interval(
                        hour => safe_cast(inicio_periodo_parts[0] as int64),
                        minute => safe_cast(inicio_periodo_parts[1] as int64),
                        second => safe_cast(inicio_periodo_parts[2] as int64)
                    ),
                    null
                ) as inicio_periodo,
                if(
                    fim_periodo is not null and array_length(fim_periodo_parts) = 3,
                    datetime(d.data) + make_interval(
                        hour => safe_cast(fim_periodo_parts[0] as int64),
                        minute => safe_cast(fim_periodo_parts[1] as int64),
                        second => safe_cast(fim_periodo_parts[2] as int64)
                    ),
                    null
                ) as fim_periodo,
                if(
                    d.data >= date("{{ var('DATA_SUBSIDIO_V9_INICIO') }}"),
                    datetime(d.data) + make_interval(
                        hour => safe_cast(o.faixa_horaria_inicio_parts[0] as int64),
                        minute => safe_cast(o.faixa_horaria_inicio_parts[1] as int64),
                        second => safe_cast(o.faixa_horaria_inicio_parts[2] as int64)
                    ),
                    datetime(d.data)
                    + make_interval(hour => 0, minute => 0, second => 0)
                ) as faixa_horaria_inicio,
                if(
                    d.data >= date("{{ var('DATA_SUBSIDIO_V9_INICIO') }}"),
                    datetime(d.data) + make_interval(
                        hour => safe_cast(o.faixa_horaria_fim_parts[0] as int64),
                        minute => safe_cast(o.faixa_horaria_fim_parts[1] as int64),
                        second => safe_cast(o.faixa_horaria_fim_parts[2] as int64)
                    ),
                    datetime(d.data)
                    + make_interval(hour => 23, minute => 59, second => 59)
                ) as faixa_horaria_fim,
                trip_id_planejado,
                trip_id,
                shape_id,
                shape_id_planejado,
                safe_cast(null as date) as data_shape,
                sentido_shape,
                id_tipo_trajeto,
                feed_version,
                feed_start_date
            from data_versao_efetiva as d
            left join
                combina_trips_shapes as o using (
                    feed_start_date, feed_version, tipo_dia, tipo_os
                )
            where
                data = date_sub("{{ var('run_date') }}", interval 1 day)
                and faixa_horaria_inicio != "24:00:00"
        ),
        shapes as (
            select shape_id, shape, start_pt, end_pt
            from {{ ref("shapes_geom_gtfs") }}
            -- `rj-smtr.gtfs.shapes_geom`
            where feed_start_date in ("{{ feed_start_dates | join('", "') }}")
            qualify
                row_number() over (partition by shape_id order by feed_start_date desc)
                = 1
        ),
        dados_agregados as (
            select
                data,
                tipo_dia,
                servico,
                vista,
                consorcio,
                sentido,
                sum(coalesce(partidas_total_planejada, 0)) as partidas_total_planejada,
                distancia_planejada,
                sum(distancia_total_planejada) as distancia_total_planejada,
                inicio_periodo,
                fim_periodo,
                faixa_horaria_inicio,
                faixa_horaria_fim,
                trip_id_planejado,
                trip_id,
                shape_id,
                shape_id_planejado,
                data_shape,
                sentido_shape,
                id_tipo_trajeto,
                feed_version,
                feed_start_date
            from data_trips_shapes
            group by
                data,
                tipo_dia,
                servico,
                vista,
                consorcio,
                sentido,
                distancia_planejada,
                inicio_periodo,
                fim_periodo,
                faixa_horaria_inicio,
                faixa_horaria_fim,
                trip_id_planejado,
                trip_id,
                shape_id,
                shape_id_planejado,
                data_shape,
                sentido_shape,
                id_tipo_trajeto,
                feed_version,
                feed_start_date
        )
    select
        data,
        tipo_dia,
        servico,
        vista,
        consorcio,
        sentido,
        partidas_total_planejada,
        distancia_planejada,
        distancia_total_planejada,
        inicio_periodo,
        fim_periodo,
        faixa_horaria_inicio,
        faixa_horaria_fim,
        trip_id_planejado,
        trip_id,
        shape_id,
        shape_id_planejado,
        data_shape,
        s.shape,
        sentido_shape,
        s.start_pt,
        s.end_pt,
        id_tipo_trajeto,
        feed_version,
        feed_start_date,
        current_datetime("America/Sao_Paulo") as datetime_ultima_atualizacao
    from dados_agregados
    left join shapes as s using (shape_id)
    {% if var("run_date") == "2024-05-05" %}
        -- Apuração "Madonna · The Celebration Tour in Rio"
        where servico != "SE001"
    {% endif %}
{% endif %}
