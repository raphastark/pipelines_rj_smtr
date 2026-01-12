# Estrutura do Projeto - Atualizada em 27/05/2025

## Visão Geral do Projeto

**Nome**: Pipelines RJSMTR  
**Versão**: 1.0.0  
**Objetivo**: Sistema de pipelines de dados para a Secretaria Municipal de Transportes do Rio de Janeiro

## Estrutura de Diretórios

### `/pipelines/` - Código Python para ETL
- **Módulos principais**:
  - `capture/` - Captura de dados de fontes externas
  - `control/` - Controle e orquestração
  - `migration/` - Migração de dados
  - `serpro/` - Integração com SERPRO
  - `treatment/` - Tratamento e transformação
  - `utils/` - Utilitários e funções auxiliares

- **Arquivos base**:
  - `constants.py` - Constantes e enumerações do projeto
  - `flows.py` - Definição de fluxos Prefect
  - `tasks.py` - Tarefas individuais do Prefect
  - `schedules.py` - Agendamentos e cronogramas

### `/queries/` - Modelos dbt para Transformação

#### Domínios de Negócio:
- **`monitoramento/`** - Dados de GPS e monitoramento operacional
- **`financeiro/`** - Dados financeiros e de subsídio
- **`planejamento/`** - Planejamento de serviços e rotas
- **`veiculo/`** - Dados de veículos e licenciamento
- **`transito/`** - Autuações e infrações de trânsito
- **`gtfs/`** - Dados GTFS (General Transit Feed Specification)
- **`subsidio/`** - Cálculos de subsídio SPPO
- **`validacao_dados_jae/`** - Validação de dados da Jaé

#### Configurações:
- `dbt_project.yml` - Configuração principal do dbt
- `selectors.yml` - Seletores para execução de grupos de modelos
- `profiles.yml` - Perfis de conexão com BigQuery

## Tecnologias Principais

### Backend/ETL
- **Python** - Linguagem principal para pipelines
- **Prefect** - Orquestração de workflows
- **BigQuery** - Data warehouse principal

### Transformação de Dados
- **dbt** - Transformação de dados SQL
- **SQL** - Queries e modelos de dados

### Infraestrutura
- **Google Cloud Platform** - Plataforma de nuvem
- **BigQuery** - Armazenamento e processamento

## Configurações de Materialização

### Estratégias por Domínio:
- **Incremental**: `financeiro`, `subsidio`, `monitoramento`, `planejamento`
- **View**: Maioria dos modelos staging e auxiliares
- **Table**: Modelos de agregação e snapshots

### Particionamento:
- Particionamento por data para modelos GPS
- Estratégia `insert_overwrite` para atualizações incrementais

## Variáveis de Configuração Importantes

### GPS e Monitoramento:
- `modo_gps`: "onibus" (padrão)
- `fonte_gps`: "conecta" (padrão)
- `15_minutos`: false (agregação de 15 minutos)

### Subsídio SPPO:
- Múltiplas versões com datas de início específicas (V1 a V15A)
- `DATA_SUBSIDIO_V15A_INICIO`: "2025-07-01" (mais recente)

### Ambientes:
- **Produção**: `rj-smtr-prod`
- **Staging**: `rj-smtr-staging`

## Seletores dbt Principais

### GPS:
- `gps` - Processamento principal de dados GPS
- `gps_15_minutos` - Agregação em intervalos de 15 minutos

### Subsídio:
- `apuracao_subsidio_v9` - Apuração com faixa horária
- `monitoramento_subsidio` - Dashboards do subsídio

### Operacionais:
- `viagem_informada` - Viagens informadas
- `planejamento_diario` - Planejamento diário
- `transacao` - Transações de bilhetagem

## Integração com Fontes Externas

### APIs Principais:
- **Conecta** - GPS de ônibus (JWT)
- **Cittati** - Bilhetagem (SOAP)
- **SERPRO** - Infrações e licenciamento (OAuth 2.0)

### Destinos:
- **BigQuery** - Data warehouse principal
- **Looker Studio** - Dashboards executivos
- **Metabase** - Análises operacionais