program AgendaDEXT.Client;

uses
  Vcl.Forms,
  System.SysUtils,
  Dext.UI,
  Dext.UI.Navigator,
  Tarefa.Controller in 'Features\Tarefas\Tarefa.Controller.pas',
  Tarefa.List in 'Features\Tarefas\Tarefa.List.pas',
  Tarefa.Edit in 'Features\Tarefas\Tarefa.Edit.pas',
  Tarefa.Status in 'Features\Tarefas\Tarefa.Status.pas',
  Tarefa.ViewModel in 'Features\Tarefas\Tarefa.ViewModel.pas',
  Tarefa.Client.DTOs in 'DTOs\Tarefa.Client.DTOs.pas',
  ApiClient in 'Services\Networking\ApiClient.pas';

{$R *.res}

var
  MainForm: TForm;
  Navigator: INavigator;
  Controller: TTarefaOrquestradorController;
begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  
  // Cria o formulário base da aplicação com passagem estritamente por ponteiro mutável
  Application.CreateForm(TForm, MainForm);
  MainForm.Caption := 'AgendaDEXT Cliente VCL — Painel de Controle';
  MainForm.Width := 1024;
  MainForm.Height := 768;
  MainForm.Position := poScreenCenter;

  // Instancia e configura o Dext Navigator apontando para a variável de escopo nativa
  Navigator := TNavigator.Create;
  Navigator.UseAdapter(TCustomContainerAdapter.Create(MainForm));

  // Instancia o orquestrador e inicia o fluxo de UI empurrando a tela principal
  Controller := TTarefaOrquestradorController.Create(Navigator);
  Controller.IniciarFluxo;

  Application.Run;
end.
