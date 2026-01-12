# Sincronização Julho 2025 - Análise de 42 Commits

## Resumo da Sincronização

**Data**: 28/07/2025  
**Commits analisados**: 42 commits  
**Período**: Junho-Julho 2025  
**Status**: ✅ Concluída com sucesso

---

## 🚨 MUDANÇAS CRÍTICAS NO ALGORITMO DE SUBSÍDIOS

### 1. **Penalidade por Tecnologia Mínima (V15A) - CRÍTICO**

#### Commit: [`2fd5087f`](https://github.com/prefeitura-rio/pipelines_rj_smtr/commit/2fd5087f871bda1002d2966acc377487a5ca6431)

**Data**: 25/07/2025  
**Impacto**: 🔴 **ALTO - Mudança no pagamento**

##### Mudanças na Penalização V15A

- **Data de início**: `DATA_SUBSIDIO_V15A_INICIO: "2025-07-01"`
- **Penalização**: Veículos com tecnologia inferior à mínima **NÃO RECEBEM PAGAMENTO**
- **Lógica alterada** em [`viagem_classificada.sql`](queries/models/subsidio/viagem_classificada.sql:107):

```sql
when
    p.prioridade < p_menor.prioridade
    and data >= date('{{ var("DATA_SUBSIDIO_V15A_INICIO") }}')
then null  -- ← ZERO PAGAMENTO para tecnologia inferior
else vs.tecnologia
```

##### Impacto Operacional

- **Antes V15A**: Tecnologia inferior recebia pagamento com tecnologia mínima
- **Após V15A**: Tecnologia inferior = **VIAGEM NÃO REMUNERADA**
- **Risco**: Empresas podem parar de operar linhas com veículos antigos

---

### 2. **Acordo Judicial - Reformulação Completa (V15)**

#### Commit: [`3a93eea9`](https://github.com/prefeitura-rio/pipelines_rj_smtr/commit/3a93eea96b383e8a693cc82eb5c9696eaf44312f)

**Data**: 24/06/2025  
**Impacto**: 🔴 **ALTO - Reestruturação do sistema**

##### Novos Modelos Criados

###### **A. `percentual_operacao_faixa_horaria.sql`** - Substitui `subsidio_faixa_servico_dia`

- **Função**: Implementa item 6.1.7 do acordo judicial
- **Lógica**: Artigo 7 IV e Artigo 5 do acordo
- **Materialização**: Incremental com serviços do anexo II

###### **B. `servico_contrato_abreviado.sql`** - Nova tabela de serviços contratuais

- **153 linhas** de código
- **Serviços mapeados**: 731, 752, 765, 790, 826, 870, 936, etc.
- **Função**: Mapeia serviços conforme acordo judicial

##### Modelos Atualizados

###### **C. `viagem_transacao_aux.sql`** - Novos tipos de viagem

- **Jinja dinâmico** para gerar colunas conforme `tipo_viagem`
- **Melhorias**: Lógica de transações relacionadas à bilhetagem
- **Integração**: GPS Validador + Transações Jaé + RioCard

##### Snapshots

- **`snapshot_percentual_operacao_faixa_horaria.sql`** - Histórico de percentuais
- **Atualização**: Selector `snapshot_subsidio`

---

### 3. **Encontro de Contas V2 - Sistema Financeiro**

#### Commit: [`406ea529`](https://github.com/prefeitura-rio/pipelines_rj_smtr/commit/406ea529039e6be5f75b8804bf5ebaad93854292)

**Data**: 15/07/2025  
**Impacto**: 🟡 **MÉDIO - Controle financeiro**

##### Estrutura Criada

- **V1**: Modelos originais mantidos
- **V2**: Nova versão com melhorias

##### Novos Modelos V2

- `balanco_consorcio_ano.sql` - Balanço anual por consórcio
- `balanco_consorcio_mes.sql` - Balanço mensal por consórcio  
- `balanco_servico_quinzena.sql` - Balanço quinzenal por serviço
- `encontro_contas_subsidio_sumario_servico_dia.sql` - Sumário diário
- `receita_tarifaria_servico_dia_sem_associacao.sql` - Receitas não associadas

##### Impacto

- **Controle financeiro** aprimorado
- **Rastreabilidade** de receitas e despesas
- **Auditoria** facilitada

---

### 4. **Modelo `viagem_classificada` - Nova Classificação**

#### Commit: [`8b146f77`](https://github.com/prefeitura-rio/pipelines_rj_smtr/commit/8b146f7785e222490ec263595e59768026696af3)

**Data**: 09/07/2025  
**Impacto**: 🟡 **MÉDIO - Melhoria na classificação**

##### Funcionalidades

- **292 linhas** de código SQL complexo
- **Classificação avançada** de viagens por:
  - Tecnologia apurada vs. remunerada
  - Status operacional do veículo
  - Autuações disciplinares
  - Indicadores de penalidade

##### Integração

- **`viagem_completa`** - Dados de viagens
- **`aux_veiculo_dia_consolidada`** - Status dos veículos
- **`autuacao_disciplinar_historico`** - Penalidades
- **`tecnologia_servico`** - Requisitos tecnológicos

---

## 🔧 MUDANÇAS OPERACIONAIS SIGNIFICATIVAS

### 5. **Desativação GPS Zirix**

#### Commit: [`1276a147`](https://github.com/prefeitura-rio/pipelines_rj_smtr/commit/1276a1479ec0b864dfc9ed5ec0ed6679beaba0f5)

**Data**: 24/07/2025
**Impacto**: 🟡 **MÉDIO - Mudança de fonte**

##### Mudança

- **Flows GPS Zirix**: Desativados completamente
- **Arquivo afetado**: `pipelines/migration/br_rj_riodejaneiro_onibus_gps_zirix/flows.py`
- **Fonte principal**: Conecta (mantida como única fonte)
- **Impacto**: Redução de fontes de dados GPS, simplificação da arquitetura

---

### 6. **Registro de Flows - Padronização**

#### Commits Relacionados

- **[`161e1fe8`](https://github.com/prefeitura-rio/pipelines_rj_smtr/commit/161e1fe86323e169336ec3a24aba6d9a87ddec46)** - Registra flow do subsídio (10/07/2025)
- **[`3473764c`](https://github.com/prefeitura-rio/pipelines_rj_smtr/commit/3473764c8c37efa2b1bb2bb613dd81cf7c0462f9)** - Registra flows bilhetagem (04/07/2025)

##### Mudanças na Padronização

- **Padronização**: Registro sistemático de flows nos módulos
- **Arquivos afetados**:
  - `pipelines/migration/projeto_subsidio_sppo/flows.py`
  - `pipelines/treatment/bilhetagem/flows.py`
- **Benefício**: Melhor rastreabilidade e controle de execuções

---

### 7. **Atualização Flow de Viagens**

#### Commit: [`1ee293f7`](https://github.com/prefeitura-rio/pipelines_rj_smtr/commit/1ee293f774050ba050d6e34624beb40bab8a6818)

**Data**: 22/07/2025
**Impacto**: 🟡 **MÉDIO - Melhoria operacional**

##### Mudanças na Refatoração de Viagens

- **Refatoração**: `viagem_planejada` com versões V1 e V2
- **Arquivos afetados**:
  - `pipelines/migration/projeto_subsidio_sppo/flows.py`
  - `pipelines/schedules.py`
  - `queries/models/projeto_subsidio_sppo/viagem_planejada.sql`
  - `queries/models/projeto_subsidio_sppo/staging/viagem_planejada_v1.sql`
  - `queries/models/projeto_subsidio_sppo/staging/viagem_planejada_v2.sql`

##### Benefícios da Refatoração

- **Versionamento**: Controle de versões para viagens planejadas
- **Flexibilidade**: Suporte a diferentes formatos de dados
- **Manutenção**: Facilita atualizações futuras

---

### 8. **Refatoração de Pipelines - Task Genérica dbt**

#### Commit: [`c3c4e9ad`](https://github.com/prefeitura-rio/pipelines_rj_smtr/commit/c3c4e9ade649a71dbf0298a67efeb3dfb84b5485)

**Data**: 21/07/2025  
**Impacto**: 🟢 **BAIXO - Melhoria técnica**

##### Mudanças na Task dbt

- **DRY Principle**: Eliminação de código duplicado
- **Task unificada**: `run_dbt` substitui múltiplas funções
- **Módulos afetados**:
  - `projeto_subsidio_sppo/flows.py`
  - `br_rj_riodejaneiro_gtfs/flows.py`
  - `br_rj_riodejaneiro_onibus_gps/flows.py`
  - `veiculo/flows.py`

##### Benefícios da Task Genérica

- **Manutenção** simplificada
- **Consistência** entre pipelines
- **Redução de bugs** por padronização

---

## 📊 NOVAS VERSÕES DE SUBSÍDIO IDENTIFICADAS

### Cronologia Atualizada

| Versão | Data Início | Descrição | Status |
|--------|-------------|-----------|---------|
| **V15** | 2025-04-01 | Acordo Judicial | ✅ Ativo |
| **V15A** | 2025-07-01 | Penalidade tecnologia mínima | ✅ **NOVO** |
| **V15B** | 2025-08-01 | Validadores Jaé | 🔄 Planejado |
| **V15C** | 2025-11-01 | Ar-condicionado obrigatório | 🔄 Planejado |

---

## 🚨 ALERTAS E PREOCUPAÇÕES

### 1. **Transparência Comprometida** (Mantida)

- **Google Drive**: Dados de fiscalização ainda privados
- **Planilha**: `1LTyNe2_AgWR0JlCmUOYGtYKpe33w57hslkMkrUqYPbw`
- **Status**: ❌ **NÃO RESOLVIDO**

### 2. **Penalização Injusta V15A** (Nova)

- **Problema**: Tecnologia inferior = zero pagamento
- **Impacto**: Empresas podem parar operação
- **Risco**: Colapso de linhas com frota antiga
- **Status**: ❌ **CRÍTICO**

### 3. **Complexidade Crescente**

- **Modelos**: Cada vez mais complexos
- **Dependências**: Múltiplas fontes de dados
- **Manutenção**: Dificuldade crescente
- **Status**: ⚠️ **ATENÇÃO**

---

## 📈 ESTATÍSTICAS DA SINCRONIZAÇÃO

### Arquivos Modificados

- **Total**: 100+ arquivos
- **Modelos SQL**: 25+ novos/alterados
- **Pipelines Python**: 15+ flows atualizados
- **Schemas**: 10+ documentações atualizadas

### Linhas de Código

- **Adicionadas**: ~2.000+ linhas
- **Removidas**: ~500+ linhas
- **Modificadas**: ~1.500+ linhas

### Domínios Impactados

1. **Subsídio** - Mudanças críticas
2. **Financeiro** - Encontro de contas V2
3. **Bilhetagem** - Integração Jaé/RioCard
4. **Veículos** - Classificação tecnológica
5. **Monitoramento** - GPS e operações

---

## 🎯 PRÓXIMOS PASSOS RECOMENDADOS

### Monitoramento Urgente

1. **V15A**: Acompanhar impacto na operação (julho/2025)
2. **Transparência**: Pressionar por dados públicos
3. **Complexidade**: Documentar dependências críticas

### Vigilância Contínua

1. **V15B/V15C**: Preparar para próximas mudanças
2. **Encontro de contas**: Validar cálculos financeiros
3. **Pipelines**: Monitorar estabilidade pós-refatoração

---

**Sincronização realizada por**: Kilo Code  
**Última atualização**: 28/07/2025 09:11 AM (UTC-3)
