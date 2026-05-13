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
  Services.AddSingleton<IMiddleware>(
    function(Provider: IServiceProvider): TObject
    begin
      Result := TApiKeyMiddleware.Create(Configuration);
    end);

  // Habilita a varredura e injeção para todos os controladores da aplicação
  Services.AddControllers;
end;

procedure TStartup.Configure(const App: IWebApplication);
begin
  // Configura a padronização global de serialização JSON de produção
  JsonDefaultSettings(JsonSettings.CamelCase.CaseInsensitive.ISODateFormat);

  App.Builder
    .UseExceptionHandler // 1. Global exception interceptor (sempre primeiro)
    .UseMiddleware<IMiddleware> // 2. Autenticação por API Key
    .MapControllers // 3. Mapeamento de rotas dos controladores REST
    .UseSwagger(SwaggerOptions.Title('AgendaDEXT API').Version('v1')); // 4. Documentação interativa (sempre por último)
end;

procedure TStartup.ConfigureDatabase(Options: TDbContextOptions);
begin
  var Servidor := FConfig.GetValue('Database:Server', 'localhost');
  var BaseDados := FConfig.GetValue('Database:Database', 'AgendaBDMG');
  var Usuario := FConfig.GetValue('Database:Username', 'sa');
  var Senha := FConfig.GetValue('Database:Password', 'SuaSenha@123');
  var Porta := FConfig.GetValue('Database:Port', '1433');

  var StringConexao := Format('Server=%s,%s;Database=%s;User Id=%s;Password=%s;', 
    [Servidor, Porta, BaseDados, Usuario, Senha]);

  Options
    .UseSQLServer(StringConexao)
    .WithPooling(True); // Pooling nativo ativado (obrigatório em APIs Web de produção)
end;

end.
