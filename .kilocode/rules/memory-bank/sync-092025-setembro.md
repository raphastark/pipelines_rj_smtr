# Sincronização Setembro 2025 - Documentação de Atualizações

**Data**: 08/09/2025
**Período coberto**: Setembro 2025
**Status**: ✅ Documentado

---

## 📋 Resumo das Mudanças

Esta sincronização com o upstream principal resultou em uma grande quantidade de alterações, totalizando 139 arquivos modificados, com 3.576 inserções e 1.893 deleções. As mudanças abrangem workflows, pipelines, modelos dbt, schemas, e scripts de configuração. Elas impactam principalmente os domínios de bilhetagem, monitoramento, subsídio, e infraestrutura, com novas funcionalidades para integração de dados da Jaé, melhorias em validações, e otimizações em pipelines. 

As alterações fortalecem a apuração de subsídios (ex.: novos modelos para bilhetagem e monitoramento de temperatura), melhoram a validação de viagens (ex.: novas regras para transações e GPS), e adicionam suporte a novas fontes como INMET. Não há impacto retroativo imediato em dados históricos, mas os novos modelos e workflows exigem monitoramento para consistência em dashboards e relatórios. O foco é em precisão para subsídios, com novas validações para transações e integrações, alinhando-se com evoluções anteriores (ex.: V15A).

### Principais Impactos:
- **Apuração de Subsídios**: Novos modelos em financeiro e bilhetagem para balanços e rateios, impactando cálculos de valor e remuneração.
- **Validação de Viagens**: Adições em monitoramento (ex.: temperatura INMET) e validação de dados Jaé, melhorando detecção de inconsistências.
- **Operacional**: Novos workflows para CD e checks dbt, otimizando deploys e testes.
- **Riscos**: Aumento de complexidade com novos módulos; monitorar integrações para evitar falhas em validações.

---

## 🔄 Mudanças Detalhadas da Sincronização Mais Recente (08/09/2025)

### 1. Alterações em Workflows e Configuração Geral
- **.github/workflows/**: Novos workflows para CD (cd-docs.yaml, cd-update-table-metadata.yaml) e dbt-checks.yaml, adicionando automação para documentação e testes dbt. Isso melhora a CI/CD para o projeto, impactando o deploy de modelos e garantindo consistência em validações.
- **.gitignore**: Adições para ignorar arquivos de configuração Kubernetes e outros, otimizando o repo.
- **.pre-commit-config.yaml**: Modificações para incluir hooks de qualidade de código, afetando o desenvolvimento local e commits.

### 2. Novos Módulos em Pipelines (Captura e Treatment)
- **pipelines/capture/inmet/**: Novo módulo para captura de dados meteorológicos do INMET, com flows.py, tasks.py, constants.py e CHANGELOG.md. Isso adiciona dados ambientais para monitoramento, impactando análises de temperatura em veículos (ex.: validação de ar-condicionado em viagem_classificada.sql).
- **pipelines/capture/jae/**: Mudanças em constants.py e flows.py para melhor suporte a bilhetagem Jaé, incluindo atualizações em CHANGELOG.md. Impacto: Melhora na validação de transações e integrações com Jaé, alinhando com documentacao_integracao_jae_20250808.md.
- **pipelines/migration/projeto_subsidio_sppo/**: Alterações significativas em constants.py (160 linhas) e flows.py (100 linhas), com atualizações em CHANGELOG.md. Isso refatora lógica de subsídio, afetando apuração de valores e validações em viagem_classificada.sql.
- **pipelines/treatment/bilhetagem/**: Mudanças em constants.py e flows.py, com novo CHANGELOG.md. Adiciona suporte para novos tipos de transações, impactando validação e classificação de viagens.
- **pipelines/treatment/financeiro/**: Novos modelos como bilhetagem_consorcio_dia.sql e bilhetagem_consorcio_operador_dia.sql, com mudanças em CHANGELOG.md e constants.py. Impacto direto na apuração financeira de subsídios.
- **pipelines/treatment/monitoramento/**: Atualizações em CHANGELOG.md e constants.py, adicionando suporte a temperatura INMET. Impacto: Integração com novos dados ambientais para validação de regularidade em veículos.
- **pipelines/treatment/validacao_dados_jae/flows.py**: Pequenas atualizações, alinhando com integrações Jaé.

### 3. Alterações em Models e Schemas (Queries)
- **queries/macros/test_transacao_valor_ordem_completa.sql**: Novo macro para testes de transações, melhorando validação de valores em bilhetagem.
- **queries/models/bilhetagem/**: Muitas mudanças, incluindo schema.yml (52 linhas), transacao.sql (65 linhas), e novos staging models. Adiciona suporte para transações com valor de ordem, impactando apuração de subsídios.
- **queries/models/bilhetagem_interno/**: Novos arquivos como transacao_gratuidade_estudante_municipal.sql, com schema.yml. Impacto: Validação específica para gratuidades, afetando classificação de passageiros.
- **queries/models/br_rj_riodejaneiro_bilhetagem/**: Deleções de arquivos obsoletos (ex.: gps_validador.sql, ordem_pagamento_consorcio_dia.sql) e atualizações em schema.yml (357 linhas reduzidas). Simplificação, mas perda de lógica antiga de GPS, migrada para monitoramento.
- **queries/models/br_rj_riodejaneiro_brt_gps/schema.yml**: Modificações para alinhar com novas validações.
- **queries/models/cadastro/**: Mudanças em schema.yml e staging_cliente.sql (69 linhas), com novo CHANGELOG.md. Melhora validação de clientes.
- **queries/models/cadastro_interno/**: Novos arquivos como cliente_jae.sql (163 linhas) e schema.yml (80 linhas). Impacto: Melhor suporte a dados de cadastro para Jaé.
- **queries/models/controle_financeiro/schema.yml**: Alterações para novos campos financeiros.
- **queries/models/dashboard_bilhetagem_jae/schema.yml**: Atualizações para dashboards de bilhetagem.
- **queries/models/dashboard_subsidio_sppo/schema.yml**: Modificações em 44 linhas, impactando dashboards de subsídio.
- **queries/models/financeiro/**: Novos modelos como bilhetagem_consorcio_dia.sql (46 linhas) e bilhetagem_consorcio_operador_dia.sql (225 linhas), com schema.yaml (249 linhas). Impacto alto na apuração de subsídios financeiros.
- **queries/models/gtfs/schema.yml**: Pequenas atualizações.
- **queries/models/monitoramento/**: Novos arquivos como gps_validador.sql (160 linhas) e temperatura_inmet.sql (61 linhas), com schema.yml (189 linhas). Adiciona suporte a GPS e temperatura, impactando validação de veículos.
- **queries/models/subsidio/**: Mudanças em schema.yml e staging/aux_viagem_temperatura.sql (275 linhas). Reforça classificação de viagens com temperatura.
- **queries/models/transito/schema.yml**: Alterações em 36 linhas.
- **queries/models/validacao_dados_jae/**: Mudanças em schema.yml e novos staging models para validação de ordens (ex.: ordem_pagamento_consorcio_dia_invalida.sql, 124 linhas).
- **queries/models/veiculo/schema.yml**: Atualizações em 17 linhas.
- **queries/profiles.yml**: Modificações em 6 linhas.
- **queries/selectors.yml**: Adições em 68 linhas, afetando seletores dbt.
- **queries/setup_dbt_profiles.sh**: Novo script de 34 linhas para setup de perfis dbt.

### 4. Novos Snapshots e Scripts
- **queries/snapshots/**: Novos snapshots para monitoramento (temperatura_inmet.sql, veiculo_regularidade_temperatura_dia.sql, viagem_regularidade_temperatura.sql, 21 linhas cada) e transito/schema.yml.
- **queries/update_table_metadata.py**: Novo script de 91 linhas para atualizar metadados de tabelas.

### 5. Outras Alterações
- **.kubernetes/**: Deleções de arquivos relacionados a Kubernetes para docs.
- **queries/CHANGELOG.md**: Atualizações em 18 linhas.
- **pipelines/constants.py** e **pipelines/flows.py**: Pequenas mudanças.

### Implicações Técnicas e de Negócio
- **Apuração de Subsídios**: Novos modelos em financeiro e bilhetagem melhoram precisão em balanços e rateios, mas aumentam complexidade; monitorar impacto em dashboards.
- **Validação de Viagens**: Adições em monitoramento e validação Jaé aprimoram detecção de inconsistências, com novos snapshots para rastreabilidade. Risco: Dependências novas podem causar falhas se não testadas.
- **Operacional**: Workflows de CD e checks dbt automatizam deploys, mas requerem configuração de perfis (setup_dbt_profiles.sh).
- **Riscos**: Alterações em schema.yml (ex.: br_rj_riodejaneiro_bilhetagem/schema.yml, 357 linhas) podem quebrar queries dependentes; validar integrações Jaé para evitar inconsistências em validação de viagens.

## Regularidade Térmica (A/C) — Regras, Vigências e Impactos (Set/2025)

Resumo técnico baseado no código atual do repositório local, com referências clicáveis para os pontos exatos.

- O que entrou nesta sincronização:
  - Integração de dados meteorológicos do INMET (captura e modelos de monitoramento).
  - Novo modelo de regularidade diária por veículo: [veiculo_regularidade_temperatura_dia.sql](queries/models/monitoramento/veiculo_regularidade_temperatura_dia.sql:1).
  - Testes/macro de conformidade por viagem: [test_check_regularidade_temperatura.sql](queries/macros/test_check_regularidade_temperatura.sql:1).
  - Preparação bilhetagem V20 (priorização e novos tipos): [viagem_transacao_aux_v2.sql](queries/models/subsidio/viagem_transacao_aux_v2.sql:221).

Regras de detecção diária de falha (staging):
- Janela incremental (gate): [aux_veiculo_falha_ar_condicionado.sql](queries/models/monitoramento/staging/aux_veiculo_falha_ar_condicionado.sql:13) usa DATA_SUBSIDIO_V17_INICIO.
- Critério de indício de falha (qualquer um verdadeiro): [aux_veiculo_falha_ar_condicionado.sql](queries/models/monitoramento/staging/aux_veiculo_falha_ar_condicionado.sql:18)
  - not indicador_temperatura_variacao_veiculo
  - or not indicador_temperatura_transmitida_veiculo
  - or indicador_temperatura_descartada_veiculo (&gt; 50% dos registros) [aux_veiculo_falha_ar_condicionado.sql](queries/models/monitoramento/staging/aux_veiculo_falha_ar_condicionado.sql:129)
  - or indicador_viagem_temperatura_descartada_veiculo (&gt; 50% por viagem) [aux_veiculo_falha_ar_condicionado.sql](queries/models/monitoramento/staging/aux_veiculo_falha_ar_condicionado.sql:131)
- Marcação do indício diário: [aux_veiculo_falha_ar_condicionado.sql](queries/models/monitoramento/staging/aux_veiculo_falha_ar_condicionado.sql:171)
- Sequência e carry-over entre janelas: [aux_veiculo_falha_ar_condicionado.sql](queries/models/monitoramento/staging/aux_veiculo_falha_ar_condicionado.sql:189), [aux_veiculo_falha_ar_condicionado.sql](queries/models/monitoramento/staging/aux_veiculo_falha_ar_condicionado.sql:200), [aux_veiculo_falha_ar_condicionado.sql](queries/models/monitoramento/staging/aux_veiculo_falha_ar_condicionado.sql:224)

Recorrência (padrão operacional de falha):
- Um veículo é recorrente quando quantidade_dia_falha_operacional &gt;= 6: [veiculo_regularidade_temperatura_dia.sql](queries/models/monitoramento/veiculo_regularidade_temperatura_dia.sql:39)
- Motivos de explicabilidade (mensagens): [veiculo_regularidade_temperatura_dia.sql](queries/models/monitoramento/veiculo_regularidade_temperatura_dia.sql:48)

Conformidade por viagem (macro de teste — verdade de referência):
- Janela incremental da verificação: [test_check_regularidade_temperatura.sql](queries/macros/test_check_regularidade_temperatura.sql:3) (DATA_SUBSIDIO_V17_INICIO).
- Deve ser TRUE quando todos forem verdadeiros: A/C, não recorrente, não nula/zero, transmitida, regular [test_check_regularidade_temperatura.sql](queries/macros/test_check_regularidade_temperatura.sql:87)
- Deve ser FALSE quando qualquer falhar: recorrência, nula/zero, sem transmissão, não regular [test_check_regularidade_temperatura.sql](queries/macros/test_check_regularidade_temperatura.sql:111)
- Deve ser NULL (indeterminado) para Art. 2º‑E: ano_fabricacao &gt; 2019, data &lt;= V19, sem A/C [test_check_regularidade_temperatura.sql](queries/macros/test_check_regularidade_temperatura.sql:136)

Vigências e reconciliação V17 vs V20:
- Repositório local (térmico): gate em V17 em [aux_veiculo_falha_ar_condicionado.sql](queries/models/monitoramento/staging/aux_veiculo_falha_ar_condicionado.sql:13) e [veiculo_regularidade_temperatura_dia.sql](queries/models/monitoramento/veiculo_regularidade_temperatura_dia.sql:13).
- Preparação V20 (bilhetagem/validador): a partir de DATA_SUBSIDIO_V20_INICIO, prioriza “Sem transação”, “Validador fechado”, “Validador associado incorretamente” [viagem_transacao_aux_v2.sql](queries/models/subsidio/viagem_transacao_aux_v2.sql:221), [viagem_transacao_aux_v2.sql](queries/models/subsidio/viagem_transacao_aux_v2.sql:227).
- Em upstream (agosto): viagem_regularidade considera indicador_falha_recorrente após V20 [viagem_regularidade_temperatura.sql](queries/models/subsidio/viagem_regularidade_temperatura.sql:20).

Impacto na apuração e classificação:
- POF: viagens excluídas por status regulatório (V15+) reduzem km que conta no POF [percentual_operacao_faixa_horaria.sql](queries/models/subsidio/percentual_operacao_faixa_horaria.sql:1).
- Classificação: a presença de falha recorrente (quando ativada em V20) pode suportar classificações como “ar inoperante”/“não autorizado”, alinhando com regras já vigentes em [viagem_classificada.sql](queries/models/subsidio/viagem_classificada.sql:1).
- Auditoria: snapshots foram adicionados para rastreabilidade (temperatura/veículo/viagem).

Riscos e recomendações:
- Risco de divergência de vigência (V17 vs V20) entre domínios; alinhar gates antes de ativar a regra.
- Calibrar thresholds de descarte (&gt;50%) e janela de recorrência (&gt;=6 dias) com séries históricas.
- Monitorar efeitos em remuneração por serviço e por sentido (POF V2 por sentido já ativo).

Checklist operacional sugerido:
- Rodar testes dbt para a janela atual: [test_check_regularidade_temperatura.sql](queries/macros/test_check_regularidade_temperatura.sql:3) e [test_check_viagem_completa.sql](queries/macros/test_check_viagem_completa.sql:1).
- Validar particionamento e insert_overwrite dos modelos térmicos em execuções recentes.
- Se/Quando ativar V20, garantir que [aux_veiculo_falha_ar_condicionado.sql](queries/models/monitoramento/staging/aux_veiculo_falha_ar_condicionado.sql:13) e [veiculo_regularidade_temperatura_dia.sql](queries/models/monitoramento/veiculo_regularidade_temperatura_dia.sql:13) também migrem para DATA_SUBSIDIO_V20_INICIO.
---

## 📝 Notas sobre Versionamento

As mudanças desta sincronização constroem sobre as de agosto 2025, com foco em integrações meteorológicas e financeiras. Versões de subsídio permanecem ativas (V15A), com novas validações para temperatura e gratuidades. Próximas versões (V15B, V15C) serão impactadas por esses modelos.

### Versões de Subsídio Ativas
- **V15A**: Ativo desde 01/07/2025 (Penalidade por tecnologia mínima)
- **V15**: Ativo desde 01/04/2025 (Acordo Judicial)
- **V14**: Ativo desde 05/01/2025
- **V13**: Ativo desde 01/01/2025

### Próximas Versões Planejadas
- **V15B**: Planejado para 01/09/2025 (Validadores Jaé)
- **V15C**: Planejado para 01/12/2025 (Ar-condicionado obrigatório)

---

## 🎯 Diretrizes para Atualizações Futuras

Este documento deve ser atualizado sempre que novas sincronizações ocorrerem. Priorizar análise de impactos em subsídios e validação, com testes de regressão para novos modelos.

---

## 📚 Referências Cruzadas

- Estrutura do projeto: [`project-structure.md`](project-structure.md)
- Arquitetura geral: [`architecture.md`](architecture.md)
- Convenções de código: [`coding-conventions.md`](coding-conventions.md)
- Pontos de integração: [`integration-points.md`](integration-points.md)
- Preocupações de transparência: [`transparency-concerns.md`](transparency-concerns.md)

---

**Documento mantido por**: Kilo Code
**Última atualização**: 08/09/2025 08:32 AM (UTC-3)
**Versão**: 1.0


# Sincronização Setembro 2025 - Atualização Complementar

**Data**: 28/09/2025
**Período coberto**: Setembro 2025
**Status**: ✅ Documentado

---

## 📋 Resumo das Mudanças (Sincronização 2)

Esta sincronização com o upstream principal (24 commits) complementa a anterior, focando em refinamentos de regras de negócio, expansão de dados de bilhetagem e melhorias operacionais.

### Principais Impactos:

1.  **Expansão de Dados de Bilhetagem e Cadastro**:
    *   Novos modelos para clientes CPF Jaé (`cliente_jae.sql`) e validação de gratuidades estudantis.
    *   Melhoria na rastreabilidade de transações e ordens de pagamento.

2.  **Reforço na Validação de Viagens**:
    *   Atualizações em modelos de subsídio e bilhetagem para suportar a regra V20 (\"Validador associado incorretamente\").
    *   Novas macros de teste para validação de valores de transação e teto de pagamento.

3.  **Monitoramento e Infraestrutura**:
    *   Novos snapshots para monitoramento de temperatura INMET e fiscalização de lacre de veículos.
    *   Atualizações em workflows de CI/CD para automação de documentação e checks dbt.

---

## 🔄 Mudanças Detalhadas

### 1. Domínio Bilhetagem e Cadastro

-   **`queries/models/cadastro_interno/cliente_jae.sql`**: Novo modelo para cadastro de clientes Jaé (CPF).
-   **`queries/models/bilhetagem_interno/transacao_gratuidade_estudante_municipal.sql`**: Validação específica para gratuidades.
-   **`queries/models/bilhetagem/transacao_valor_ordem.sql`**: Suporte a transações com valor de ordem.

### 2. Domínio Subsídio e Validação

-   **Regra V20 (Validador Incorreto)**: Preparação para a regra que penaliza divergências entre o serviço do validador e o serviço planejado/GPS.
-   **Macros de Teste**: Adição de testes para garantir a integridade dos dados financeiros e de subsídio (`test_transacao_valor_ordem_completa.sql`, `test_teto_pagamento_valor_subsidio_pago.sql`).

### 3. Domínio Monitoramento e Snapshots de Fiscalização

-   **Snapshots de Fiscalização**: Adição de snapshots para rastreabilidade de dados críticos:
    *   `snapshot_veiculo_fiscalizacao_lacre.sql`

#### Detalhes dos Snapshots de Regularidade Térmica:

-   **`queries/snapshots/monitoramento/snapshot_temperatura_inmet.sql`**:
    *   **Função**: Cria um histórico imutável dos dados de temperatura externa do INMET.
    *   **Chave Única**: `concat(data, '-', hora, '-', id_estacao)`.
    *   **Estratégia**: `timestamp` (baseada em `timestamp_ultima_atualizacao`).
    *   **Importância**: Essencial para auditar a fonte de dados externa usada na fiscalização de ar-condicionado.

-   **`queries/snapshots/subsidio/snapshot_viagem_regularidade_temperatura.sql`**:
    *   **Função**: Cria um histórico imutável da conformidade térmica por viagem.
    *   **Chave Única**: `id_viagem`.
    *   **Estratégia**: `timestamp` (baseada em `timestamp_ultima_atualizacao`).
    *   **Importância**: Fundamental para a rastreabilidade e auditoria das classificações de viagens baseadas na conformidade térmica (A/C), que impactam diretamente o subsídio (Regra V20/V19+).

### 4. Operacional e CI/CD

-   **Workflows**: Novos workflows em `.github/workflows/` para CD e checks dbt.
-   **Scripts**: Adição de `queries/setup_dbt_profiles.sh` e `queries/update_table_metadata.py`.

---

## ⚠️ Alertas e Recomendações

-   **Vigência V20**: A regra V20 está preparada, mas a data de ativação (`DATA_SUBSIDIO_V20_INICIO`) deve ser monitorada.
-   **Complexidade**: A introdução de novos modelos de bilhetagem e fiscalização aumenta a complexidade do pipeline.

---

**Documento mantido por**: Kilo Code
**Última atualização**: 28/09/2025 21:25 PM (UTC-3)
**Versão**: 2.0 - Complementar