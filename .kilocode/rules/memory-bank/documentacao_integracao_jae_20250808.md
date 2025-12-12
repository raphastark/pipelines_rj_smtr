# Documentação da Integração com a Bilhetagem Jaé - 08/08/2025

## Visão Geral

A integração com o sistema de bilhetagem da Jaé é um componente crucial dos pipelines de dados do RJSMTR, fornecendo informações detalhadas sobre transações, rastreamento de validadores (GPS), lançamentos financeiros, ressarcimentos e gratuidades. Esses dados são essenciais para a classificação de viagens, apuração de subsídios e monitoramento operacional.

## Componentes Principais da Integração

A integração da Jaé envolve módulos de captura em Python (Prefect) e modelos de transformação de dados (dbt) em SQL.

### 1. Pipelines de Captura (`pipelines/capture/jae/`)

Os flows de captura da Jaé são definidos em [`pipelines/capture/jae/flows.py`](pipelines/capture/jae/flows.py:1) e utilizam configurações e constantes de [`pipelines/capture/jae/constants.py`](pipelines/capture/jae/constants.py:1).

#### Fontes de Dados e Frequência de Captura:

A Jaé possui múltiplos bancos de dados (MySQL/PostgreSQL) que são acessados para extração de dados. As capturas são realizadas em diferentes frequências para garantir a granularidade e a atualização necessárias:

-   **Minuto a Minuto**:
    *   `transacao`: Dados de transações de bilhetagem.
    *   `transacao_riocard`: Transações específicas do RioCard.
    *   `gps_validador`: Dados de GPS dos validadores.
    *   `lancamento`: Lançamentos financeiros.
-   **A Cada 10 Minutos**:
    *   `transacao_retificada`: Retificações de transações.
-   **Horárias**:
    *   `auxiliares`: Tabelas auxiliares como `linha`, `produto`, `operadora_transporte`, `cliente`, `pessoa_fisica`, `gratuidade`, `consorcio`, `percentual_rateio_integracao`, `linha_tarifa`, `linha_consorcio`, `linha_consorcio_operadora_transporte`, `endereco`, `ordem_ressarcimento`, `ordem_pagamento`.
-   **Diárias**:
    *   `integracao`: Dados de integração de transações.
    *   `ordem_pagamento`: Ordens de pagamento.
    *   `transacao_ordem`: Transações associadas a ordens.

#### Fluxos de Controle e Monitoramento:

-   **`jae: verifica ip do banco de dados`**: Um flow agendado a cada hora que testa as conexões com os diversos bancos de dados da Jaé. Em caso de falha, envia alertas via Discord.
-   **`jae: backup dados BillingPay`**: Realiza backups de dados do BillingPay, com agendamento diário, para garantir a persistência e auditoria dos dados brutos.
-   **`jae: backup historico BillingPay`**: Realiza backups históricos de dados do BillingPay.
-   **`jae: verificacao captura`**: Um flow agendado diariamente que verifica lacunas nas capturas de dados da Jaé e envia alertas via Discord se houver inconsistências.

### 2. Modelos de Transformação (dbt)

Os modelos dbt na camada de `queries/models/` processam os dados brutos da Jaé, transformando-os e validando-os para uso em análises e cálculos de subsídio.

#### Modelos de Validação (`queries/models/validacao_dados_jae/`):

-   [`integracao_invalida.sql`](queries/models/validacao_dados_jae/integracao_invalida.sql:1): Identifica integrações que estão fora da matriz de integração, com tempo de integração inválido ou rateio incorreto.
-   [`transacao_invalida.sql`](queries/models/validacao_dados_jae/transacao_invalida.sql:1): Sinaliza transações com geolocalização zerada, fora do município do Rio de Janeiro, fora do stop (para BRT) ou com serviço fora do GTFS/vigência.
-   `ordem_pagamento_invalida.sql`: (Não lido, mas presumivelmente valida ordens de pagamento).
-   `transacao_invalida.sql`: (Já lido, foca em geolocalização e serviço).

#### Modelos de Bilhetagem (`queries/models/bilhetagem/` e `queries/models/br_rj_riodejaneiro_bilhetagem/`):

-   [`transacao.sql`](queries/models/bilhetagem/transacao.sql:1): Modelo central de transações, que integra dados de diversas fontes da Jaé e RioCard, aplicando lógicas de retificação e associação com ordens de pagamento. Ele classifica as transações em diferentes tipos (`tipo_transacao_atualizado`, `tipo_transacao`, `produto`, `tipo_usuario`, `subtipo_usuario`, `meio_pagamento`) e calcula o `valor_pagamento`.
-   [`gps_validador.sql`](queries/models/br_rj_riodejaneiro_bilhetagem/gps_validador.sql:1): Processa os dados de GPS dos validadores, fornecendo informações de geolocalização para cada transação.
-   Outros modelos como `integracao.sql`, `passageiro_hora.sql`, `ordem_pagamento_dia.sql` etc., que agregam e sumarizam os dados de bilhetagem para diferentes finalidades.

## Impacto na Apuração dos Subsídios e Validação de Viagens

A integração dos dados da bilhetagem da Jaé é fundamental para a apuração dos subsídios e o processo de validação das viagens, pois:

1.  **Aumenta a Cobertura e Granularidade**: Permite uma visão mais completa e detalhada das transações de bilhetagem e do rastreamento (GPS dos validadores), o que é essencial para classificar corretamente as viagens.
2.  **Classificação de Viagens**: Os dados de bilhetagem são usados para identificar tipos de viagem (e.g., "Integração", "Integral", "Transferência", "Gratuidade", "Pagante"), validar a ocorrência de transações e associar passageiros às viagens. Isso influencia diretamente a elegibilidade para remuneração e o valor do subsídio. Por exemplo, uma viagem pode ser considerada "não remunerada" se não houver uma transação válida associada ou se a transação for inválida.
3.  **Monitoramento e Verificação**: A frequência diferenciada de captura (minuto a minuto, a cada 10 minutos, horária, diária) permite verificações e monitoramento mais precisos, como checagem de IP e alertas, que contribuem para a integridade dos dados de validação.
4.  **Contexto Operacional**: A integração expõe problemas operacionais da Jaé, como atualizações irresponsáveis e bugs nos validadores, que podem levar a "viagens sem transação" ou "validador associado incorretamente". Essas falhas técnicas podem resultar em viagens não remuneradas, especialmente quando agravadas por regras como a penalidade V15A. A visibilidade desses dados permite identificar e, idealmente, mitigar esses problemas.

## Riscos e Preocupações

Conforme documentado em [`transparency-concerns.md`](.kilocode/rules/memory-bank/transparency-concerns.md:1), existem preocupações operacionais com a Jaé, como atualizações "Over the Air" irresponsáveis e falta de processo de teste, que podem levar a incidentes (validadores travando, linhas sumindo) e, consequentemente, a "viagens não remuneradas" injustas, agravadas pela regra V15A.

## Diagrama de Fluxo de Dados (Simplificado)

```mermaid
graph TD
    subgraph Fontes de Dados Jaé
        DB_Transacao[DB Transação (PostgreSQL)]
        DB_Tracking[DB Tracking (PostgreSQL)]
        DB_Financeiro[DB Financeiro (PostgreSQL)]
        DB_Principal[DB Principal (MySQL)]
        DB_Ressarcimento[DB Ressarcimento (PostgreSQL)]
        DB_Gratuidade[DB Gratuidade (PostgreSQL)]
    end

    subgraph Pipelines de Captura (Python/Prefect)
        Flow_Transacao(Captura Transação)
        Flow_GPSTracking(Captura GPS Validador)
        Flow_Lancamento(Captura Lançamento)
        Flow_Auxiliares(Captura Auxiliares)
        Flow_Integracao(Captura Integração)
        Flow_OrdemPagamento(Captura Ordem Pagamento)
        Flow_VerificaIP(Verifica IP DB)
        Flow_BackupBillingPay(Backup BillingPay)
    end

    subgraph Transformação (dbt/SQL)
        Model_Transacao[Modelo dbt: transacao]
        Model_GPSValidador[Modelo dbt: gps_validador]
        Model_IntegracaoInvalida[Modelo dbt: integracao_invalida]
        Model_TransacaoInvalida[Modelo dbt: transacao_invalida]
        Model_ViagemClassificada[Modelo dbt: viagem_classificada]
    end

    subgraph Data Warehouse (BigQuery)
        Table_Transacao[Tabela: br_rj_riodejaneiro_bilhetagem.transacao]
        Table_GPSValidador[Tabela: br_rj_riodejaneiro_bilhetagem.gps_validador]
        Table_IntegracaoInvalida[Tabela: validacao_dados_jae.integracao_invalida]
        Table_TransacaoInvalida[Tabela: validacao_dados_jae.transacao_invalida]
        Table_ViagemClassificada[Tabela: subsidio.viagem_classificada]
    end

    DB_Transacao --> Flow_Transacao
    DB_Transacao --> Flow_Transacao_Retificada
    DB_Transacao --> Flow_Transacao_RioCard
    DB_Tracking --> Flow_GPSTracking
    DB_Financeiro --> Flow_Lancamento
    DB_Principal --> Flow_Auxiliares
    DB_Ressarcimento --> Flow_Integracao
    DB_Ressarcimento --> Flow_OrdemPagamento
    DB_Transacao --> Flow_OrdemPagamento
    DB_Gratuidade --> Flow_Auxiliares

    Flow_Transacao --> Model_Transacao
    Flow_Transacao_Retificada --> Model_Transacao
    Flow_Transacao_RioCard --> Model_Transacao
    Flow_GPSTracking --> Model_GPSValidador
    Flow_Lancamento --> Model_Transacao
    Flow_Auxiliares --> Model_Transacao
    Flow_Integracao --> Model_Transacao
    Flow_OrdemPagamento --> Model_Transacao
    Flow_Transacao_Ord --> Model_Transacao

    Model_Transacao --> Table_Transacao
    Model_GPSValidador --> Table_GPSValidador
    Model_IntegracaoInvalida --> Table_IntegracaoInvalida
    Model_TransacaoInvalida --> Table_TransacaoInvalida

    Table_Transacao --> Model_IntegracaoInvalida
    Table_Transacao --> Model_TransacaoInvalida
    Table_Transacao --> Model_ViagemClassificada
    Table_GPSValidador --> Model_ViagemClassificada

    Model_IntegracaoInvalida --> Table_IntegracaoInvalida
    Model_TransacaoInvalida --> Table_TransacaoInvalida
    Model_ViagemClassificada --> Table_ViagemClassificada