# Sincronização Agosto 2025 - Documentação de Atualizações

Data: 08/08/2025
Período coberto: Agosto 2025
Status: ✅ Documento criado para registro de atualizações

---

## 📋 Introdução

Este documento foi criado para registrar atualizações e mudanças que ocorreram em agosto de 2025, complementando a documentação consolidada de junho-julho de 2025. As mudanças documentadas nos meses anteriores permanecem válidas e podem ser consultadas nos seguintes documentos:

- Documentação consolidada de junho-julho: [`documentacao-mudancas-julho-2025.md`](documentacao-mudancas-julho-2025.md)
- Análise técnica detalhada do modelo de POF: [`modelo-percentual_operacao_faixa_horaria.md`](modelo-percentual-operacao-faixa-horaria.md)
- Sincronização completa de julho: [`sync-july-2025.md`](sync-july-2025.md)

---

## 🔄 Atualizações Identificadas em Agosto 2025

Até o momento, as principais atualizações e mudanças significativas no projeto foram consolidadas no período de Junho-Julho de 2025. Este documento serve como um ponto de referência para futuras atualizações a partir de Agosto de 2025.

Para uma compreensão detalhada das mudanças que impactam a apuração dos subsídios e o processo de validação das viagens, incluindo a integração de dados da bilhetagem da Jaé, por favor, consulte os documentos de sincronização de Julho de 2025.

### Consequências para a Apuração dos Subsídios e Validação de Viagens (Baseado nas Mudanças de Julho)

As mudanças implementadas em julho de 2025 tiveram um impacto significativo na apuração dos subsídios e no processo de validação das viagens elegíveis para remuneração:

#### 1. Novo Modelo Central de Percentual de Operação por Faixa Horária (POF)
- **Impacto na Apuração**: O novo modelo [`percentual_operacao_faixa_horaria.sql`](queries/models/subsidio/percentual_operacao_faixa_horaria.sql:1) substituiu o modelo anterior, centralizando o cálculo do POF. Isso garante uma fonte única de verdade para este indicador crítico, eliminando divergências entre dashboards e unificando as regras de versionamento (pré-V15 vs V15+). Um POF mais rigoroso significa que menos viagens podem contar para o mínimo de 80% de operação, aumentando a penalização para empresas com veículos irregulares.
- **Validação de Viagens**: A lógica de cálculo do POF agora incorpora regras versionadas, excluindo viagens com status como "Não licenciado", "Não vistoriado", "Lacrado" e "Não autorizado por ausência de ar-condicionado" (estes dois últimos a partir da V15). Isso afeta diretamente quais viagens são consideradas válidas para o cálculo do subsídio.

#### 2. Penalidade V15A: Tecnologia Mínima
- **Impacto na Apuração**: A partir de 01/07/2025, veículos com tecnologia inferior à mínima exigida não recebem pagamento, resultando em **zero remuneração** para essas viagens. Anteriormente, esses veículos recebiam com base na tecnologia mínima.
- **Validação de Viagens**: O processo de validação agora inclui uma verificação rigorosa da tecnologia do veículo. Se a tecnologia for inferior à mínima e a data for posterior a 01/07/2025, a viagem é automaticamente classificada como não remunerada. Isso afeta diretamente a elegibilidade das viagens para subsídio.

#### 3. Nova Classificação de Viagens
- **Impacto na Apuração e Validação**: O modelo [`viagem_classificada.sql`](queries/models/subsidio/viagem_classificada.sql:1) foi aprimorado com mais de 290 linhas de regras e integrações. Ele classifica as viagens com base em:
    - Tecnologia apurada vs. remunerada
    - Status operacional do veículo
    - Autuações disciplinares
    - Indicadores de penalidade
- Essa classificação mais granular e coerente com as regras de negócio serve como base para a aplicação de penalidades, incluindo a V15A, e afeta diretamente a elegibilidade e o valor do subsídio.

#### 4. Integração de Dados da Bilhetagem da Jaé
- **Impacto na Validação de Viagens**: A integração com a Jaé (bilhetagem) é crucial para a validação das viagens. Múltiplos bancos de dados (MySQL/PostgreSQL) com domínios como transações, RioCard, tracking (GPS validadores), lançamentos, ressarcimentos e gratuidades são capturados.
- **Por que integra dados da bilhetagem da Jaé?**: A integração dos dados da Jaé é fundamental porque:
    - **Aumenta a cobertura e granularidade**: Permite uma visão mais completa e detalhada das transações de bilhetagem e do rastreamento (GPS dos validadores), o que é essencial para classificar corretamente as viagens.
    - **Classificação de Viagens**: Os dados de bilhetagem são usados para identificar tipos de viagem, validar a ocorrência de transações e associar passageiros às viagens, influenciando diretamente a elegibilidade para remuneração.
    - **Monitoramento e Verificação**: A frequência diferenciada de captura (minuto a minuto para transações e tracking, a cada 10 min para retificações, etc.) permite verificações e monitoramento mais precisos, como checagem de IP e alertas, que contribuem para a integridade dos dados de validação.
    - **Contexto Operacional**: Problemas operacionais da Jaé, como atualizações irresponsáveis e bugs nos validadores, podem levar a "viagens sem transação" ou "validador associado incorretamente", que, agravadas pela regra V15A, resultam em viagens não remuneradas. A integração desses dados permite identificar e, idealmente, mitigar esses problemas.

---

## 📝 Notas sobre Versionamento

As mudanças críticas identificadas nos meses anteriores continuam em vigor:

### Versões de Subsídio Ativas
- **V15A**: Ativo desde 01/07/2025 (Penalidade por tecnologia mínima)
- **V15**: Ativo desde 01/04/2025 (Acordo Judicial)
- **V14**: Ativo desde 05/01/2025
- **V13**: Ativo desde 01/01/2025

### Próximas Versões Planejadas
- **V15B**: Planejado para 01/08/2025 (Validadores Jaé)
- **V15C**: Planejado para 01/11/2025 (Ar-condicionado obrigatório)

---

## 🎯 Diretrizes para Atualizações Futuras

Este documento deve ser atualizado sempre que forem identificadas mudanças significativas no projeto após a consolidação de julho de 2025, especialmente:

1. Alterações nos algoritmos de cálculo de subsídio
2. Novas versões de modelos críticos
3. Mudanças em fontes de dados ou integrações
4. Atualizações em pipelines e flows
5. Modificações em regras de negócio

---

## 📚 Referências Cruzadas

Para informações detalhadas sobre as mudanças já implementadas, consultar:

- Estrutura do projeto: [`project-structure.md`](project-structure.md)
- Arquitetura geral: [`architecture.md`](architecture.md)
- Convenções de código: [`coding-conventions.md`](coding-conventions.md)
- Pontos de integração: [`integration-points.md`](integration-points.md)
- Preocupações de transparência: [`transparency-concerns.md`](transparency-concerns.md)

---

**Documento mantido por**: Kilo Code
**Última atualização**: 08/08/2025 07:57 AM (UTC-3)
**Versão**: 1.0