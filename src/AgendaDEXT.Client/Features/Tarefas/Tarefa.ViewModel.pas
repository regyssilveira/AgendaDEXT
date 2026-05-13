unit Tarefa.ViewModel;

interface

uses
  System.SysUtils,
  System.Classes,
  Dext.Collections,
  Tarefa.Client.DTOs,
  ApiClient;

type
  TTarefaItemViewModel = class
  private
    FId: Integer;
    FTitulo: string;
    FPrioridadeDesc: string;
    FStatus: string;
    FDataCriacao: string;
  public
    property Id: Integer read FId write FId;
    property Titulo: string read FTitulo write FTitulo;
    property PrioridadeDesc: string read FPrioridadeDesc write FPrioridadeDesc;
    property Status: string read FStatus write FStatus;
    property DataCriacao: string read FDataCriacao write FDataCriacao;
  end;

  TTarefasDashboardViewModel = class
  private
    FApi: IApiClient;
    FTarefas: IList<TTarefaItemViewModel>;
    FTotalTarefas: Integer;
    FMediaPrioridade: Double;
    FConcluidasUltimos7Dias: Integer;
    FFiltroStatus: string;
    FFiltroPrioridade: Integer;
    FPaginaAtual: Integer;
    FTotalPaginas: Integer;
    FStatusMensagem: string;
    function ConverterPrioridade(Valor: Integer): string;
  public
    constructor Create(Api: IApiClient);
    procedure CarregarDados;
    procedure ProximaPagina;
    procedure PaginaAnterior;
    procedure LimparFiltros;

    // Propriedades publicadas para o Magic Binding
    property Tarefas: IList<TTarefaItemViewModel> read FTarefas;
    property TotalTarefas: Integer read FTotalTarefas write FTotalTarefas;
    property MediaPrioridade: Double read FMediaPrioridade write FMediaPrioridade;
    property ConcluidasUltimos7Dias: Integer read FConcluidasUltimos7Dias write FConcluidasUltimos7Dias;
    property FiltroStatus: string read FFiltroStatus write FFiltroStatus;
    property FiltroPrioridade: Integer read FFiltroPrioridade write FFiltroPrioridade;
    property PaginaAtual: Integer read FPaginaAtual write FPaginaAtual;
    property TotalPaginas: Integer read FTotalPaginas write FTotalPaginas;
    property StatusMensagem: string read FStatusMensagem write FStatusMensagem;
  end;

  TTarefaEditViewModel = class
  private
    FTitulo: string;
    FDescricao: string;
    FPrioridade: Integer;
    FErrors: TStringList;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Limpar;
    function Validar: Boolean;
    function ObterDtoCriacao: TCriarTarefaDto;

    property Titulo: string read FTitulo write FTitulo;
    property Descricao: string read FDescricao write FDescricao;
    property Prioridade: Integer read FPrioridade write FPrioridade;
    property Errors: TStringList read FErrors;
  end;

  TTarefaStatusViewModel = class
  private
    FTarefaId: Integer;
    FTituloTarefa: string;
    FStatusAtual: string;
    FNovoStatus: string;
    FTransicoesValidas: TStringList;
  public
    constructor Create;
    destructor Destroy; override;
    procedure CarregarTarefa(Id: Integer; const Titulo, StatusAtual: string);

    property TarefaId: Integer read FTarefaId;
    property TituloTarefa: string read FTituloTarefa;
    property StatusAtual: string read FStatusAtual;
    property NovoStatus: string read FNovoStatus write FNovoStatus;
    property TransicoesValidas: TStringList read FTransicoesValidas;
  end;

implementation

constructor TTarefasDashboardViewModel.Create(Api: IApiClient);
begin
  inherited Create;
  FApi := Api;
  FTarefas := TCollections.CreateObjectList<TTarefaItemViewModel>(True);
  FPaginaAtual := 1;
  FFiltroPrioridade := 0;
  FFiltroStatus := '';
end;

function TTarefasDashboardViewModel.ConverterPrioridade(Valor: Integer): string;
begin
  case Valor of
    1: Result := 'Muito Baixa';
    2: Result := 'Baixa';
    3: Result := 'Média';
    4: Result := 'Alta';
    5: Result := 'Crítica';
    else Result := 'Desconhecida';
  end;
end;

procedure TTarefasDashboardViewModel.CarregarDados;
begin
  try
    FStatusMensagem := 'Carregando dados da API...';
    
    // 1. Carrega Estatísticas
    var Est := FApi.ObterEstatisticas;
    FTotalTarefas := Est.TotalTarefas;
    FMediaPrioridade := Est.MediaPrioridadePendentes;
    FConcluidasUltimos7Dias := Est.TarefasConcluidasUltimos7Dias;

    // 2. Carrega a lista filtrada e paginada
    var Res := FApi.ListarTarefas(FFiltroStatus, FFiltroPrioridade, FPaginaAtual);
    
    FTarefas.Clear;
    for var Item in Res.Dados do
    begin
      var Vm := TTarefaItemViewModel.Create;
      Vm.Id := Item.Id;
      Vm.Titulo := Item.Titulo;
      Vm.PrioridadeDesc := ConverterPrioridade(Item.Prioridade);
      Vm.Status := Item.Status;
      Vm.DataCriacao := Item.DataCriacao;
      FTarefas.Add(Vm);
    end;

    FPaginaAtual := Res.Paginacao.PaginaAtual;
    FTotalPaginas := Res.Paginacao.TotalPaginas;
    FStatusMensagem := Format('Listagem atualizada. Exibindo página %d de %d.', [FPaginaAtual, FTotalPaginas]);
  except
    on E: Exception do
      FStatusMensagem := 'Erro de Conexão: ' + E.Message;
  end;
end;

procedure TTarefasDashboardViewModel.ProximaPagina;
begin
  if FPaginaAtual < FTotalPaginas then
  begin
    FPaginaAtual := FPaginaAtual + 1;
    CarregarDados;
  end;
end;

procedure TTarefasDashboardViewModel.PaginaAnterior;
begin
  if FPaginaAtual > 1 then
  begin
    FPaginaAtual := FPaginaAtual - 1;
    CarregarDados;
  end;
end;

procedure TTarefasDashboardViewModel.LimparFiltros;
begin
  FFiltroStatus := '';
  FFiltroPrioridade := 0;
  FPaginaAtual := 1;
  CarregarDados;
end;

constructor TTarefaEditViewModel.Create;
begin
  inherited Create;
  FErrors := TStringList.Create;
  Limpar;
end;

destructor TTarefaEditViewModel.Destroy;
begin
  FErrors.Free;
  inherited Destroy;
end;

procedure TTarefaEditViewModel.Limpar;
begin
  FTitulo := '';
  FDescricao := '';
  FPrioridade := 3; // Média padrão
  FErrors.Clear;
end;

function TTarefaEditViewModel.Validar: Boolean;
begin
  FErrors.Clear;
  if Trim(FTitulo) = '' then
    FErrors.Add('O título é obrigatório.');
  if Length(FTitulo) > 150 then
    FErrors.Add('O título excede 150 caracteres.');
  if Length(FDescricao) > 1000 then
    FErrors.Add('A descrição excede 1000 caracteres.');
  if (FPrioridade < 1) or (FPrioridade > 5) then
    FErrors.Add('Selecione uma prioridade válida entre 1 e 5.');

  Result := FErrors.Count = 0;
end;

function TTarefaEditViewModel.ObterDtoCriacao: TCriarTarefaDto;
begin
  Result := TCriarTarefaDto.Create;
  Result.Titulo := Trim(FTitulo);
  Result.Descricao := Trim(FDescricao);
  Result.Prioridade := FPrioridade;
end;

constructor TTarefaStatusViewModel.Create;
begin
  inherited Create;
  FTransicoesValidas := TStringList.Create;
end;

destructor TTarefaStatusViewModel.Destroy;
begin
  FTransicoesValidas.Free;
  inherited Destroy;
end;

procedure TTarefaStatusViewModel.CarregarTarefa(Id: Integer; const Titulo, StatusAtual: string);
begin
  FTarefaId := Id;
  FTituloTarefa := Titulo;
  FStatusAtual := UpperCase(Trim(StatusAtual));
  FNovoStatus := '';

  FTransicoesValidas.Clear;
  if FStatusAtual = 'PENDENTE' then
  begin
    FTransicoesValidas.Add('EM_ANDAMENTO');
    FTransicoesValidas.Add('CANCELADA');
  end
  else if FStatusAtual = 'EM_ANDAMENTO' then
  begin
    FTransicoesValidas.Add('CONCLUIDA');
    FTransicoesValidas.Add('CANCELADA');
    FTransicoesValidas.Add('PENDENTE');
  end
  else if FStatusAtual = 'CANCELADA' then
  begin
    FTransicoesValidas.Add('PENDENTE');
  end;
  // Se concluída, a lista fica vazia indicando estado final
end;

end.
