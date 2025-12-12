# Mudanças Recentes - Junho 2025

## Sincronização realizada em 03/07/2025

### 🏛️ Ajustes Apuração - Acordo Judicial (24/06/2025)

#### Commit: [`3a93eea9`](https://github.com/prefeitura-rio/pipelines_rj_smtr/commit/3a93eea96b383e8a693cc82eb5c9696eaf44312f)
**Autor**: Guilherme Botelho
**PR**: #624

#### Principais Mudanças:

##### Novos Modelos Criados:
- **`percentual_operacao_faixa_horaria.sql`** - Substitui `subsidio_faixa_servico_dia`
  - Implementa item 6.1.7 do acordo judicial
  - Artigo 7 IV e Artigo 5 do acordo
  - Materialização com serviços do anexo II do acordo judicial

- **`servico_contrato_abreviado.sql`** - Nova tabela de serviços contratuais
  - 153 linhas de código
  - Mapeia serviços conforme acordo judicial

##### Modelos Atualizados:
- **`viagem_transacao_aux.sql`** - Novos tipos de viagem relacionados à bilhetagem
  - Jinja para gerar colunas conforme `tipo_viagem`
  - Melhorias na lógica de transações

- **`viagens_remuneradas.sql`** - Ajustes no dashboard de subsídio
- **`sumario_faixa_servico_dia_pagamento.sql`** - Reorganização da lógica de pagamento

##### Snapshots:
- **`snapshot_percentual_operacao_faixa_horaria.sql`** - Novo snapshot para histórico
- Atualização do selector `snapshot_subsidio`

### 💰 Modelos para Painel de Custos GCP (30/06/2025)

#### Commit: [`2f0c1068`](https://github.com/prefeitura-rio/pipelines_rj_smtr/commit/2f0c10685b98dc7b91ab3c35f80476db60025fe5)
**Autor**: Rafael Carvalho Pinheiro
**PR**: #549

#### Novo Domínio: `infraestrutura`

##### Modelos Principais:
- **`custo_cloud.sql`** - Custos da Google Cloud Platform
  - Materialização incremental
  - Taxa de conversão para Real
  - Filtro por `data_inicial_custo_cloud`

- **`log_bigquery.sql`** - Logs de execução do BigQuery
  - 195 linhas de código
  - Rastreamento de execuções dbt
  - Coluna `id_execucao_dbt` para correlação

##### Modelos Auxiliares:
- **`aux_preco_bigquery.sql`** - Precificação do BigQuery
  - 98 linhas de código
  - Cálculos de custos por operação

##### Novo Pipeline:
- **`pipelines/treatment/infraestrutura/`** - Módulo completo
  - `flows.py` - Flow de materialização
  - `constants.py` - Constantes do domínio
  - Integração com `pipelines/flows.py`

##### Configurações:
- **Novo selector**: `infraestrutura`
- **Novas variáveis dbt**:
  - `data_inicial_logs_bigquery`
  - `data_inicial_custo_cloud`
- **Nova macro**: `query_comment.sql` - Comentários automáticos em queries

### 🚔 Alteração Pipeline Captura de Infrações (30/06/2025)

#### Commit: [`0eda3281`](https://github.com/prefeitura-rio/pipelines_rj_smtr/commit/0eda32812b5a6922521237056704c9615f2e387b)
**Autor**: Victor Miguel Rocha
**PR**: #637

#### Mudanças:
- **`staging_infracao.sql`** - Ajustes na view de staging
- **Pipelines atualizados**:
  - `migration/projeto_subsidio_sppo/flows.py`
  - `migration/veiculo/flows.py`
  - `treatment/monitoramento/flows.py`

### 📊 Resumo das Mudanças de Junho 2025

#### Arquivos Modificados: 40+
#### Linhas Adicionadas: ~1.200+
#### Novos Domínios: 1 (`infraestrutura`)
#### Novos Modelos: 5 principais + auxiliares
#### Novos Seletores: 1 (`infraestrutura`)

#### Impacto por Domínio:
- **Subsídio**: Implementação completa do acordo judicial
- **Infraestrutura**: Novo domínio para custos e monitoramento
- **Veículos**: Melhorias na captura de infrações
- **Financeiro**: Ajustes em staging e schemas

---

# Mudanças Anteriores - Maio 2025

## Sincronização realizada em 27/05/2025

### 🚌 Novos Modelos de GPS (Versão 1.3.7 - 20/05/2025)

#### Modelos Principais Criados:
- **`gps.sql`** - Modelo incremental principal para dados GPS
  - Materialização incremental com estratégia `insert_overwrite`
  - Particionado por data (granularidade diária)
  - Usa alias dinâmico baseado em variáveis: `modo_gps` e `fonte_gps`
  - Tag: `geolocalizacao`

- **`gps_15_minutos.sql`** - Agregação de dados GPS em intervalos de 15 minutos
  - Materialização como tabela
  - Particionado por data
  - Processa velocidades e paradas dos veículos

#### Modelos Auxiliares (staging):
- `staging_gps.sql` - Staging principal dos dados GPS
- `aux_gps_filtrada.sql` - Filtros aplicados aos dados GPS
- `aux_gps_parada.sql` - Identificação de paradas dos veículos
- `aux_gps_realocacao.sql` - Tratamento de realocações
- `aux_gps_trajeto_correto.sql` - Validação de trajetos
- `aux_gps_velocidade.sql` - Cálculos de velocidade
- `staging_garagens.sql` - Dados de garagens
- `staging_realocacao.sql` - Staging de realocações

### 🔧 Nova Macro Criada

#### `generate_date_hour_partition_filter.sql`
- **Função**: Gera filtros de partição otimizados por data e hora
- **Casos de uso**:
  - Mesmo dia: filtra por data e intervalo de horas
  - Dois dias consecutivos: filtra início e fim
  - Múltiplos dias: filtra intervalo completo
- **Benefício**: Otimização de queries incrementais com filtros temporais precisos

### 📊 Novos Seletores dbt

#### Selector `gps`
```yaml
- staging_gps
- aux_gps_filtrada, aux_gps_parada, aux_gps_realocacao
- aux_gps_trajeto_correto, aux_gps_velocidade
- staging_garagens, staging_realocacao
- gps
```

#### Selector `gps_15_minutos`
```yaml
- staging_gps
- aux_gps_filtrada, aux_gps_parada, aux_gps_realocacao
- aux_gps_trajeto_correto, aux_gps_velocidade
- staging_garagens, staging_realocacao
- gps_15_minutos
```

### 🔄 Atualizações nos Pipelines

#### Mudanças em pipelines:
- `pipelines/utils/extractors/gps.py`: Remoção de linha (limpeza de código)
- `pipelines/utils/utils.py`: Adição de 5 novas linhas de código

### 📈 Melhorias na Documentação

- `queries/models/docs.md`: 32 novas linhas de documentação
- `br_rj_riodejaneiro_brt_gps/schema.yml`: 59 linhas modificadas
- `monitoramento/schema.yml`: 60 novas linhas adicionadas
- `monitoramento/staging/schema.yml`: 82 novas linhas

### 🎯 Impacto e Benefícios

#### Performance:
- Modelos incrementais otimizados para dados GPS
- Particionamento por data para queries mais eficientes
- Filtros temporais precisos com a nova macro

#### Monitoramento:
- Agregações de 15 minutos para análises operacionais
- Melhor rastreamento de paradas e velocidades
- Validação aprimorada de trajetos

#### Flexibilidade:
- Aliases dinâmicos permitem múltiplas fontes GPS
- Seletores específicos para diferentes necessidades
- Modelos auxiliares modulares

### 📋 Resumo Quantitativo

| Categoria | Quantidade | Detalhes |
|-----------|------------|----------|
| **Novos Modelos** | 11 | GPS principal, 15min, e 9 auxiliares |
| **Novas Macros** | 1 | Filtro de partição otimizado |
| **Novos Seletores** | 2 | `gps` e `gps_15_minutos` |
| **Arquivos Modificados** | 25 | Incluindo schemas, docs e utils |
| **Linhas Adicionadas** | ~1000+ | Principalmente novos modelos e docs |

### 🔧 Problemas Resolvidos na Sincronização

#### Erro `git-error-1748337027934`:
- **Causa**: Arquivos `desktop.ini` corrompidos nas referências do Git
- **Solução**: Remoção de arquivos corrompidos em:
  - `.git/refs/remotes/origin/`
  - `.git/refs/remotes/upstream/`
  - `.git/objects/` (múltiplas pastas)

#### Comandos executados para sincronização:
```bash
git fetch upstream
git merge upstream/main
git pull origin main
git push origin main
```

## Estado Atual do Projeto (27/05/2025)

### 📊 Configurações dbt Atuais

#### Versões de Subsídio Ativas:
- **V15A** (mais recente): Início em 01/07/2025
- **V15**: Início em 01/04/2025  
- **V14**: Início em 05/01/2025
- **V13**: Início em 01/01/2025

#### Variáveis GPS Configuradas:
- `modo_gps`: "onibus"
- `fonte_gps`: "conecta"
- `15_minutos`: false
- `buffer_segmento_metros`: 20
- `velocidade_maxima`: 60 km/h

#### Domínios com Materialização Incremental:
- `monitoramento` - GPS e operações
- `financeiro` - Subsídios e pagamentos
- `planejamento` - Rotas e horários
- `subsidio` - Cálculos SPPO
- `transito` - Autuações

### 🔄 Seletores Principais Ativos:

1. **GPS**: `gps`, `gps_15_minutos`
2. **Subsídio**: `apuracao_subsidio_v9`, `monitoramento_subsidio`
3. **Operacionais**: `viagem_informada`, `planejamento_diario`
4. **Bilhetagem**: `transacao`, `integracao`
5. **Validação**: `validacao_dados_jae`

### 📅 Próximas Atualizações Esperadas

Com base no changelog e configurações atuais:
- Implementação completa da versão V15A do subsídio
- Melhorias nos modelos de monitoramento GPS
- Otimizações adicionais em performance
- Novos seletores para outros domínios de dados

### 🏗️ Arquitetura Atual

#### Pipelines Python:
- **Módulos**: capture, control, migration, serpro, treatment, utils
- **Orquestração**: Prefect com flows e tasks
- **Constantes**: Enum centralizado em `constants.py`

#### Modelos dbt:
- **Total de domínios**: 15+ domínios de negócio
- **Estratégia**: Incremental com `insert_overwrite`
- **Particionamento**: Por data para otimização
- **Snapshots**: Histórico de dados críticos

#### Infraestrutura:
- **Produção**: `rj-smtr-prod` (BigQuery)
- **Staging**: `rj-smtr-staging` (BigQuery)
- **Dashboards**: Looker Studio + Metabase