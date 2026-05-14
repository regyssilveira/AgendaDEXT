program AgendaDEXT.API;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  Dext.Utils,
  Dext,
  Dext.Entity,
  Dext.Web,
  Dext.Configuration.Yaml,
  AgendaDEXT.API.Startup in 'AgendaDEXT.API.Startup.pas',
  Estatisticas.Controller in 'Controllers\Estatisticas.Controller.pas',
  Health.Controller in 'Controllers\Health.Controller.pas',
  Tarefas.Controller in 'Controllers\Tarefas.Controller.pas',
  AgendaDEXT.Context in 'Database\AgendaDEXT.Context.pas',
  Tarefa.DTOs in 'DTOs\Tarefa.DTOs.pas',
  Tarefa.Interfaces in 'Interfaces\Tarefa.Interfaces.pas',
  ApiKeyMiddleware in 'Middlewares\ApiKeyMiddleware.pas',
  Tarefa.Entity in 'Models\Tarefa.Entity.pas',
  Tarefa.Repository in 'Repositories\Tarefa.Repository.pas',
  Tarefa.Service in 'Services\Tarefa.Service.pas',
  DateFormat.Utils in 'Utils\DateFormat.Utils.pas';

var
  App: IWebApplication;
  Provider: IServiceProvider;
  LPort: Integer;
  Config: IConfiguration;

begin
  SetConsoleCharSet; // OBRIGATÓRIO: garante saída correta de caracteres UTF-8 no terminal console
  try
    // Inicializa o orquestrador da aplicação e injeta a classe Startup
    App := WebApplication;
    App.UseStartup(TStartup.Create);
    Provider := App.BuildServices;

    // Inicializa a porta padronizada do serviço
    LPort := StrToIntDef(App.Configuration.Item['server:port'], 1);

    Writeln('');
    Writeln('=============================================================');
    Writeln('            AGENDA DEXT - SERVIDOR BACKEND (API)             ');
    Writeln('=============================================================');
    Writeln(Format(' [v] Status     : ONLINE na porta %d', [LPort])); 
    Writeln(Format(' [v] Base URL   : http://localhost:%d/api', [LPort]));
    Writeln(Format(' [v] Swagger UI : http://localhost:%d/swagger/doc/html', [LPort]));
    Writeln('-------------------------------------------------------------');
    Writeln('                CONEXAO COM BANCO DE DADOS                   ');
    Writeln('-------------------------------------------------------------');
    Writeln(' [ ] Driver     : SQL Server');
    Writeln(' [ ] Servidor   : localhost:1433');
    Writeln(' [ ] Database   : AgendaDEXT');
    Writeln(' [ ] Usuario    : sa');
    Writeln(' [v] Dext ORM   : Connection Pooling Ativo via AppDbContext');
    Writeln('=============================================================');
    Writeln(' Pressione Ctrl+C para encerrar o servidor...                ');
    Writeln('=============================================================');

    // Inicia a escuta da API REST de forma bloqueante
    App.Run(LPort);
  except
    on E: Exception do
      Writeln('Erro Fatal na Inicialização: ' + E.Message);
  end;
  ConsolePause; // OBRIGATÓRIO: mantém a janela de terminal aberta durante execução de debug na IDE
end.
