# Dext Framework — Agent Skills

> [!NOTE]
> **Propósito**: Esta pasta contém pacotes de instruções focados em agentes de IA (como Antigravity, Claude e Codex). Enquanto o **Dext Book** é o guia mestre para humanos, o **Skills** é otimizado para que IAs possam ler e aplicar padrões de código idiomáticos do Dext rapidamente.

Focused instruction packages for writing correct, idiomatic **Dext** (Delphi modern framework) code.

## Available Skills

| Skill | File | Load When |
|-------|------|-----------|
| **dext-app-structure** | `dext-app-structure.md` | New project setup, Startup class, middleware pipeline, `.dpr` bootstrap, project layout |
| **dext-web** | `dext-web.md` | HTTP endpoints, Minimal APIs, Controllers, routing, model binding, Results pattern |
| **dext-orm** | `dext-orm.md` | ORM entities, DbContext, querying, Smart Properties, CRUD |
| **dext-orm-advanced** | `dext-orm-advanced.md` | Relationships, eager loading, inheritance (TPH/TPT), Specifications, migrations, raw SQL, stored procedures, locking, multi-tenancy |
| **dext-di** | `dext-di.md` | Service registration, lifetimes (Scoped/Singleton/Transient), constructor injection, `[Inject]` attribute |
| **dext-auth** | `dext-auth.md` | JWT authentication, login endpoints, `[Authorize]`, claims, `TClaimsBuilder` |
| **dext-testing** | `dext-testing.md` | Unit tests, `Mock<T>`, fluent assertions (`Should`), `[TestFixture]`, snapshot testing |
| **dext-collections** | `dext-collections.md` | `IList<T>`, `TCollections`, LINQ operations, ownership semantics, `IChannel<T>` |
| **dext-api-features** | `dext-api-features.md` | Middleware, CORS, rate limiting, response caching, health checks, OpenAPI/Swagger, static files, compression |
| **dext-background** | `dext-background.md` | Background workers (`IHostedService`), configuration (`IConfiguration`, Options pattern), async tasks (`TAsyncTask`) |
| **dext-networking** | `dext-networking.md` | REST client (`TRestClient`), async HTTP requests, typed responses, auth providers, connection pooling |
| **dext-realtime** | `dext-realtime.md` | Hubs (`THub`), SignalR-compatible real-time messaging, groups, `IHubContext<T>` |
| **dext-database-as-api** | `dext-database-as-api.md` | Zero-code CRUD REST API from ORM entities (`MapDataApi<T>`) |
| **dext-desktop-ui** | `dext-desktop-ui.md` | VCL desktop apps, Navigator (Flutter-inspired), Magic Binding (declarative two-way), MVVM |
| **dext-server-adapters** | `dext-server-adapters.md` | Indy adapter (self-hosted), SSL/HTTPS (OpenSSL/Taurus), `Run` vs `Start`, deployment patterns, WebBroker/ISAPI (roadmap) |

## Manual Installation

Copy the `Docs/Skills/` folder into your project, then reference skills by filename.

| Agent | Project-level path | Global path |
|-------|--------------------|-------------|
| **Antigravity** | `.gemini/skills/` | `.gemini/skills/` |
| **Claude Code** | `.claude/skills/` | `~/.claude/skills/` |
| **Cursor** | `.agents/skills/` | `~/.agents/skills/` |
| **Cline** | `.cline/skills/` | `~/.cline/skills/` |
| **OpenCode** | `.agents/skills/` | `~/.agents/skills/` |
| **Continue** | `.continue/skills/` | `~/.continue/skills/` |

## How It Works

Skills are loaded dynamically when the agent needs them. The README is always loaded so the agent knows which skill to activate. Individual skill files are loaded on demand — keeping the context window lean. Note that some advanced users prefer to setup symbolic links to point tools like `claude-code` from `.claude/skills` directly to the `Docs/Skills` repository.

## Trigger Guide

**Load `dext-app-structure`** when:

- Creating a new Dext project from scratch
- Setting up the Startup class and middleware pipeline
- Configuring the `.dpr` entry point
- Organising project files and modules

**Load `dext-web`** when:

- Creating or modifying HTTP endpoints (`MapGet`, `MapPost`, `[HttpGet]`, `[HttpPost]`)
- Writing controllers (`[ApiController]`, `TInterfacedObject`)
- Handling model binding, route parameters, query strings, headers
- Using `Results.Ok`, `Results.Created`, etc.

**Load `dext-orm`** when:

- Defining entity classes with `[Table]`, `[PK]`, `[Required]`, etc.
- Writing `TDbContext` subclasses with `IDbSet<T>` properties
- Querying with `.Where`, `.ToList`, `.Find`, Smart Properties
- Adding/updating/removing records, database seeding

**Load `dext-orm-advanced`** when:

- Defining relationships (`[ForeignKey]`, `[InverseProperty]`, `[ManyToMany]`)
- Using eager loading (`.Include`)
- Working with TPH/TPT inheritance (`[Inheritance]`, `[DiscriminatorColumn]`)
- Writing Specification classes, migrations, raw SQL, stored procedures
- Implementing locking (optimistic/pessimistic) or multi-tenancy

**Load `dext-di`** when:

- Registering services with `.AddScoped`, `.AddSingleton`, `.AddTransient`
- Setting up `ConfigureServices` in a Startup class
- Injecting services via constructors or `[Inject]` attribute
- Using factory registration with `IServiceProvider`

**Load `dext-auth`** when:

- Implementing JWT authentication
- Creating login endpoints
- Using `[Authorize]`, `[AllowAnonymous]`
- Building claims with `TClaimsBuilder`

**Load `dext-testing`** when:

- Writing `[TestFixture]` classes
- Using `Mock<T>` (from `Dext.Mocks`)
- Writing fluent assertions with `Should(...)`
- Setting up test projects (`.dpr`)
- Using snapshot testing (`MatchSnapshot`)

**Load `dext-collections`** when:

- Using `IList<T>`, `TCollections.CreateList`, `TCollections.CreateObjectList`
- Writing LINQ-style queries on in-memory lists
- Using `IChannel<T>` for thread communication

**Load `dext-api-features`** when:

- Adding middleware (CORS, rate limiting, compression, static files)
- Configuring OpenAPI/Swagger documentation
- Setting up health checks, response caching

**Load `dext-background`** when:

- Creating background workers with `IHostedService`
- Loading or binding configuration (`appsettings.json`, environment variables, Options pattern)
- Using `TAsyncTask` for non-blocking async operations

**Load `dext-networking`** when:

- Making outbound HTTP requests to external APIs
- Using `TRestClient` for REST calls
- Needing async HTTP with typed deserialization

**Load `dext-realtime`** when:

- Building real-time features (WebSockets, push notifications)
- Using `THub` and `IHubContext<T>`
- Sending messages to connected clients or groups

**Load `dext-database-as-api`** when:

- Needing instant REST CRUD for an entity with zero controller code
- Using `App.Builder.MapDataApi<T>` for admin panels or rapid prototyping

**Load `dext-server-adapters`** when:

- Configuring SSL/HTTPS (`SslProvider`, `SslCert`, `SslKey`)
- Choosing between `App.Run` (blocking) and `App.Start` (non-blocking)
- Deploying behind IIS/nginx reverse proxy
- Questions about ISAPI/WebBroker or future adapter support

**Load `dext-desktop-ui`** when:

- Building VCL desktop applications with Dext Navigator
- Implementing Magic Binding (declarative two-way binding)
- Following MVVM pattern with ViewModel + Controller + Frame

## Key Framework Facts

- **Package**: Dext.Core, Dext.EF.Core, Dext.Web.Core, Dext.Testing, Dext.Net
- **Target**: Delphi 11 Alexandria and newer
- **Paradigm**: ASP.NET Core-inspired (Minimal APIs, Controller pattern, DI, ORM)
- **Source**: `$(DEXT)\Sources\` — set `DEXT` environment variable
- **Examples**: `$(DEXT)\Examples\` — 39 complete example projects
- **Docs**: `$(DEXT)\Docs\Book\` — 79 markdown chapters

## Critical Rules (Apply to All Skills)

1. **Route params use `{id}` syntax**, not `:id` (Express style)
2. **Route params in controllers MUST start with `/`**: `[HttpGet('/{id}')]`
3. **NEVER name a controller method `Create`** — conflicts with Delphi constructors (use `CreateUser`, `CreateOrder`, etc.)
4. **NEVER use `Ctx.RequestServices.GetService<T>`** — use generic type parameters
5. **NEVER use `TObjectList<T>`** for ORM results — use `IList<T>` from `Dext.Collections`
6. **NEVER use `[StringLength]`** — use `[MaxLength(N)]`
7. **NEVER use `NavType<T>`** — use `Nullable<T>` from `Dext.Types.Nullable`
8. **Always `.WithPooling(True)`** for Web API DbContexts
9. **Always call `.Update(Entity)` before `SaveChanges`** for detached entities
10. **`Mock<T>` is a Record** — never call `.Free` on it
11. **`Dext.Entity.Core`** must be in `uses` for `IDbSet<T>` generics to compile
12. **`SetConsoleCharSet`** is REQUIRED in all console projects (test runners, CLI tools)
13. **Uses Clause Order (CRITICAL)**: Due to Delphi's single class helper limitation, the `uses` order MUST always be: `Dext` → `Dext.Entity` → `Dext.Web`. The last one always wins and ensures Web methods (like `MapGet`, `AddWebStencils`) are visible.
14. **Smart Properties**: For entities, always use **IntType**, **StringType**, **DoubleType**, and **BoolType** aliases (from `Dext.Core.SmartTypes`) instead of `Prop<T>`.
