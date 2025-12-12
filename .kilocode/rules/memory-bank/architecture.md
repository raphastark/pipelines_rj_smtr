# Arquitetura do Projeto

## Visão Geral

O projeto Pipelines RJSMTR é estruturado como um sistema de ETL (Extract, Transform, Load) para dados de transporte público do Rio de Janeiro. A arquitetura é baseada em pipelines de dados que extraem informações de diversas fontes, transformam esses dados e os carregam em um data warehouse para análise.

## Componentes Principais

### Pipelines de Captura (Extract)

- Módulos em Python para extração de dados de diferentes fontes
- Organização por fonte de dados (conecta, cittati, serpro, etc.)
- Cada módulo contém flows, tasks e utilitários específicos

### Transformação de Dados (Transform)

- Modelos dbt para transformação de dados
- Organização por domínios de negócio (veículos, financeiro, monitoramento, etc.)
- Macros reutilizáveis para operações comuns

### Armazenamento (Load)

- BigQuery como data warehouse principal
- Estrutura de tabelas organizada por domínios

## Fluxo de Dados

1. Extração de dados brutos de APIs e sistemas externos
2. Pré-processamento e limpeza de dados
3. Transformação usando modelos dbt
4. Carregamento em tabelas dimensionais e fatos
5. Disponibilização para análise e dashboards

## Orquestração

- Prefect para orquestração de pipelines
- Agendamento e monitoramento de execuções
- Tratamento de falhas e retentativas
