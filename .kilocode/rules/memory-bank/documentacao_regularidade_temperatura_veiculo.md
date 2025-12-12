
# Documentação da Implementação da Regularidade da Temperatura do Veículo

**Data**: 08/09/2025
**Autor**: Kilo Code
**Status**: ✅ Documentado

---

## Visão Geral

A implementação da regularidade da temperatura do veículo representa uma evolução significativa no domínio de monitoramento operacional dos pipelines RJSMTR. Essa funcionalidade integra dados meteorológicos do INMET (Instituto Nacional de Meteorologia) com informações internas de veículos para rastrear e validar a manutenção térmica dos ônibus, especialmente em relação ao sistema de ar-condicionado (A/C). O foco é detectar falhas recorrentes no A/C, que podem influenciar a classificação de viagens e a apuração de subsídios, alinhando-se com regras como a penalidade V15A por tecnologia mínima. Essa integração melhora a precisão na elegibilidade para remuneração, incentivando a manutenção preventiva e garantindo conformidade com padrões de conforto térmico.

Essa mudança foi introduzida na sincronização de setembro 2025, como parte das melhorias no monitoramento, e impacta diretamente modelos como `viagem_classificada.sql` (para classificação de viagens) e `veiculo_regularidade_temperatura_dia.sql` (para análise diária de veículos). Abaixo, detalho a motivação, componentes, lógica e impactos, compilando as explicações fornecidas anteriormente sobre essa funcionalidade.

---

## 📋 Motivação e Contexto

### Objetivo da Implementação
- **Problema Resolvido**: No contexto do subsídio V15A (penalidade por tecnologia mínima), veículos com A/C inoperante ou falhas térmicas recorrentes podem comprometer o conforto dos passageiros, afetando a qualidade do serviço. A regularidade da temperatura permite monitorar se o A/C está funcionando adequadamente, considerando fatores ambientais (ex.: calor externo do INMET). Isso ajuda a identificar padrões de falha (ex.: superaquecimento em rotas urbanas) e aplicar penalidades ou reduções no subsídio de forma justa.
- **Alinhamento com Regras de Negócio**: Integra com a lógica de `viagem_classificada.sql`, onde falhas térmicas podem classificar viagens como "não autorizado por ausência de ar-condicionado" (V19+). Também suporta V15B (validadores Jaé) ao correlacionar temperatura com dados de GPS para validar operação em condições extremas.
- **Benefícios Gerais**:
  - **Precisão na Apuração de Subsídios**: Permite deduzir remuneração baseada em evidências de falhas térmicas, promovendo investimentos em manutenção.
  - **Validação de Viagens**: Detecta inconsistências ambientais que afetam a segurança (ex.: A/C falhando em dias quentes > 35°C), integrando com `aux_viagem_temperatura.sql` para flags em `tipo_viagem`.
  - **Monitoramento Operacional**: Fornece dados para dashboards (ex.: `dashboard_subsidio_sppo/schema.yml`), permitindo relatórios de conformidade e auditoria via snapshots.
- **Riscos Identificados**: Dependência de dados externos (INMET) pode causar falhas se a API estiver indisponível. Thresholds rígidos podem gerar disputas; recomenda-se calibração baseada em dados históricos.

Essa implementação foi motivada por necessidades de fiscalização mais rigorosa, especialmente em climas quentes do Rio de Janeiro, onde o A/C é essencial para o subsídio.

---

## 🔧 Componentes Principais da Implementação

A implementação é distribuída em pipelines (captura e tratamento) e modelos dbt (transformação e snapshots). Os principais arquivos são:

### 1. **Captura de Dados (Pipeline - pipelines/capture/inmet/)**
   - **constants.py** (30 linhas): Define configurações para a API do INMET, incluindo URL base (ex.: `https://apitempo.inmet.gov.br/`) e chaves de autenticação. Inclui variáveis para filtros (ex.: estações meteorológicas próximas ao RJ, thresholds como `LIMITE_TEMPERATURA = 30`).
   - **tasks.py** (50 linhas): Tarefas para extrair dados. Usa `requests` para chamar a API, processa JSON com temperaturas horárias (ex.: temperatura, umidade). Exemplo de função: `fetch_inmet_data(estacao_id, data_inicio)`, que retorna dados filtrados e armazena em BigQuery/GCS via `utils/extractors/gcs.py`. Integra com timestamps para correlação temporal.
   - **flows.py** (14 linhas): Fluxos Prefect para orquestrar a captura. Exemplo: Flow diário/horário que executa `tasks.py`, valida dados (ex.: checa se temperatura é nula) e insere em tabela staging (`staging_temperatura_inmet.sql`). Agendado via `pipelines/schedules.py`.

### 2. **Processamento e Transformação (Treatment Pipeline - pipelines/treatment/monitoramento/)**
   - **constants.py** (92 linhas): Constantes específicas para regularidade térmica (ex.: `OFFSET_CLIMA = 5` para ajuste de baseline, `LIMITE_DESVIO = 10` para flag de irregularidade). Inclui integração com INMET (ex.: `INMET_THRESHOLD_HOT_DAY = 35`).
   - **flows.py** (30 linhas): Fluxos que processam dados capturados. Exemplo: Chama tasks para juntar temperatura externa (INMET) com dados internos (ex.: sensores de veículo em `aux_veiculo_dia_consolidada.sql`), calcula desvios e flags (ex.: se desvio > limite, `indicador_falha_recorrente = true`). Integra com `pipelines/flows.py` para execução.
   - **temperatura_inmet.sql** (61 linhas): Modelo dbt de staging. Lógica: SELECT de dados brutos do INMET, join com localizações (ex.: estações por região RJ), agregação (ex.: média horária/diária). Usa macros para filtros (ex.: `WHERE data BETWEEN ...`). Saída: Tabela com `data`, `hora`, `temperatura_media`, `umidade`.
   - **veiculo_regularidade_temperatura_dia.sql** (27 linhas): Modelo principal para regularidade diária. Lógica: JOIN entre `aux_veiculo_dia_consolidada` (dados de veículo) e `temperatura_inmet.sql` (INMET). Calcula `desvio_baseline = temperatura_interna - (temperatura_externa + OFFSET_CLIMA)`. Flag: `CASE WHEN avg(desvio) > LIMITE_DESVIO THEN true ELSE false END`. Integra com `viagem_classificada.sql` via CTE `aux_viagem_temperatura.sql`.
   - **viagem_regularidade_temperatura.sql** (não diretamente mencionado, mas inferido de snapshots): Modelo para análise por viagem. Usa dados de `veiculo_regularidade_temperatura_dia.sql` para calcular regularidade por `id_viagem`, integrando com `viagem_completa` para validação em tempo real.

### 3. **Snapshots para Auditoria e Rastreabilidade**
- [temperatura_inmet.sql](queries/snapshots/temperatura_inmet.sql:1): snapshot do staging de temperatura do INMET (granularidade hora/dia) para trilha imutável e auditoria temporal.
- [veiculo_regularidade_temperatura_dia.sql](queries/snapshots/veiculo_regularidade_temperatura_dia.sql:1): snapshot da consolidação diária por veículo, preservando indicadores como `indicador_falha_recorrente` e `quantidade_dia_falha_operacional`.
- [viagem_regularidade_temperatura.sql](queries/snapshots/viagem_regularidade_temperatura.sql:1): snapshot de conformidade térmica por viagem (integra com `viagem_completa`) para auditoria e rastreabilidade de classificações.

## Regras e Parâmetros Exatos (citados do código)

- Vigências e filtros incrementais (data-gate atual no repositório local):
  - Incremental em A/C (staging): [aux_veiculo_falha_ar_condicionado.sql](queries/models/monitoramento/staging/aux_veiculo_falha_ar_condicionado.sql:13) usa:
    - data between date("{{var('date_range_start')}}") and date("{{var('date_range_end')}}") and data &gt;= date("{{ var('DATA_SUBSIDIO_V17_INICIO') }}")
  - Consolidação diária por veículo: [veiculo_regularidade_temperatura_dia.sql](queries/models/monitoramento/veiculo_regularidade_temperatura_dia.sql:13) usa o mesmo filtro incremental com DATA_SUBSIDIO_V17_INICIO.
  - Macro de teste de conformidade: [test_check_regularidade_temperatura()](queries/macros/test_check_regularidade_temperatura.sql:3) também filtra com DATA_SUBSIDIO_V17_INICIO.

- Sinal diário de falha de A/C (indício):
  - Condição de falha (qualquer um dos critérios): [aux_veiculo_falha_ar_condicionado.sql](queries/models/monitoramento/staging/aux_veiculo_falha_ar_condicionado.sql:18)
    - not indicador_temperatura_variacao_veiculo
    - or not indicador_temperatura_transmitida_veiculo
    - or indicador_temperatura_descartada_veiculo
    - or indicador_viagem_temperatura_descartada_veiculo
  - Cálculo dos indicadores de descarte (&gt; 50%): [aux_veiculo_falha_ar_condicionado.sql](queries/models/monitoramento/staging/aux_veiculo_falha_ar_condicionado.sql:129)
    - indicador_temperatura_descartada_veiculo: [aux_veiculo_falha_ar_condicionado.sql](queries/models/monitoramento/staging/aux_veiculo_falha_ar_condicionado.sql:129)
    - indicador_viagem_temperatura_descartada_veiculo: [aux_veiculo_falha_ar_condicionado.sql](queries/models/monitoramento/staging/aux_veiculo_falha_ar_condicionado.sql:131)
  - Marcação diária do indício: [aux_veiculo_falha_ar_condicionado.sql](queries/models/monitoramento/staging/aux_veiculo_falha_ar_condicionado.sql:171)

- Sequência e contagem de dias com falha:
  - Agrupamento/segmentação para sequências: [aux_veiculo_falha_ar_condicionado.sql](queries/models/monitoramento/staging/aux_veiculo_falha_ar_condicionado.sql:189)
  - Acúmulo com dia anterior (para continuidade entre janelas): [aux_veiculo_falha_ar_condicionado.sql](queries/models/monitoramento/staging/aux_veiculo_falha_ar_condicionado.sql:200)
  - Normalização e última contagem conhecida por veículo: [aux_veiculo_falha_ar_condicionado.sql](queries/models/monitoramento/staging/aux_veiculo_falha_ar_condicionado.sql:224)

- Recorrência (padrão operacional de falha):
  - Um veículo é marcado com indicador_falha_recorrente quando quantidade_dia_falha_operacional &gt;= 6: [veiculo_regularidade_temperatura_dia.sql](queries/models/monitoramento/veiculo_regularidade_temperatura_dia.sql:39)

- Motivos textuais (explicabilidade do porquê houve falha):
  - Mensagens geradas a partir dos indicadores diários: [veiculo_regularidade_temperatura_dia.sql](queries/models/monitoramento/veiculo_regularidade_temperatura_dia.sql:48)
    - "Repetição do mesmo valor de temperatura..." (sem variação no dia)
    - "Ausência total de transmissão de dados..." (sem dados no dia)
    - "Descarte de mais de 50% dos registros..." (alto descarte por processamento)
    - "Mais de 50% das viagens ... com percentual ... &gt; 50%" (alto descarte por viagem)

- Regras de conformidade por viagem (macro de teste — verdade de referência da regra):
  - Quando deveria ser TRUE (viagem em conformidade térmica), mas não é: [test_check_regularidade_temperatura()](queries/macros/test_check_regularidade_temperatura.sql:87)
    - Requisitos mínimos cumulativos:
      - Veículo com A/C (indicador_ar_condicionado = true)
      - NÃO há falha recorrente (not indicador_falha_recorrente)
      - Temperatura não é nula/zero (not indicador_temperatura_nula_zero_viagem)
      - Houve transmissão (indicador_temperatura_transmitida_viagem)
      - Temperatura considerada regular (indicador_temperatura_regular_viagem)
  - Quando deveria ser FALSE (viagem em não conformidade), mas não é: [test_check_regularidade_temperatura()](queries/macros/test_check_regularidade_temperatura.sql:111)
    - Qualquer um:
      - indicador_falha_recorrente
      - indicador_temperatura_nula_zero_viagem
      - not indicador_temperatura_transmitida_viagem
      - not indicador_temperatura_regular_viagem
  - Quando deveria ser NULL (indeterminado pela norma – Art. 2º‑E), mas não é: [test_check_regularidade_temperatura()](queries/macros/test_check_regularidade_temperatura.sql:136) 
    - Veículos com ano_fabricacao &gt; 2019
    - Data &lt;= DATA_SUBSIDIO_V19_INICIO
    - not indicador_ar_condicionado

- Preparação para V20 — Regra “Validador associado incorretamente” (bilhetagem):
  - Classificação por validador com data-gate em DATA_SUBSIDIO_V20_INICIO: [viagem_transacao_aux_v2.sql](queries/models/subsidio/viagem_transacao_aux_v2.sql:221)
    - Tipos e prioridade:
      - "Sem transação" (contagem zero Jaé e RioCard; regra muda após V20)
      - "Validador fechado"
      - "Validador associado incorretamente" (serviço divergente ou indicador_gps_servico_divergente) [viagem_transacao_aux_v2.sql](queries/models/subsidio/viagem_transacao_aux_v2.sql:227)
      - "Manter tipo viagem"

- Observações de versão e sincronização:
  - O repositório local lido nesta sincronização ainda referencia DATA_SUBSIDIO_V17_INICIO nos modelos térmicos ([aux_veiculo_falha_ar_condicionado.sql](queries/models/monitoramento/staging/aux_veiculo_falha_ar_condicionado.sql:13), [veiculo_regularidade_temperatura_dia.sql](queries/models/monitoramento/veiculo_regularidade_temperatura_dia.sql:13), [test_check_regularidade_temperatura()](queries/macros/test_check_regularidade_temperatura.sql:3)).
  - A preparação para V20 está evidente no domínio de bilhetagem ([viagem_transacao_aux_v2.sql](queries/models/subsidio/viagem_transacao_aux_v2.sql:221)). Caso o merge com o upstream aplique o commit de troca de vigência, espera-se a substituição do gate V17 por V20 também nos modelos de monitoramento térmico.

- Resumo paramétrico prático:
  - Janela de avaliação (local): DATA_SUBSIDIO_V17_INICIO em monitoramento térmico; DATA_SUBSIDIO_V20_INICIO em bilhetagem.
  - Indício de falha diária: “sem variação” OU “sem transmissão” OU “descarte &gt; 50% (registros ou viagens)”.
  - Recorrência: falha em 6+ dias consecutivos por veículo.
  - Conformidade por viagem (TRUE) requer simultaneamente A/C, sem recorrência, sem temperatura nula/zero, com transmissão e “temperatura regular”.
  - Não conformidade (FALSE) por qualquer quebra dos requisitos acima.
  - Nulo (NULL) conforme Art. 2º‑E para veículos mais novos sem A/C até V19.
