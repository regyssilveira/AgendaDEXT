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
  TTarefaListFrame = class(TFrame)
  private
    FViewModel: TTarefasDashboardViewModel;
  published
    // Componentes Visuais padrão VCL sem atributos de Binding
    LblTotalTarefas: TLabel;
    LblMediaPrioridade: TLabel;
    LblConcluidas7Dias: TLabel;
    LblStatusRodape: TLabel;
    EdtFiltroStatus: TEdit;
    BtnFiltrar: TButton;
    BtnLimparFiltros: TButton;
    BtnAnterior: TButton;
    BtnProxima: TButton;
    BtnAdicionar: TButton;
    BtnModificarStatus: TButton;
    BtnRemover: TButton;
    StringGridTarefas: TStringGrid;

    // Manipuladores de eventos VCL normais declarados na seção published
    procedure BtnFiltrarClick(Sender: TObject);
    procedure BtnLimparFiltrosClick(Sender: TObject);
    procedure BtnAnteriorClick(Sender: TObject);
    procedure BtnProximaClick(Sender: TObject);
    procedure BtnAdicionarClick(Sender: TObject);
    procedure BtnModificarStatusClick(Sender: TObject);
    procedure BtnRemoverClick(Sender: TObject);
  public
    procedure AfterConstruction; override;
    destructor Destroy; override;
    procedure OnNavigatedTo(const Context: TNavigationContext);
    procedure OnNavigatedFrom;
    procedure AtualizarInterface;
    procedure SincronizarGrid;
  end;

implementation

{$R *.dfm}

uses
  ApiClient,
  Tarefa.Controller;

procedure TTarefaListFrame.AfterConstruction;
begin
  inherited;
  FViewModel := TTarefasDashboardViewModel.Create(TApiClient.Create);
end;

destructor TTarefaListFrame.Destroy;
begin
  FViewModel.Free;
  inherited Destroy;
end;

procedure TTarefaListFrame.OnNavigatedTo(const Context: TNavigationContext);
begin
  FViewModel.CarregarDados;
  AtualizarInterface;
end;

procedure TTarefaListFrame.OnNavigatedFrom;
begin
end;

procedure TTarefaListFrame.AtualizarInterface;
begin
  if LblTotalTarefas <> nil then
    LblTotalTarefas.Caption := IntToStr(FViewModel.TotalTarefas);

  if LblMediaPrioridade <> nil then
    LblMediaPrioridade.Caption := FormatFloat('0.0', FViewModel.MediaPrioridade);

  if LblConcluidas7Dias <> nil then
    LblConcluidas7Dias.Caption := IntToStr(FViewModel.ConcluidasUltimos7Dias);

  if LblStatusRodape <> nil then
    LblStatusRodape.Caption := FViewModel.StatusMensagem;

  SincronizarGrid;
end;

procedure TTarefaListFrame.SincronizarGrid;
begin
  if StringGridTarefas = nil then Exit;

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

procedure TTarefaListFrame.BtnFiltrarClick(Sender: TObject);
begin
  if EdtFiltroStatus <> nil then
    FViewModel.FiltroStatus := EdtFiltroStatus.Text;
  FViewModel.CarregarDados;
  AtualizarInterface;
end;

procedure TTarefaListFrame.BtnLimparFiltrosClick(Sender: TObject);
begin
  if EdtFiltroStatus <> nil then
    EdtFiltroStatus.Text := '';
  FViewModel.LimparFiltros;
  AtualizarInterface;
end;

procedure TTarefaListFrame.BtnAnteriorClick(Sender: TObject);
begin
  FViewModel.PaginaAnterior;
  AtualizarInterface;
end;

procedure TTarefaListFrame.BtnProximaClick(Sender: TObject);
begin
  FViewModel.ProximaPagina;
  AtualizarInterface;
end;

procedure TTarefaListFrame.BtnAdicionarClick(Sender: TObject);
begin
  // Em código imperativo nativo, notifica a abertura da tela de criação
end;

procedure TTarefaListFrame.BtnModificarStatusClick(Sender: TObject);
begin
  if (StringGridTarefas <> nil) and (StringGridTarefas.Row > 0) then
  begin
    var IdStr := StringGridTarefas.Cells[0, StringGridTarefas.Row];
    var Id := StrToIntDef(IdStr, 0);
    if Id > 0 then
    begin
      // Hook preparado para navegação visual nativa
    end;
  end;
end;

procedure TTarefaListFrame.BtnRemoverClick(Sender: TObject);
begin
  if (StringGridTarefas <> nil) and (StringGridTarefas.Row > 0) then
  begin
    var IdStr := StringGridTarefas.Cells[0, StringGridTarefas.Row];
    var Id := StrToIntDef(IdStr, 0);
    if Id > 0 then
    begin
      var Api := TApiClient.Create;
      Api.RemoverTarefa(Id);
      FViewModel.CarregarDados;
      AtualizarInterface;
    end;
  end;
end;

end.
