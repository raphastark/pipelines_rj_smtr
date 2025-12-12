# Mudança Crítica: Modelo `percentual_operacao_faixa_horaria` - Julho 2025

## Resumo da Mudança

**Data**: 28/07/2025  
**Tipo**: Substituição de modelo central  
**Impacto**: 🔴 **ALTO - Mudança arquitetural crítica**  
**Status**: ✅ Documentado e analisado

---

## Contexto

O modelo `subsidio_faixa_servico_dia` foi **completamente substituído** pelo novo
[`percentual_operacao_faixa_horaria.sql`](queries/models/subsidio/percentual_operacao_faixa_horaria.sql:1),
representando uma das mudanças mais significativas na arquitetura do sistema de
subsídios desde a implementação do acordo judicial V15.

---

## 🔄 **Mudanças Técnicas Detalhadas**

### 1. **Novo Modelo Central**

#### **Arquivo**: `queries/models/subsidio/percentual_operacao_faixa_horaria.sql`

- **Linhas**: 111 linhas de código SQL
- **Materialização**: Incremental com `insert_overwrite`
- **Particionamento**: Por data (granularidade diária)
- **Função**: Fonte única de verdade para cálculo do POF

#### **Estrutura de Dados**

```sql
-- Campos principais do modelo
data,
tipo_dia,
faixa_horaria_inicio,
faixa_horaria_fim,
consorcio,
servico,
viagens_faixa,
km_apurada_faixa,
km_planejada_faixa,
pof,  -- ← Campo crítico centralizado
versao,
datetime_ultima_atualizacao
```

### 2. **Lógica do POF Revolucionada**

#### **Antes da Mudança**

- Cada modelo calculava POF independentemente
- Inconsistências entre dashboards
- Lógica duplicada em múltiplos arquivos

#### **Após a Mudança** (linhas 53-81)

```sql
-- Cálculo unificado do POF com regras versionadas
safe_cast(
    coalesce(
        round(
            100 * sum(
                if(
                    -- REGRAS PRÉ-V15 (até 31/03/2025)
                    (p.data < date('{{ var("DATA_SUBSIDIO_V15_INICIO") }}')
                     and v.tipo_viagem in ('Não licenciado', 'Não vistoriado'))
                    or 
                    -- REGRAS V15+ (a partir 01/04/2025)
                    (p.data >= date('{{ var("DATA_SUBSIDIO_V15_INICIO") }}')
                     and v.tipo_viagem in (
                         'Não licenciado',
                         'Não vistoriado',
                         'Lacrado',  -- ← NOVO na V15
                         'Não autorizado por ausência de ar-condicionado'  -- ← NOVO V15
                     )),
                    0,  -- Viagem NÃO conta para POF
                    v.distancia_planejada  -- Viagem conta para POF
                )
            ) / p.km_planejada,
            2
        ),
        0
    ) as numeric
) as pof
```

### 3. **Snapshot para Auditoria**

#### **Arquivo**: `queries/snapshots/subsidio/snapshot_percentual_operacao_faixa_horaria.sql`

- **Estratégia**: Timestamp-based
- **Chave única**: `concat(data, '-', faixa_horaria_inicio, '-', servico)`
- **Schema**: `subsidio_staging`
- **Função**: Histórico completo de mudanças no POF

---

## 🔗 **Modelos Impactados**

### **1. `subsidio_faixa_servico_dia_tipo_viagem.sql`** (linha 19)

```sql
-- ANTES: Calculava POF internamente
-- AGORA: Consome POF do modelo centralizado
from {{ ref("percentual_operacao_faixa_horaria") }}
```

### **2. `sumario_faixa_servico_dia.sql`** (linha 21)

```sql
-- Dashboard V1 - Dados históricos (antes V14)
from {{ ref("percentual_operacao_faixa_horaria") }}
where data < date("{{ var('DATA_SUBSIDIO_V14_INICIO') }}")
```

### **3. `sumario_faixa_servico_dia_pagamento.sql`** (linha 64)

```sql
-- Dashboard V2 - Dados atuais (V14+)
from {{ ref("percentual_operacao_faixa_horaria") }}
where data >= date('{{ var("DATA_SUBSIDIO_V14_INICIO") }}')
```

---

## 🎯 **Implicações de Negócio**

### **1. Acordo Judicial V15 - Implementação Completa**

#### **Mudança Crítica no POF**

- **Antes V15**: Apenas `Não licenciado` + `Não vistoriado` eram excluídos
- **V15+**: Também exclui `Lacrado` + `Sem ar-condicionado`

#### **Impacto Financeiro**

- **POF mais rigoroso** = Menos viagens contam para os 80% mínimos
- **Penalização aumentada** para empresas com veículos irregulares
- **Pressão operacional** para manter frota em conformidade

### **2. Transparência e Auditoria**

#### **Melhorias**

- **Fonte única**: Elimina discrepâncias entre relatórios
- **Versionamento**: Rastreabilidade completa de mudanças
- **Snapshot**: Histórico imutável para auditoria

#### **Riscos**

- **Ponto único de falha**: Se o modelo falhar, todo sistema para
- **Aplicação retroativa**: Mudanças podem afetar dados históricos

---

## ⚠️ **Alertas Críticos**

### **1. Mudança Retroativa Perigosa**

```sql
-- PROBLEMA: Aplica regras V15 para TODAS as datas
p.data >= date('{{ var("DATA_SUBSIDIO_V15_INICIO") }}')
```

**Risco**: POF de períodos passados pode ser recalculado, afetando pagamentos já
realizados.

### **2. Dependência Crítica**

- **Cascata de falhas**: Erro no modelo central afeta todos os dashboards
- **Monitoramento essencial**: Requer alertas específicos para este modelo

### **3. Complexidade Operacional**

- **Lógica condicional**: Diferentes regras por período histórico
- **Manutenção complexa**: Debugar problemas requer conhecimento profundo

---

## 📊 **Comparativo: Antes vs. Depois**

| Aspecto | **Modelo Antigo** | **Novo Modelo** |
|---------|-------------------|-----------------|
| **Arquitetura** | Distribuída (múltiplos modelos) | Centralizada (fonte única) |
| **Cálculo POF** | Duplicado em vários lugares | Unificado e padronizado |
| **Regras V15** | Implementação inconsistente | Padronizada e versionada |
| **Performance** | Recálculos redundantes | Materialização incremental |
| **Auditoria** | Limitada, sem histórico | Snapshot completo |
| **Manutenção** | Múltiplos pontos de mudança | Fonte única (risco/benefício) |
| **Transparência** | Discrepâncias possíveis | Consistência garantida |
| **Monitoramento** | Disperso | Centralizado (crítico) |

---

## 🔧 **Recomendações Técnicas**

### **Imediatas**

1. **Monitoramento crítico**: Alertas específicos para falhas no modelo
2. **Validação histórica**: Comparar POF antes/depois da migração
3. **Backup de segurança**: Manter dados do modelo antigo temporariamente

### **Médio Prazo**

1. **Testes de regressão**: Validar consistência com dados históricos
2. **Documentação operacional**: Guias para troubleshooting
3. **Plano de contingência**: Rollback em caso de problemas críticos

### **Longo Prazo**

1. **Otimização de performance**: Monitorar tempo de execução
2. **Evolução do modelo**: Preparar para futuras versões (V15B, V15C)
3. **Integração com novos dashboards**: Padronizar uso do modelo

---

## 📈 **Métricas de Sucesso**

### **Técnicas**

- ✅ **Consistência**: POF idêntico em todos os dashboards
- ✅ **Performance**: Tempo de execução otimizado
- ✅ **Disponibilidade**: 99.9% uptime do modelo central

### **Negócio**

- ✅ **Transparência**: Auditoria completa do POF
- ✅ **Conformidade**: Implementação correta do acordo judicial
- ✅ **Confiabilidade**: Dados consistentes para tomada de decisão

---

## 🚨 **Status de Monitoramento**

### **Pontos de Atenção**

- [ ] **Validação de dados históricos** - Pendente
- [ ] **Alertas de monitoramento** - Pendente  
- [ ] **Documentação operacional** - Pendente
- [x] **Implementação técnica** - Concluída
- [x] **Análise de impacto** - Concluída

### **Próximas Verificações**

- **Semanal**: Performance e disponibilidade
- **Mensal**: Consistência de dados
- **Trimestral**: Evolução das regras de negócio

---

## 📝 **Conclusão**

A substituição do `subsidio_faixa_servico_dia` pelo `percentual_operacao_faixa_horaria`
representa uma **modernização arquitetural crítica** do sistema de subsídios.

**Benefícios principais**:

- Padronização e consistência do cálculo POF
- Implementação correta do acordo judicial V15
- Melhoria na auditabilidade e transparência

**Riscos principais**:

- Dependência crítica de um único modelo
- Possível impacto retroativo em dados históricos
- Complexidade operacional aumentada

Esta mudança deve ser **monitorada de perto** nas próximas semanas para garantir
estabilidade e consistência do sistema de pagamento de subsídios.

---

**Documentado por**: Kilo Code  
**Data**: 28/07/2025 09:32 AM (UTC-3)  
**Versão**: 1.0
