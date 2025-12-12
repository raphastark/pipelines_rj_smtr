# Sincronização Dezembro 2025 - Documentação de Atualizações

**Data**: 12/12/2025
**Período coberto**: Dezembro 2025
**Commits analisados**: 163 commits
**Status**: ✅ Documentado

---

## 📋 Resumo das Mudanças

Esta sincronização com o upstream principal resultou em 163 novas alterações, representando uma atualização significativa na pipeline de dados da SMTR. As mudanças abrangem melhorias em indicadores estratégicos, ajustes em modelos de subsídio, atualizações na bilhetagem e correções operacionais diversas.

### Principais Impactos:
- **Novo Indicador Euro VI**: Implementação de modelo para rastreamento de veículos com tecnologia Euro VI
- **Retomada de Descontos por Ar-Condicionado**: Alteração crítica no modelo `viagem_regularidade_temperatura` para retomada dos descontos
- **Melhorias na Bilhetagem**: Adição de colunas para matrícula e ID único de lançamento
- **Ajustes Operacionais**: Várias correções em modelos de veículos e licenciamento

---

## 🔄 Mudanças Críticas Identificadas

### 1. Novo Indicador Euro VI (Commit: 560b1ac3)

**O quê**: Implementação completa do indicador para rastreamento de veículos com tecnologia Euro VI
**Impacto**: 🔴 **ALTO - Novo indicador estratégico**

#### Detalhes da Implementação:
- **Novo modelo**: `queries/models/indicador_interno/staging/indicador_euro_vi.sql` (171 linhas)
- **Modelo estratégico**: `queries/models/indicador_interno/indicador_estrategico.sql` (54 linhas)
- **Snapshot**: `queries/snapshots/indicador_interno/snapshot_indicador_estrategico.sql`
- **Schema atualizado**: Inclusão dos novos modelos no schema do indicador interno

#### Implicações:
- **Monitoramento ambiental**: Acompanhamento da frota mais moderna e menos poluente
- **Potencial impacto em subsídios**: Pode influenciar futuras políticas de remuneração baseadas em tecnologia
- **Auditoria**: Snapshot criado para rastreabilidade histórica

### 2. Retomada de Descontos por Inoperabilidade do Ar-Condicionado (Commit: b7dcb01f)

**O quê**: Alteração no modelo `viagem_regularidade_temperatura` para retomada dos descontos
**Impacto**: 🔴 **ALTO - Impacto direto no cálculo de subsídios**

#### Mudança Específica:
```sql
-- Antes:
and not vt.indicador_temperatura_nula_viagem and (vt.data < date('{{ var("DATA_SUBSIDIO_V22_INICIO") }}'))

-- Após:
and not vt.indicador_temperatura_nula_viagem and (vt.data not between date('{{ var("DATA_SUBSIDIO_V22_INICIO") }}') and date("2025-11-15")) --Período de interrupção dos descontos por inoperabilidade do ar-condicionado
```

#### Contexto Legal:
- **Referência**: Evento 112 do PROCEDIMENTO COMUM CÍVEL Nº 3019687-30.2025.8.19.0001/RJ
- **Período de paralisação**: Entre `DATA_SUBSIDIO_V22_INICIO` e `2025-11-15`
- **Impacto**: Viagens com falha no ar-condicionado voltarão a ser penalizadas após o período de paralisação

#### Implicações Financeiras:
- **Retomada de glosas**: Empresas voltarão a receber descontos por falha no ar-condicionado
- **Período específico**: A paralisação foi temporária e documentada legalmente
- **Previsibilidade**: Mudança bem documentada facilita planejamento das operadoras

### 3. Melhorias na Bilhetagem - Matrícula e ID Único (Commit: 930c5ca3)

**O quê**: Adição de colunas para melhor rastreabilidade na bilhetagem
**Impacto**: 🟡 **MÉDIO - Melhoria na rastreabilidade**

#### Mudanças Implementadas:
- **Coluna `numero_matricula`**: Adicionada em `aux_gratuidade_info` e `transacao_gratuidade_estudante_municipal`
- **Coluna `id_unico_lancamento`**: Adicionada em `extrato_cliente_cartao.sql`
- **Flows atualizados**: Registro dos novos modelos nos pipelines de bilhetagem

#### Implicações:
- **Rastreabilidade**: Melhor identificação de estudantes municipais
- **Auditoria**: ID único facilita conciliação de lançamentos
- **Integração**: Melhora cruzamento com sistemas educacionais

### 4. Ajustes no Modelo `veiculo_dia` (Commit: 66352898)

**O quê**: Otimização das verificações de unicidade no modelo `veiculo_dia`
**Impacto**: 🟡 **MÉDIO - Melhoria técnica**

#### Mudança Específica:
- **Verificação simplificada**: Agora considera apenas `data` e `id_veiculo` para unicidade
- **Filtro ajustado**: Melhoria na lógica de filtragem do modelo
- **Constants atualizadas**: Ajuste em `pipelines/treatment/monitoramento/constants.py`

#### Implicações:
- **Performance**: Redução de complexidade nas verificações
- **Consistência**: Evita duplicações indevidas
- **Manutenibilidade**: Código mais simples de manter

---

## 🔧 Outras Mudanças Significativas

### 5. Correções de Data de Processamento

Múltiplos commits (146345d7, 20b2bc84, 416cca09, 2d4a5078) corrigiram datas de processamento em diversos modelos:

- **veiculo_dia**: Correções em hotfixes para datas de processamento
- **Exceção específica**: Ajuste para data `2025-12-03`
- **Consistência**: Garantia de processamento correto dos dados

### 6. Atualizações em Tecnologia e Licenciamento

- **Tecnologia Euro VI**: Atualização para novembro Q2 (993a86c9)
- **Serviços Contrato Abreviado**: Atualização da lista (3b3f2644)
- **Testes dbt**: Melhorias em verificações de unicidade (73b1359c)

### 7. Infraestrutura e Operação

- **Registro de Flow**: Flow do subsídio registrado para melhor rastreabilidade (a6d4e5ad)
- **IP Tracking DB**: Alteração de IP para banco de dados da Jaé (1eb1ab25)
- **Regex Fiscalização**: Correção em modelo de fiscalização de lacre (b4689331)

---

## 📊 Impacto na Apuração dos Subsídios

### Mudanças com Impacto Direto:

1. **Retomada de Descontos por Ar-Condicionado**:
   - Viagens com falha no ar-condicionado voltarão a ser penalizadas
   - Período de paralisação claramente definido: até 15/11/2025
   - Impacto financeiro direto nas operadoras

2. **Indicador Euro VI**:
   - Potencial influência em futuras políticas de subsídio
   - Monitoramento da frota mais moderna
   - Base para decisões estratégicas

3. **Melhorias na Bilhetagem**:
   - Maior precisão na identificação de gratuidades
   - Melhor auditoria de transações
   - Suporte a integrações futuras

### Mudanças Técnicas:

1. **Otimizações de Performance**:
   - Simplificação de verificações em `veiculo_dia`
   - Melhorias em processamento incremental
   - Redução de complexidade em modelos críticos

2. **Correções de Datas**:
   - Consistência no processamento temporal
   - Hotfixes aplicados rapidamente
   - Garantia de integridade dos dados

---

## ⚠️ Pontos de Atenção e Riscos

### Monitoramento Necessário:

1. **Transição da Paralisação do Ar-Condicionado**:
   - Verificar se a retomada dos descontos está ocorrendo corretamente
   - Monitorar impacto financeiro nas operadoras
   - Validar períodos de transição

2. **Novo Indicador Euro VI**:
   - Acompanhar qualidade dos dados do novo indicador
   - Verificar integração com outros modelos
   - Monitorar performance do novo modelo

3. **Mudanças na Bilhetagem**:
   - Validar preenchimento das novas colunas
   - Verificar compatibilidade com sistemas downstream
   - Monitorar impacto em relatórios existentes

### Riscos Identificados:

1. **Complexidade Crescente**:
   - Múltiplas exceções e regras temporárias
   - Necessidade de documentação atualizada
   - Risco de erros em períodos de transição

2. **Dependências Críticas**:
   - Modelos interdependentes com múltiplas versões
   - Necessidade de testes abrangentes
   - Risco de cascata em caso de falhas

---

## 📈 Estatísticas da Sincronização

### Arquivos Modificados:
- **Total estimado**: 200+ arquivos
- **Modelos SQL**: 50+ novos/alterados
- **Pipelines Python**: 20+ flows atualizados
- **Schemas**: 15+ documentações atualizadas

### Linhas de Código:
- **Adicionadas**: ~5.000+ linhas
- **Removidas**: ~500+ linhas
- **Modificadas**: ~2.000+ linhas

### Domínios Impactados:
1. **Subsídio** - Mudanças críticas em ar-condicionado
2. **Indicadores** - Novo indicador Euro VI
3. **Bilhetagem** - Melhorias de rastreabilidade
4. **Monitoramento** - Otimizações e correções
5. **Veículos** - Ajustes em licenciamento

---

## 🎯 Próximos Passos Recomendados

### Monitoramento Imediato:

1. **Validar Retomada dos Descontos**:
   - Verificar se as penalidades por ar-condicionado estão sendo aplicadas
   - Confirmar período de transição está correto
   - Acompanhar reações das operadoras

2. **Testar Novo Indicador Euro VI**:
   - Validar qualidade dos dados
   - Verificar integração com dashboards
   - Documentar metodologia

3. **Verificar Bilhetagem**:
   - Confirmar preenchimento das novas colunas
   - Testar relatórios dependentes
   - Validar integridade dos dados

### Ações de Médio Prazo:

1. **Documentação Complementar**:
   - Criar documentação detalhada do indicador Euro VI
   - Documentar período de paralisação do ar-condicionado
   - Atualizar manuais operacionais

2. **Testes Automatizados**:
   - Implementar testes para as novas funcionalidades
   - Criar validações para períodos de transição
   - Automatizar verificações de qualidade

---

## 📚 Referências Cruzadas

Para informações detalhadas sobre mudanças anteriores, consultar:

- Sincronização anterior: [`sync-102025-outubro.md`](sync-102025-outubro.md)
- Documentação de temperatura: [`documentacao_regularidade_temperatura_veiculo.md`](documentacao_regularidade_temperatura_veiculo.md)
- Estrutura do projeto: [`project-structure.md`](project-structure.md)
- Arquitetura geral: [`architecture.md`](architecture.md)

---

**Documento mantido por**: Kilo Code
**Última atualização**: 12/12/2025 09:31 AM (UTC-3)
**Versão**: 1.0