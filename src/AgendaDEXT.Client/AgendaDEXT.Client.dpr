program AgendaDEXT.Client;

uses
  Vcl.Forms,
  System.SysUtils,
  Dext.UI,
  Tarefa.Controller in 'Features\Tarefas\Tarefa.Controller.pas',
  Tarefa.List in 'Features\Tarefas\Tarefa.List.pas',
  Tarefa.Edit in 'Features\Tarefas\Tarefa.Edit.pas',
  Tarefa.Status in 'Features\Tarefas\Tarefa.Status.pas',
  Tarefa.ViewModel in 'Features\Tarefas\Tarefa.ViewModel.pas',
  Tarefa.Client.DTOs in 'DTOs\Tarefa.Client.DTOs.pas',
  ApiClient in 'Services\Networking\ApiClient.pas';

{$R *.res}

var
  Navigator: ISimpleNavigator;
  Controller: TTarefaOrquestradorController;
begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  
  // Cria o formulário base da aplicação de forma implícita ou explícita
  Application.CreateForm(TForm, Application.MainForm);
  Application.MainForm.Caption := 'AgendaDEXT Cliente VCL — Painel de Controle';
  Application.MainForm.Width := 1024;
  Application.MainForm.Height := 768;
  Application.MainForm.Position := poScreenCenter;

  // Instancia e configura o Dext Navigator apontando para o formulário principal
  Navigator := TSimpleNavigator.Create;
  Navigator.UseAdapter(TCustomContainerAdapter.Create(Application.MainForm));

  // Instancia o orquestrador e inicia o fluxo de UI empurrando a tela principal
  Controller := TTarefaOrquestradorController.Create(Navigator);
  Controller.IniciarFluxo;

  Application.Run;
end.
