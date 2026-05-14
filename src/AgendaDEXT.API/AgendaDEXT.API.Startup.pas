unit AgendaDEXT.API.Startup;

interface

uses
  System.SysUtils,
  Dext.Entity.Core,
  Dext,
  Dext.Entity,
  Dext.Web,
  Dext.Entity.Dialects,
  FireDAC.Stan.Intf,
  FireDAC.Comp.Client;

type
  TStartup = class(TInterfacedObject, IStartup)
  private
    FConfig: IConfiguration;
    procedure ConfigureDatabase(Options: TDbContextOptions);
    procedure RegisterPool;
  public
    procedure ConfigureServices(const Services: TDextServices; const Configuration: IConfiguration);
    procedure Configure(const App: IWebApplication);
  end;

implementation

uses
  FileLogProvider,
  AgendaDEXT.Context,
  Tarefa.Interfaces,
  Tarefa.Repository,
  Tarefa.Service,
  ApiKeyMiddleware,
  Tarefas.Controller,
  Estatisticas.Controller,
  Health.Controller;

const
  CONNECTION_DEF_NAME = 'AgendaPool';

procedure TStartup.RegisterPool;
begin
  if not FDManager.IsConnectionDef(CONNECTION_DEF_NAME) then
  begin
    var Servidor := FConfig['database:server'];
    if Servidor.Trim.IsEmpty then
      Servidor := 'localhost';

    var BaseDados := FConfig['database:database'];
    if BaseDados.Trim.IsEmpty then
      BaseDados := 'AgendaDEXT';

    var Usuario := FConfig['database:username'];
    if Usuario.Trim.IsEmpty then
      Usuario := 'sa';

    var Senha := FConfig['database:password'];
    if Senha.Trim.IsEmpty then
      Senha := 'SuaSenha@123';

    var Porta := FConfig['database:port'];
    if Porta.Trim.IsEmpty then
      Porta := '1433';

    var Driver := FConfig['database:driver'];
    if Driver.Trim.IsEmpty then
      Driver := 'MSSQL';

    var LDef := FDManager.ConnectionDefs.AddConnectionDef;
    LDef.Name := 'AgendaPool';
    LDef.Params.Add('DriverID=' + Driver);
    LDef.Params.Add('Server=' + Servidor);
    if StrToIntDef(Porta, 0) > 0 then
      LDef.Params.Add('Port=' + Porta);
    LDef.Params.Add('Database=' + BaseDados);
    LDef.Params.Add('User_Name=' + Usuario);
    LDef.Params.Add('Password=' + Senha);
    LDef.Params.Add('Pooled=True');
    LDef.Params.Add('POOL_MaximumItems=50');
    LDef.Params.Add('MARS=No');
    LDef.Params.Add('OSAuthent=No');
    LDef.Params.Add('Encrypt=No');
  end;
end;

procedure TStartup.ConfigureDatabase(Options: TDbContextOptions);
begin
  Self.RegisterPool;

  Options.Dialect := TSQLServerDialect.Create;
  Options.UseConnectionDef(CONNECTION_DEF_NAME);
  Options.WithPooling(True);
end;

procedure TStartup.ConfigureServices(const Services: TDextServices; const Configuration: IConfiguration);
begin
  FConfig := Configuration;

  // Registra o contexto de banco de dados
  Services.AddDbContext<TAgendaDbContext>(ConfigureDatabase);

  // Logging infrastructure with Telemetry Bridge
  Services
    .AddLogging(
      procedure(Builder: ILoggingBuilder)
      begin
        Builder
          .SetMinimumLevel(TLogLevel.Information)
          //.AddConsole
          .AddProvider(TFileLoggerProvider.Create)
          .AddTelemetry;
      end
    );

  // Registra os Repositórios e Serviços de negócio em escopo por requisição
  Services
    .AddScoped<ITarefaRepository, TTarefaRepository>
    .AddScoped<ITarefaService, TTarefaService>;

  // Habilita a varredura e injeção para todos os controladores da aplicação
  Services.AddControllers;
end;

procedure TStartup.Configure(const App: IWebApplication);
begin
  // Configura a padronização global de serialização JSON de produção
  JsonDefaultSettings(JsonSettings.CamelCase.CaseInsensitive.ISODateFormat);

  App
    .MapControllers
    .UseMiddleware(TApiKeyMiddleware)
    .Builder
    .UseExceptionHandler
    .UseSwagger(SwaggerOptions.Title('AgendaDEXT API').Version('v1'));
end;

end.
