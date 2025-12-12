# Análise da Sincronização do Repositório - 07/10/2025

Este documento detalha as 17 principais mudanças incorporadas ao seu fork a partir do repositório original `prefeitura-rio/pipelines_rj_smtr`. A análise foca nas implicações para a lógica de negócio, especialmente o cálculo de subsídios, e nas mudanças estruturais da pipeline de dados.

## Resumo Geral das Mudanças

A atualização representa um marco na maturidade e robustez da pipeline de dados da SMTR. As principais mudanças podem ser agrupadas em três categorias:

1.  **Aumento da Resiliência e Confiabilidade:** Foram introduzidos novos fluxos para recapturar dados perdidos, múltiplos agendamentos de "fallback" para garantir a execução, e uma refatoração técnica geral para usar métodos de acesso a dados mais modernos.
2.  **Ajustes na Lógica de Negócio:** Foram feitas correções importantes em regras específicas, notadamente no cálculo da regularidade do ar condicionado e na validação de viagens, tornando as regras mais precisas.
3.  **Refatoração Estrutural:** Houve uma reorganização significativa dos modelos de dados, com a criação de um novo schema (`financeiro_interno`) para isolar as tabelas de subsídio, e a criação de um novo modelo central (`viagem_valida`) para simplificar as dependências.

---

## 1. Mudanças Estruturais e de Pipeline

### 1.1. Refatoração: `basedosdados` para `pandas-gbq` e Autenticação OAuth

- **O que mudou:** Em toda a base de código Python (`pipelines/**/*.py`), as chamadas à função `basedosdados.read_sql()` foram substituídas por `pandas_gbq.read_gbq()`. Além disso, o arquivo de configuração de perfil do dbt (`queries/dev/profiles-example.yml`) foi alterado para usar o método de autenticação `oauth` em vez de `service-account`.
- **Possíveis Efeitos:** Esta é uma mudança primariamente técnica. O uso de `oauth` simplifica a autenticação em ambientes de desenvolvimento local, não exigindo mais um arquivo de chave de serviço. A troca de biblioteca pode trazer melhorias de performance ou compatibilidade. **Não há impacto direto esperado na lógica de cálculo.**

### 1.2. Movimentação de Esquemas: `financeiro` para `financeiro_interno`

- **O que mudou:** Os modelos de dbt que geram as tabelas de subsídio (`subsidio_faixa_servico_dia_tipo_viagem`, `subsidio_sumario_servico_dia_pagamento`, etc.) foram movidos. Eles agora são materializados no schema `financeiro_interno` em vez de `financeiro`. A mudança é visível no `dbt_project.yml` e na renomeação de diretórios em `queries/models/`.
- **Possíveis Efeitos:** **CRÍTICO.** Esta é a mudança estrutural mais importante. Qualquer ferramenta externa, dashboard (Metabase, PowerBI) ou consulta manual que apontava para `rj-smtr.financeiro.subsidio_*` **deixará de funcionar** e precisará ser atualizada para apontar para `rj-smtr.financeiro_interno.subsidio_*`. A intenção parece ser isolar as tabelas finais de pagamento das tabelas financeiras mais gerais.

### 1.3. Nova Pipeline: `bilhetagem_processos_manuais`

- **O que mudou:** Um novo conjunto de arquivos foi criado em `pipelines/treatment/bilhetagem_processos_manuais/`. Ele introduz dois novos fluxos principais:
    - `ordem_atrasada`: Orquestra a captura e o reprocessamento de ordens de pagamento que possam não ter sido processadas no dia correto.
    - `timestamp_divergente_jae_recaptura`: Um fluxo poderoso que consulta uma tabela de verificação (`resultado_verificacao_captura_jae`), encontra timestamps onde a contagem de registros entre o banco de origem e o data lake divergiu, e dispara a recaptura e reprocessamento apenas para esses períodos específicos.
- **Possíveis Efeitos:** Aumenta significativamente a robustez e a confiabilidade dos dados. O sistema agora tem um mecanismo automatizado para se autocorrigir em caso de falhas de captura, garantindo que menos dados sejam perdidos e que o cálculo do subsídio seja baseado em informações mais completas.

### 1.4. Melhorias de Agendamento e Fallback

- **O que mudou:** Vários fluxos, como `INTEGRACAO_MATERIALIZACAO` e `TRANSACAO_ORDEM_MATERIALIZACAO`, receberam agendamentos adicionais ao longo do dia. Além disso, foi introduzida uma lógica de `fallback_run`. Se um fluxo agendado percebe que a execução anterior falhou ou não aconteceu, o `fallback` é acionado para garantir que a materialização ocorra.
- **Possíveis Efeitos:** Maior garantia de que os dados estarão atualizados. Reduz a chance de um problema em uma execução impedir a atualização dos dados por um dia inteiro.

---

## 2. Mudanças na Lógica de Negócio e Modelos DBT

### 2.1. Criação da Tabela `viagem_valida`

- **O que mudou:** Foi criado um novo modelo, `viagem_valida.sql`, que simplesmente filtra a tabela `viagem_validacao` para manter apenas os registros com `indicador_viagem_valida = true`.
- **Possíveis Efeitos:** Positivo para a manutenibilidade do código. Em vez de cada modelo downstream ter que aplicar o filtro `where indicador_viagem_valida`, eles agora podem simplesmente usar `ref('viagem_valida')`. Isso centraliza a definição de uma viagem válida e simplifica o restante do código.

### 2.2. Correção na Regra de Regularidade do Ar Condicionado

- **O que mudou:** Esta é uma correção sutil, mas importante, na regra de negócio, localizada no arquivo `queries/models/subsidio/viagem_regularidade_temperatura.sql`.
    - **Antes:** A lógica para definir `indicador_regularidade_ar_condicionado_viagem` penalizava uma viagem se o `indicador_falha_recorrente` fosse verdadeiro, entre outras condições.
    - **Depois:** A lógica foi ajustada para que a verificação do `indicador_falha_recorrente` **só seja aplicada** para viagens ocorrendo a partir da data definida na variável `DATA_SUBSIDIO_V20_INICIO`. Para datas anteriores, a falha recorrente é ignorada no cálculo da regularidade do ar.
- **Possíveis Efeitos:** **Impacto direto no cálculo do subsídio.** Viagens que antes poderiam ser glosadas por falha recorrente de ar condicionado agora podem ser consideradas regulares (e portanto, remuneradas) se ocorreram antes da data de início da v20. Isso representa um relaxamento da regra para o período anterior à v20, ou a correção de uma regra que estava sendo aplicada retroativamente por engano. O teste em `macros/test_check_regularidade_temperatura.sql` foi ajustado para refletir essa nova lógica.

### 2.3. Novo Modelo Financeiro: `extrato_cliente_cartao`

- **O que mudou:** Foi adicionado o modelo `extrato_cliente_cartao.sql` e seu schema. Ele processa a tabela de `lancamento` da Jaé para criar um extrato de movimentações financeiras por cliente e cartão.
- **Possíveis Efeitos:** Cria uma nova fonte de dados para análise financeira e auditoria. Não parece ter impacto direto no cálculo do subsídio de GPS, mas enriquece o ecossistema de dados de bilhetagem.

### 2.4. Outras Correções e Melhorias

- **Cálculo de Velocidade Média:** Em `viagem_validacao.sql`, o cálculo de `velocidade_media` foi envolto em uma função `safe_divide` para evitar erros de divisão por zero, que poderiam ocorrer em viagens com duração zero.
- **Validação de Partida/Chegada:** A mesma tabela agora invalida viagens onde `datetime_chegada <= datetime_partida`.
- **Chave de Snapshot:** A chave única do `snapshot_veiculo_dia.sql` foi corrigida para evitar erros de sintaxe.
- **Remoção de `is_incremental()`:** Em vários modelos efêmeros, a verificação `is_incremental()` foi removida, pois não faz sentido nesse tipo de materialização, limpando o código.

---

## 3. Remoção de Workflows (CI/CD)

- **O que mudou:** Uma série de arquivos de workflow do GitHub Actions relacionados a um "Gemini Agent" (`gemini-dispatch.yml`, `gemini-invoke.yml`, etc.) foram removidos.
- **Possíveis Efeitos:** Nenhuma. Trata-se da limpeza de uma experimentação de automação de CI/CD com IA que não afeta a lógica de negócio do projeto.

---

## Conclusão e Potenciais Impactos

A sincronização traz uma versão muito mais madura e resiliente da pipeline. Para sua análise, os pontos de maior atenção são:

- **A mudança do schema `financeiro` para `financeiro_interno`**, que exige atualização de quaisquer ferramentas de BI ou queries salvas.
- **A correção na regra do ar condicionado**, que altera como a glosa por falha recorrente é aplicada, com impacto direto no valor pago.
- O novo **fluxo de recaptura de dados**, que aumenta a confiança nos dados de entrada, potencialmente reduzindo o número de viagens invalidadas por problemas técnicos na origem.
