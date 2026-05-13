# AgendaDEXT — Sistema de Gerenciamento de Tarefas

Solução corporativa completa desenvolvida nativamente na plataforma **Delphi**, integrando uma **API REST** de alta concorrência e um **Cliente Desktop VCL** desacoplado. Todo o ecossistema é alicerçado sob a arquitetura pura do **Dext Framework**, com persistência relacional transacionada em **SQL Server**.

---

## 🚀 Tecnologias Utilizadas

- **Linguagem**: Delphi 11+ (Alexandria / Athens)
- **Framework Base**: Dext Framework Puro (`Dext.Core`, `Dext.Web`, `Dext.Entity`, `Dext.Net`, `Dext.UI`)
- **Banco de Dados**: Microsoft SQL Server 2022 (via Docker Compose)
- **Persistência**: Dext ORM (Mapeado via *Smart Properties*) com *Connection Pooling* nativo do FireDAC
- **Comunicação REST**: `TRestClient` com desserialização tipada mágica e autenticação via cabeçalho `X-API-KEY`
- **Frontend VCL**: Padrão **MVVM** orquestrado pelo **Dext Navigator** e **Magic Binding** bidirecional

---

## 📁 Estrutura de Diretórios

```text
/
├── docker-compose.yml             # Orquestração do SQL Server 2022 local
├── server.ini.example             # Template de configuração do Backend
├── client.ini.example             # Template de configuração do Cliente VCL
├── README.md                      # Documentação central do projeto
└── /src
    ├── /AgendaDEXT.API            # Projeto Backend (API RESTful)
    │   ├── /Controllers           # Endpoints mapeados via atributos
    │   ├── /Models                # Entidades ORM decoradas com Smart Properties
    │   ├── /Repositories          # Consultas tipadas e queries estatísticas SQL brutas
    │   ├── /Services              # Camada de regras e validações de negócio
    │   ├── /Middlewares           # Interceptador customizado de API Key
    │   └── AgendaDEXT.API.dpr     # Ponto de entrada console bloqueante
    │
    └── /AgendaDEXT.Client         # Projeto Frontend (Cliente Desktop VCL)
        ├── /Features              # Telas e ViewModels segmentadas por funcionalidade
        ├── /Services              # Abstração de TRestClient tipada
        └── AgendaDEXT.Client.dpr  # Ponto de entrada não-bloqueante via Dext Navigator
```

---

## ⚙️ Configuração do Ambiente e SQL Server

A infraestrutura relacional está empacotada no arquivo `docker-compose.yml` da raiz. Para provisionar a instância:

```bash
# Sobe o container local do SQL Server 2022 em segundo plano
docker-compose up -d
```

O script estrutural (DDL) completo, contendo a tabela `Tarefas` e os quatro índices filtrados de alta performance, encontra-se disponível em:
`src/AgendaDEXT.API/Database/schema.sql`

---

## 🔐 Configuração das Aplicações (Arquivos INI)

As aplicações procuram na inicialização os arquivos `server.ini` e `client.ini` em seus respectivos diretórios binários. Caso inexistentes, o sistema aplica graciosamente os valores-padrão.

### Parâmetros Base (`server.ini` e `client.ini`)
- **Porta Unificada**: `9005`
- **Senha de SA do Banco**: `SuaSenha@123`
- **API Key Padrão de Desenvolvimento**: `agenda-BDMG-dev-key-2026`

---

## ▶️ Como Executar

### 1. Executando o Backend (API REST)
Compile e execute o projeto `AgendaDEXT.API.dpr`. O console UTF-8 inicializará a escuta na porta **9005**:
```text
Servidor configurado para escutar na porta: 9005
Documentação Swagger ativa em: http://localhost:9005/swagger
```

### 2. Executando o Frontend (Cliente VCL)
Compile e execute o projeto `AgendaDEXT.Client.dpr`. A janela principal orquestrará a exibição nativa da listagem e do painel de estatísticas, conectando magicamente sem congelamento de tela.

---

## 📡 Exemplos de Chamadas REST (cURL)

> **Nota de Autenticação**: Com exceção do `/api/health`, todas as chamadas exigem a passagem do cabeçalho `X-API-KEY`.

### 1. Health Check (Público)
```bash
curl -X GET http://localhost:9005/api/health
```

### 2. Criar Nova Tarefa
```bash
curl -X POST http://localhost:9005/api/tarefas \
  -H "Content-Type: application/json" \
  -H "X-API-KEY: agenda-BDMG-dev-key-2026" \
  -d '{"titulo": "Implementar Testes Unitários", "descricao": "Validar regras de transição", "prioridade": 5}'
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

## 🏛️ Padrões e Decisões de Engenharia

- **Prevenção de Smart Linking**: Registrados os *Controllers* em blocos `initialization` para assegurar o descobrimento RTTI em tempo de execução.
- **Pureza de DTOs**: Os *Records* de comunicação são puramente separados das classes relacionais (*Entities*), impedindo injeção e manipulação indevida de dados.
- **ISO 8601 Estrito**: As datas transacionam de forma unificada no padrão `YYYY-MM-DDTHH:mm:ss` sem o sufixo Z, respeitando o *timezone* local do servidor.
