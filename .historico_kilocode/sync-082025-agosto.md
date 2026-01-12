# Sincronização Agosto 2025 - Documentação Consolidada

**Data**: 19/08/2025
**Período coberto**: Agosto 2025
**Status**: ✅ Documentado e Organizado

---

## 📋 Introdução

Este documento consolida todas as mudanças identificadas em agosto de 2025, organizando de forma clara as sincronizações realizadas durante o mês. As mudanças documentadas nos meses anteriores permanecem válidas e podem ser consultadas nos seguintes documentos:

- Documentação consolidada de junho-julho: [`documentacao-mudancas-julho-2025.md`](documentacao-mudancas-julho-2025.md)
- Análise técnica detalhada do modelo de POF: [`modelo-percentual_operacao_faixa_horaria.md`](modelo-percentual-operacao-faixa-horaria.md)
- Sincronização completa de julho: [`sync-july-2025.md`](sync-july-2025.md)

---

## 🔄 Resumo das Sincronizações de Agosto 2025

### Sincronização 1 - Início de Agosto (08/08/2025)
- **Foco**: Apuração por sentido no POF e correções em modelos GTFS
- **Impacto**: 🔴 **ALTO - Mudanças fundamentais na apuração**
- **Detalhes**: Documentado em [`sincronizacao2_agosto_2025.md`](sincronizacao2_agosto_2025.md)

### Sincronização 2 - Meio de Agosto (19/08/2025)
- **Foco**: Regras de fiscalização de ar-condicionado (V20)
- **Impacto**: 🟡 **MÉDIO - Ajustes de fiscalização**
- **Commit**: `4044fd38` - "Altera data para inclusão da regra de padrão de falha do ar condicionado"

---

## 🚨 Mudanças Críticas Identificadas

### 1. Apuração do POF por Sentido (Início de Agosto)
- **O quê**: Introdução do **sentido** da viagem (ida/volta/circular) no cálculo do POF
- **Impacto**: Remuneração mais granular e precisa, condicionada à operação em cada sentido planejado
- **Modelos afetados**: [`percentual_operacao_faixa_horaria.sql`](queries/models/subsidio/percentual_operacao_faixa_horaria.sql)

### 2. Nova Regra V20: "Validador Associado Incorretamente"
- **O quê**: Nova variável `DATA_SUBSIDIO_V20_INICIO` para controlar classificação de viagens com divergência entre validador e GPS
- **Status**: Preparada mas **desativada** (data definida como `3000-01-01`)
- **Impacto futuro**: Viagens não remuneradas quando houver inconsistência entre serviço do validador e planejamento

### 3. Fiscalização de Ar-Condicionado V20 (Meio de Agosto)
- **O quê**: Alteração da data de referência de `DATA_SUBSIDIO_V17_INICIO` para `DATA_SUBSIDIO_V20_INICIO`
- **Modelos afetados**:
  - [`aux_veiculo_falha_ar_condicionado.sql`](queries/models/monitoramento/staging/aux_veiculo_falha_ar_condicionado.sql:15)
  - [`veiculo_regularidade_temperatura_dia.sql`](queries/models/monitoramento/veiculo_regularidade_temperatura_dia.sql:15)
  - [`viagem_regularidade_temperatura.sql`](queries/models/subsidio/viagem_regularidade_temperatura.sql:20-21)
- **Nova lógica**: Considera `indicador_falha_recorrente` para classificação de ar inoperante

---

## 🔧 Correções e Melhorias Técnicas

### Modelos de Planejamento (GTFS)
- **Correção de duplicação** em `ordem_servico_trips_shapes`
- **Lógica de trajetos alternativos** aprimorada com `indicador_duplo_sentido`
- **Otimização de performance** com remoção de condições incrementais desnecessárias

### Organização de Código
- **Refatoração de modelos de dashboard** movidos para `staging/`
- **Uso de COALESCE** para versão de shapes como fallback
- **Reagendamento de pipelines** para otimizar execução

---

## 📊 Versionamento de Subsídio Atualizado

### Versões Ativas
- **V15A**: Ativo desde 01/07/2025 (Penalidade por tecnologia mínima)
- **V15**: Ativo desde 01/04/2025 (Acordo Judicial)
- **V14**: Ativo desde 05/01/2025
- **V13**: Ativo desde 01/01/2025

### Versões em Preparação
- **V20**: Preparada mas desativada (Validador associado incorretamente + Padrões de falha de ar-condicionado)
- **V15B**: Planejado para 01/08/2025 (Validadores Jaé)
- **V15C**: Planejado para 01/11/2025 (Ar-condicionado obrigatório)

---

## ⚠️ Pontos de Atenção

### Monitoramento Necessário
1. **Ativação da V20**: Monitorar quando `DATA_SUBSIDIO_V20_INICIO` for alterada para data presente
2. **Apuração por sentido**: Validar resultados da nova lógica de POF
3. **Fiscalização de ar-condicionado**: Acompanhar impacto das falhas recorrentes

### Riscos Identificados
- **Complexidade crescente**: Múltiplas versões e regras condicionais por data
- **Dependências críticas**: Modelos centralizados com cascata de falhas
- **Transparência**: Dados de fiscalização ainda em fontes privadas

---

## 📈 Impacto na Apuração dos Subsídios

As mudanças de agosto de 2025 continuam a evolução iniciada em julho, com foco em:

1. **Maior precisão**: Apuração por sentido torna o cálculo mais granular
2. **Fiscalização aprimorada**: Padrões de falha de ar-condicionado mais sofisticados
3. **Validação rigorosa**: Nova regra para divergências entre validador e GPS
4. **Estabilidade técnica**: Correções em modelos de planejamento GTFS

---

## 📚 Referências Detalhadas

Para informações completas sobre as mudanças de agosto:

- **Sincronização detalhada**: [`sincronizacao2_agosto_2025.md`](sincronizacao2_agosto_2025.md)
- **Estrutura do projeto**: [`project-structure.md`](project-structure.md)
- **Arquitetura geral**: [`architecture.md`](architecture.md)
- **Preocupações de transparência**: [`transparency-concerns.md`](transparency-concerns.md)

---

**Documento mantido por**: Kilo Code
**Última atualização**: 19/08/2025 02:14 AM (UTC-3)
**Versão**: 2.0 - Consolidada e Organizada



# Sincronização Agosto 2025 - Documentação de Atualizações

**Data**: 19/08/2025
**Período coberto**: Agosto 2025
**Status**: ✅ Documentado e Atualizado

---

## 📋 Resumo das Mudanças

### Sincronização Mais Recente (19/08/2025)

**Commit analisado**: `4044fd38` - "Altera data para inclusão da regra de padrão de falha do ar condicionado (#788)"

**Impacto**: 🟡 **MÉDIO - Ajuste de regras de fiscalização de ar-condicionado**

Esta sincronização trouxe uma mudança importante na fiscalização de ar-condicionado, alterando a data de referência de [`DATA_SUBSIDIO_V17_INICIO`](queries/dbt_project.yml:1) para [`DATA_SUBSIDIO_V20_INICIO`](queries/dbt_project.yml:1) em vários modelos relacionados ao monitoramento de temperatura e falhas de ar-condicionado.

### Mudanças Anteriores de Agosto 2025

As atualizações no início de agosto de 2025 focaram em refinar a lógica de apuração de subsídios, corrigir bugs críticos em modelos de planejamento (GTFS) e ajustar a orquestração de pipelines para maior estabilidade. As mudanças mais significativas incluem a introdução da **apuração por sentido** no cálculo do Percentual de Operação por Faixa Horária (POF) e o versionamento de novas regras de negócio para classificação de viagens.

---

## 🔄 Mudanças Detalhadas da Sincronização Mais Recente (19/08/2025)

### 1. Alteração da Data de Referência para Fiscalização de Ar-Condicionado (V20)

**Commit**: `4044fd38` - PR #788
**Data**: 15/08/2025
**Impacto**: 🟡 **MÉDIO - Mudança na lógica de fiscalização**

#### Arquivos Modificados:

1. **[`queries/models/monitoramento/staging/aux_veiculo_falha_ar_condicionado.sql`](queries/models/monitoramento/staging/aux_veiculo_falha_ar_condicionado.sql:15)**
   - **Mudança**: Filtro incremental alterado de `DATA_SUBSIDIO_V17_INICIO` para `DATA_SUBSIDIO_V20_INICIO`
   - **Linha 15**: `and data >= date("{{ var('DATA_SUBSIDIO_V20_INICIO') }}")`
   - **Impacto**: Modelo não materializa dados antes da data V20

2. **[`queries/models/monitoramento/veiculo_regularidade_temperatura_dia.sql`](queries/models/monitoramento/veiculo_regularidade_temperatura_dia.sql:15)**
   - **Mudança**: Filtro incremental alterado de `DATA_SUBSIDIO_V17_INICIO` para `DATA_SUBSIDIO_V20_INICIO`
   - **Linha 15**: `and data >= date("{{ var('DATA_SUBSIDIO_V20_INICIO') }}")`
   - **Impacto**: Modelo não materializa dados antes da data V20

3. **[`queries/models/subsidio/viagem_regularidade_temperatura.sql`](queries/models/subsidio/viagem_regularidade_temperatura.sql:20-21)**
   - **Mudança**: Lógica de ar inoperante alterada para considerar `indicador_falha_recorrente` após `DATA_SUBSIDIO_V20_INICIO`
   - **Linhas 20-21**:
     ```sql
     vt.data >= date('{{ var("DATA_SUBSIDIO_V20_INICIO") }}')
     and coalesce(vr.indicador_falha_recorrente, false)
     ```
   - **Impacto**: Nova lógica para classificação de ar inoperante

4. **Atualizações de Pipelines**:
   - **[`pipelines/migration/projeto_subsidio_sppo/flows.py`](pipelines/migration/projeto_subsidio_sppo/flows.py:6)**: Comentário DBT atualizado de "2025-08-14" para "2025-08-15"
   - **[`pipelines/treatment/monitoramento/flows.py`](pipelines/treatment/monitoramento/flows.py:6)**: Comentário DBT atualizado de "2025-08-14" para "2025-08-15"

5. **Documentação Atualizada**:
   - **[`queries/models/monitoramento/CHANGELOG.md`](queries/models/monitoramento/CHANGELOG.md:3-7)**: Versão 1.6.4 adicionada documentando a refatoração dos modelos para não materializar dados antes de `DATA_SUBSIDIO_V20_INICIO`
   - **[`queries/models/subsidio/CHANGELOG.md`](queries/models/subsidio/CHANGELOG.md:3-7)**: Versão 2.1.2 adicionada documentando a alteração da lógica para considerar `indicador_falha_recorrente` após `DATA_SUBSIDIO_V20_INICIO`

#### Implicações Técnicas e de Negócio:

1. **Nova Versão de Subsídio V20**:
   - A mudança indica a preparação para uma nova versão de subsídio (V20) focada em padrões de falha de ar-condicionado
   - Atualmente `DATA_SUBSIDIO_V20_INICIO` está definida como `3000-01-01`, ou seja, **desativada**

2. **Fiscalização Mais Rigorosa**:
   - A introdução do `indicador_falha_recorrente` sugere uma fiscalização mais sofisticada
   - Falhas recorrentes de ar-condicionado podem impactar a classificação de viagens

3. **Impacto na Remuneração**:
   - Quando ativada, a V20 pode resultar em viagens classificadas como "ar inoperante" com base em padrões de falha
   - Isso pode afetar a remuneração das empresas com problemas recorrentes de ar-condicionado

4. **Alinhamento com Cronograma de Versões**:
   - V15C estava planejada para 01/11/2025 (ar-condicionado obrigatório)
   - V20 pode ser uma evolução dessa regra, focando em padrões de falha

---

## 🔄 Mudanças Detalhadas das Sincronizações Anteriores de Agosto 2025

### 1. Evolução nos Algoritmos de Subsídio

#### 1.1. Apuração do POF por Sentido
- **O quê**: O modelo [`queries/models/subsidio/percentual_operacao_faixa_horaria.sql`](queries/models/subsidio/percentual_operacao_faixa_horaria.sql) foi alterado para incorporar o **sentido** da viagem (ida/volta/circular) no cálculo do POF.
- **Impacto**: A remuneração agora é mais granular e precisa, condicionada à operação em cada sentido planejado, o que pode impactar o valor final do subsídio para as operadoras. A mudança está documentada em [`queries/models/subsidio/CHANGELOG.md`](queries/models/subsidio/CHANGELOG.md).

#### 1.2. Nova Regra de Negócio: `Validador Associado Incorretamente` (V20)
- **O quê**: Foi introduzida uma nova variável de subsídio, `DATA_SUBSIDIO_V20_INICIO`, no arquivo [`queries/dbt_project.yml`](queries/dbt_project.yml). Essa variável controla a ativação da regra que classifica uma viagem como `"Validador associado incorretamente"`.
- **Detalhes**: A verificação, presente nos modelos [`queries/models/subsidio/viagem_transacao_aux_v1.sql`](queries/models/subsidio/viagem_transacao_aux_v1.sql) e [`queries/models/subsidio/viagem_transacao_aux_v2.sql`](queries/models/subsidio/viagem_transacao_aux_v2.sql), foi alterada para usar esta nova data. Atualmente, a data está definida como `3000-01-01`, o que significa que a regra está preparada mas desativada.

    **Exemplo e Explicação da Regra "Validador associado incorretamente":**

    Esta regra é aplicada quando há uma divergência entre o serviço (linha) registrado no validador de bilhetagem do ônibus e o serviço que o sistema determina que o ônibus deveria estar operando com base em seus dados de GPS e planejamento.

    **Cenário Dummy:**

    **Tabela `rj-smtr-prod.bilhetagem.transacao` (Dados do Validador):**

    | data       | id_viagem | servico_validador |
    | :--------- | :-------- | :---------------- |
    | 2025-08-05 | VIAGEM001 | 123               |
    | 2025-08-05 | VIAGEM001 | 123               |
    | 2025-08-05 | VIAGEM001 | 456               |
    | 2025-08-05 | VIAGEM002 | 789               |

    **Tabela `rj-smtr-prod.projeto_subsidio_sppo.viagem_completa` (Dados de GPS/Planejamento):**

    | data       | id_viagem | servico_gps_planejado |
    | :--------- | :-------- | :-------------------- |
    | 2025-08-05 | VIAGEM001 | 123                   |
    | 2025-08-05 | VIAGEM002 | 789                   |

    **Como a lógica funciona (internamente nos modelos dbt):**

    1.  **Junção dos Dados:** Os modelos dbt fazem um `JOIN` entre `transacao` e `viagem_completa` usando `data` e `id_viagem`.
    2.  **Identificação da Divergência:** Para cada `id_viagem`, o sistema compara o `servico_validador` com o `servico_gps_planejado`. No exemplo acima, para `VIAGEM001`, a terceira transação (`servico_validador` 456) é diferente do `servico_gps_planejado` (123).
    3.  **Cálculo dos Indicadores de Divergência:** Se houver transações com serviço divergente, indicadores internos (como `quantidade_transacao_servico_divergente`) são marcados como maiores que zero.
    4.  **Classificação Final (`tipo_viagem`):** Se a data da viagem for igual ou posterior a `DATA_SUBSIDIO_V20_INICIO` (atualmente `3000-01-01`), e os indicadores de divergência forem maiores que zero, a viagem é classificada como `'Validador associado incorretamente'`.

    Portanto, a query que você usaria para consultar essas viagens já classificadas é:

    ```sql
    SELECT
        data,
        servico,
        id_viagem,
        id_veiculo,
        tipo_viagem
    FROM
        `rj-smtr-prod.subsidio.viagem_transacao`
    WHERE
        data BETWEEN '2025-08-01' AND '2025-08-07' -- Substitua pelo intervalo de datas desejado
        AND servico = 'SEU_SERVICO_AQUI' -- Substitua pelo código do serviço
        AND tipo_viagem = 'Validador associado incorretamente'
    ORDER BY
        data, 
        id_viagem;
    ```
    Esta query funciona porque a tabela `viagem_transacao` (ou `viagem_classificada`) já é o **resultado final** desse processo de comparação e classificação realizado pelo pipeline de dados.

### 1.3. Nova Regra de Negócio: `Validador Associado Incorretamente` (V20) (Commit `2228642`)

- **O quê**: Foi introduzida uma nova variável de subsídio, `DATA_SUBSIDIO_V20_INICIO`, no arquivo [`queries/dbt_project.yml`](queries/dbt_project.yml). Essa variável controla a ativação da regra que classifica uma viagem como `"Validador associado incorretamente"`.
- **Detalhes**: A verificação, presente nos modelos [`queries/models/subsidio/viagem_transacao_aux_v1.sql`](queries/models/subsidio/viagem_transacao_aux_v1.sql) e [`queries/models/subsidio/viagem_transacao_aux_v2.sql`](queries/models/subsidio/viagem_transacao_aux_v2.sql), foi alterada para usar esta nova data. Atualmente, a data está definida como `3000-01-01`, o que significa que a regra está preparada mas desativada.

    **Exemplo e Explicação da Regra "Validador associado incorretamente":**

    Esta regra é aplicada quando há uma divergência entre o serviço (linha) registrado no validador de bilhetagem do ônibus e o serviço que o sistema determina que o ônibus deveria estar operando com base em seus dados de GPS e planejamento.

    **Cenário Dummy:**

    **Tabela `rj-smtr-prod.bilhetagem.transacao` (Dados do Validador):**

    | data       | id_viagem | servico_validador |
    | :--------- | :-------- | :---------------- |
    | 2025-08-05 | VIAGEM001 | 123               |
    | 2025-08-05 | VIAGEM001 | 123               |
    | 2025-08-05 | VIAGEM001 | 456               |
    | 2025-08-05 | VIAGEM002 | 789               |

    **Tabela `rj-smtr-prod.projeto_subsidio_sppo.viagem_completa` (Dados de GPS/Planejamento):**

    | data       | id_viagem | servico_gps_planejado |
    | :--------- | :-------- | :-------------------- |
    | 2025-08-05 | VIAGEM001 | 123                   |
    | 2025-08-05 | VIAGEM002 | 789                   |

    **Como a lógica funciona (internamente nos modelos dbt):**

    1.  **Junção dos Dados:** Os modelos dbt fazem um `JOIN` entre `transacao` e `viagem_completa` usando `data` e `id_viagem`.
    2.  **Identificação da Divergência:** Para cada `id_viagem`, o sistema compara o `servico_validador` com o `servico_gps_planejado`. No exemplo acima, para `VIAGEM001`, a terceira transação (`servico_validador` 456) é diferente do `servico_gps_planejado` (123).
    3.  **Cálculo dos Indicadores de Divergência:** Se houver transações com serviço divergente, indicadores internos (como `quantidade_transacao_servico_divergente`) são marcados como maiores que zero.
    4.  **Classificação Final (`tipo_viagem`):** Se a data da viagem for igual ou posterior a `DATA_SUBSIDIO_V20_INICIO` (atualmente `3000-01-01`), e os indicadores de divergência forem maiores que zero, a viagem é classificada como `'Validador associado incorretamente'`.

    Portanto, a query que você usaria para consultar essas viagens já classificadas é:

    ```sql
    SELECT
        data,
        servico,
        id_viagem,
        id_veiculo,
        tipo_viagem
    FROM
        `rj-smtr-prod.subsidio.viagem_transacao`
    WHERE
        data BETWEEN '2025-08-01' AND '2025-08-07' -- Substitua pelo intervalo de datas desejado
        AND servico = 'SEU_SERVICO_AQUI' -- Substitua pelo código do serviço
        AND tipo_viagem = 'Validador associado incorretamente'
    ORDER BY
        data, 
        id_viagem;
    ```
    Esta query funciona porque a tabela `viagem_transacao` (ou `viagem_classificada`) já é o **resultado final** desse processo de comparação e classificação realizado pelo pipeline de dados.

- **Consequências e Efeitos:**
    *   **Nova Penalidade Potencial**: Embora desativada por enquanto, a regra V20 representa uma nova forma de penalização para as empresas, caso haja inconsistência entre o serviço do validador e o serviço planejado/GPS.
    *   **Maior Granularidade na Validação**: A introdução dessa regra permite uma validação mais granular da operação, identificando problemas de associação de serviços.
    *   **Impacto na Remuneração Futura**: Uma vez ativada, essa regra pode levar a viagens não remuneradas se as empresas não garantirem a correta associação dos serviços nos validadores.

### 2. Correções em Modelos de Planejamento (GTFS)

#### 2.1. Correção de Duplicação em `ordem_servico_trips_shapes`
- **O quê**: Vários commits foram dedicados a corrigir bugs que causavam duplicação de viagens no modelo [`queries/models/gtfs/staging/ordem_servico_trips_shapes_gtfs_v2.sql`](queries/models/gtfs/staging/ordem_servico_trips_shapes_gtfs_v2.sql).
- **Impacto**: A correção evita a contagem duplicada de viagens planejadas, garantindo que os dados de planejamento sejam mais precisos, o que é fundamental para o cálculo correto do POF.

#### 2.2. Lógica de Trajetos Alternativos e Sentido Duplo
- **O quê**: Foi adicionada a coluna `indicador_duplo_sentido` no modelo [`queries/models/gtfs/staging/ordem_servico_trajeto_alternativo_sentido_atualizado_aux_gtfs_v2.sql`](queries/models/gtfs/staging/ordem_servico_trajeto_alternativo_sentido_atualizado_aux_gtfs_v2.sql) para melhor identificar serviços que operam em ambos os sentidos. Além disso, o `JOIN` com trajetos alternativos foi corrigido no modelo `ordem_servico_trips_shapes_v2`.
- **Impacto**: Essas mudanças garantem que os trajetos, tanto regulares quanto alternativos, sejam associados corretamente às ordens de serviço, melhorando a precisão do planejamento.

### 2.3. Remoção da Condição de Materialização Incremental
- **O quê**: Removida a condição para materialização incremental nos modelos efêmeros `ordem_servico_trajeto_alternativo_sentido_atualizado_aux_gtfs`, `ordem_servico_trips_shapes` e `trips_filtrada_aux_gtfs` e suas versões (PR #776).
- **Impacto**: Pode otimizar a performance do pipeline.

### 3. Alterações em Fontes de Dados e Estrutura

#### 3.1. Refatoração de Modelos de Dashboard
- **O quê**: Os modelos `viagens_remuneradas_v1` e `viagens_remuneradas_v2` foram movidos para o subdiretório `staging/` dentro de [`queries/models/dashboard_subsidio_sppo/`](queries/models/dashboard_subsidio_sppo/), conforme registrado no `CHANGELOG.md` do domínio.
- **Impacto**: Melhora a organização do projeto, alinhando-o com as convenções de separar modelos de preparação (`staging`).

#### 3.2. Uso de `COALESCE` para Versão de Shapes
- **O quê**: O modelo `subsidio_shapes_geom` (agora obsoleto) foi alterado para usar `COALESCE(data_versao_shapes, feed_start_date)`, garantindo um fallback para a data de início do feed GTFS caso a versão do shape não esteja disponível.
- **Impacto**: Aumenta a robustez do pipeline, evitando falhas quando `data_versao_shapes` é nula.

### 4. Ajustes Operacionais e de Orquestração

- **Reagendamento de Pipelines**: Os agendamentos de pipelines importantes foram ajustados no arquivo [`pipelines/schedules.py`](pipelines/schedules.py) e [`pipelines/treatment/bilhetagem/constants.py`](pipelines/treatment/bilhetagem/constants.py).
    - O flow `ordem_pagamento_quality_check` foi movido das 8h para as 11h.
    - A materialização dos dados de `integracao` foi alterada das 5:15h para as 6:15h.
- **Impacto**: Estes ajustes provavelmente visam otimizar a execução dos pipelines, garantindo que os dados de origem estejam prontos e evitando conflitos de dependência.

---

## 🚀 Próximos Passos e Recomendações

- **Monitorar Ativação da V20**: A regra do "Validador associado incorretamente" (V20) está atualmente desativada. É crucial monitorar quando a data `DATA_SUBSIDIO_V20_INICIO` for alterada para uma data presente, pois isso ativará uma nova regra de negócio que impactará a classificação das viagens.
- **Validar Apuração por Sentido**: A introdução da apuração por sentido no POF é uma mudança significativa. Recomenda-se validar os resultados gerados por esta nova lógica para garantir que estejam alinhados com as expectativas de negócio.

### 1. Evolução nos Algoritmos de Subsídio: Apuração por Sentido (Commit `f1028a9`)

**Data**: 07/08/2025
**Impacto**: 🔴 **ALTO - Mudança fundamental na apuração do subsídio**

**Descrição**: Este commit introduz a apuração do Percentual de Operação por Faixa Horária (POF) considerando o "sentido" da viagem (ida/volta/circular). Isso permite uma granularidade muito maior e mais precisa no cálculo do subsídio, alinhando-o melhor com a operação real das linhas.

**Mudanças Detalhadas**:

*   **Modelos de POF Versionados**:
    *   Criação de `queries/models/subsidio/staging/percentual_operacao_faixa_horaria_v1.sql` (para dados anteriores a `DATA_SUBSIDIO_V17_INICIO`, sem `sentido`).
    *   Criação de `queries/models/subsidio/staging/percentual_operacao_faixa_horaria_v2.sql` (para dados a partir de `DATA_SUBSIDIO_V17_INICIO`, incluindo `sentido`).
    *   O modelo principal `queries/models/subsidio/percentual_operacao_faixa_horaria.sql` agora faz um `full outer union all by name` entre V1 e V2, aplicando a lógica correta com base na data.
    *   O `schema.yml` do subsídio foi atualizado para incluir a coluna `sentido` no modelo `percentual_operacao_faixa_horaria`.

*   **Atualização da Macro `queries/macros/test_check_km_planejada.sql`**:
    *   A macro foi atualizada para incluir o campo `sentido` na seleção e nos agrupamentos.
    *   A lógica de `os` (ordem de serviço) agora faz um `full outer union all by name` entre `ordem_servico_faixa_horaria_sentido` (para dados a partir de `DATA_SUBSIDIO_V17_INICIO`) e `ordem_servico_faixa_horaria` (para dados anteriores a `DATA_SUBSIDIO_V17_INICIO`). Isso garante que o teste de quilometragem planejada considere o sentido quando aplicável.
    *   A junção final (`using (data, servico, faixa_horaria_inicio, sentido)`) agora inclui o `sentido`, tornando o teste mais preciso para a nova lógica.

*   **Refatoração de `queries/models/dashboard_subsidio_sppo/viagens_remuneradas.sql`**:
    *   O modelo foi significativamente alterado para se adaptar à nova lógica de apuração por sentido e ao versionamento.
    *   As CTEs `planejado` e `viagem` foram removidas, e a lógica de cálculo de `inicio_periodo` e `fim_periodo` foi simplificada.
    *   A lógica de `trips` e `shapes` foi mantida, mas a forma como são utilizadas e unidas ao quadro horário foi ajustada para incorporar o `sentido`.
    *   O modelo agora parece consumir diretamente os dados já processados com o `sentido` incluído, o que indica uma dependência dos novos modelos `percentual_operacao_faixa_horaria_v1/v2`.

*   **Atualização de `queries/models/projeto_subsidio_sppo/viagem_planejada.sql`:**
    *   Este modelo agora também utiliza um versionamento interno, fazendo um `union all by name` entre `viagem_planejada_v1` e `viagem_planejada_v2` com base em `DATA_SUBSIDIO_V6_INICIO`.
    *   Foi adicionada a coluna `id_execucao_dbt` para rastreabilidade.

*   **Atualizações de `CHANGELOG.md` e `schema.yml`:**
    *   `queries/models/dashboard_subsidio_sppo/CHANGELOG.md` foi atualizado para a versão `8.0.0`, mencionando a apuração por sentido e o versionamento.
    *   `queries/models/dashboard_subsidio_sppo/schema.yml` foi atualizado para incluir as colunas `id_execucao_dbt` e `sentido`.
    *   `queries/models/subsidio/CHANGELOG.md` foi atualizado para a versão `2.0.8`, mencionando a apuração por sentido e o versionamento.

**Consequências e Efeitos:**

*   **Maior Precisão na Remuneração**: A inclusão do `sentido` permite uma apuração mais granular e justa do subsídio, alinhando-se melhor com a operação real das linhas de ônibus.
*   **Complexidade Aumentada**: A introdução de versionamento e a dependência de múltiplos modelos efêmeros aumentam a complexidade da codebase, exigindo maior atenção na manutenção e no entendimento da lógica.
*   **Impacto em Dados Históricos**: A distinção entre V1 e V2 com base em datas (`DATA_SUBSIDIO_V17_INICIO`) significa que relatórios e análises históricas precisarão considerar essa quebra de lógica.
*   **Rastreabilidade Melhorada**: A adição de `id_execucao_dbt` em `viagem_planejada.sql` e `percentual_operacao_faixa_horaria.sql` melhora a rastreabilidade das execuções do dbt.

## 📚 Referências Cruzadas

Para informações detalhadas sobre as mudanças já implementadas, consultar:

- Estrutura do projeto: [`project-structure.md`](project-structure.md)
- Arquitetura geral: [`architecture.md`](architecture.md)
- Convenções de código: [`coding-conventions.md`](coding-conventions.md)
- Pontos de integração: [`integration-points.md`](integration-points.md)
- Preocupações de transparência: [`transparency-concerns.md`](transparency-concerns.md)

---

**Documento mantido por**: Kilo Code
**Última atualização**: 17/08/2025 00:07 AM (UTC-3)
**Versão**: 2.0

# Sincronização Agosto 2025 - Atualizações Complementares

Data: 18/08/2025
Período coberto: Agosto 2025
Status: ✅ Documentado

---

## 🔄 Mudanças Detalhadas (Continuação)

### 5. Fiscalização de Ar Condicionado (Commit `fb3c431`)

**O quê**: Este commit provavelmente refina a lógica de fiscalização do ar condicionado em [`queries/models/monitoramento/staging/aux_veiculo_falha_ar_condicionado.sql`](../../../queries/models/monitoramento/staging/aux_veiculo_falha_ar_condicionado.sql). O modelo utiliza indicadores de temperatura (`indicador_temperatura_variacao_veiculo`, `indicador_temperatura_transmitida_veiculo`, `indicador_temperatura_descartada_veiculo`, `indicador_viagem_temperatura_descartada_veiculo`) para determinar se há falha no sistema de ar condicionado.

**Impacto**: Embora os detalhes exatos das alterações não estejam disponíveis nos documentos de sincronização, é provável que o commit tenha ajustado os critérios ou thresholds para a detecção de falhas, visando uma fiscalização mais precisa e justa. Isso pode influenciar diretamente a classificação de viagens e, consequentemente, a remuneração dos veículos.