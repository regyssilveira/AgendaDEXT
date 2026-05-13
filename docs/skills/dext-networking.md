---
name: dext-networking
description: Make HTTP requests from Delphi using the Dext REST client with fluent API, async/await, connection pooling, and authentication providers. Use when consuming external APIs or microservices from a Dext application.
---

# Dext Networking (REST Client)

Fluent, async HTTP client with built-in connection pooling and automatic JSON serialization.

## Core Import

```pascal
uses
  Dext.Net.RestClient,   // TRestClient
  Dext.Net.RestRequest,  // Fluent request builder
  Dext.Threading.Async;  // TAsyncTask integration
```

> `TRestClient` is a **record** — create cheaply, no `.Free` needed. It shares a thread-safe connection pool internally.

## Basic Usage

```pascal
var Client := TRestClient.Create('https://api.example.com');

// Fire-and-forget style
Client.Get('/users/1')
  .OnComplete(procedure(Res: IRestResponse)
    begin
      WriteLn('Status: ', Res.StatusCode);
      WriteLn('Body: ', Res.ContentString);
    end)
  .Start;
```

## HTTP Methods

```pascal
Client.Get('/resource');
Client.Post('/resource');
Client.Put('/resource');
Client.Delete('/resource');
Client.Patch('/resource');
```

## Building Requests

```pascal
// Headers and query parameters
Client.Get('/search')
  .Header('Authorization', 'Bearer ' + Token)
  .Header('X-Custom', 'Value')
  .QueryParam('q', 'delphi')
  .QueryParam('page', '1')
  .Start;

// JSON body (auto-serialized)
var User := TUser.Create('Alice');
try
  Client.Post('/users')
    .Body(User)     // Serialized to JSON automatically
    .Start;
finally
  User.Free;
end;

// Raw JSON string
Client.Post('/data')
  .JsonBody('{"name":"test"}')
  .Start;

// Stream body (file upload)
Client.Post('/upload')
  .Body(FileStream)
  .Start;
```

## Typed Responses (Auto-Deserialization)

```pascal
// Generic typed response
Client.Get<TUser>('/users/1')
  .OnComplete(procedure(User: TUser)
    begin
      WriteLn('User: ', User.Name);
    end)
  .Start;

// List response
Client.Get<IList<TUser>>('/users')
  .OnComplete(procedure(Users: IList<TUser>)
    begin
      for var U in Users do WriteLn(U.Name);
    end)
  .Start;
```

## Synchronous Execution

Block the current thread and wait for the result (use in console apps or background workers):

```pascal
var User := Client.Get<TUser>('/users/1').Await;
WriteLn(User.Name);

var Res := Client.Post('/data').JsonBody('{}').Await;
WriteLn(Res.StatusCode);
```

## Task Chaining

```pascal
Client.Get<TToken>('/auth/token')
  .ThenBy<TUser>(function(Token: TToken): TUser
    begin
      Result := Client.Get('/profile')
        .Header('Authorization', Token.AccessToken)
        .Execute<TUser>
        .Await;
    end)
  .OnComplete(procedure(User: TUser)
    begin
      UpdateUI(User);  // UI thread
    end)
  .Start;
```

## Cancellation

```pascal
var CTS := TCancellationTokenSource.Create;

Client.Get('/long-process')
  .Cancellation(CTS.Token)
  .Start;

// Later
CTS.Cancel;
```

## Authentication Providers

```pascal
// Bearer token (JWT)
Client.Authenticator(TBearerAuthProvider.Create('my-jwt-token'));

// Basic auth
Client.Authenticator(TBasicAuthProvider.Create('user', 'password'));

// API key in header
Client.Authenticator(TApiKeyAuthProvider.Create('X-API-Key', 'secret'));
```

## Response Object

```pascal
IRestResponse = interface
  StatusCode: Integer;         // 200, 404, etc.
  ContentString: string;       // Raw body as string
  ContentStream: TStream;      // Body as stream
  Headers: TStrings;           // Response headers
  IsSuccess: Boolean;          // StatusCode in 200-299
end;
```

## Error Handling

```pascal
Client.Get('/data')
  .OnComplete(procedure(Res: IRestResponse)
    begin
      if Res.IsSuccess then
        Process(Res.ContentString)
      else
        WriteLn('Error: ', Res.StatusCode);
    end)
  .OnException(procedure(Ex: Exception)
    begin
      WriteLn('Network error: ', Ex.Message);
    end)
  .Start;
```

## Connection Pool

`TRestClient` uses a shared `TConnectionPool` internally:
- Reuses `THttpClient` instances — no TCP/SSL overhead per request
- Fully thread-safe — safe to share across threads
- Automatic stale connection cleanup

No configuration needed; pooling is on by default.

## DI Registration

Register as singleton for the best pool reuse:

```pascal
Services.AddSingleton<IExternalApiClient, TExternalApiClient>(
  function(P: IServiceProvider): TObject
  begin
    Result := TExternalApiClient.Create(
      TRestClient.Create('https://api.external.com'));
  end);
```

