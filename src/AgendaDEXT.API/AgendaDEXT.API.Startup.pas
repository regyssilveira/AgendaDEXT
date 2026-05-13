unit AgendaDEXT.API.Startup;

interface

uses
  System.SysUtils,
  Dext.Entity.Core,
  Dext,
  Dext.Entity,
  Dext.Web;

type
  TStartup = class(TInterfacedObject, IStartup)
  private
    FConfig: IConfiguration;
    procedure ConfigureDatabase(Options: TDbContextOptions);
  public
    procedure ConfigureServices(const Services: TDextServices; const Configuration: IConfiguration);
    procedure Configure(const App: IWebApplication);
  end;

implementation

uses
  AgendaDEXT.Context,
  Tarefa.Interfaces,
  Tarefa.Repository,
  Tarefa.Service,
  ApiKeyMiddleware,
  Tarefas.Controller,
  Estatisticas.Controller,
  Health.Controller;

procedure TStartup.ConfigureServices(const Services: TDextServices; const Configuration: IConfiguration);
begin
  FConfig := Configuration;
  
  // Registra o contexto de banco de dados
  Services.AddDbContext<TAgendaDbContext>(ConfigureDatabase);

  // Registra os Repositórios e Serviços de negócio em escopo por requisição
  Services
    .AddScoped<ITarefaRepository, TTarefaRepository>
    .AddScoped<ITarefaService, TTarefaService>;

  // Registra o Middleware customizado de validação de API Key
  var ApiKeyMid := TApiKeyMiddleware.Create(FConfig);
  Services.AddSingleton<IMiddleware>(ApiKeyMid);

  // Habilita a varredura e injeção para todos os controladores da aplicação
  Services.AddControllers;
end;

procedure TStartup.Configure(const App: IWebApplication);
begin
  // api key
  FConfig.Item['Security:ApiKey'] := 'agenda-BDMG-dev-key-2026';

  // Configura a padronização global de serialização JSON de produção
  JsonDefaultSettings(JsonSettings.CamelCase.CaseInsensitive.ISODateFormat);

  App
    .MapControllers
    .UseMiddleware(TApiKeyMiddleware)
    .Builder
    .UseExceptionHandler
    .UseSwagger(SwaggerOptions.Title('AgendaDEXT API').Version('v1'));
end;

procedure TStartup.ConfigureDatabase(Options: TDbContextOptions);
begin
  // Acesso direto canônico via indexador nativo de chaves (sintaxe oficial para strings)
  var Servidor := FConfig['Database:Server'];
  if Trim(Servidor) = '' then Servidor := 'localhost';

  var BaseDados := FConfig['Database:Database'];
  if Trim(BaseDados) = '' then BaseDados := 'AgendaDEXT';

  var Usuario := FConfig['Database:Username'];
  if Trim(Usuario) = '' then Usuario := 'sa';

  var Senha := FConfig['Database:Password'];
  if Trim(Senha) = '' then Senha := 'SuaSenha@123';

  var Porta := FConfig['Database:Port'];
  if Trim(Porta) = '' then Porta := '1433';

  var StringConexao := Format('Server=%s,%s;Database=%s;User Id=%s;Password=%s;', 
    [Servidor, Porta, BaseDados, Usuario, Senha]);

  Options.UseDriver('MSSQL').ConnectionString := StringConexao;
  Options.WithPooling(True); // Pooling nativo ativado (obrigatório em APIs Web de produção)
end;

end.
