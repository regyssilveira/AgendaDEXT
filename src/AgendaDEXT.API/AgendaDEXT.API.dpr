program AgendaDEXT.API;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  Dext.Utils,
  Dext,
  Dext.Entity,
  Dext.Web,
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
  Config: IConfiguration;
  Porta: Integer;
begin
  SetConsoleCharSet; // OBRIGATÓRIO: garante saída correta de caracteres UTF-8 no terminal console
  try
    WriteLn('===================================================');
    WriteLn('       AgendaDEXT API REST Backend — Inicializando ');
    WriteLn('===================================================');

    // Inicializa o builder da aplicação e injeta a classe Startup
    App := WebApplication;
    App.UseStartup(TStartup.Create);
    
    // Constrói os serviços e lê a porta customizada do arquivo de configuração
    Provider := App.BuildServices;
    Config := Provider.GetService<IConfiguration>;
    Porta := StrToIntDef(Config.GetValue('Server:Port', '9005'), 9005);

    WriteLn('Servidor configurado para escutar na porta: ', Porta);
    WriteLn('Documentação Swagger ativa em: http://localhost:' + IntToStr(Porta) + '/swagger');
    WriteLn('Pressione Ctrl+C para encerrar o serviço.');
    WriteLn('===================================================');

    // Inicia o loop do servidor HTTP de forma bloqueante
    App.Run(Porta);
  except
    on E: Exception do
      WriteLn('Erro Fatal na Inicialização: ' + E.Message);
  end;
  ConsolePause; // OBRIGATÓRIO: mantém a janela de terminal aberta durante execução de debug na IDE
end.
