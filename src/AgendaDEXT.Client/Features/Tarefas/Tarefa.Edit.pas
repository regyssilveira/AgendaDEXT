unit Tarefa.Edit;

interface

uses
  System.SysUtils,
  System.Classes,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.StdCtrls,
  Dext.UI,
  Dext.UI.Binding,
  Tarefa.ViewModel;

type
  TSalvarMsg = class end;
  TCancelarMsg = class end;

  TTarefaEditFrame = class(TFrame, INavigationAware)
  private
    FViewModel: TTarefaEditViewModel;
    FBindingEngine: TBindingEngine;
  published
    [BindEdit('Titulo')]
    EdtTitulo: TEdit;

    [BindEdit('Descricao')]
    EdtDescricao: TEdit;

    // Vinculado a prioridade inteira via conversor customizado opcional ou input string
    [BindEdit('Prioridade')]
    EdtPrioridade: TEdit;

    [BindText('Errors.Text')]
    LblErros: TLabel;

    [OnClickMsg(TSalvarMsg)]
    BtnSalvar: TButton;

    [OnClickMsg(TCancelarMsg)]
    BtnCancelar: TButton;
  public
    procedure AfterConstruction; override;
    procedure OnNavigatedTo(const Context: TNavigationContext);
    procedure OnNavigatedFrom;
  end;

implementation

procedure TTarefaEditFrame.AfterConstruction;
begin
  inherited;
  FViewModel := TTarefaEditViewModel.Create;
  FBindingEngine := TBindingEngine.Create(Self, FViewModel);
end;

procedure TTarefaEditFrame.OnNavigatedTo(const Context: TNavigationContext);
begin
  FViewModel.Limpar;
  FBindingEngine.Refresh;
end;

procedure TTarefaEditFrame.OnNavigatedFrom;
begin
end;

end.
