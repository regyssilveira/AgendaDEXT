---
name: dext-di
description: Register and inject services using the Dext Dependency Injection container — lifetimes, constructor injection, factories, and scopes.
---

# Dext Dependency Injection

## Core Import

```pascal
uses
  Dext.DI; // TDextServices, IServiceProvider, IServiceScope
```

DI is configured through `TDextServices` in the Startup `ConfigureServices` method.

## Service Registration

```pascal
procedure TStartup.ConfigureServices(
  const Services: TDextServices;
  const Configuration: IConfiguration);
begin
  Services
    .AddScoped<IUserService, TUserService>
    .AddSingleton<ILogger, TConsoleLogger>
    .AddTransient<IValidator, TValidator>
    .AddDbContext<TAppDbContext>(ConfigureDatabase)
    .AddControllers;
end;
```

> `TDextServices` is a **Record** — never call `.Free` on it.
> Registrations are chained fluently with `.Add*`.

## Service Lifetimes

| Lifetime | Method | Behavior | Use Case |
|----------|--------|----------|----------|
| **Singleton** | `.AddSingleton<I, T>` | One instance for the entire app | Loggers, configuration, caches |
| **Scoped** | `.AddScoped<I, T>` | One instance per HTTP request | DbContext, user sessions |
| **Transient** | `.AddTransient<I, T>` | New instance every resolution | Validators, factories |

> **Captive dependency warning**: Never inject a Scoped service into a Singleton. The Scoped service would be held for the app's entire lifetime.

## Constructor Injection

Services registered in the container are automatically injected by constructor:

```pascal
type
  TUserService = class(TInterfacedObject, IUserService)
  private
    FRepository: IUserRepository;
    FLogger: ILogger;
  public
    constructor Create(Repository: IUserRepository; Logger: ILogger);
  end;

constructor TUserService.Create(Repository: IUserRepository; Logger: ILogger);
begin
  FRepository := Repository;
  FLogger := Logger;
end;
```

Registration:
```pascal
Services
  .AddScoped<IUserRepository, TUserRepository>
  .AddSingleton<ILogger, TConsoleLogger>
  .AddScoped<IUserService, TUserService>; // Dependencies auto-injected
```

## Factory Registration (Custom Initialization)

Use a factory function when constructor parameters are not all from DI:

```pascal
Services.AddSingleton<IJwtTokenHandler, TJwtTokenHandler>(
  function(Provider: IServiceProvider): TObject
  begin
    Result := TJwtTokenHandler.Create(JWT_SECRET, JWT_ISSUER, JWT_AUDIENCE, JWT_EXPIRATION);
  end);
```

> **Always use the explicit two-type-parameter form** to avoid compiler errors E2250/E2003:
> ```pascal
> Services.AddSingleton<IAuthService, TAuthService>(FactoryFunc)  // ✅
> Services.AddSingleton<IAuthService>(FactoryFunc)                // ❌ May fail
> ```

## Custom Constructor (`[ServiceConstructor]`)

When a class has multiple constructors, mark the one DI should use:

```pascal
type
  TUserService = class(TInterfacedObject, IUserService)
  public
    constructor Create; overload;

    [ServiceConstructor]  // DI uses this constructor
    constructor Create(Repo: IUserRepository; Logger: ILogger); overload;
  end;
```

## Resolving Services

### In Minimal APIs — Generic Parameters (Recommended)

```pascal
// ✅ Services auto-injected via generic type parameters
Builder.MapGet<IUserService, IResult>('/api/users',
  function(Svc: IUserService): IResult
  begin
    Result := Results.Ok(Svc.GetAll);
  end);
```

> ❌ **NEVER** do `Ctx.RequestServices.GetService<IUserService>` in Minimal APIs.

### In Controllers — Constructor Injection

```pascal
type
  [ApiController('/api/users')]
  TUsersController = class
  private
    FUserService: IUserService;
    FLogger: ILogger;
  public
    constructor Create(UserService: IUserService; Logger: ILogger);
  end;

constructor TUsersController.Create(UserService: IUserService; Logger: ILogger);
begin
  FUserService := UserService;
  FLogger := Logger;
end;
```

Register:
```pascal
Services
  .AddScoped<IUserService, TUserService>
  .AddSingleton<ILogger, TConsoleLogger>
  .AddControllers;
```

### Manual Resolution (Seeders, Background Tasks)

When you need a service outside the normal injection context, create a scope:

```pascal
var Scope := Provider.CreateScope;
try
  var Db := Scope.ServiceProvider.GetService(TAppDbContext) as TAppDbContext;
  // Use service...
finally
  Scope := nil;  // Disposes all scoped services in this scope
end;
```

## DbContext Registration

Always separate database configuration into a private method:

```pascal
procedure TStartup.ConfigureServices(const Services: TDextServices; ...);
begin
  Services
    .AddDbContext<TAppDbContext>(ConfigureDatabase)
    .AddScoped<IUserService, TUserService>;
end;

procedure TStartup.ConfigureDatabase(Options: TDbContextOptions);
begin
  Options
    .UseSQLite('App.db')
    .WithPooling(True);  // REQUIRED for Web APIs
end;
```

> **Always enable `.WithPooling(True)`** for production Web APIs. Web APIs are multithreaded; without pooling you get connection exhaustion.

## Field & Property Injection (`[Inject]`)

Beyond constructor injection, Dext also supports field and property injection using the `[Inject]` attribute:

```pascal
uses
  Dext.DI.Attributes; // [Inject]

type
  TUserService = class(TInterfacedObject, IUserService)
  public
    [Inject]
    Logger: ILogger;  // Injected automatically after construction
  end;
```

> Prefer constructor injection for required dependencies. Use `[Inject]` for optional dependencies.

## Best Practices

1. **Prefer constructor injection** — explicit dependencies are easier to test
2. **Use interfaces** — enables mocking in tests
3. **Scoped for DbContext** — one per HTTP request avoids threading issues
4. **Singleton for stateless** services (loggers, configuration)
5. **Enable Connection Pooling** for all Web API DbContexts
6. **Use fluent chaining** for all service registrations
7. **Avoid captive dependencies** — never inject Scoped into Singleton
8. **Use `[ServiceConstructor]`** when a class has multiple constructors

## Quick Reference

```pascal
// Registration
Services
  .AddScoped<IFoo, TFoo>
  .AddSingleton<IBar, TBar>
  .AddTransient<IBaz, TBaz>
  .AddSingleton<IFoo, TFoo>(FactoryFunc)  // With factory
  .AddDbContext<TCtx>(ConfigureDb)
  .AddControllers;

// Minimal API injection (automatic via generics)
Builder.MapGet<IFoo, IResult>('/path', function(Foo: IFoo): IResult ...);

// Manual scope
var Scope := Provider.CreateScope;
try
  var Svc := Scope.ServiceProvider.GetService(TFoo) as TFoo;
finally
  Scope := nil;
end;
```

