unit Tarefa.Controller;

interface

uses
  System.SysUtils,
  System.Rtti,
  Dext.UI,
  Tarefa.List,
  Tarefa.Edit,
  Tarefa.Status;

type
  TTarefaOrquestradorController = class
  private
    FNavigator: INavigator;
  public
    constructor Create(Navigator: INavigator);
    procedure IniciarFluxo;
    procedure AbrirCriacao;
    procedure AbrirStatus(Id: Integer; const Titulo, StatusAtual: string);
    procedure Voltar;
  end;

implementation

constructor TTarefaOrquestradorController.Create(Navigator: INavigator);
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
  // Empurra a tela de alteração de status
  FNavigator.Push(TTarefaStatusFrame);
end;

procedure TTarefaOrquestradorController.Voltar;
begin
  FNavigator.Pop;
end;

end.
