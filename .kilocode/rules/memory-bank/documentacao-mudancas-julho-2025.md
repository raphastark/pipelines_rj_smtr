# Sincronização Julho 2025 - Documentação Consolidada

Data: 28/07/2025  
Período coberto: Junho–Julho/2025
> **Nota**: Para atualizações a partir de agosto de 2025, consulte a documentação mais recente em [`sincronizacao_agosto_2025.md`](sincronizacao_agosto_2025.md).

Status: ✅ Consolidado no memory bank

---

## 🚨 Mudanças Críticas no Algoritmo de Subsídios

### 1) Novo Modelo Central POF

Arquivo: [`queries/models/subsidio/percentual_operacao_faixa_horaria.sql`](queries/models/subsidio/percentual_operacao_faixa_horaria.sql:1)

Resumo
- Substitui totalmente o modelo anterior `subsidio_faixa_servico_dia`
- Materialização incremental com estratégia insert_overwrite
- Particionado por data (granularidade diária)
- Campo pof centralizado (fonte única de verdade)

Impacto
- Elimina divergências entre dashboards
- Unifica regras versionadas (pré-V15 vs V15+)
- Base de consumo para modelos dependentes (sumários, apuração)

Pontos de atenção técnicos
- Exclusões no POF prévias à V15: "Não licenciado", "Não vistoriado"
- Exclusões adicionais a partir da V15: "Lacrado", "Não autorizado por ausência de ar-condicionado"
- Risco de aplicação retroativa se filtros de data não forem cuidadosamente condicionados

Modelos impactados (exemplos)
- sumário histórico: consumo filtrado por datas anteriores à V14
- sumário atual (V14+): consumo a partir da V14
- tipificação por tipo de viagem: passa a consumir o modelo central

Snapshot de auditoria
- Arquivo: [`queries/snapshots/subsidio/snapshot_percentual_operacao_faixa_horaria.sql`](queries/snapshots/subsidio/snapshot_percentual_operacao_faixa_horaria.sql:1)
- Estratégia: timestamp-based
- Chave única: concat(data, '-', faixa_horaria_inicio, '-', servico)
- Objetivo: trilha imutável de alterações do POF

Conclusão técnica
- Modernização arquitetural crítica, com centralização, versionamento e auditabilidade reforçada

---

### 2) Penalidade V15A: Tecnologia Mínima

Arquivo: [`queries/models/subsidio/viagem_classificada.sql`](queries/models/subsidio/viagem_classificada.sql:107)

Regra
- Início: 2025-07-01 (var DATA_SUBSIDIO_V15A_INICIO)
- Veículos com tecnologia inferior à mínima: viagem não remunerada (pagamento nulo)

Trecho de lógica relevante
- Referência ao ponto da regra de prioridade tecnológica que promove resultado nulo para tecnologia inferior após a data de vigência V15A

Impacto de negócio
- Antes: tecnologia inferior recebia com tecnologia mínima
- Depois: zero pagamento para tecnologia inferior
- Risco operacional: linhas com frota antiga podem ter desincentivo a operar

Alertas
- Penalização severa pode gerar disfunção operacional
- Necessário monitorar impacto na disponibilidade do serviço

---

## 🔧 Alterações Operacionais e de Orquestração

### 3) Integração Jaé (bilhetagem)

Módulo: pipelines de captura  
- Diretório: [`pipelines/capture/jae/flows.py`](pipelines/capture/jae/flows.py:1), [`pipelines/capture/jae/constants.py`](pipelines/capture/jae/constants.py:1)

Pontos principais
- Múltiplos bancos (MySQL/PostgreSQL) com domínios: transações, RioCard, tracking (GPS validadores), lançamentos, ressarcimentos, gratuidades e outros
- Frequências de captura diferenciadas: minuto a minuto (transações, tracking), a cada 10 min (retificações), horárias (auxiliares) e diárias (integrações/ordens)
- Verificações e monitoramento: checagem de IP, backups (BillingPay), verificação de captura, alertas (Discord)

Impacto
- Aumenta a cobertura e granularidade para classificação de viagens
- Eleva complexidade operacional e necessidade de monitoramento multi-conexão

Observação histórica
- Alteração estrutural de tracking (id → data_tracking em 26/03/2025) já absorvida no design

---

### 4) Desativação do GPS Zirix

Arquivo afetado: [`pipelines/migration/br_rj_riodejaneiro_onibus_gps_zirix/flows.py`](pipelines/migration/br_rj_riodejaneiro_onibus_gps_zirix/flows.py:1)

Resumo
- Flows de Zirix desativados
- Conecta mantida como principal fonte GPS

Impacto
- Simplificação arquitetural
- Redução de heterogeneidade na captura GPS

---

### 5) Padronização de Registro de Flows

Commits relevantes
- Registro sistemático em subsídio e bilhetagem
- Arquivos: [`pipelines/migration/projeto_subsidio_sppo/flows.py`](pipelines/migration/projeto_subsidio_sppo/flows.py:1), [`pipelines/treatment/bilhetagem/flows.py`](pipelines/treatment/bilhetagem/flows.py:1)

Benefícios
- Rastreabilidade de execuções
- Padrão unificado de exposição de flows

---

### 6) Refatoração de Viagens Planejadas (V1 e V2)

Arquivos
- [`queries/models/projeto_subsidio_sppo/viagem_planejada.sql`](queries/models/projeto_subsidio_sppo/viagem_planejada.sql:1)
- [`queries/models/projeto_subsidio_sppo/staging/viagem_planejada_v1.sql`](queries/models/projeto_subsidio_sppo/staging/viagem_planejada_v1.sql:1)
- [`queries/models/projeto_subsidio_sppo/staging/viagem_planejada_v2.sql`](queries/models/projeto_subsidio_sppo/staging/viagem_planejada_v2.sql:1)
- Flows/schedules associados: [`pipelines/migration/projeto_subsidio_sppo/flows.py`](pipelines/migration/projeto_subsidio_sppo/flows.py:1), [`pipelines/schedules.py`](pipelines/schedules.py:1)

Impacto
- Versionamento explícito para formatos distintos
- Facilidade de evolução e manutenção

---

### 7) Task genérica dbt (run_dbt)

Mudança
- Substitui funções duplicadas por task padronizada

Arquivos afetados (exemplos)
- [`pipelines/migration/projeto_subsidio_sppo/flows.py`](pipelines/migration/projeto_subsidio_sppo/flows.py:1)
- [`pipelines/migration/br_rj_riodejaneiro_gtfs/flows.py`](pipelines/migration/br_rj_riodejaneiro_gtfs/flows.py:1)
- [`pipelines/migration/br_rj_riodejaneiro_onibus_gps/flows.py`](pipelines/migration/br_rj_riodejaneiro_onibus_gps/flows.py:1)
- [`pipelines/migration/veiculo/flows.py`](pipelines/migration/veiculo/flows.py:1)

Benefícios
- DRY, consistência e redução de bugs

---

## 💰 Custos GCP e Logs BigQuery (Novo Domínio)

Domínio: infraestrutura

Modelos principais
- [`queries/models/infraestrutura/custo_cloud.sql`](queries/models/infraestrutura/custo_cloud.sql:1)
- [`queries/models/infraestrutura/log_bigquery.sql`](queries/models/infraestrutura/log_bigquery.sql:1)

Modelos auxiliares
- [`queries/models/infraestrutura/aux_preco_bigquery.sql`](queries/models/infraestrutura/aux_preco_bigquery.sql:1)

Pipeline
- [`pipelines/treatment/infraestrutura/`](pipelines/treatment/infraestrutura/:1)

Config/selector
- Selector: infraestrutura
- Variáveis: data_inicial_logs_bigquery, data_inicial_custo_cloud

Impacto
- Observabilidade de custos e execuções
- Otimização orientada por dados operacionais

---

## 🧮 Encontro de Contas V2

Versão
- Manutenção da V1 e introdução da V2 com aprimoramentos

Principais modelos V2
- [`queries/models/projeto_subsidio_sppo_encontro_contas/v2/balanco_consorcio_ano.sql`](queries/models/projeto_subsidio_sppo_encontro_contas/v2/balanco_consorcio_ano.sql:1)
- [`queries/models/projeto_subsidio_sppo_encontro_contas/v2/balanco_consorcio_mes.sql`](queries/models/projeto_subsidio_sppo_encontro_contas/v2/balanco_consorcio_mes.sql:1)
- [`queries/models/projeto_subsidio_sppo_encontro_contas/v2/balanco_servico_quinzena.sql`](queries/models/projeto_subsidio_sppo_encontro_contas/v2/balanco_servico_quinzena.sql:1)
- [`queries/models/projeto_subsidio_sppo_encontro_contas/v2/encontro_contas_subsidio_sumario_servico_dia.sql`](queries/models/projeto_subsidio_sppo_encontro_contas/v2/encontro_contas_subsidio_sumario_servico_dia.sql:1)
- [`queries/models/projeto_subsidio_sppo_encontro_contas/v2/receita_tarifaria_servico_dia_sem_associacao.sql`](queries/models/projeto_subsidio_sppo_encontro_contas/v2/receita_tarifaria_servico_dia_sem_associacao.sql:1)

Impacto
- Controle e rastreabilidade financeira superiores
- Melhor base para auditoria

---

## 🧪 Nova Classificação de Viagens

Arquivo: [`queries/models/subsidio/viagem_classificada.sql`](queries/models/subsidio/viagem_classificada.sql:1)

Destaques
- 290+ linhas de regras e integrações
- Classificação por tecnologia apurada vs. remunerada, status operacional, autuações disciplinares e penalidades
- Integra pontos de dados: viagem_completa, aux_veiculo_dia_consolidada, autuacao_disciplinar_historico, tecnologia_servico

Impacto
- Classificação mais granular e coerente com regras de negócio
- Base para aplicação de penalidades (incluindo V15A)

---

## ⚠️ Riscos e Preocupações

Transparência comprometida
- Módulo: [`pipelines/capture/veiculo_fiscalizacao/`](pipelines/capture/veiculo_fiscalizacao/:1)
- Fonte: Google Sheets privado (planilha id 1LTyNe2_AgWR0JlCmUOYGtYKpe33w57hslkMkrUqYPbw)
- Problema: dados que influenciam penalidades não são auditáveis publicamente
- Recomendação: fonte pública (CSV versionado, BigQuery público, Portal de Dados Abertos ou sheet público read-only)

Penalização V15A
- Severidade: alta (zero pagamento)
- Risco: desincentivo operacional em frotas com veículos antigos
- Ação: monitorar indicadores de disponibilidade e cobertura por serviço

Complexidade crescente
- Múltiplas fontes (Jaé + RioCard), versionamentos e regras por período
- Recomendação: documentação de dependências críticas, testes de regressão e monitoramento segmentado por domínio

Problemas operacionais Jaé
- Atualizações OTA sem janela protegida e sem piloto controlado
- Incidentes: validadores travando, linhas sumindo do menu, exigindo reboots
- Efeito colateral: falhas técnicas podem gerar “viagens não remuneradas”, agravadas pela regra V15A

---

## 📅 Linha do Tempo das Versões de Subsídio

- V15: 2025-04-01 – Acordo Judicial – ✅ Ativo
- V15A: 2025-07-01 – Penalidade por tecnologia mínima – ✅ Implementado
- V15B: 2025-08-01 – Validadores Jaé – 🔄 Planejado
- V15C: 2025-11-01 – Ar-condicionado obrigatório – 🔄 Planejado

---

## 📈 Estatísticas (Consolidadas)

- Commits analisados: 42  
- Arquivos modificados: 100+  
- Modelos SQL: 25+ novos/alterados  
- Pipelines Python: 15+ flows atualizados  
- Linhas: ~2.000+ adicionadas, ~500+ removidas, ~1.500+ modificadas

---

## ✅ Verificação de Fidedignidade

Conferido com:
- Guia geral de sincronização: [`sync-july-2025.md`](.kilocode/rules/memory-bank/sync-july-2025.md:1)
- Análise técnica do novo modelo: [`modelo-percentual_operacao_faixa_horaria.md`](.kilocode/rules/memory-bank/modelo-percentual-operacao-faixa-horaria.md:1)

Resultado
- Conteúdo fornecido estava essencialmente correto
- Ajustes aplicados: padronização editorial, referências clicáveis, organização por impactos e riscos
- Risco retroativo V15: mantido como alerta técnico; observar condicionais de data na derivação do POF

---

## 🎯 Recomendações

Imediatas
- Monitoramento dedicado ao modelo POF (SLO de disponibilidade e validade do particionamento)
- Validação histórica do POF (pré e pós migração centralizada)
- Observabilidade de efeitos V15A em disponibilidade por linha/serviço

Médio prazo
- Testes de regressão para regras versionadas
- Documentação operacional (runbooks) por domínio
- Plano de rollback para o modelo central POF

Transparência
- Migrar dados de fiscalização para fonte pública auditável
- Publicar critérios de lacre e histórico de alterações

---

## 📝 Conclusão

A centralização do POF e a introdução da penalidade V15A alteram substancialmente o comportamento de pagamento e a governança dos dados. A arquitetura tornou-se mais consistente e auditável, porém mais sensível a falhas do modelo central e a efeitos colaterais de mudanças operacionais de terceiros (Jaé). O sucesso depende de monitoramento específico, documentação de dependências, e medidas de transparência para dados que afetam penalidades contratuais.

— Kilo Code, 28/07/2025 09:32 (UTC-3)