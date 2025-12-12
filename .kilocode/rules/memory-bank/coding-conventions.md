# Convenções de Código

## Python

### Estilo

- Seguir PEP 8 para estilo de código Python
- Usar snake_case para nomes de variáveis e funções
- Usar CamelCase para nomes de classes
- Limitar linhas a 88 caracteres (configuração Black)

### Estrutura de Módulos

- Cada módulo de captura deve ter:
  - `__init__.py` para exportação de funções
  - `flows.py` para definição de fluxos Prefect
  - `tasks.py` para tarefas individuais
  - `constants.py` para constantes e configurações
  - `utils.py` para funções utilitárias

### Documentação

- Docstrings para todas as funções e classes
- Comentários para código complexo
- README.md para cada módulo principal

## SQL (dbt)

### Nomenclatura

- Usar snake_case para nomes de modelos
- Prefixar tabelas temporárias com `aux_`
- Sufixar tabelas de staging com `_staging`

### Estrutura de Modelos

- Organizar modelos por domínio de negócio
- Incluir schema.yml para documentação
- Incluir testes para validação de dados

### Convenções SQL

- Palavras-chave SQL em MAIÚSCULAS
- Aliases para tabelas e colunas quando necessário
- Comentários para explicar lógica complexa

## Controle de Versão

### Commits

- Mensagens de commit descritivas
- Prefixar com tipo de alteração (feat, fix, docs, etc.)
- Referenciar número de issue quando aplicável

### Branches

- Feature branches para novas funcionalidades
- Hotfix branches para correções urgentes
- Pull requests para revisão de código
