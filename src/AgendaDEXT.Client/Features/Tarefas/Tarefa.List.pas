unit Tarefa.List;

interface

uses
  System.SysUtils,
  System.Classes,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.StdCtrls,
  Vcl.Grids,
  Vcl.ExtCtrls,
  Dext.UI,
  Tarefa.ViewModel;

type
  // Declaração completa de mensagens para o Magic Binding (evita erros de forward declaration no Delphi)
  TCarregarMsg = class end;
  TProximaPaginaMsg = class end;
  TPaginaAnteriorMsg = class end;
  TLimparFiltrosMsg = class end;
  TAdicionarTarefaMsg = class end;
  TModificarStatusMsg = class end;
  TRemoverTarefaMsg = class end;

  TTarefaListFrame = class(TFrame, INavigationAware)
  private
    FViewModel: TTarefasDashboardViewModel;
    FBindingEngine: TBindingEngine;
  published
    // Componentes Visuais decorados com Magic Binding
    [BindText('TotalTarefas')]
    LblTotalTarefas: TLabel;

    [BindText('MediaPrioridade')]
    LblMediaPrioridade: TLabel;

    [BindText('ConcluidasUltimos7Dias')]
    LblConcluidas7Dias: TLabel;

    [BindText('StatusMensagem')]
    LblStatusRodape: TLabel;

    [BindEdit('FiltroStatus')]
    EdtFiltroStatus: TEdit;

    [OnClickMsg(TCarregarMsg)]
    BtnFiltrar: TButton;

    [OnClickMsg(TLimparFiltrosMsg)]
    BtnLimparFiltros: TButton;

    [OnClickMsg(TPaginaAnteriorMsg)]
    BtnAnterior: TButton;

    [OnClickMsg(TProximaPaginaMsg)]
    BtnProxima: TButton;

    [OnClickMsg(TAdicionarTarefaMsg)]
    BtnAdicionar: TButton;

    [OnClickMsg(TModificarStatusMsg)]
    BtnModificarStatus: TButton;

    [OnClickMsg(TRemoverTarefaMsg)]
    BtnRemover: TButton;

    // A Grid VCL principal
    StringGridTarefas: TStringGrid;
  public
    procedure AfterConstruction; override;
    procedure OnNavigatedTo(const Context: TNavigationContext);
    procedure OnNavigatedFrom;
    procedure SincronizarGrid;
  end;

implementation

uses
  ApiClient;

procedure TTarefaListFrame.AfterConstruction;
begin
  inherited;
  // Inicializa a engine de binding bidirecional nativa
  FViewModel := TTarefasDashboardViewModel.Create(TApiClient.Create);
  FBindingEngine := TBindingEngine.Create(Self, FViewModel);
end;

procedure TTarefaListFrame.OnNavigatedTo(const Context: TNavigationContext);
begin
  FViewModel.CarregarDados;
  SincronizarGrid;
  FBindingEngine.Refresh;
end;

procedure TTarefaListFrame.OnNavigatedFrom;
begin
  // Limpeza de contexto se necessário
end;

procedure TTarefaListFrame.SincronizarGrid;
begin
  if StringGridTarefas = nil then Exit;

  // Configuração de cabeçalhos
  StringGridTarefas.ColCount := 5;
  StringGridTarefas.RowCount := FViewModel.Tarefas.Count + 1;
  StringGridTarefas.Cells[0, 0] := 'ID';
  StringGridTarefas.Cells[1, 0] := 'Título';
  StringGridTarefas.Cells[2, 0] := 'Prioridade';
  StringGridTarefas.Cells[3, 0] := 'Status';
  StringGridTarefas.Cells[4, 0] := 'Data Criação';

  for var i := 0 to FViewModel.Tarefas.Count - 1 do
  begin
    var Item := FViewModel.Tarefas[i];
    StringGridTarefas.Cells[0, i + 1] := IntToStr(Item.Id);
    StringGridTarefas.Cells[1, i + 1] := Item.Titulo;
    StringGridTarefas.Cells[2, i + 1] := Item.PrioridadeDesc;
    StringGridTarefas.Cells[3, i + 1] := Item.Status;
    StringGridTarefas.Cells[4, i + 1] := Item.DataCriacao;
  end;
end;

end.
