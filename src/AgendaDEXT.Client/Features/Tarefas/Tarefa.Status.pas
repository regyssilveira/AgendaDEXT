unit Tarefa.Status;

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
  TConfirmarStatusMsg = class end;
  TFecharStatusMsg = class end;

  TTarefaStatusFrame = class(TFrame, INavigationAware)
  private
    FViewModel: TTarefaStatusViewModel;
    FBindingEngine: TBindingEngine;
  published
    [BindText('TituloTarefa')]
    LblTitulo: TLabel;

    [BindText('StatusAtual')]
    LblStatusAtual: TLabel;

    [BindEdit('NovoStatus')]
    EdtNovoStatus: TEdit;

    [BindText('TransicoesValidas.Text')]
    LblOpcoesValidas: TLabel;

    [OnClickMsg(TConfirmarStatusMsg)]
    BtnConfirmar: TButton;

    [OnClickMsg(TFecharStatusMsg)]
    BtnVoltar: TButton;
  public
    procedure AfterConstruction; override;
    procedure OnNavigatedTo(const Context: TNavigationContext);
    procedure OnNavigatedFrom;
  end;

implementation

procedure TTarefaStatusFrame.AfterConstruction;
begin
  inherited;
  FViewModel := TTarefaStatusViewModel.Create;
  FBindingEngine := TBindingEngine.Create(Self, FViewModel);
end;

procedure TTarefaStatusFrame.OnNavigatedTo(const Context: TNavigationContext);
begin
  if Context.HasValue then
  begin
    // Desempacota os dados da tarefa selecionada passados como TValue
    // Exemplo: Id|Titulo|StatusAtual
    var Partes := Context.Value.AsString.Split(['|']);
    if Length(Partes) >= 3 then
      FViewModel.CarregarTarefa(StrToIntDef(Partes[0], 0), Partes[1], Partes[2]);
  end;
  FBindingEngine.Refresh;
end;

procedure TTarefaStatusFrame.OnNavigatedFrom;
begin
end;

end.
