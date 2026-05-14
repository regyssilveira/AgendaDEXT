program AgendaDEXT.Tests;

{$APPTYPE CONSOLE}

uses
  Dext.Utils,
  System.SysUtils,
  Dext.Testing,
  AgendaDEXT.Tests.TarefaService in 'AgendaDEXT.Tests.TarefaService.pas',
  AgendaDEXT.Tests.DateFormatUtils in 'AgendaDEXT.Tests.DateFormatUtils.pas',
  AgendaDEXT.Tests.ViewModels in 'AgendaDEXT.Tests.ViewModels.pas',
  Tarefa.Entity in '..\AgendaDEXT.API\Models\Tarefa.Entity.pas',
  Tarefa.DTOs in '..\AgendaDEXT.API\DTOs\Tarefa.DTOs.pas',
  Tarefa.Interfaces in '..\AgendaDEXT.API\Interfaces\Tarefa.Interfaces.pas',
  Tarefa.Service in '..\AgendaDEXT.API\Services\Tarefa.Service.pas',
  DateFormat.Utils in '..\AgendaDEXT.API\Utils\DateFormat.Utils.pas',
  Tarefa.Client.DTOs in '..\AgendaDEXT.Client\DTOs\Tarefa.Client.DTOs.pas',
  ApiClient in '..\AgendaDEXT.Client\Services\Networking\ApiClient.pas',
  Tarefa.ViewModel in '..\AgendaDEXT.Client\Features\Tarefas\Tarefa.ViewModel.pas';

begin
  SetConsoleCharSet; // OBRIGATÓRIO: garante encoding limpo no runner de console do Windows

  WriteLn('===================================================');
  WriteLn('   Iniciando Suíte de Testes — AgendaDEXT 100%     ');
  WriteLn('===================================================');

  // Configuração e execução mestre do Dext Testing Framework com saída verbosa obrigatória
  TTest.SetExitCode(
    TTest.Configure
      //.UseDashboard(9000, True)
      .VeryVerbose
      .RegisterFixtures([
        TTarefaServiceTests,
        TDateFormatUtilsTests,
        TViewModelsTests
      ])
      .Run
  );

  WriteLn('===================================================');
  ConsolePause; // OBRIGATÓRIO: mantém console aberto ao rodar via IDE
end.
