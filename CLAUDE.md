# CLAUDE.md - Guia de Contexto para Auditoria do Sistema de Subsídios SMTR/RJ

## Sobre Este Documento

Este documento serve como base de conhecimento centralizada para a auditoria e monitoramento contínuo do código da Secretaria Municipal de Transportes (SMTR) do Rio de Janeiro, especificamente o sistema de cálculo de subsídios pagos às empresas de ônibus (SPPO - Serviço Público de Transporte de Passageiros por Ônibus).

**Objetivo:** Documentar, monitorar e auditar - não corrigir ou alterar o código.

**Repositório:** Fork local de `prefeitura-rio/pipelines_rj_smtr`

**Data da Análise Inicial:** 28 de Novembro de 2025

**Estado do Repositório (após atualização):** Commit `56971229e` (upstream/main) - **ÚLTIMA ATUALIZAÇÃO: 14/02/2026**

---

## ⚠️⚠️⚠️ ALERTA CRÍTICO - FEVEREIRO 2026 ⚠️⚠️⚠️

### AUMENTO DE TARIFA CONFIRMADO 💰

**PR:** #1162 (mergeado em 13/01/2026)
**Data de Vigência:** 04/01/2026
**Impacto:** **ALTO**

- Tarifa pública aumentou de **R$ 4,70 para R$ 5,00**
- Aumento de **6,38%** no valor da tarifa
- Base Legal: **DECRETO RIO Nº 57473 DE 29 DE DEZEMBRO DE 2025**
- Nova tabela [`tarifa_publica.sql`](queries/models/planejamento/tarifa_publica.sql) criada para histórico de tarifas

**Histórico de Tarifas (novo modelo):**
| Período | Valor | Base Legal |
|---------|-------|------------|
| 07/01/2023 - 04/01/2025 | R$ 4,30 | DECRETO RIO Nº 51914/2023 |
| 05/01/2025 - 03/01/2026 | R$ 4,70 | DECRETO RIO Nº 55631/2025 |
| 04/01/2026 - atual | R$ 5,00 | DECRETO RIO Nº 57473/2025 |

---

### EXTENSÃO DO PRAZO DE VISTORIA 🔧

**PR:** #1183 (mergeado em 23/01/2026)
**Data:** 23/01/2026
**Impacto:** **MÉDIO**

- **Resolução SMTR Nº 3894** altera prazo final de vistoria para **31 de janeiro de 2026**
- Veículos com vistoria realizada até 2 anos antes são considerados vistoriados em janeiro/2026
- Modificação no modelo [`veiculo_dia.sql`](queries/models/monitoramento/veiculo_dia.sql)

**Trecho do código:**
```sql
when date(data) between ('2026-01-01') and ('2026-01-31')
and ano_ultima_vistoria >= extract(year from date(data)) - 2
then true  -- RESOLUÇÃO SMTR Nº 3894
```

---

### EXCEÇÕES DE LIMITE DE VIAGENS - JANEIRO 2026 🚌

**PR:** #1195 (mergeado em 27/01/2026)
**Processo:** n° 000300.001720/2026-55
**Impacto:** **ALTO**

Adicionada exceção no limite de viagens para serviços específicos entre **01-15 de janeiro de 2026**:

**Serviços com exceção:**
`104, 107, 109, 161, 167, 169, 409, 410, 435, 473, 583, 584, LECD127, LECD128, 552, SP805, 361, LECD129, 232`

**Efeito:** Viagens acima do limite nestes serviços não são glosadas durante o período.

---

### PLANO VERÃO 2026 - NOVAS DATAS ☀️

**PR:** #1203 (mergeado em 02/02/2026)
**Impacto:** **MÉDIO**

Novas datas adicionadas ao "Plano Verão":
- **17-18 de janeiro de 2026** (Processo: 000399.000456/2026-91)
- **31 de janeiro - 01 de fevereiro de 2026** (Processo: 000399.001025/2026-41)

**Efeito:** Nestas datas, o tipo de OS é "Verão" com regras operacionais diferenciadas.

---

### PONTO FACULTATIVO 26/01/2026 - LECD126 📅

**PR:** #1217 (mergeado em 09/02/2026)
**Impacto:** **BAIXO**

- Serviço **LECD126** no dia 26/01/2026 (ponto facultativo) tratado como **sábado**
- Modificação em [`ordem_servico_trips_shapes_gtfs_v2.sql`](queries/models/gtfs/staging/ordem_servico_trips_shapes_gtfs_v2.sql)

---

### REMOÇÃO DO ACRÉSCIMO DE 4% - RIOCARD 💳

**PR:** #1185 (mergeado em 26/01/2026)
**Impacto:** **ALTO**

- **REMOVIDO** o acréscimo de 4% nas transações RioCard
- Anteriormente: `valor_pagamento / 0.96` (acréscimo de ~4,17%)
- Agora: `valor_pagamento` direto, sem acréscimo
- Afeta modelo [`aux_passageiro_hora.sql`](queries/models/bilhetagem/staging/aux_passageiro_hora.sql)

**Impacto financeiro:** Redução de ~4% nos valores de transações RioCard reportados.

---

### NOVO MODELO: `validador_operadora` 📋

**PR:** #1181 (mergeado em 10/02/2026)
**Impacto:** **MÉDIO**

- Nova view [`validador_operadora.sql`](queries/models/cadastro/validador_operadora.sql)
- Atualização de [`view_viagem_climatizacao.sql`](queries/models/dashboard_monitoramento_interno/view_viagem_climatizacao.sql)
- Objetivo: Rastrear qual operadora está associada a cada validador

---

### MODELO `viagem_transacao` - INCLUSÃO DE VIAGENS DO DIA ANTERIOR 🔄

**PR:** #1108 (mergeado em 15/01/2026)
**Impacto:** **ALTO**

- Ajuste para incluir viagens do dia anterior fora do ambiente de produção
- Modificação em [`viagem_transacao_aux_v2.sql`](queries/models/subsidio/staging/viagem_transacao_aux_v2.sql)
- Permite que viagens iniciadas em um dia e terminadas no seguinte sejam contabilizadas

---

### CORREÇÕES DE TEMPERATURA E TESTES 🌡️

**PRs:** #1176 (19/01/2026) e #1189 (30/01/2026)
**Impacto:** **MÉDIO**

- Correção no modelo [`temperatura.sql`](queries/models/monitoramento/temperatura.sql)
- Ajuste no teste `test_completude_temperatura.sql` para **remover o dia posterior** do cálculo
- Impacta validação de climatização para fins de glosa

---

### DESATIVAÇÃO DE SCHEDULES 📴

**PRs:** #1211 (05/02/2026) e #1219 (10/02/2026)
**Impacto:** **BAIXO**

- Removido schedule do flow `CAPTURA_GPS_VALIDADOR`
- Removido schedule do flow de materialização da `gps_validador`
- Tabelas continuam existindo mas não são mais atualizadas automaticamente

---

### BACKUP BILLINGPAY - TABELAS EXCLUÍDAS 💾

**PR:** #1241 (mergeado em 11/02/2026)
**Impacto:** **BAIXO (operacional)**

Tabelas adicionadas ao exclude do backup:
- `transacao_erro`
- `temp_cancelamento_estudante_08122025`
- `temp_cancelamento_estudante_sme_08122025`

---

## ALERTAS ANTERIORES (JANEIRO 2026)

### FIM DA SUSPENSÃO V22 - REVERSÃO TOTAL

**Data da Reversão:** 29/12/2025 (commit `5e39e7367`)
**Data do Merge:** 09/01/2026
**Impacto:** **EXTREMO**

A versão V22 foi **COMPLETAMENTE REMOVIDA** do código:
- A variável `DATA_SUBSIDIO_V22_INICIO` não existe mais em `dbt_project.yml`
- O filtro que bloqueava glosas por climatização foi **ELIMINADO**
- Viagens de OUT/NOV 2025 (16/10 a 15/11) **VOLTAM A SER AUDITADAS**
- **Reprocessamento retroativo** confirmado

**O que isso significa:**
A "suspensão das glosas" durou menos de 3 meses e foi revertida. O período que estava isento (16/10 a 15/11/2025) agora volta a ser auditado e pode sofrer penalizações.

**Padrão Confirmado:** Implementação → "Concessão Temporária" → Reversão Total

---

### HISTÓRICO DE ALERTAS ANTERIORES

#### VERSÃO V22: SUSPENSÃO TOTAL DAS GLOSAS POR CLIMATIZAÇÃO (28/11/2025)

**Data de Início:** 16/10/2025
**Status:** **REVERTIDA** em 29/12/2025

A partir de 16/10/2025, **NENHUMA viagem era glosada** por problemas de ar-condicionado. Esta suspensão durou apenas 30 dias (até 15/11/2025) e foi completamente revertida.

**Detalhes completos:** Ver `RELATORIO_SEMANAL_2026-01-12.md` seção "FIM DA SUSPENSÃO V22"

---

## 1. Visão Geral da Arquitetura

### 1.1 Stack Tecnológico

O sistema é uma pipeline de dados moderna baseada em componentes especializados:

| Componente | Tecnologia | Função | Localização |
|------------|-----------|---------|-------------|
| **Orquestração** | Prefect 1.4.1 | Agendamento e execução de fluxos de trabalho | `pipelines/` |
| **Transformação** | dbt 1.7.3 | Lógica de negócio e cálculo de subsídios | `queries/` |
| **Data Warehouse** | Google BigQuery | Armazenamento e processamento SQL | GCP |
| **Storage** | Google Cloud Storage | Arquivos intermediários (GTFS, etc.) | GCP |
| **Linguagem** | Python 3.10 | Scripts de automação e integração | Todo o projeto |
| **Gerenciamento de Deps** | Poetry | Controle de dependências | `pyproject.toml` |

### 1.2 Estrutura de Diretórios

```
pipelines_rj_smtr/
├── pipelines/              # Orquestração Prefect (Python)
│   ├── capture/           # Captura de dados externos
│   ├── migration/
│   │   └── projeto_subsidio_sppo/  # Flows específicos de subsídio
│   ├── treatment/         # Tratamento e transformação
│   └── utils/             # Utilitários compartilhados
│
├── queries/               # Projeto dbt completo
│   ├── models/           # Modelos SQL (lógica de negócio)
│   │   ├── subsidio/    # **Modelos centrais de subsídio**
│   │   ├── dashboard_subsidio_sppo_v2/  # **Sumários e pagamentos**
│   │   ├── bilhetagem/  # Dados de transações
│   │   ├── veiculo/     # Licenciamento e infrações
│   │   └── gtfs/        # Planejamento operacional
│   ├── macros/          # Funções SQL reutilizáveis
│   ├── tests/           # Testes de qualidade de dados
│   └── dbt_project.yml  # **ARQUIVO CRÍTICO - Configuração central**
│
└── pyproject.toml        # Dependências Python
```

---

## 2. O Arquivo dbt_project.yml - Coração da Lógica de Negócio

### 2.1 Por que este arquivo é crítico?

O `queries/dbt_project.yml` contém **todas as variáveis que parametrizam as regras de subsídio**. É onde estão definidos:
- Datas de início de cada versão de regra de subsídio
- Percentuais e limiares de conformidade
- Referências a tabelas de staging
- Configuração de materialização dos modelos

### 2.2 Estrutura de Versões do Subsídio

O sistema evoluiu através de **20 versões documentadas** de regras de subsídio, cada uma ativada a partir de uma data específica. Aqui está o histórico completo:

| Versão | Data de Início | Mudança Principal | Base Legal |
|--------|---------------|-------------------|------------|
| **V2** | 2023-01-16 | Penalidade de autuação por inoperância do ar condicionado | DECRETO RIO 51940/2023 |
| **V3** | 2023-07-04 | Penalidade de autuação por segurança e limpeza/equipamento | DECRETO RIO 52820/2023 |
| **V3A** | 2023-09-16 | Viagens remuneradas | RESOLUÇÃO SMTR Nº 3645/2023 |
| **V4** | 2024-01-04 | Penalidade aplicada por agente de verão | DECRETO RIO 53856/2023 e RESOLUÇÃO SMTR 3682/2024 |
| **V5** | 2024-03-01 | Penalidade de vistoria | RESOLUÇÃO SMTR 3683/2024 |
| **V6** | 2024-04-01 | Trajetos alternativos | - |
| **V7** | 2024-05-01 | Apuração Madonna (The Celebration Tour in Rio) | - |
| **V8** | 2024-07-20 | Viagens sem transação | - |
| **V9** | 2024-08-16 | Apuração por faixa horária | - |
| **V9A** | 2024-09-01 | Desconsideração de km não vistoriado e não licenciado | - |
| **V10** | 2024-11-01 | Novas faixas horárias | RESOLUÇÃO SMTR 3777/2024 |
| **V11** | 2024-11-06 | Novas faixas horárias - Feed GTFS | RESOLUÇÃO SMTR 3777/2024 |
| **V12** | 2024-11-16 | Parâmetro 110 km/h + alterações em `viagem_transacao.sql` | - |
| **V13** | 2025-01-01 | Inclusão de colunas de tecnologia em sppo_veiculo_dia | - |
| **V14** | 2025-01-05 | Apuração por tecnologia e penalidade por faixa horária | DECRETO 55631/2025 |
| **V15** | 2025-04-01 | Acordo judicial ACP 0045547-94.2019.8.19.0001 | RESOLUÇÃO SMTR 3843/2025 |
| **V16** | 2025-07-01 | Não pagamento de tecnologia inferior à mínima permitida | RESOLUÇÃO SMTR 3843/2025 |
| **V17** | 2025-07-16 | Regularidade de temperatura | RESOLUÇÃO SMTR 3857/2025 |
| **V18** | 2025-08-01 | Validadores e transações Jaé | RESOLUÇÃO SMTR 3843/2025 e 3858/2025 |
| **V19** | 2025-11-01 | Não pagamento de viagens licenciadas sem ar condicionado | RESOLUÇÃO SMTR 3843/2025 |
| **V20** | 2025-08-16 | Inciso IV Climatização | - |
| **V21** | 2025-10-01 | Mudanças em validadores (implementação conturbada com reversões) | RESOLUÇÃO SMTR 3878/2025 |
| **V22** | 2025-10-16 | **SUSPENSÃO DAS GLOSAS POR CLIMATIZAÇÃO** | - |
| **V99** | 3000-01-01 | Placeholder para features futuras | - |

### 2.3 Parâmetros Chave de Conformidade

```yaml
# Parâmetros de GPS e Conformidade de Trajeto
tamanho_buffer_metros: 500                      # Buffer da rota para validação
intervalo_max_desvio_segundos: 600             # Tempo máximo fora da rota
velocidade_maxima: 60                          # km/h para evitar outliers
velocidade_limiar_parado: 3                    # km/h para considerar parado

# Conformidade para Subsídio
conformidade_velocidade_min: 110               # % mínimo
perc_conformidade_distancia_min: 0             # % mínimo
perc_conformidade_shape_min: 80                # % mínimo
perc_conformidade_registros_min: 50            # % mínimo
perc_distancia_total_subsidio: 80              # % da distância para pagamento
distancia_inicio_fim_conformidade_velocidade_min: 2000  # metros

# Licenciamento de Veículos
sppo_licenciamento_validade_vistoria_ano: 1    # Prazo de validade
sppo_licenciamento_tolerancia_primeira_vistoria_dia: 15  # Tolerância para veículos novos
```

---

## 3. Modelos dbt de Subsídio - Fluxo de Cálculo

### 3.1 Módulo `subsidio/` - Modelos Centrais

Localização: `queries/models/subsidio/`

**Modelos Principais:**

1. **`viagem_classificada.sql`** (Criado em: 2025-07-03, PR #649)
   - Classifica cada viagem por tecnologia (Mini, Midi, Básico, Padrão)
   - Determina tecnologia apurada vs. tecnologia remunerada
   - Adiciona modo, sentido, placa e ano de fabricação
   - **Impacto:** Base para toda classificação financeira

2. **`viagem_transacao.sql`** (Refatorado múltiplas vezes, última: 2025-08-11)
   - Relaciona viagens com transações de bilhetagem
   - Utiliza modelos auxiliares versionados (`viagem_transacao_aux_v1` e `v2`)
   - Classifica viagens como: "Sem transação", "Validador fechado", "Validador associado incorretamente"
   - **Impacto Crítico:** Define quais viagens são pagas ou glosadas

3. **`viagem_regularidade_temperatura.sql`** (Criado em: 2025-07-31, PR #703)
   - Valida regularidade da climatização durante as viagens
   - Implementa indicadores de falha recorrente
   - Base: dados de temperatura dos validadores
   - **Impacto:** Penalização por ar-condicionado irregular (V17+)

4. **`percentual_operacao_faixa_horaria.sql`** (Criado em: 2025-06-24)
   - Calcula POF (Percentual de Operação por Faixa Horária)
   - Apuração por sentido de viagem
   - **Impacto:** Penalização proporcional à faixa horária (V9+)

5. **`valor_km_tipo_viagem.sql`** (Criado em: 2025-01-21)
   - Define valores por km para cada tipo de viagem
   - Varia por tecnologia do veículo
   - **Impacto:** Base monetária do pagamento

**Modelos Auxiliares em `subsidio/staging/`:**

- `aux_viagem_temperatura.sql`: Agregação de dados de temperatura por viagem
- `viagem_transacao_aux_v1.sql`: Lógica de transação para datas < 2025-04-01
- `viagem_transacao_aux_v2.sql`: Lógica de transação para datas >= 2025-04-01
- `percentual_operacao_faixa_horaria_v1.sql` e `v2.sql`: Versionamento do cálculo de POF

### 3.2 Módulo `dashboard_subsidio_sppo_v2/` - Sumários e Pagamentos

Localização: `queries/models/dashboard_subsidio_sppo_v2/`

**Modelos de Output Final:**

1. **`sumario_servico_dia_pagamento.sql`**
   - **Função:** Tabela final de valores a pagar por serviço/dia
   - **Agregação:** Por data, tipo_dia, consórcio, servico
   - **Colunas Críticas:**
     - `km_apurada_*`: Quilometragem por categoria de conformidade
       - `licenciado_com_ar_n_autuado`: KM válidos para pagamento
       - `licenciado_sem_ar_n_autuado`: KM com penalização
       - `n_licenciado`, `n_vistoriado`: KM glosados
       - `autuado_*`: Penalizações diversas
       - `sem_transacao`: KM sem validação de bilhetagem
     - `valor_a_pagar`: **VALOR FINAL** a ser pago
     - `valor_glosado`: Total de penalizações
     - `valor_total_apurado`: Valor bruto antes de glosas
     - `valor_judicial`: Ajustes legais
     - `valor_penalidade`: Penalidades aplicadas
   - **Status:** Desabilitado para datas >= V14 (2025-01-05)

2. **`sumario_faixa_servico_dia_pagamento.sql`**
   - Similar ao anterior, mas com quebra por faixa horária
   - Implementado na V14
   - Utiliza versionamento através de staging (v1 e v2)

3. **`sumario_faixa_servico_dia.sql`**
   - Sumário agregado por faixa horária
   - Inclui desvio padrão de POF
   - Quebra de KM por tecnologia (mini, midi, básico, padrão)

### 3.3 Fluxo Lógico Completo (Simplificado)

```
Dados Brutos (BigQuery)
    ├── GPS Ônibus (onibus_gps)
    ├── Transações Bilhetagem (transacao, transacao_riocard)
    ├── Licenciamento/Infrações (sppo_licenciamento_stu, sppo_infracao)
    ├── GTFS (shapes, trips, stop_times) - Planejamento
    └── Ordens de Serviço (ordem_servico_*) - Determinação
          ↓
    [MODELOS INTERMEDIÁRIOS - subsidio/]
          ↓
    viagem_classificada → Define tecnologia, sentido
          ↓
    viagem_transacao → Valida bilhetagem
          ↓
    viagem_regularidade_temperatura → Valida climatização
          ↓
    percentual_operacao_faixa_horaria → Calcula POF
          ↓
    [SUMÁRIOS FINAIS - dashboard_subsidio_sppo_v2/]
          ↓
    sumario_faixa_servico_dia_pagamento
          ↓
    → VALOR_A_PAGAR (por serviço/dia/faixa)
```

---

## 4. Orquestração Prefect - Fluxos de Execução

### 4.1 Flow Principal: `subsidio_sppo_apuracao`

Localização: `pipelines/migration/projeto_subsidio_sppo/flows.py`

**Características:**
- **Agendamento:** Diariamente às 07:05 (`every_day_hour_seven_minute_five`)
- **Imagem Docker:** Definida em `constants.DOCKER_IMAGE`
- **Executado em:** Kubernetes (GCP)

**Fases de Execução:**

1. **Setup**
   - Determina range de datas (padrão: D-7 a D-7)
   - Obtém versão do dataset (SHA git)

2. **Materialização de Dados Prerequisitos**
   - Trigger opcional de `sppo_veiculo_dia` (dados de veículos)
   - Checagem de gaps na captura Jaé (bilhetagem)

3. **Pre-Data Quality Check** (Controlado por `skip_pre_test`)
   - Executa testes em: `transacao`, `transacao_riocard`, `gps_validador`
   - Envia alertas para Discord em caso de falha
   - Valida consistência dos dados de entrada

4. **Cálculo (Branching por Versão)**
   - **Se data < V9 (2024-08-16):**
     - Executa seletor `apuracao_subsidio_v8`
     - Testa `dashboard_subsidio_sppo`
   - **Se data >= V9 e < V14:**
     - Executa seletor `apuracao_subsidio_v9`
     - Roda `monitoramento_subsidio`
     - Testa `dashboard_subsidio_sppo_v2`
   - **Se data >= V14 (2025-01-05):**
     - Executa seletor `apuracao_subsidio_v9`
     - Testa especificamente modelos V14

5. **Snapshots**
   - Captura estado histórico com `snapshot_subsidio`

6. **Post-Data Quality Check**
   - Valida resultados finais
   - Envia relatório para Discord

### 4.2 Flow Secundário: `viagens_sppo`

**Função:** Processar dados de viagens (pré-requisito para subsídio)
**Agendamento:** Diariamente às 05:00 e 14:00
**Modelos Executados:** GPS, trajetos, conformidade

---

## 5. Pontos de Auditoria Críticos

### 5.1 Classificações que Impactam Pagamento

**A. Veículos Glosados (Não Pagos)**

1. **Não Licenciado** (`n_licenciado`)
   - Origem: `veiculo/sppo_licenciamento_stu`
   - Lógica: Licença vencida ou inexistente
   - Versão: Desde V9A (2024-09-01) - desconsiderado do KM

2. **Não Vistoriado** (`n_vistoriado`)
   - Origem: `veiculo/sppo_licenciamento_stu`
   - Lógica: Vistoria com validade expirada (> 1 ano)
   - Tolerância: 15 dias para veículos novos
   - Versão: Desde V5 (2024-03-01)

3. **Sem Transação** (`sem_transacao`)
   - Origem: `viagem_transacao.sql`
   - Lógica: Viagem sem validação de bilhetagem (RioCard ou Jaé)
   - Exceções: Eleições, eventos especiais
   - Versão: Desde V8 (2024-07-20)

**B. Autuações (Penalizações)**

1. **Autuado por Ar Inoperante** (`autuado_ar_inoperante`)
   - Origem: `veiculo/sppo_infracao`
   - Base Legal: DECRETO RIO 51940/2023
   - Versão: Desde V2 (2023-01-16)

2. **Autuado por Segurança** (`autuado_seguranca`)
   - Origem: `veiculo/sppo_infracao`
   - Base Legal: DECRETO RIO 52820/2023
   - Versão: Desde V3 (2023-07-04)

3. **Autuado por Limpeza/Equipamento** (`autuado_limpezaequipamento`)
   - Origem: `veiculo/sppo_infracao`
   - Base Legal: DECRETO RIO 52820/2023
   - Versão: Desde V3 (2023-07-04)

4. **Penalidade por Faixa Horária** (V14+)
   - Origem: `percentual_operacao_faixa_horaria`
   - Lógica: POF < 100% gera penalização proporcional

**C. Tecnologia Remunerada**

- Modelo: `viagem_classificada.sql`
- Lógica:
  - V15+: Pode ser diferente da tecnologia apurada
  - V16+ (2025-07-01): Tecnologia inferior à mínima não é paga
  - V19+ (2025-11-01): Licenciado sem ar-condicionado não é pago

### 5.2 Testes de Qualidade (dbt tests)

**Pré-Execução (Pre-Tests):**
- Verificação de gaps na captura Jaé
- Validação de nulos em colunas críticas
- Unicidade de chaves primárias

**Pós-Execução (Post-Tests):**
- Consistência entre `viagem_classificada` e `viagem_regularidade_temperatura`
- Validação de partidas planejadas vs. Ordem de Serviço
- Ranges de valores esperados (km, valores monetários)

### 5.3 Macros SQL de Interesse

Localização: `queries/macros/`

**Principais:**
- `generate_km_columns`: Gera colunas dinâmicas de KM por categoria
- `custom_get_where_subquery.sql`: Controla partições para testes
- Macros de validação customizadas (a serem exploradas)

---

## 6. Análise de Versões e Reversões

> **Nota:** Análises jurídicas detalhadas sobre padrões de reversão da SMTR estão disponíveis localmente no arquivo `ANALISE_JURIDICA_SMTR.md` (não versionado no GitHub).

### 6.1 Histórico de Versões do Subsídio

O sistema evoluiu através de múltiplas versões, algumas com características temporárias:

| Versão | Data Início | Característica | Status |
|--------|-------------|----------------|--------|
| **V22** | 16/10/2025 | Suspensão temporária glosas climatização | **REVERTIDA** 29/12/2025 |
| **V21** | 01/10/2025 | Mudanças em validadores | Ativa |
| **V20** | 16/08/2025 | Inciso IV Climatização | Ativa |
| **V19** | 01/11/2025 | Não pagamento sem ar condicionado | Ativa |
| **V17** | 16/07/2025 | Regularidade de temperatura | Ativa |
| **V15** | 01/04/2025 | Acordo judicial | Substituída |

### 6.2 Lições Aprendidas

- Algumas versões são implementadas como "temporárias" e depois revertidas
- É importante documentar todas as versões para rastreabilidade
- Mudanças temporárias podem ter impacto retroativo

---

## 7. Evolução Recente (Últimos Commits)

### 6.1 Refatoração Crítica: Cálculo de Integrações

**Commit:** `c567adac - Altera cálculo de integrações na tabela integracao_nao_realizada (#793)`

**Mudança:** Substituição completa da lógica SQL por PySpark

**Novos Componentes:**
- `aux_calculo_integracao.py`: Script PySpark que itera transações de cliente
- `aux_transacao_filtro_integracao_calculada.sql`: Prepara dados para Spark
- `aux_integracao_calculada.sql`: Consolida resultados

**Impacto:** Alto - Altera forma de calcular integrações entre viagens, afetando remuneração

### 6.2 Aumento de Cobertura de Testes

**PR #783:** Adição massiva de testes em modelos de bilhetagem
- Dezenas de testes `not_null` e `unique`
- Validações em `transacao.sql`, `ordem_pagamento.sql`
- Aumento de confiabilidade nos dados de entrada

### 6.3 Validação de Partidas Planejadas

**Commit:** `d4154835`
- Novo teste: `check_partidas_planejadas.sql`
- Valida GTFS contra Ordem de Serviço
- Pode invalidar viagens inconsistentes

---

## 10. Matriz de Integração Tarifária - Bilhete Único

### 10.1 Visão Geral do Sistema

O sistema de **Bilhete Único** do Rio de Janeiro permite que passageiros realizem múltiplas viagens pagando uma única tarifa. O cálculo de integrações é feito através de um pipeline complexo que envolve modelos SQL e um script PySpark.

### 10.2 Fluxo de Dados da Integração

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    PIPELINE DE INTEGRAÇÃO TARIFÁRIA                         │
└─────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────┐
│  SOURCE: SMTR        │
│  (Dados Brutos)      │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│  MODELO: tarifa_publica.sql (NOVO - PR #1162)                               │
│  ─────────────────────────────────────────────────                           │
│  • Define valor da tarifa pública por período                               │
│  • Histórico: R$ 4,30 (2023) → R$ 4,70 (2025) → R$ 5,00 (2026)              │
│  • Usado como base para valor_integracao                                    │
└──────────────────────────────────────────────────────────────────────────────┘
           │
           ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│  MODELO: matriz_reparticao_tarifaria.sql                                    │
│  ─────────────────────────────────────────────                               │
│  • Define a sequência de modos permitidos (ex: Ônibus-Ônibus, Ônibus-Metrô) │
│  • Define percentuais de rateio por perna (ex: 50%-50%, 60%-40%)            │
│  • Define tempo máximo de integração em minutos                             │
│  • Source: source_smtr.matriz_reparticao_tarifaria                          │
└──────────────────────────────────────────────────────────────────────────────┘
           │
           ├──────────────────────────────────────────────┐
           │                                              │
           ▼                                              ▼
┌─────────────────────────────────┐    ┌─────────────────────────────────────┐
│ aux_matriz_integracao_modo.sql  │    │  aux_matriz_transferencia.sql       │
│ ─────────────────────────────── │    │  ─────────────────────────────────  │
│ • Integrações entre modos       │    │  • Transferências específicas       │
│ • Ex: Ônibus → Ônibus           │    │  • Serviços específicos origem/dest │
│ • Usa tarifa_publica para valor │    │  • Usa tarifa_publica para valor    │
└─────────────────────────────────┘    └─────────────────────────────────────┘
           │                                              │
           └──────────────────────┬───────────────────────┘
                                  │
                                  ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│  MODELO: matriz_integracao.sql (CENTRAL)                                     │
│  ─────────────────────────────────────                                        │
│  • Une: integrações regulares + transferências + exceções                    │
│  • Fontes:                                                                   │
│    - aux_matriz_integracao_modo (integrações por modo)                      │
│    - aux_matriz_transferencia (transferências específicas)                   │
│    - source_smtr.matriz_integracao_excecao (exceções manuais)                │
│  • Output: Tabela particionada por data_inicio                               │
│  • Colunas principais:                                                       │
│    - modo_origem, modo_destino                                              │
│    - id_servico_jae_origem, id_servico_jae_destino                          │
│    - tempo_integracao_minutos                                               │
│    - valor_integracao (R$ 5,00 atual)                                       │
│    - tipo_integracao: "Integração" ou "Transferência"                       │
└──────────────────────────────────────────────────────────────────────────────┘
                                  │
                                  ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│  MODELO: aux_transacao_filtro_integracao_calculada.sql                       │
│  ─────────────────────────────────────────────────────────                   │
│  • Prepara transações para cálculo de integração                            │
│  • Join com tarifa_publica para obter valor_tarifa                          │
│  • Classifica modo_join (SPPO, BRT, BRT ESP, Van, Ônibus)                   │
│  • Filtra: tipo_transacao != 'Gratuidade' e tipo_transacao_jae != 'Botoeira'│
└──────────────────────────────────────────────────────────────────────────────┘
                                  │
                                  ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│  SCRIPT PySpark: aux_calculo_integracao.py                                   │
│  ────────────────────────────────────────────                                │
│  • Lógica principal de cálculo de integração                                │
│  • Processa transações agrupadas por cliente_cartao                          │
│  • Itera sobre transações ordenadas por datetime_transacao                  │
│                                                                              │
│  ALGORITMO:                                                                  │
│  1. Para cada cliente, ordena transações por horário                        │
│  2. Primeira transação = "Primeira perna"                                   │
│  3. Para transações subsequentes:                                           │
│     a. Verifica se é TRANSFERÊNCIA (serviço diferente, dentro do tempo)     │
│     b. Verifica se é INTEGRAÇÃO (modo compatível, dentro do tempo)          │
│     c. Se não for integração → nova "Primeira perna"                        │
│  4. Calcula tempo entre transações vs. tempo_integracao_minutos             │
│  5. Consulta matriz_integracao para validar regras                          │
│                                                                              │
│  OUTPUT:                                                                     │
│  • id_integracao: ID da primeira transação do grupo                         │
│  • sequencia_integracao: 1, 2, 3...                                         │
│  • tipo_integracao: "Primeira perna", "Integração", "Transferência"         │
│  • datetime_inicio_integracao: horário da primeira perna                    │
└──────────────────────────────────────────────────────────────────────────────┘
                                  │
                                  ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│  MODELOS FINAIS                                                              │
│  ─────────────────                                                           │
│  • integracao_invalida.sql: Transações que falharam na integração           │
│  • Usado para validação e monitoramento                                     │
└──────────────────────────────────────────────────────────────────────────────┘
```

### 10.3 Componentes Principais

#### A. Tabela de Tarifas (`tarifa_publica.sql`)

**Criada no PR #1162 (13/01/2026)**

```sql
-- Histórico de tarifas
| data_inicio | data_fim    | valor_tarifa | legislacao                    |
|-------------|-------------|--------------|-------------------------------|
| 2023-01-07  | 2025-01-04  | R$ 4,30      | DECRETO RIO Nº 51914/2023     |
| 2025-01-05  | 2026-01-03  | R$ 4,70      | DECRETO RIO Nº 55631/2025     |
| 2026-01-04  | (atual)     | R$ 5,00      | DECRETO RIO Nº 57473/2025     |
```

#### B. Matriz de Repartição Tarifária

Define como o valor da integração é dividido entre as empresas:

| Integração | Sequência de Modos | Rateio |
|------------|-------------------|--------|
| Ônibus-Ônibus | [Ônibus, Ônibus] | [50%, 50%] |
| Ônibus-Ônibus-Ônibus | [Ônibus, Ônibus, Ônibus] | [33%, 33%, 34%] |
| Ônibus-BRT | [Ônibus, BRT] | [50%, 50%] |

#### C. Regras de Integração

**Tipos de Integração:**

1. **Integração** (`tipo_integracao = "Integração"`)
   - Entre modos diferentes (Ônibus → BRT, Ônibus → Van)
   - Dentro do tempo máximo definido
   - Valor: R$ 5,00 (tarifa única)

2. **Transferência** (`tipo_integracao = "Transferência"`)
   - Entre serviços específicos
   - Serviço de origem ≠ Serviço de destino
   - Regras específicas por serviço

3. **Exceções** (`source_smtr.matriz_integracao_excecao`)
   - Casos especiais definidos manualmente
   - Podem sobrescrever regras gerais

### 10.4 Tempo de Integração

O tempo máximo para integração é definido em `tempo_integracao_minutos` na matriz. O script PySpark calcula:

```python
tempo_integracao = (
    datetime.fromisoformat(datetime_transacao)
    - datetime.fromisoformat(datetime_inicio_integracao)
).total_seconds() / 60
```

Se `tempo_integracao <= tempo_integracao_minutos`, a integração é válida.

### 10.5 Classificação de Modos

O campo `modo_join` é usado para matching na matriz:

```sql
case
    when modo = 'Van' then consorcio
    when modo = 'Ônibus' and not (serviço especial) then 'SPPO'
    when modo = 'BRT' and tarifa > tarifa_publica then 'BRT ESP'
    else modo
end as modo_join
```

### 10.6 Impacto da Atualização de Tarifa

Com o aumento para R$ 5,00 (PR #1162):

1. **Valor da integração** passou de R$ 4,70 para R$ 5,00
2. A tabela `tarifa_publica` é consultada via JOIN em:
   - `aux_matriz_integracao_modo.sql`
   - `aux_matriz_transferencia.sql`
   - `aux_transacao_filtro_integracao_calculada.sql`
3. O valor é automaticamente propagado para `valor_integracao` na matriz

### 10.7 Fluxo de Execução

```
1. transacao.sql (dados brutos de transações)
        ↓
2. aux_transacao_filtro_integracao_calculada.sql (prepara dados)
        ↓
3. aux_calculo_integracao.py (PySpark - cálculo iterativo)
        ↓
4. aux_integracao_calculada.sql (consolida resultados)
        ↓
5. integracao_invalida.sql (validação)
```

---

## 11. Análise de Impacto - Atualização Fevereiro 2026

### 10.1 Resumo de Impacto Financeiro

| Mudança | Direção | Magnitude | Período Afetado |
|---------|---------|-----------|-----------------|
| Aumento tarifa (R$ 5,00) | ↑ Favorável empresas | ~6,4% | A partir de 04/01/2026 |
| Extensão prazo vistoria | ↑ Favorável empresas | Médio | Janeiro/2026 |
| Exceções limite viagens | ↑ Favorável empresas | Alto (19 serviços) | 01-15/01/2026 |
| Remoção acréscimo 4% RioCard | ↓ Desfavorável empresas | ~4% redução | Permanente |
| Plano Verão (novas datas) | ↔ Neutro | Operacional | Janeiro-Fevereiro/2026 |

### 10.2 Análise Detalhada por Mudança

#### A. Aumento de Tarifa (PR #1162)

**Contexto:**
A tarifa pública foi aumentada de R$ 4,70 para R$ 5,00 via Decreto Rio Nº 57473/2025. Foi criada uma nova tabela `tarifa_publica.sql` que mantém o histórico de tarifas desde 2023.

**Impacto no Subsídio:**
- Aumento de 6,38% no valor da tarifa
- Afeta diretamente o cálculo de integrações e matriz de repartição tarifária
- Modelo `matriz_integracao.sql` foi atualizado para usar a nova tabela

**Risco:** Baixo. Mudança normativa esperada e documentada.

---

#### B. Extensão do Prazo de Vistoria (PR #1183)

**Contexto:**
A Resolução SMTR Nº 3894 estendeu o prazo de vistoria até 31/01/2026, permitindo que veículos com vistoria de até 2 anos sejam considerados regulares durante janeiro/2026.

**Impacto no Subsídio:**
- Veículos que seriam glosados por "não vistoriados" em janeiro/2026 passam a ser considerados regulares
- Redução temporária de glosas por vistoria

**Risco:** Médio. Extensão temporária que pode não ser renovada em fevereiro.

---

#### C. Exceções de Limite de Viagens (PR #1195)

**Contexto:**
Processo administrativo n° 000300.001720/2026-55 determina que 19 serviços específicos tenham exceção no limite de viagens entre 01-15 de janeiro de 2026.

**Serviços Beneficiados:**
```
104, 107, 109, 161, 167, 169, 409, 410, 435, 473, 
583, 584, LECD127, LECD128, 552, SP805, 361, LECD129, 232
```

**Impacto no Subsídio:**
- Viagens acima do limite nestes serviços não são glosadas
- Aumento de remuneração para estes serviços específicos

**Risco:** Alto. Cria precedente para exceções pontuais por processo administrativo.

---

#### D. Remoção do Acréscimo de 4% RioCard (PR #1185)

**Contexto:**
Anteriormente, transações RioCard recebiam um acréscimo de 4% no valor de pagamento (`valor_pagamento / 0.96`). Este acréscimo foi removido.

**Código Anterior:**
```sql
) / 0.96 as valor_pagamento,  -- acréscimo de ~4,17%
```

**Código Atual:**
```sql
) as valor_pagamento,  -- sem acréscimo
```

**Impacto no Subsídio:**
- Redução de aproximadamente 4% nos valores de transações RioCard
- Afeta o modelo `aux_passageiro_hora.sql`
- Pode impactar cálculos de passageiros transportados

**Risco:** Alto. Mudança que reduz valores reportados, sem clara justificativa normativa.

---

#### E. Plano Verão - Novas Datas (PR #1203)

**Contexto:**
O "Plano Verão" teve novas datas adicionadas:
- 17-18/01/2026 (Processo: 000399.000456/2026-91)
- 31/01-01/02/2026 (Processo: 000399.001025/2026-41)

**Impacto no Subsídio:**
- Nestas datas, o tipo_os = "Verão" com regras operacionais diferenciadas
- Pode afetar ordens de serviço e planejamento de viagens

**Risco:** Baixo. Mudança operacional esperada para período de verão.

---

### 10.3 Padrões Identificados

#### Padrão de "Exceções Pontuais"

Observa-se um padrão de criação de exceções pontuais via processos administrativos:
1. **Processo 000300.001720/2026-55:** Exceção limite viagens
2. **Processo 000399.000456/2026-91:** Plano Verão 17-18/01
3. **Processo 000399.001025/2026-41:** Plano Verão 31/01-01/02

Isso sugere uma estratégia de flexibilização pontual sem alterar regras permanentes.

#### Padrão de "Correções Silenciosas"

A remoção do acréscimo de 4% nas transações RioCard foi feita sem grande alarde, mas representa uma redução significativa nos valores reportados.

---

### 10.4 Recomendações

1. **Monitorar** se a extensão de prazo de vistoria será renovada para fevereiro/2026
2. **Documentar** os processos administrativos que geram exceções
3. **Investigar** a justificativa para remoção do acréscimo de 4% RioCard
4. **Acompanhar** se novas datas de Verão serão adicionadas
5. **Verificar** impacto financeiro real da remoção do acréscimo 4%

---

## 12. Glossário de Termos

- **SPPO:** Serviço Público de Transporte de Passageiros por Ônibus
- **SMTR:** Secretaria Municipal de Transportes
- **POF:** Percentual de Operação por Faixa Horária
- **GTFS:** General Transit Feed Specification (planejamento operacional)
- **OS:** Ordem de Serviço (determinação contratual)
- **Jaé:** Sistema de bilhetagem eletrônica
- **RioCard:** Sistema de bilhetagem por cartão
- **Glosa:** Desconto/penalização no valor a pagar
- **Apuração:** Cálculo do valor devido
- **Conformidade:** Aderência aos requisitos (GPS, transação, etc.)
- **Vistoria:** Inspeção periódica obrigatória de veículos
- **Licenciamento:** Autorização para operar (similar a licenciamento veicular)

---

## 8. Próximos Passos para Auditoria

### 8.1 Análises Recomendadas

1. **Rastreamento de Linhagem (Lineage)**
   - Mapear todas as dependências de `sumario_servico_dia_pagamento.sql`
   - Criar diagrama de fluxo de dados

2. **Análise Comparativa de Versões**
   - Documentar diferenças exatas entre V14, V15, V16, V17
   - Quantificar impacto financeiro de cada mudança

3. **Validação de Limiares**
   - Analisar sensibilidade dos parâmetros em `dbt_project.yml`
   - Simular impacto de mudanças em `conformidade_*_min`

4. **Auditoria do Script PySpark**
   - Revisar `aux_calculo_integracao.py` linha por linha
   - Validar lógica de matriz de integração

5. **Monitoramento de Mudanças**
   - Configurar alertas para commits que alterem:
     - `dbt_project.yml` (variáveis de subsídio)
     - Modelos em `subsidio/` e `dashboard_subsidio_sppo_v2/`
     - Flows de apuração em Prefect

### 8.2 Perguntas a Investigar

- Como exatamente o valor de `valor_a_pagar` é calculado?
- Qual o peso de cada penalização no valor final?
- Como são tratadas as exceções (eleições, eventos)?
- Qual o percentual médio de glosas por categoria?
- Há backdoors ou condições especiais não documentadas?

---

## 9. Histórico de Atualizações deste Documento

| Data | Descrição |
|------|-----------|
| 2025-11-28 | Criação inicial - Estado as-is do repositório (commit `f9f4f3ff`) |
| 2025-11-28 | **ATUALIZAÇÃO: 139 commits do upstream** - Análise completa em `CHANGELOG_2025-11-28.md` |
|  | • Novas versões: **V21** (01/10/2025) e **V22** (16/10/2025) |
|  | • **CRÍTICO: V22 suspende TODAS as glosas por climatização** |
|  | • Novos tipos de dia: ENEM, dias atípicos |
|  | • Operação Lago Limpo: modelos deprecated desabilitados |
|  | • Integração com AlertaRio para dados de temperatura |
|  | • Novos testes de qualidade e validação |
| 2026-01-12 | **ATUALIZAÇÃO: 28 commits do upstream** - Reversão da V22 |
|  | • **CRÍTICO: V22 REVERTIDA** - Glosas por climatização reativadas |
|  | • Aumento de tarifa de integração (R$ 4,70 → R$ 5,00) |
| 2026-02-14 | **ATUALIZAÇÃO: 28 novos commits do upstream** (commit `56971229e`) |
|  | • **AUMENTO DE TARIFA CONFIRMADO:** R$ 5,00 a partir de 04/01/2026 |
|  | • **Extensão prazo vistoria:** Até 31/01/2026 (Resolução SMTR 3894) |
|  | • **Exceções limite viagens:** 19 serviços em janeiro/2026 |
|  | • **Plano Verão:** Novas datas 17-18/01 e 31/01-01/02/2026 |
|  | • **Remoção acréscimo 4% RioCard:** Impacto em transações |
|  | • Novo modelo `validador_operadora` para rastreamento |
|  | • Ajustes em `viagem_transacao` para viagens do dia anterior |
|  | • Correções em testes de temperatura |
|  | • Desativação de schedules GPS validador |

---

**Nota Final:** Este documento é vivo e deve ser atualizado a cada nova sincronização com o repositório upstream da Prefeitura. Toda mudança relevante deve ser documentada, analisada e seu impacto no cálculo de subsídio deve ser avaliado.
