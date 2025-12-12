# Documentação: Modelo `percentual_operacao_faixa_horaria` - Versões V1 e V2

**Data**: 08/08/2025
**Autor**: Kilo Code
**Status**: ✅ Documentado

---

## 📋 Resumo das Versões

Este documento detalha as diferenças entre as versões V1 e V2 do modelo `percentual_operacao_faixa_horaria`, com foco principal na introdução do "sentido" da viagem como um critério para o cálculo do Percentual de Operação por Faixa Horária (POF) e, consequentemente, para a remuneração.

- **V1**: Versão inicial do cálculo do POF, que **não** considerava o sentido da viagem como um critério explícito para agrupamento e cálculo.
- **V2**: Ativada em **01/07/2025**, esta versão **inclui** o `sentido` da viagem como uma dimensão adicional no agrupamento e cálculo do POF, impactando diretamente a remuneração.

---

## 🔄 Mudanças Técnicas Detalhadas

### 1. Modelo Central: `queries/models/subsidio/percentual_operacao_faixa_horaria.sql`

Este modelo atua como a fonte única de verdade para o POF, unificando a lógica das versões V1 e V2 com base na data. Ele referencia os modelos de staging `percentual_operacao_faixa_horaria_v1` e `percentual_operacao_faixa_horaria_v2`.

### 2. Versão V1: `queries/models/subsidio/staging/percentual_operacao_faixa_horaria_v1.sql`

- **Período de Vigência**: Até 30/06/2025.
- **Lógica Principal**: O cálculo do POF nesta versão é baseado em agrupamentos que **não incluem** o `sentido` da viagem. A remuneração era apurada sem essa granularidade.
- **Exemplo de Agrupamento (simplificado)**:
    ```sql
    GROUP BY
        data,
        faixa_horaria_inicio,
        faixa_horaria_fim,
        consorcio,
        servico
    ```

### 3. Versão V2: `queries/models/subsidio/staging/percentual_operacao_faixa_horaria_v2.sql`

- **Período de Vigência**: A partir de 01/07/2025.
- **Lógica Principal**: A principal mudança é a inclusão do `sentido` da viagem nos agrupamentos e joins para o cálculo do POF. Isso significa que o POF é agora calculado de forma mais granular, considerando se a viagem foi realizada em um sentido específico (ida ou volta, por exemplo).
- **Impacto na Remuneração**: Ao incluir o `sentido`, a remuneração passa a ser condicionada à operação em cada sentido planejado, tornando a apuração mais precisa e alinhada com a realidade operacional.
- **Exemplo de Agrupamento (simplificado)**:
    ```sql
    GROUP BY
        data,
        faixa_horaria_inicio,
        faixa_horaria_fim,
        consorcio,
        servico,
        sentido -- ← NOVO CRITÉRIO
    ```
- **Integração com Planejamento**: A V2 se beneficia de modelos de planejamento que já incorporam o `sentido`, como `queries/models/planejamento/ordem_servico_faixa_horaria_sentido.sql`, garantindo que a quilometragem planejada e as partidas sejam consideradas por sentido.

---

## 🎯 Implicações de Negócio e Impacto

### 1. Maior Granularidade na Apuração do POF

- A inclusão do `sentido` permite uma apuração mais detalhada do POF, refletindo com maior precisão a operação real dos serviços.
- Isso pode levar a uma distribuição mais justa dos subsídios, pois penaliza ou remunera com base na operação efetiva em cada sentido.

### 2. Impacto Direto na Remuneração

- Viagens que antes poderiam ser consideradas válidas apenas pela faixa horária e serviço, agora precisam ter o `sentido` correto para serem remuneradas.
- Empresas que não operam consistentemente em ambos os sentidos (ida e volta) de uma linha podem ter seu POF impactado negativamente, resultando em menor remuneração.

### 3. Alinhamento com o Planejamento Operacional

- A V2 do POF se alinha melhor com a forma como as viagens são planejadas e executadas no dia a dia, onde o sentido é um fator crucial.

---

## ⚠️ Alertas e Considerações

- **Dados Históricos**: A aplicação da V2 a partir de 01/07/2025 significa que dados históricos (anteriores a essa data) continuarão a ser processados pela V1, sem a granularidade do `sentido`. É crucial garantir que os dashboards e relatórios que consomem o POF considerem essa distinção temporal.
- **Complexidade**: A introdução de uma nova dimensão aumenta a complexidade do modelo, exigindo maior atenção na manutenção e no entendimento da lógica.
- **Monitoramento**: É fundamental monitorar o impacto da V2 na remuneração das empresas e na disponibilidade dos serviços, especialmente para linhas que possam ter desafios operacionais em manter a consistência em ambos os sentidos.

---

## 📈 Comparativo: V1 vs. V2

| Aspecto | **Versão V1** | **Versão V2** |
|---------------------------------|---------------------------------------------------|-------------------------------------------------------------------|
| **Data de Ativação**            | Até 30/06/2025                                    | A partir de 01/07/2025                                            |
| **Critério "Sentido"**          | ❌ Não incluído no agrupamento do POF             | ✅ Incluído no agrupamento do POF                                 |
| **Granularidade do POF**        | Menor (por data, faixa, consórcio, serviço)       | Maior (por data, faixa, consórcio, serviço, **sentido**)          |
| **Impacto na Remuneração**      | Menos granular, sem distinção por sentido         | Mais granular, remuneração condicionada ao sentido da viagem      |
| **Alinhamento com Planejamento**| Menos direto                                      | Mais direto, utilizando modelos de planejamento por sentido       |
| **Complexidade**                | Menor                                             | Maior                                                             |

---

## 📝 Conclusão

A transição para a V2 do modelo `percentual_operacao_faixa_horaria` representa um avanço na precisão da apuração do POF e na remuneração dos serviços de transporte. A inclusão do `sentido` da viagem como critério é um passo importante para alinhar os cálculos com a realidade operacional e as necessidades de fiscalização. No entanto, exige atenção contínua ao monitoramento e à compreensão das implicações para os dados históricos e a performance dos serviços.

---

**Documentado por**: Kilo Code
**Data**: 08/08/2025 08:32 AM (UTC-3)
**Versão**: 1.0