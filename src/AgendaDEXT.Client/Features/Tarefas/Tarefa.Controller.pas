unit Tarefa.Controller;

interface

uses
  System.SysUtils,
  Dext.UI,
  Tarefa.List,
  Tarefa.Edit,
  Tarefa.Status;

type
  TTarefaOrquestradorController = class
  private
    FNavigator: ISimpleNavigator;
  public
    constructor Create(Navigator: ISimpleNavigator);
    procedure IniciarFluxo;
    procedure AbrirCriacao;
    procedure AbrirStatus(Id: Integer; const Titulo, StatusAtual: string);
    procedure Voltar;
  end;

implementation

constructor TTarefaOrquestradorController.Create(Navigator: ISimpleNavigator);
begin
  inherited Create;
  FNavigator := Navigator;
end;

procedure TTarefaOrquestradorController.IniciarFluxo;
begin
  // Empurra a tela principal da listagem
  FNavigator.Push(TTarefaListFrame);
end;

procedure TTarefaOrquestradorController.AbrirCriacao;
begin
  // Empurra a tela de criação
  FNavigator.Push(TTarefaEditFrame);
end;

procedure TTarefaOrquestradorController.AbrirStatus(Id: Integer; const Titulo, StatusAtual: string);
begin
  // Empurra a tela de alteração de status com dados parametrizados
  var Dados := Format('%d|%s|%s', [Id, Titulo, StatusAtual]);
  FNavigator.Push(TTarefaStatusFrame, TValue.From<string>(Dados));
end;

procedure TTarefaOrquestradorController.Voltar;
begin
  FNavigator.Pop;
end;

end.
