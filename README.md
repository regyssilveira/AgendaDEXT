# Agenda DEXT — Sistema de Gerenciamento de Tarefas (DEXT Edition)

O **Agenda DEXT** é um sistema corporativo completo e moderno de gerenciamento de tarefas desenvolvido em Object Pascal (Delphi), arquitetado sob a ótica de um **Arquiteto de Software Sênior** para demonstrar máxima proficiência em padrões de projeto, Clean Code, princípios SOLID e estrita separação de responsabilidades.

Esta versão representa a evolução definitiva da solução, migrada em sua totalidade para o ecossistema de alta concorrência e performance do **DEXT Framework** (*Dext ORM*, *Dext Web*, *Dext Networking* e *Dext Testing Framework*), provendo uma comunicação unificada relacional e nativa em banco de dados **SQL Server**.

---

## 🛠️ Tecnologias e Bibliotecas Utilizadas

- **Linguagem Base:** Object Pascal (Delphi 11+ Alexandria / Athens)
- **Backend Web:** Dext Web Framework (Pipeline de middlewares globais, Roteamento via Atributos e Handlers fluentes via `Results`)
- **Acesso a Dados (ORM):** Dext ORM (`TAgendaDbContext`) com mapeamento declarativo nativo e filtragem segura via *Smart Properties* (`TTarefaProps`)
- **Frontend (Cliente VCL):** Delphi VCL nativo com Magic Binding bidirecional + `Dext.Net.RestClient` (Record de rede otimizada substituindo conectores defasados)
- **Banco de Dados:** Microsoft SQL Server 2022 (Conteinerizado localmente via Docker Compose)
- **Persistência Relacional:** Otimização de conexão via *Connection Pooling* nativo do FireDAC orquestrado pelo Dext
- **Testes Automatizados:** Dext Testing Framework (`[TestFixture]`, `[Test]`) integrado com *Mocking* de repositórios

---

## 🏛️ Arquitetura do Sistema e Ecossistema

A solução adota a abordagem de **Monorepo** segmentado fisicamente para garantir o isolamento absoluto entre as camadas de apresentação, roteamento e inteligência de dados.

### 1. Modelagem Relacional e ORM
A persistência transaciona na tabela `Tarefas` no SQL Server, blindada através de:
- **Mapeamento Declarativo:** Entidades mapeadas puramente via classes e propriedades nativas com `[Table('Tarefas')]`, `[PK, AutoInc]` e colunas representadas por `Nullable<T>`.
- **Soft Delete Automatizado:** Exclusões lógicas são registradas em tempo real na coluna `DataExclusao` via atributo `[SoftDelete]`. O Dext ORM intercepta e oculta transparentemente registros excluídos sem requerer *magic strings* na regra de negócio.

### 2. Backend (Server API — `AgendaDEXT.API`)
A API REST foi estruturada adotando o padrão semântico mestre do Dext:
- **Orquestrador de Boot (`TStartup`)**: Registra serviços em escopo sob demanda (`Services.AddScoped<T>`) e inicializa os middlewares de interceptação na ordem canônica.
- **Segurança Nativa por API Key**: Interceptador próprio (`TApiKeyMiddleware`) avaliando em *short-circuit* o cabeçalho `X-API-KEY`, barrando chamadas anônimas e franqueando acesso exclusivo à rota pública de monitoramento (`/api/health`).
- **DTOs Puros**: O envio e recebimento de cargas úteis ocorrem via *Records* fortemente tipadas, impedindo manipulações indesejadas de estado nas entidades transacionais.

### 3. Frontend (Client VCL — `AgendaDEXT.Client`)
O Client Desktop atua puramente como consumidor dos serviços distribuídos, preservando a mais estrita fidelidade visual e estrutural através dos seus formulários nativos (`TfrmPrincipal`, `TfrmTarefa`, `TfrmStatus`):
- **Magic Binding Declarativo**: Sincronização automatizada da interface visual (Grids, caixas de texto e botões) com as ViewModels por meio de marcações RTTI (`[BindEdit]`, `[OnClickMsg]`).
- **Navegação de Alta Performance**: Orquestrada por instâncias desacopladas do **Dext Navigator** (`Navigator.Push`), injetando *frames* visuais limpas com injeção tipada de estado sem causar congelamentos de thread.
- **Parametrização de Rede**: O cliente `TRestClient` inicializa dinamicamente consumindo as chaves e o BaseURL de seus arquivos locais de configuração na porta unificada **9005**.

---

## 📁 Estrutura do Monorepo

```text
/
├── docker-compose.yml             # Orquestração do SQL Server 2022 local
├── appsettings.yaml.example       # Template de configuração do Backend (YAML)
├── client.yaml.example            # Template de configuração do Cliente VCL (YAML)
├── README.md                      # Documentação central do projeto
├── /docs                          # Coleção do Postman e documentação técnica
└── /src
    ├── /AgendaDEXT.API            # Projeto Backend (API RESTful em Dext Puro)
    │   ├── /Controllers           # Controladores consolidados e roteamento via atributos
    │   ├── /Models                # Entidades ORM decoradas com Smart Properties
    │   ├── /Repositories          # Buscas tipadas e execuções brutas de queries estatísticas
    │   ├── /Services              # Inteligência de domínio e máquina de estados de status
    │   ├── /Middlewares           # Interceptador customizado de API Key e Logs
    │   └── AgendaDEXT.API.dpr     # Binário console bloqueante com saída UTF-8
    │
    └── /AgendaDEXT.Client         # Projeto Frontend (Cliente Desktop VCL)
        ├── /Features              # Telas VCL e ViewModels puras (MVVM)
        ├── /Services              # Wrapper otimizado da record TRestClient
        └── AgendaDEXT.Client.dpr  # Binário inicializador GUI não-bloqueante
```

---

## ⚡ Referência Rápida das APIs e Status HTTP

Consulte a matriz abaixo para uma visão geral instantânea das rotas transacionadas pelo backend, bem como os códigos de **Status HTTP esperados** para cenários de sucesso e validações. Todas as requisições transacionais exigem o cabeçalho `X-API-KEY`.

| Verbo | Rota | Descrição | Autenticação | Carga Útil / Query Params | Status HTTP Esperados |
| :---: | :--- | :--- | :---: | :--- | :--- |
| **GET** | `/api/health` | Monitoramento de saúde e versão em tempo real | Pública | *Nenhuma* | `200 OK` |
| **POST** | `/api/tarefas` | Cadastra uma nova tarefa na base | `X-API-KEY` | JSON: `{ titulo, descricao, prioridade }` | `201 Created` / `401 Unauthorized` / `400 Bad Request` |
| **GET** | `/api/tarefas` | Listagem de tarefas paginada e filtrada | `X-API-KEY` | Query: `status`, `prioridade`, `ordem`, `page`, `limit` | `200 OK` / `401 Unauthorized` |
| **GET** | `/api/tarefas/{id}` | Obtém os detalhes de uma tarefa específica | `X-API-KEY` | Rota: `id` | `200 OK` / `401 Unauthorized` / `404 Not Found` |
| **PUT** | `/api/tarefas/{id}` | Atualização completa dos dados da tarefa | `X-API-KEY` | JSON: `{ titulo, descricao, prioridade }` | `200 OK` / `401 Unauthorized` / `404 Not Found` |
| **PUT** | `/api/tarefas/{id}/status` | Transição segura de ciclo de vida (Status) | `X-API-KEY` | JSON: `{ status }` | `200 OK` / `401 Unauthorized` / `404 Not Found` / `422 Unprocessable Entity` |
| **DELETE** | `/api/tarefas/{id}` | Exclusão lógica transacionada (*Soft Delete*) | `X-API-KEY` | Rota: `id` | `200 OK` / `401 Unauthorized` / `404 Not Found` |
| **GET** | `/api/estatisticas` | Indicadores e métricas de negócio consolidadas | `X-API-KEY` | *Nenhuma* | `200 OK` / `401 Unauthorized` |

---

## 🚀 Passo a Passo de Execução

### Etapa 1: Subindo o Banco de Dados (SQL Server)
A infraestrutura relacional está empacotada no arquivo `docker-compose.yml` da raiz. Para provisionar a instância isolada:
```powershell
docker-compose up -d
```
O banco atenderá na porta padronizada `1433` com a senha de SA `SuaSenha@123`. Os scripts de criação física (DDL) e os quatro índices filtrados de alta performance estão estruturados em:
`src/AgendaDEXT.API/Database/schema.sql`

### Etapa 2: Configurando as Chaves e Arquivos YAML
As aplicações buscam os arquivos de configuração locais no mesmo diretório de seus executáveis. O arquivo de configuração do servidor deve se chamar `appsettings.yaml`, enquanto o do cliente VCL é `client.yaml`. Para total flexibilidade e modernização, os templates base fornecidos na raiz seguem o padrão hierárquico **YAML** (`appsettings.yaml.example` e `client.yaml.example`). Caso inexistentes na inicialização, o sistema gera os binários consumindo os seguintes valores-padrão alinhados com a raiz:
- **Porta Unificada**: `9005`
- **Senha do Banco**: `SuaSenha@123`
- **API Key Padrão de Desenvolvimento**: `agenda-BDMG-dev-key-2026`

### Etapa 3: Compilando e Rodando o Servidor (Backend)
Abra o projeto do servidor (`src\AgendaDEXT.API\AgendaDEXT.API.dpr`) na IDE ou compile por linha de comando. O console inicializará o serviço atestando a escuta ativa:
```text
Servidor configurado para escutar na porta: 9005
Documentação Swagger ativa em: http://localhost:9005/swagger
```

### Etapa 4: Testando o Aplicativo Desktop (Cliente VCL)
Abra e compile o projeto cliente (`src\AgendaDEXT.Client\AgendaDEXT.Client.dpr`). O formulário de controle orquestrará as requisições nativas via `TRestClient` para consultar a base, inserir registros, validar o fluxo de status e renderizar as métricas em tempo real.

---

## 📡 Exemplos de Chamadas REST (cURL)

> **Dica de Homologação**: Uma coleção oficial completa e padronizada para o **Postman** com todos os payloads e variáveis pré-configuradas está disponível em `docs/AgendaDEXT.postman_collection.json`.

> **Nota de Autenticação**: O cabeçalho `X-API-KEY` é de envio obrigatório para todas as rotas transacionadas, exceto a consulta de saúde.

### 1. Health Check (Público)
```bash
curl -X GET http://localhost:9005/api/health
```

### 2. Criar Nova Tarefa
```bash
curl -X POST http://localhost:9005/api/tarefas \
  -H "Content-Type: application/json" \
  -H "X-API-KEY: agenda-BDMG-dev-key-2026" \
  -d '{"titulo": "Revisar Integração Dext", "descricao": "Validar rotinas de injeção e endpoints", "prioridade": 5}'
```

### 3. Listar Tarefas (Paginado e Filtrado)
```bash
curl -X GET "http://localhost:9005/api/tarefas?status=PENDENTE&prioridade=5&page=1&limit=10" \
  -H "X-API-KEY: agenda-BDMG-dev-key-2026"
```

### 4. Modificar Status da Tarefa
```bash
curl -X PUT http://localhost:9005/api/tarefas/1/status \
  -H "Content-Type: application/json" \
  -H "X-API-KEY: agenda-BDMG-dev-key-2026" \
  -d '{"status": "CONCLUIDA"}'
```

### 5. Consultar Estatísticas de Negócio
```bash
curl -X GET http://localhost:9005/api/estatisticas \
  -H "X-API-KEY: agenda-BDMG-dev-key-2026"
```

---

## 🧪 Rodando a Suíte de Testes Unitários Automatizados

Para certificar que a inteligência de domínio e validações críticas se mantiveram absolutamente puras na transição de infraestrutura, a suíte de testes do projeto original é plenamente suportada e executada através do **Dext Testing Framework**.

A cobertura abrange:
1. **Regras de Negócio e Injeções**: Testes isolados com a estrutura de `Mock<T>` em repositórios simulados, atestando a rejeição de títulos vazios, descrições extensas e prioridades fora do range de 1 a 5.
2. **Consistência da Máquina de Estados**: Garantia de que a transição para `CONCLUIDA` preencha a data de encerramento em tempo real e bloqueie reaberturas indevidas.
3. **Precisão de Conversores**: Validação estrita das strings geradas no formato ISO 8601 (`YYYY-MM-DDTHH:mm:ss`) sem perdas de fuso horário.

---
*Desenvolvido sob rígidas premissas de Clean Code, Injeção de Dependências e arquitetura de ponta na plataforma Delphi.*
