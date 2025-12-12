# Documentação do Modelo `viagem_classificada.sql` - 08/08/2025

## Visão Geral

O modelo [`queries/models/subsidio/viagem_classificada.sql`](queries/models/subsidio/viagem_classificada.sql:1) é responsável por classificar as viagens de ônibus para determinar sua elegibilidade e o tipo de remuneração no sistema de subsídios. Ele integra dados de viagens completas, informações de veículos (incluindo tecnologia e status), e autuações disciplinares para aplicar um conjunto complexo de regras de negócio.

## Materialização e Particionamento

- **Materialização**: Incremental (`incremental_strategy="insert_overwrite"`)
- **Particionamento**: Por data (`partition_by={"field": "data", "data_type": "date", "granularity": "day"}`)
- **Filtro Incremental**: As atualizações incrementais são filtradas por um período de datas (`data between date("{{var('date_range_start')}}") and date("{{var('date_range_end')}}")` ou `data between date("{{var('start_date')}}") and date("{{var('end_date')}}")`), garantindo que apenas os dados mais recentes sejam processados e que a data seja maior ou igual à `DATA_SUBSIDIO_V15_INICIO`.

## Fontes de Dados (CTEs)

O modelo utiliza as seguintes Common Table Expressions (CTEs) como fontes de dados:

-   **`viagens`**: Seleciona dados básicos de viagens do modelo `viagem_completa`, como data, serviço, horários de partida e chegada, ID do veículo e distância planejada.
-   **`veiculos`**: Obtém informações detalhadas dos veículos do modelo `aux_veiculo_dia_consolidada`, incluindo placa, ano de fabricação, tecnologia, status e indicadores.
-   **`autuacao_disciplinar`**: Busca autuações disciplinares do modelo `autuacao_disciplinar_historico`, filtrando por data de inclusão no datalake e modo "ONIBUS".
-   **`ordem_status`**: Tabela de referência para a ordem de prioridade dos status de viagem, vinda de `valor_km_tipo_viagem`.
-   **`tecnologias`**: Contém informações sobre as tecnologias permitidas por serviço e período de vigência, do modelo `tecnologia_servico`.
-   **`prioridade_tecnologia`**: Tabela que define a prioridade de cada tipo de tecnologia, do modelo `tecnologia_prioridade`.

## Lógica de Classificação de Viagens (`viagem_classificada` CTE)

A classificação das viagens é realizada na CTE `viagem_classificada` através de uma série de condições `CASE WHEN`, que determinam o `tipo_viagem` com base no status do veículo, tecnologia e autuações. A ordem das condições é crucial, pois a primeira condição verdadeira é aplicada.

### Regras de Classificação Detalhadas:

1.  **"Não licenciado"**:
    *   `when vt.status = "Não licenciado" then "Não licenciado"`
    *   A viagem é classificada como "Não licenciado" se o status do veículo for explicitamente "Não licenciado".

2.  **"Não vistoriado"**:
    *   `when vt.status = "Não vistoriado" then "Não vistoriado"`
    *   A viagem é classificada como "Não vistoriado" se o status do veículo for explicitamente "Não vistoriado".

3.  **"Lacrado"**:
    *   `when vt.status = "Lacrado" then "Lacrado"`
    *   A viagem é classificada como "Lacrado" se o status do veículo for explicitamente "Lacrado".

4.  **"Não autorizado por ausência de ar-condicionado" (V19+)**:
    *   `when vt.status = "Licenciado sem ar e não autuado" and vt.servico not in (select servico from {{ ref("servico_contrato_abreviado") }}) and vt.data >= date("{{ var('DATA_SUBSIDIO_V19_INICIO') }}") then "Não autorizado por ausência de ar-condicionado"`
    *   Esta regra se aplica a partir da versão V19 do subsídio.
    *   Classifica a viagem como "Não autorizado por ausência de ar-condicionado" se o veículo estiver "Licenciado sem ar e não autuado" e o serviço não estiver na lista de serviços com contrato abreviado.

5.  **"Não autorizado por capacidade" (V17+)**:
    *   `when vt.indicador_penalidade_tecnologia and vt.data >= date('{{ var("DATA_SUBSIDIO_V17_INICIO") }}') then "Não autorizado por capacidade"`
    *   Esta regra se aplica a partir da versão V17 do subsídio.
    *   Classifica a viagem como "Não autorizado por capacidade" se houver um indicador de penalidade de tecnologia (`indicador_penalidade_tecnologia` é `TRUE`). Este indicador é definido na CTE `viagem_tecnologia` quando a `tecnologia_apurada` do veículo tem uma prioridade menor que a `menor_tecnologia_permitida` para o serviço.

6.  **"Autuado por ar inoperante"**:
    *   `when vt.status = "Autuado por ar inoperante" then "Autuado por ar inoperante"`
    *   A viagem é classificada como "Autuado por ar inoperante" se o status do veículo for explicitamente "Autuado por ar inoperante".

7.  **Autuações Disciplinares Específicas (baseadas em `id_infracao`)**:
    *   `when vah.id_infracao = "017.III" then "Autuado por alterar itinerário"`
    *   `when vah.id_infracao = "023.X" then "Autuado por vista inoperante"`
    *   `when vah.id_infracao = "029.I" then "Autuado por não atender solicitação de parada"`
    *   `when vah.id_infracao = "029.XIII" then "Autuado por iluminação insuficiente"`
    *   `when vah.id_infracao = "040.I" then "Autuado por não concluir itinerário"`
    *   Estas regras classificam a viagem com base em infrações específicas registradas na tabela de autuações disciplinares (`autuacao_disciplinar_historico`), que são associadas à viagem na CTE `viagem_autuacao_hora`.

8.  **Status Operacionais Restantes**:
    *   `when vt.status = "Registrado com ar inoperante" then "Registrado com ar inoperante"`
    *   `when vt.status = "Licenciado sem ar e não autuado" then "Licenciado sem ar e não autuado"`
    *   `when vt.status = "Licenciado com ar e não autuado" then "Licenciado com ar e não autuado"`
    *   Estas são as classificações padrão para veículos que não se enquadram nas regras de penalidade ou autuação anteriores.

### Campo `tecnologia_remunerada`

O campo `tecnologia_remunerada` (linhas 110-118) é crucial para o cálculo do subsídio e reflete a penalidade V15A (que no código está referenciada como V17).

-   `when p.prioridade > p_maior.prioridade then t.maior_tecnologia_permitida`: Se a tecnologia apurada do veículo tiver uma prioridade maior (ou seja, for uma tecnologia superior) do que a `maior_tecnologia_permitida` para o serviço, a tecnologia remunerada será a `maior_tecnologia_permitida`.
-   `when p.prioridade < p_menor.prioridade and data >= date('{{ var("DATA_SUBSIDIO_V17_INICIO") }}') then null`: **Esta é a regra da penalidade V15A (referenciada como V17 no código)**. Se a tecnologia apurada do veículo tiver uma prioridade menor (ou seja, for uma tecnologia inferior) do que a `menor_tecnologia_permitida` para o serviço, e a data da viagem for igual ou posterior à `DATA_SUBSIDIO_V17_INICIO` (que corresponde à V15A), a `tecnologia_remunerada` será `NULL`. Isso significa que a viagem não será remunerada por tecnologia.
-   `else vs.tecnologia`: Caso contrário, a tecnologia remunerada será a `tecnologia_apurada` do veículo.

### Indicadores

O campo `indicadores` é atualizado para incluir o `indicador_penalidade_tecnologia` e sua `data_inicio_vigencia`, permitindo rastreabilidade das penalidades aplicadas.

## Deduplicação (`deduplica` CTE)

A CTE `deduplica` garante que cada viagem seja classificada de forma única, utilizando a função `ROW_NUMBER()` particionada por `data` e `id_viagem`, e ordenada pela `ordem` definida na tabela `ordem_status`. Isso resolve possíveis múltiplas classificações para a mesma viagem, priorizando a classificação com menor ordem.

## Processo de Validação de Viagens

O processo de validação de viagens é diretamente afetado por estas regras, pois elas determinam se uma viagem é elegível para remuneração e, em caso afirmativo, sob qual classificação e tecnologia. A integração de dados de bilhetagem (mencionada nos documentos de julho) complementa este processo, fornecendo informações adicionais sobre transações e rastreamento (GPS dos validadores) que podem influenciar a classificação final da viagem. Por exemplo, uma viagem pode ser classificada como "sem transação" se os dados da bilhetagem indicarem ausência de registro, o que pode levar a uma viagem não remunerada.

## Conclusão

O modelo `viagem_classificada.sql` é um componente central no cálculo do subsídio, aplicando regras de negócio complexas para determinar a elegibilidade e o tipo de remuneração das viagens. A sua lógica é dinâmica, incorporando versões de subsídio e integrando diversas fontes de dados para garantir a precisão da apuração.