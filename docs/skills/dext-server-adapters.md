---
name: dext-server-adapters
description: Configure and deploy Dext Web applications using server adapters — Indy (self-hosted), WebBroker (ISAPI/CGI/IIS), SSL/HTTPS setup with OpenSSL or Taurus TLS, and deployment patterns (console service, VCL sidecar, reverse proxy, ISAPI DLL).
---

# Dext Server Adapters

Dext decouples the HTTP pipeline from the underlying transport via the `IWebHost` interface. Three adapters are available:

- **Indy** (Default) — self-hosted TCP server (console app, Windows service, VCL sidecar)
- **DCS (Cross-Socket)** — Extreme high-performance, asynchronous event-driven TCP server
- **WebBroker** — ISAPI DLL or CGI executable (IIS in-process, Apache mod_cgi)

## Current Adapter: Indy

### Core Classes

| Class / Interface | Unit | Role |
|---|---|---|
| `IWebHost` | `Dext.Web.Interfaces` | Adapter contract (`Run`, `Start`, `Stop`) |
| `IWebApplication` | `Dext.Web.Interfaces` | Full app host (extends `IWebHost`) |
| `TWebApplication` | `Dext.Web` (alias) | Concrete implementation |
| `TIndyWebServer` | `Dext.Web.Indy.Server` | Indy HTTP server (internal, used by `IWebApplication`) |

> `TDextApplication` is a deprecated alias for `TWebApplication`. Use `TWebApplication` or the `WebApplication` factory.

### Bootstrap — Console App (Standard)

```pascal
program MyApi;

{$APPTYPE CONSOLE}

uses
  Dext.MM,
  Dext.Utils,
  System.SysUtils,
  Dext,
  Dext.Web,
  MyApi.Startup in 'MyApi.Startup.pas';

var
  App: IWebApplication;
  Provider: IServiceProvider;
begin
  SetConsoleCharSet;  // REQUIRED in all console projects
  try
    App := WebApplication;           // Factory — creates TWebApplication
    App.UseStartup(TStartup.Create);
    Provider := App.BuildServices;
    App.Run(9000);                   // Blocking — returns when stopped
  except
    on E: Exception do
      WriteLn('Fatal: ' + E.Message);
  end;
  ConsolePause;
end.
```

### Bootstrap — VCL GUI (Non-blocking Sidecar)

```pascal
// TMainForm
procedure TMainForm.FormCreate(Sender: TObject);
begin
  FApp := WebApplication;
  FApp.UseStartup(TStartup.Create);
  FProvider := FApp.BuildServices;
  FApp.Start(8080);  // Non-blocking — server runs in background
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  FApp.Stop;  // Graceful shutdown before form closes
end;
```

### Run vs Start

| Method | Blocks? | Use For |
|--------|---------|---------|
| `App.Run(port)` | Yes | Console apps, Windows services |
| `App.Start(port)` | No | VCL/FMX forms with embedded server |
| `App.Stop` | — | Called manually to stop `Start`-ed server |

---

## SSL / HTTPS

SSL is configured via `appsettings.json`. Two SSL providers are supported.

### appsettings.json

```json
{
  "Server": {
    "Port": 8080,
    "UseHttps": "true",
    "SslProvider": "OpenSSL",
    "SslCert": "server.crt",
    "SslKey": "server.key",
    "SslRootCert": ""
  }
}
```

### SSL Providers

| Provider | Compiler Define | Unit | OpenSSL version |
|----------|----------------|------|-----------------|
| `OpenSSL` | `DEXT_ENABLE_SSL` | `Dext.Web.Indy.SSL.OpenSSL` | 1.0.x / 1.1.x |
| `Taurus` | `DEXT_ENABLE_TAURUS_TLS` | `Dext.Web.Indy.SSL.Taurus` | 1.1.x / 3.x |

Enable in `Sources\Dext.inc`:

```pascal
{.$DEFINE DEXT_ENABLE_SSL}         // Uncomment for OpenSSL
{.$DEFINE DEXT_ENABLE_TAURUS_TLS}  // Uncomment for Taurus TLS (OpenSSL 3.x)
```

> For OpenSSL, copy `ssleay32.dll` + `libeay32.dll` (v1.0.2) to the app output directory.
> For Taurus, use the matching Taurus DLLs for OpenSSL 1.1.x/3.x.

---

## Port Configuration

Port can be set in code or via `appsettings.json` (the JSON value wins if present):

```pascal
App.Run(9000);               // Port in code
App.SetDefaultPort(3000);   // Set default before Run/Start
```

Or in `appsettings.json`:

```json
{ "Server": { "Port": 9000 } }
```

---

## Deployment Patterns

### Pattern 1 — Standalone Console Service (Recommended for Production)

Run the `.exe` directly, optionally wrapped as a Windows service with NSSM.

```bash
# Run directly
MyApi.exe

# Or register as Windows service (NSSM)
nssm install MyApi "C:\services\MyApi\MyApi.exe"
nssm start MyApi
```

### Pattern 2 — Behind IIS/nginx Reverse Proxy

Use the Indy server on a local port and let IIS or nginx handle HTTPS termination.

**IIS Application Request Routing (`web.config`):**

```xml
<system.webServer>
  <rewrite>
    <rules>
      <rule name="ReverseProxy" stopProcessing="true">
        <match url="(.*)" />
        <action type="Rewrite" url="http://127.0.0.1:9000/{R:1}" />
      </rule>
    </rules>
  </rewrite>
</system.webServer>
```

**nginx:**

```nginx
server {
    listen 443 ssl;
    server_name api.example.com;
    location / {
        proxy_pass http://127.0.0.1:9000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

With this pattern:

- Dext runs on HTTP (no SSL needed in `appsettings.json`)
- IIS/nginx handles the SSL certificate
- No Indy SSL DLLs required

---

## WebBroker Adapter (ISAPI / CGI)

Unit: `Dext.Web.WebBroker`

Allows deploying a Dext application as:

- **ISAPI DLL** — hosted in-process inside IIS
- **CGI executable** — standard WebBroker CGI target

The Startup class, middleware pipeline, controllers, and DI configuration are **identical** to a console app. Only the project type (Library vs Program) and `.dpr` bootstrap differ.

### Key Classes

| Class | Role |
|-------|------|
| `TDextWebBrokerApp` | Global coordinator — `Configure` / `HandleRequest` / `Shutdown` |
| `TDextWebModule` | `TWebModule` subclass; set as `Application.WebModuleClass` |
| `TDextWebBrokerServer` | No-op `IWebHost` returned by the factory (IIS owns the loop) |
| `TDextWebBrokerRequest` | `IHttpRequest` backed by `TWebRequest` |
| `TDextWebBrokerResponse` | `IHttpResponse` with buffered output flushed to `TWebResponse` |

### ISAPI DLL Bootstrap

```pascal
library MyApi;

uses
  Web.Win.ISAPIApp,
  Dext.Web.WebBroker,
  MyApi.Startup in 'Startup.pas';

exports
  GetExtensionVersion,
  HttpExtensionProc,
  TerminateExtension;

begin
  TDextWebBrokerApp.Configure(TMyStartup.Create);
  Application.Initialize;
  Application.WebModuleClass := TDextWebModule;
end.
```

### CGI Bootstrap

```pascal
program MyApiCGI;

uses
  Web.CGIApp,
  Dext.Web.WebBroker,
  MyApi.Startup in 'Startup.pas';

begin
  TDextWebBrokerApp.Configure(TMyStartup.Create);
  Application.Initialize;
  Application.WebModuleClass := TDextWebModule;
  Application.Run;
  TDextWebBrokerApp.Shutdown;
end.
```

### How It Works

1. `TDextWebBrokerApp.Configure(Startup)` registers a `TServerFactory` via `IWebApplication.UseServerFactory`.
2. When `App.Start(0)` is called internally, the factory runs: it captures the built `TRequestDelegate` pipeline and `IServiceProvider` into class vars, then returns a no-op `TDextWebBrokerServer`.
3. On each incoming request, IIS calls `TDextWebModule.WebModuleBeforeDispatch`, which calls `TDextWebBrokerApp.HandleRequest`.
4. `HandleRequest` wraps `TWebRequest`/`TWebResponse` in Dext request/response objects, creates a request-scoped DI scope, runs the pipeline, then flushes the buffered response to `TWebResponse`.
5. `TDextWebBrokerApp.Shutdown` is called automatically in the `finalization` section of `Dext.Web.WebBroker` (or explicitly in the CGI program).

### Thread Safety

- `Configure` is called once at DLL load (single-threaded at that point).
- `FPipeline` and `FServiceProvider` are read-only after `Configure` — no locking needed.
- Each request gets its own `TDextWebBrokerContext` with its own DI scope (scoped services are request-isolated).

### Custom Server Factory (Advanced)

Use `IWebApplication.UseServerFactory` directly to plug in any transport:

```pascal
var Factory: TServerFactory := function(Port: Integer;
  Pipeline: TRequestDelegate; Services: IServiceProvider): IWebHost
begin
  // Store pipeline + services, return your own IWebHost
  Result := TMyCustomServer.Create(Pipeline, Services);
end;

App.UseServerFactory(Factory);
App.UseStartup(TMyStartup.Create);
App.Start(0);
```

`TServerFactory` is defined in `Dext.Web.Interfaces`:

```pascal
TServerFactory = reference to function(Port: Integer;
  Pipeline: TRequestDelegate; Services: IServiceProvider): IWebHost;
```

---

## DCS Adapter (High-Performance)

Unit: `Dext.Web.DCS`

The Delphi-Cross-Socket (DCS) adapter provides a high-performance, asynchronous event-driven HTTP server alternative to Indy, ideal for ultra-high concurrency and low-latency scenarios.

### Architecture & Key Features

- **OS-Native I/O Models**: Leverages the best asynchronous engine per platform: **IOCP** (Windows), **EPOLL** (Linux/Android), and **KQUEUE** (FreeBSD/macOS/iOS).
- **Ultra-High Concurrency**: Designed to handle over 100,000+ simultaneous connections (OS limits permitting).
- **Zero Memory Copy**: Highly optimized for throughput without redundant structural memory allocations.
- **Dual Stack Support**: Natively handles IPv4 and IPv6 simultaneously.

### Requirements

To use DCS, you must add the DCS library to your search path and enable the compiler directive in `Dext.inc` or project options:

```pascal
{$DEFINE DEXT_ENABLE_DCS}
```

> **License Warning**: DCS is LGPL-3.0 licensed. Take care when statically linking it into closed-source commercial applications.

### DCS Bootstrap

Since Indy is the default, switching to DCS requires swapping the Server Factory during initialization:

```pascal
uses
  Dext.Web,
  Dext.Web.DCS, // Add DCS Adapter
  MyApi.Startup;

begin
  App := WebApplication;
  
  // Swap the default engine for the DCS factory
  App.UseServerFactory(TDextDCSServer.Factory);
  
  App.UseStartup(TStartup.Create);
  App.Run(9000);
end;
```

The DCS server automatically manages optimal I/O threads based on your CPU count.

---

