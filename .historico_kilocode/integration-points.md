# Pontos de Integração

## Fontes de Dados Externas

### Conecta

- API REST para dados de GPS de ônibus
- Autenticação via token JWT
- Endpoints principais:
  - `/api/v1/positions` - Posições em tempo real
  - `/api/v1/vehicles` - Cadastro de veículos

### Cittati

- API SOAP para dados de bilhetagem
- Autenticação via certificado digital
- Serviços principais:
  - `GetTransactions` - Transações de bilhetagem
  - `GetVehicleStatus` - Status operacional dos veículos

### SERPRO

- API REST para dados de infrações e licenciamento
- Autenticação OAuth 2.0
- Rate limiting: 100 requisições/minuto
- Endpoints principais:
  - `/api/v3/vehicles/{plate}` - Dados de veículos
  - `/api/v3/infractions` - Dados de infrações

## Destinos de Dados

### BigQuery

- Projeto: `rj-smtr-prod`
- Datasets organizados por domínio:
  - `br_rj_riodejaneiro_veiculos` - Dados de veículos
  - `br_rj_riodejaneiro_rdo` - Relatórios diários de operação
  - `financeiro` - Dados financeiros e de subsídio

### Dashboards

- Looker Studio para visualizações executivas
- Metabase para análises operacionais
- Atualização: diária (1:00 AM, UTC-3)

## Sistemas Internos

### Sistema de Monitoramento

- Prometheus para métricas de pipeline
- Alertmanager para notificações
- Grafana para visualização de métricas

### Sistema de Logs

- Elasticsearch para armazenamento de logs
- Kibana para visualização e busca
- Retenção: 30 dias para logs detalhados, 1 ano para logs agregados
