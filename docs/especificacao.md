# Especificação Técnica - Sistema de Gerenciamento de Tarefas em Delphi

## Objetivo

Desenvolver uma solução completa em Delphi composta por:

1. Um serviço REST para gerenciamento de tarefas.
2. Uma aplicação cliente VCL responsável pelo consumo do serviço.
3. Persistência em banco SQL Server.
4. Implementação de estatísticas SQL.
5. Estrutura organizada utilizando boas práticas de arquitetura e padrões de projeto.

O objetivo desta especificação é definir a solução completa, incluindo backend, frontend, persistência, arquitetura, organização de código, tratamento de erros e documentação.

---

# Requisitos Gerais

## Tecnologias Obrigatórias

### Backend
- Linguagem: Delphi
- Framework REST: Horse
- Banco de Dados: SQL Server
- Serialização JSON utilizando Horse de possível utilização, de outra forma utilize biblioteca REST nativa do Delphi
- Arquitetura em camadas

### Frontend
- Aplicação VCL Delphi
- Comunicação REST utilizando RESTRequest4Delphi

---

# Arquitetura Esperada

## Backend

A aplicação backend deve seguir arquitetura organizada em camadas:

### Camadas obrigatórias

- Controllers
- Services
- Repositories
- Entities/Models
- DTOs
- Factorys
- Database
- Middlewares
- Utils

---

# Estrutura de Diretórios Esperada

```text
/src
  /controller
  /service
  /repository
  /model
  /dto
  /factory
  /database
  /middleware
  /utils
  /interfaces
  server.dpr
```

---

# Requisitos Funcionais do Serviço REST

## Entidade Principal

### Tarefa

Campos obrigatórios:

| Campo | Tipo | Descrição |
|---|---|---|
| Id | Integer | Identificador único |
| Titulo | String(150) | Título da tarefa |
| Descricao | String(1000) | Descrição detalhada |
| Prioridade | Integer (1-5) | Prioridade da tarefa (enum) |
| Status | String(30) | Status atual (enum) |
| DataCriacao | DateTime | Data de criação |
| DataConclusao | DateTime Nullable | Data de conclusão |
| DataExclusao | DateTime Nullable | Data de exclusão (não serializado) |

---

## Formato de Data

Todas as datas devem ser serializadas e recebidas no formato **ISO 8601**:

```text
Formato: YYYY-MM-DDTHH:mm:ss
Exemplo: 2026-05-12T10:00:00
Timezone: horário local do servidor (sem sufixo Z)
```

---

# Regras de Negócio

## Status Permitidos (enumerator - Delphi)

```text
PENDENTE
EM_ANDAMENTO
CONCLUIDA
CANCELADA
```

---

## Prioridade (enumerator - Delphi)

| Valor | Descrição |
|------:|-----------|
| 1 | Muito Baixa |
| 2 | Baixa |
| 3 | Média |
| 4 | Alta |
| 5 | Crítica |

Valores fora do range 1-5 devem ser rejeitados com erro de validação.

---

## Regras de Transição de Status

As transições de status devem ser validadas. Transições não listadas devem ser rejeitadas.

| Status Atual | Transições Permitidas |
|---|---|
| PENDENTE | EM_ANDAMENTO, CANCELADA |
| EM_ANDAMENTO | CONCLUIDA, CANCELADA, PENDENTE |
| CONCLUIDA | _(nenhuma — estado final)_ |
| CANCELADA | PENDENTE |

### Regras adicionais

- Ao transicionar para `CONCLUIDA`, preencher automaticamente `DataConclusao` com a data/hora atual.
- `CONCLUIDA` é estado final definitivo — não é possível alterar o status após conclusão.
- `CANCELADA → PENDENTE` permite reabrir uma tarefa cancelada.

---

# Endpoints REST Obrigatórios

> **Nota:** O campo `DataExclusao` não deve ser serializado nas respostas JSON, pois somente registros não excluídos são retornados.

## Health Check

### GET

```http
/api/health
```

### Resposta (HTTP 200)

```json
{
  "status": "UP",
  "timestamp": "2026-05-12T10:00:00",
  "version": "1.0.0"
}
```

---

## Listar tarefas

Listar somente tarefas com data de exclusão nula (soft delete).

Ordenação padrão: `DataCriacao DESC` (mais recentes primeiro).

### GET

```http
/api/tarefas
```

### Parâmetros de Query (opcionais)

| Parâmetro | Tipo | Padrão | Descrição |
|-----------|------|--------|-----------|
| `page` | Integer | 1 | Número da página |
| `limit` | Integer | 20 | Itens por página (máx. 100) |
| `status` | String | — | Filtrar por status (`PENDENTE`, `EM_ANDAMENTO`, `CONCLUIDA`, `CANCELADA`) |
| `prioridade` | Integer | — | Filtrar por prioridade (1-5) |
| `ordem` | String | `dataCriacao_desc` | Ordenação: `dataCriacao_asc`, `dataCriacao_desc`, `prioridade_asc`, `prioridade_desc`, `titulo_asc`, `titulo_desc` |

### Resposta (HTTP 200)

```json
{
  "dados": [
    {
      "id": 1,
      "titulo": "Implementar API",
      "descricao": "Criar endpoints REST",
      "prioridade": 5,
      "status": "PENDENTE",
      "dataCriacao": "2026-05-12T10:00:00",
      "dataConclusao": null
    }
  ],
  "paginacao": {
    "paginaAtual": 1,
    "itensPorPagina": 20,
    "totalItens": 100,
    "totalPaginas": 5
  }
}
```

---

## Obter tarefa por ID

Listar somente tarefas com data de exclusão nula (soft delete).

### GET

```http
/api/tarefas/{id}
```

### Resposta (HTTP 200)

```json
{
  "id": 1,
  "titulo": "Implementar API",
  "descricao": "Criar endpoints REST",
  "prioridade": 5,
  "status": "PENDENTE",
  "dataCriacao": "2026-05-12T10:00:00",
  "dataConclusao": null
}
```

### Resposta (HTTP 404)

```json
{
  "sucesso": false,
  "mensagem": "Tarefa não encontrada",
  "detalhes": null
}
```

---

## Criar tarefa

### POST

```http
/api/tarefas
```

### Body

```json
{
  "titulo": "Nova tarefa",
  "descricao": "Descrição da tarefa",
  "prioridade": 3
}
```

### Regras de Validação

- `titulo`: obrigatório, máximo 150 caracteres.
- `descricao`: opcional, máximo 1000 caracteres.
- `prioridade`: obrigatória, inteiro entre 1 e 5.

### Resposta (HTTP 201)

```json
{
  "id": 1,
  "titulo": "Nova tarefa",
  "descricao": "Descrição da tarefa",
  "prioridade": 3,
  "status": "PENDENTE",
  "dataCriacao": "2026-05-12T10:00:00",
  "dataConclusao": null
}
```

---

## Atualizar tarefa (edição completa)

### PUT

```http
/api/tarefas/{id}
```

### Body

```json
{
  "titulo": "Título atualizado",
  "descricao": "Nova descrição",
  "prioridade": 4
}
```

### Regras de Validação

- Mesmas regras do POST.
- Não permite alterar `status` por este endpoint (utilizar o endpoint específico de status).
- Retorna `404` se a tarefa não existir ou estiver excluída.

### Resposta (HTTP 200)

```json
{
  "id": 1,
  "titulo": "Título atualizado",
  "descricao": "Nova descrição",
  "prioridade": 4,
  "status": "PENDENTE",
  "dataCriacao": "2026-05-12T10:00:00",
  "dataConclusao": null
}
```

---

## Atualizar status da tarefa

### PUT

```http
/api/tarefas/{id}/status
```

### Body

```json
{
  "status": "CONCLUIDA"
}
```

### Regras

- A transição deve respeitar a tabela de transições de status permitidas.
- Quando o status for alterado para `CONCLUIDA`, preencher automaticamente o campo `DataConclusao`.
- Transições inválidas retornam `422 Unprocessable Entity`.

### Resposta (HTTP 200)

```json
{
  "id": 1,
  "titulo": "Implementar API",
  "descricao": "Criar endpoints REST",
  "prioridade": 5,
  "status": "CONCLUIDA",
  "dataCriacao": "2026-05-12T10:00:00",
  "dataConclusao": "2026-05-12T15:30:00"
}
```

---

## Remover tarefa

  Atualizar o campo DataExclusao com a data atual. 
- Não apagar o registro. 
- Utilizaremos soft delete.

### DELETE

```http
/api/tarefas/{id}
```

### Resposta (HTTP 200)

> **Nota:** O DELETE retorna confirmação de sucesso em vez da entidade, pois o registro foi logicamente excluído e não deve mais ser exibido.

```json
{
  "sucesso": true,
  "mensagem": "Tarefa removida com sucesso"
}
```

---

# Endpoints Estatísticos

## Estatísticas gerais

### GET

```http
/api/estatisticas
```

### Resposta

```json
{
  "totalTarefas": 100,
  "mediaPrioridadePendentes": 3.5,
  "tarefasConcluidasUltimos7Dias": 15
}
```

---

# Consultas SQL Obrigatórias

## Total de tarefas

```sql
SELECT COUNT(*) AS TotalTarefas
FROM Tarefas
WHERE DataExclusao IS NULL;
```

---

## Média de prioridade de tarefas pendentes

```sql
SELECT AVG(CAST(Prioridade AS FLOAT)) AS MediaPrioridadePendentes
FROM Tarefas
WHERE Status = 'PENDENTE' AND DataExclusao IS NULL;
```

---

## Quantidade de tarefas concluídas nos últimos 7 dias

```sql
SELECT COUNT(*) AS TarefasConcluidasUltimos7Dias
FROM Tarefas
WHERE Status = 'CONCLUIDA'
AND DataConclusao >= DATEADD(DAY, -7, GETDATE()) 
AND DataExclusao IS NULL;
```

---

# Estrutura SQL Esperada

## Tabela Tarefas

```sql
CREATE TABLE Tarefas (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Titulo VARCHAR(150) NOT NULL,
    Descricao VARCHAR(1000),
    Prioridade INT NOT NULL CHECK (Prioridade BETWEEN 1 AND 5),
    Status VARCHAR(30) NOT NULL CHECK (Status IN ('PENDENTE', 'EM_ANDAMENTO', 'CONCLUIDA', 'CANCELADA')),
    DataCriacao DATETIME NOT NULL DEFAULT GETDATE(),
    DataConclusao DATETIME NULL,
    DataExclusao DATETIME NULL
);

-- Índices para otimização de consultas frequentes
CREATE INDEX IX_Tarefas_Status ON Tarefas (Status) WHERE DataExclusao IS NULL;
CREATE INDEX IX_Tarefas_DataExclusao ON Tarefas (DataExclusao);
CREATE INDEX IX_Tarefas_DataConclusao ON Tarefas (DataConclusao) WHERE Status = 'CONCLUIDA';
CREATE INDEX IX_Tarefas_Prioridade ON Tarefas (Prioridade) WHERE DataExclusao IS NULL;
```

---

# Segurança

## Requisitos mínimos

Implementar pelo menos:

- HTTPS Ready
- Middleware de autenticação simples
- API Key Header

### Header esperado

```http
X-API-KEY: SUA_CHAVE
```

### Valor padrão para desenvolvimento

```text
API Key padrão (dev): agenda-BDMG-dev-key-2026
```

> **Nota:** Em produção, a API Key deve ser configurável via variável de ambiente ou arquivo de configuração externo. O endpoint `/api/health` deve ser acessível **sem autenticação**.

---

# Tratamento de Erros

## Backend

Padronizar respostas de erro:

```json
{
  "sucesso": false,
  "mensagem": "Tarefa não encontrada",
  "detalhes": null
}
```

---

# Padrões de Projeto Obrigatórios

## Factory Method ou Abstract Factory

A solução deve utilizar Factorys para:

- Criação de conexões
- Criação de repositories
- Criação de services

Exemplo esperado:

```text
TFabricaRepository
TFabricaService
TFabricaConexao
```

---

# Persistência

## Requisitos

- Utilizar FireDAC
- Connection Pooling
- Queries parametrizadas
- Evitar SQL Injection
- Transactions quando necessário

---

# Configuração Externa (Arquivos INI)

As configurações do sistema devem ser externalizadas em arquivos `.ini`, localizados no mesmo diretório do executável. Isso permite alterar parâmetros sem recompilação.

## Backend — `server.ini`

```ini
[Database]
Server=localhost
Port=1433
Database=AgendaBDMG
Username=sa
Password=SuaSenha123
; Driver FireDAC para SQL Server
Driver=MSSQL

[Server]
Port=9000

[Security]
ApiKey=agenda-BDMG-dev-key-2026
```

### Parâmetros do Backend

| Seção | Chave | Tipo | Padrão | Descrição |
|-------|-------|------|--------|-----------|
| `[Database]` | `Server` | String | `localhost` | Endereço do SQL Server |
| `[Database]` | `Port` | Integer | `1433` | Porta do SQL Server |
| `[Database]` | `Database` | String | `AgendaBDMG` | Nome do banco de dados |
| `[Database]` | `Username` | String | `sa` | Usuário de conexão |
| `[Database]` | `Password` | String | — | Senha de conexão |
| `[Database]` | `Driver` | String | `MSSQL` | Driver FireDAC |
| `[Server]` | `Port` | Integer | `9000` | Porta do serviço REST |
| `[Security]` | `ApiKey` | String | `agenda-BDMG-dev-key-2026` | Chave de autenticação da API |

---

## Frontend — `client.ini`

```ini
[Server]
Host=localhost
Port=9000
; Protocolo: http ou https
Protocol=http

[Security]
ApiKey=agenda-BDMG-dev-key-2026
```

### Parâmetros do Frontend

| Seção | Chave | Tipo | Padrão | Descrição |
|-------|-------|------|--------|-----------|
| `[Server]` | `Host` | String | `localhost` | Endereço do servidor backend |
| `[Server]` | `Port` | Integer | `9000` | Porta do servidor backend |
| `[Server]` | `Protocol` | String | `http` | Protocolo de comunicação |
| `[Security]` | `ApiKey` | String | `agenda-BDMG-dev-key-2026` | Chave de autenticação da API |

> **Nota:** A URL base será montada automaticamente como `{Protocol}://{Host}:{Port}` (ex: `http://localhost:9000`).

---

## Regras de Carregamento

- Os arquivos `.ini` devem ser carregados na inicialização da aplicação.
- Se o arquivo não existir, criá-lo com os valores padrão.
- Utilizar `TIniFile` nativo do Delphi (`System.IniFiles`).
- Erros de leitura devem ser logados e valores padrão utilizados como fallback.
- Os arquivos `.ini` **não devem ser versionados** (incluir no `.gitignore`). Um arquivo `.ini.example` deve ser incluído como template.

---

# Logging

Implementar logs para:

- Requisições REST
- Erros
- Exceções
- SQL Errors

---

# Aplicação Cliente VCL

## Objetivo

Aplicação responsável exclusivamente pelo consumo do serviço REST.

Não deve existir persistência local.

---

# Funcionalidades Obrigatórias

## Listar tarefas

Exibir:

- Título
- Prioridade (com descrição: Muito Baixa, Baixa, Média, Alta, Crítica)
- Status
- Data de criação
- Suporte a paginação (botões Anterior/Próxima)
- Filtros por status e prioridade (ComboBox)
- Indicador de total de registros

---

## Criar tarefa

Tela/Modal com:

- Título (obrigatório, máx. 150 caracteres)
- Descrição (opcional, máx. 1000 caracteres)
- Prioridade (ComboBox com valores 1-5 e descrição)

---

## Editar tarefa

Tela/Modal com:

- Título (preenchido com valor atual)
- Descrição (preenchido com valor atual)
- Prioridade (preenchido com valor atual)
- Não permite alteração de status por esta tela

---

## Atualizar status

Permitir:

- Selecionar tarefa
- Alterar status via ComboBox
- Exibir apenas as transições válidas conforme status atual

---

## Remover tarefa

  Atualizar o campo DataExclusao com a data atual. 
- Não apagar o registro. 
- Utilizaremos soft delete.

### DELETE

```http
/api/tarefas/{id}
```

### Resposta (HTTP 200)

> **Nota:** O DELETE retorna confirmação de sucesso em vez da entidade, pois o registro foi logicamente excluído e não deve mais ser exibido.

```json
{
  "sucesso": true,
  "mensagem": "Tarefa removida com sucesso"
}
```

---

# Visualizar estatísticas

Exibir:

- Total de tarefas
- Média de prioridade pendente
- Concluídas últimos 7 dias

---

# Estrutura Esperada da Aplicação VCL

```text
/src
  /forms
  /services
  /dto
  /utils
  /components
  client.dpr
```

---

# Componentes Visuais Esperados

## Tela Principal

### Componentes mínimos

- Grid de tarefas
- Botões:
  - Adicionar
  - Editar
  - Atualizar Status
  - Remover
  - Atualizar Lista
- Painel de estatísticas

---

# Comunicação REST

## Requisitos

- Timeout configurável
- Tratamento de falhas
- Retry simples
- Serialização JSON

---

# Requisitos Não Funcionais

## Código

- Código limpo
- SOLID
- Baixo acoplamento
- Alta coesão
- Comentários apenas quando necessário
- Nomenclatura padronizada

---

# Diferenciais Desejáveis

## Backend

- Swagger/OpenAPI
- Versionamento de API
- Middleware global de exceções
- DTO validation
- Dependency Injection
- Testes unitários

---

## Frontend

- Interface moderna
- Feedback visual de carregamento
- Mensagens amigáveis
- Responsividade básica da interface VCL

---

# Critérios de Avaliação

A solução será avaliada considerando:

- Organização do projeto
- Qualidade do código
- Arquitetura
- Uso correto de padrões
- Tratamento de erros
- Qualidade das queries SQL
- Segurança
- Clareza do código
- Facilidade de manutenção
- Qualidade da interface VCL

---

# Entregáveis Esperados

## Repositório GitHub contendo

### Backend
- Código fonte completo
- Scripts SQL
- Arquivo README.md
- Collection Postman ou Insomnia

### Frontend
- Código fonte completo
- Projeto Delphi funcional

---

# README Esperado

O README deve conter:

- Descrição da solução
- Tecnologias utilizadas
- Estrutura do projeto
- Como executar backend
- Como executar frontend
- Como configurar SQL Server
- Como configurar API KEY
- Exemplos de chamadas REST

---

# Requisitos de Execução

## Backend

```text
- Delphi 11 ou superior
- SQL Server 2019+
- Horse Framework
- FireDAC
- Porta padrão: 9000 (http://localhost:9000)
```

---

## Frontend

```text
- Delphi VCL
- RESTRequest4Delphi
```

---

# Requisitos de Qualidade para IA

A IA responsável pelo desenvolvimento deve:

- Gerar código compilável
- Evitar código monolítico
- Separar responsabilidades
- Criar units organizadas
- Utilizar interfaces quando apropriado
- Evitar duplicação de código
- Criar código extensível
- Priorizar legibilidade
- Implementar tratamento de exceções
- Criar DTOs distintos das entidades
- Utilizar boas práticas Delphi modernas

---

# Resultado Esperado

Ao final, a solução deverá permitir:

1. Criar tarefas
2. Consultar tarefas
3. Atualizar status
4. Remover tarefas
5. Consultar estatísticas SQL
6. Consumir tudo via aplicação VCL
7. Operar completamente via REST API
8. Demonstrar arquitetura profissional em Delphi
