# Status do Memory Bank - 19/08/2025

## Atualização Completa ✅

O memory bank foi atualizado com sucesso em **19 de agosto de 2025 às 02:16 AM (UTC-3)**
com as mudanças mais recentes do upstream.

### Última Sincronização

- **Fork sincronizado**: 19/08/2025
- **Commits upstream analisados**: 1 commit (4044fd38)
- **Período coberto**: Agosto 2025

### Arquivos Atualizados

1. **`sync-july-2025.md`** ✅ **NOVO**
   - Análise completa dos 42 commits de julho 2025
   - Mudanças críticas no algoritmo de subsídios documentadas
   - Penalidade V15A por tecnologia mínima identificada
   - Acordo judicial e reformulação do sistema mapeada
   - Encontro de contas V2 e sistema financeiro documentado
   - Mudanças operacionais em flows registradas

2. **`modelo-percentual-operacao-faixa-horaria.md`** ✅ **NOVO**
   - Documentação detalhada da substituição do modelo `subsidio_faixa_servico_dia`
   - Análise técnica completa do novo modelo `percentual_operacao_faixa_horaria`
   - Implicações arquiteturais e de negócio mapeadas
   - Riscos e alertas críticos identificados
   - Recomendações técnicas e métricas de sucesso definidas
   - Status de monitoramento estabelecido

3. **`project-structure.md`** ✅
   - Estrutura completa do projeto atualizada
   - Domínios de negócio mapeados
   - Configurações de materialização documentadas
   - Seletores dbt principais listados

4. **`recent-changes.md`** ✅
   - Mudanças de junho 2025 adicionadas
   - Ajustes do acordo judicial documentados
   - Novo domínio de infraestrutura mapeado
   - Mudanças de maio 2025 preservadas

5. **`architecture.md`** ✅ (existente)
   - Visão geral da arquitetura mantida
   - Componentes principais documentados

6. **`brief.md`** ✅ (existente)
   - Descrição do projeto atualizada
   - Tecnologias principais listadas

7. **`coding-conventions.md`** ✅ (existente)
   - Convenções de código Python e SQL
   - Estrutura de módulos definida

8. **`integration-points.md`** ✅ (existente)
   - Pontos de integração mapeados
   - APIs externas documentadas

### Informações Capturadas

#### Estrutura do Projeto

- **Pipelines Python**: 6 módulos principais (capture, control, migration, serpro,
  treatment, utils)
- **Modelos dbt**: 15+ domínios de negócio
- **Configurações**: dbt_project.yml, selectors.yml, profiles.yml

#### Tecnologias

- **Backend**: Python, Prefect, BigQuery
- **Transformação**: dbt, SQL
- **Infraestrutura**: Google Cloud Platform

#### Configurações Atuais

- **Versão do projeto**: 1.0.0
- **Subsídio mais recente**: V15A (início: 01/07/2025)
- **GPS**: modo "onibus", fonte "conecta"
- **Ambientes**: rj-smtr-prod (produção), rj-smtr-staging (staging)

#### Seletores dbt Ativos

- `gps` e `gps_15_minutos` - Processamento GPS
- `apuracao_subsidio_v9` - Apuração com faixa horária
- `viagem_informada` - Viagens informadas
- `transacao` e `integracao` - Bilhetagem
- `validacao_dados_jae` - Validação de dados
- `infraestrutura` - Custos e monitoramento GCP

### Próximos Passos

1. **Monitoramento**: Acompanhar implementação da versão V15A do subsídio
2. **Performance**: Verificar otimizações nos modelos GPS
3. **Documentação**: Manter atualizado conforme novas mudanças
4. **Integração**: Monitorar novos pontos de integração

### Última Verificação

- **Data**: 28/07/2025 09:16 AM
- **Arquivos verificados**: 42 commits analisados
- **Status**: Sincronizado com o estado atual do projeto

---

**Memory Bank Status**: 🟢 **ATIVO E ATUALIZADO**
