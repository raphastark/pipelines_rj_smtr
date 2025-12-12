# Documentação do Indicador Euro VI - Dezembro/2025

**Data**: 12/12/2025  
**Autor**: Kilo Code  
**Status**: ✅ Documentado

---

## Visão Geral

O indicador Euro VI representa uma evolução significativa no monitoramento ambiental da frota de ônibus do Rio de Janeiro. Esta funcionalidade foi implementada para rastrear veículos com tecnologia Euro VI ou superior, que são os mais modernos e menos poluentes atualmente disponíveis no mercado. O indicador tem potencial para influenciar futuras políticas de subsídio baseadas em critérios ambientais e tecnológicos.

---

## 📋 Contexto e Motivação

### Objetivo da Implementação
- **Monitoramento Ambiental**: Acompanhamento da frota mais moderna e menos poluente
- **Políticas Públicas**: Base para decisões sobre remuneração baseada em tecnologia
- **Transparência**: Visibilidade sobre a composição tecnológica da frota
- **Benchmarking**: Comparação entre operadoras em termos de modernidade da frota

### Padrão Euro VI
- **Definição**: Padrão europeu de emissões para veículos pesados
- **Implementação**: Veículos fabricados a partir de 2023 geralmente cumprem este padrão
- **Benefícios**: Redução drástica de NOx, material particulado e outras emissões
- **Relevância**: Alinhamento com metas de sustentabilidade urbana

---

## 🔧 Componentes Principais da Implementação

### 1. Modelo Staging: `indicador_euro_vi.sql`

**Arquivo**: `queries/models/indicador_interno/staging/indicador_euro_vi.sql`  
**Linhas**: 171 linhas de código SQL complexo  
**Materialização**: Incremental com estratégia otimizada

#### Estrutura do Modelo

```sql
-- Meta-dados completos para governança
config(
    meta={
        "data_product": "Indicador: Percentual de Veículos Operantes Euro VI ou Superior",
        "data_product_code": "PVEUROIV",
        "ted": "TED_001-25_DTDI/SUBTT-SUBPCT",
        "chief_data_owner": "lauro.silvestre@prefeitura.rio",
        "business_data_owner": "rebeca.bittencourt@prefeitura.rio",
        "data_steward": "victormiguel@prefeitura.rio",
        "data_custodian": "rodrigo.fcunha@prefeitura.rio",
    }
)
```

#### Lógica de Cálculo

O modelo identifica veículos Euro VI através do critério principal:

```sql
ano_fabricacao >= 2023 as indicador_euro_vi
```

Este critério é baseado na regulamentação europeia que implementou o padrão Euro VI para veículos novos a partir de 2023.

#### Fontes de Dados Integradas

1. **`viagem_completa`**: Dados de viagens completas do SPPO
2. **`veiculo_licenciamento_dia_backup`**: Dados de licenciamento (2025-04-01 a 2025-07-24)
3. **`veiculo_licenciamento_dia_prod`**: Dados de licenciamento em produção (após 2025-07-24)
4. **`veiculo_dia`**: Dados diários dos veículos do SPPO
5. **`sppo_veiculo_dia`**: Dados históricos de veículos (período V1)
6. **`licenciamento_data_versao_efetiva`**: Controle de versão de dados
7. **`licenciamento`**: Dados de licenciamento de veículos

#### Tratamento de Dados Históricos

O modelo implementa uma estratégia sofisticada para lidar com diferentes períodos de dados:

- **Período V1** (antes de 2025-04-01): Usa `sppo_veiculo_dia`
- **Período Backup** (2025-04-01 a 2025-07-24): Usa tabela de backup
- **Período Produção** (após 2025-07-24): Usa `veiculo_licenciamento_dia` em produção

#### Filtros Aplicados

- **Tipo de Veículo**: Exclui BRTs e veículos especiais
  ```sql
  tipo_veiculo not in (
      '44 BRT PADRON',
      '45 BRT ARTICULADO',
      '46 BRT BIARTICULADO',
      '61 RODOV. C/AR E ELEV',
      '5 ONIBUS ROD. C/ AR'
  )
  ```
- **Ano de Fabricação**: Exclui veículos sem ano informado
- **Período Temporal**: A partir de `DATA_SUBSIDIO_V13_INICIO`

### 2. Modelo Estratégico: `indicador_estrategico.sql`

**Arquivo**: `queries/models/indicador_interno/indicador_estrategico.sql`  
**Linhas**: 54 linhas  
**Função**: Agrega e consolida indicadores estratégicos

Este modelo consolida o indicador Euro VI com outros indicadores estratégicos do sistema, fornecendo uma visão unificada para tomada de decisão.

### 3. Snapshot de Auditoria

**Arquivo**: `queries/snapshots/indicador_interno/snapshot_indicador_estrategico.sql`  
**Função**: Histórico imutável de todos os indicadores estratégicos  
**Estratégia**: Timestamp-based para rastreabilidade completa

---

## 📊 Regras de Negócio e Lógica

### Critérios de Classificação

1. **Veículo Euro VI**: `ano_fabricacao >= 2023`
2. **Veículo Não Euro VI**: `ano_fabricacao < 2023`
3. **Indeterminado**: `ano_fabricacao IS NULL`

### Exclusões Específicas

São excluídos do cálculo:
- Veículos BRT (todos os tipos)
- Veículos especiais com ar condicionado elevado
- Veículos sem ano de fabricação informado

### Período de Vigência

- **Data Inicial**: `DATA_SUBSIDIO_V13_INICIO` (01/01/2025)
- **Atualização**: Mensal com dados incrementais
- **Retenção**: Histórico completo através de snapshots

---

## 🎯 Impactos e Implicações

### Impacto na Apuração de Subsídios

**Impacto Direto**: Ainda não aplicado diretamente nos cálculos de subsídio, mas estabelece base para:

1. **Políticas Futuras**: Possível bonificação por frota moderna
2. **Penalizações**: Potencial redução para frotas antigas
3. **Metas Estabelecidas**: Referência para objetivos de modernização

### Impacto Operacional

1. **Monitoramento**: Visibilidade sobre a composição da frota
2. **Benchmarking**: Comparação entre operadoras
3. **Planejamento**: Base para estratégias de renovação

### Impacto Regulatório

1. **Transparência**: Dados públicos sobre frota moderna
2. **Conformidade**: Alinhamento com metas ambientais
3. **Relatórios**: Subsídio para relatórios de sustentabilidade

---

## 🔍 Análise Técnica Detalhada

### Estrutura de Dados

#### Campos Principais

```sql
data,                    -- Data de referência
id_veiculo,             -- Identificador único do veículo
placa,                  -- Placa do veículo
ano_fabricacao,         -- Ano de fabricação
indicador_euro_vi,       -- Boolean: true se Euro VI
versao,                 -- Versão do modelo
datetime_ultima_atualizacao, -- Timestamp de atualização
id_execucao_dbt         -- ID de execução para rastreabilidade
```

#### Lógica de Incremental

O modelo usa um filtro incremental sofisticado:

```sql
{% set incremental_filter %}
    {% if is_incremental() %}
    data between date_trunc(date("{{ var('start_date') }}"), month) and last_day(date("{{ var('end_date') }}"), month)
    and data < date_trunc(current_date("America/Sao_Paulo"), month)
    {% else %}
    data < date_trunc(current_date("America/Sao_Paulo"), month)
    {% endif %}
{% endset %}
```

### Tratamento de Lacunas de Dados

O modelo implementa uma estratégia robusta para lidar com lacunas nos dados de licenciamento:

1. **Período de Backup**: Usa tabela específica para período crítico
2. **União de Fontes**: Combina múltiplas fontes de dados
3. **COALESCE**: Prioriza dados mais recentes e confiáveis

---

## 📈 Métricas e KPIs

### Indicadores Calculados

1. **Percentual de Frota Euro VI**: `COUNT(veículos Euro VI) / COUNT(total veículos)`
2. **Evolução Temporal**: Variação mensal do percentual
3. **Distribuição por Operadora**: Comparativo entre empresas
4. **Cobertura por Linha**: Análise por serviço/linha

### Dashboards Potenciais

1. **Painel Executivo**: Visão geral da frota Euro VI
2. **Painel Operacional**: Detalhamento por operadora
3. **Painel Histórico**: Evolução temporal
4. **Painel de Metas**: Progresso vs. objetivos

---

## ⚠️ Pontos de Atenção e Riscos

### Riscos de Dados

1. **Qualidade do Ano de Fabricação**: Dependência crítica deste campo
2. **Consistência Histórica**: Diferentes fontes podem ter discrepâncias
3. **Atualização de Frota**: Tempo de atualização dos dados de licenciamento

### Riscos Operacionais

1. **Interpretação do Critério**: Ano de fabricação ≠ padrão Euro VI
2. **Veículos Importados**: Padrões diferentes podem se aplicar
3. **Retrofits**: Veículos adaptados podem não seguir o critério de ano

### Recomendações de Monitoramento

1. **Validação Cruzada**: Comparar com dados do DENATRAN
2. **Amostragem**: Verificação física em campo
3. **Atualização**: Monitorar frequência de atualização dos dados

---

## 🔄 Evolução Futura

### Melhorias Planejadas

1. **Critério Refinado**: Usar dados específicos de emissões quando disponíveis
2. **Integração DENATRAN**: Enriquecer com dados do órgão regulador
3. **Análise de Consumo**: Correlacionar com consumo de combustível
4. **Impacto Ambiental**: Cálculo de redução de emissões

### Potenciais Aplicações

1. **Subsídio Verde**: Bonificação por frota moderna
2. **Zonas de Baixa Emissão**: Restrições baseadas em tecnologia
3. **Metas Contratuais**: Exigências de modernização
4. **Relatórios ESG**: Suporte para relatórios de sustentabilidade

---

## 📚 Referências e Documentação

### Referências Normativas

1. **Euro VI**: Regulamento Europeu 582/2011
2. **CONAMA**: Resoluções sobre emissões veiculares no Brasil
3. **PROCONVE**: Programa de Controle da Poluição do Ar por Veículos

### Documentos Relacionados

- [`sync-122025-dezembro.md`](sync-122025-dezembro.md) - Sincronização que introduziu o indicador
- [`project-structure.md`](project-structure.md) - Estrutura do projeto
- [`architecture.md`](architecture.md) - Arquitetura geral

---

## 📝 Conclusão

O indicador Euro VI representa um avanço significativo na capacidade de monitoramento e gestão da frota de ônibus do Rio de Janeiro. Sua implementação estabelece as bases para políticas públicas mais sofisticadas baseadas em critérios ambientais e tecnológicos.

A abordagem técnica adotada, com tratamento robusto de dados históricos e múltiplas fontes, garante a confiabilidade necessária para suportar decisões estratégicas sobre remuneração e planejamento da frota.

O monitoramento contínuo da qualidade dos dados e a evolução dos critérios de classificação serão essenciais para manter a relevância e precisão do indicador ao longo do tempo.

---

**Documentado por**: Kilo Code  
**Data**: 12/12/2025 09:33 AM (UTC-3)  
**Versão**: 1.0