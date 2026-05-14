unit Tarefa.Service;

interface

uses
  System.SysUtils,
  Dext,
  Dext.Collections,
  Tarefa.Entity,
  Tarefa.DTOs,
  Tarefa.Interfaces,
  DateFormat.Utils;

type
  TTarefaService = class(TInterfacedObject, ITarefaService)
  private
    FRepo: ITarefaRepository;
    function MapearParaDto(Tarefa: TTarefa): TTarefaResponseDto;
    procedure ValidarPrioridade(Prioridade: Integer);
  public
    constructor Create(Repo: ITarefaRepository);
    function Listar(StatusFiltro: string; PrioridadeFiltro: Integer; OrdemFiltro: string; Pagina, Limite: Integer): TTarefasPaginadasDto;
    function ObterPorId(Id: Integer): TTarefaResponseDto;
    function Criar(Request: TCriarTarefaRequest): TTarefaResponseDto;
    function Atualizar(Request: TAtualizarTarefaRequest): TTarefaResponseDto;
    function AtualizarStatus(Request: TAtualizarStatusRequest): TTarefaResponseDto;
    procedure Remover(Id: Integer);
    function ObterEstatisticas: TEstatisticasResponseDto;
  end;

implementation

constructor TTarefaService.Create(Repo: ITarefaRepository);
begin
  inherited Create;
  FRepo := Repo;
end;

procedure TTarefaService.ValidarPrioridade(Prioridade: Integer);
begin
  if (Prioridade < 1) or (Prioridade > 5) then
    raise Exception.Create('Validação falhou: A prioridade deve estar no intervalo de 1 a 5.');
end;

function TTarefaService.MapearParaDto(Tarefa: TTarefa): TTarefaResponseDto;
begin
  Result.Id := Tarefa.Id;
  Result.Titulo := Tarefa.Titulo;
  Result.Descricao := Tarefa.Descricao;
  Result.Prioridade := Tarefa.Prioridade;
  Result.Status := Tarefa.Status;
  Result.DataCriacao := TDateFormatUtils.DateTimeToIsoString(Tarefa.DataCriacao);
  Result.DataConclusao := TDateFormatUtils.NullableDateTimeToIsoString(Tarefa.DataConclusao);
end;

function TTarefaService.Listar(StatusFiltro: string; PrioridadeFiltro: Integer; OrdemFiltro: string; Pagina, Limite: Integer): TTarefasPaginadasDto;
begin
  var Pag := Pagina;
  if Pag < 1 then Pag := 1;

  var Lim := Limite;
  if Lim < 1 then Lim := 20;
  if Lim > 100 then Lim := 100;

  var TotalRegistros: Integer := 0;
  var Entidades := FRepo.Listar(StatusFiltro, PrioridadeFiltro, OrdemFiltro, Pag, Lim, TotalRegistros);

  var ListaDto := TCollections.CreateList<TTarefaResponseDto>;
  for var Item in Entidades do
    ListaDto.Add(MapearParaDto(Item));

  Result.Dados := ListaDto;
  Result.Paginacao.PaginaAtual := Pag;
  Result.Paginacao.ItensPorPagina := Lim;
  Result.Paginacao.TotalItens := TotalRegistros;
  
  if TotalRegistros > 0 then
    Result.Paginacao.TotalPaginas := ((TotalRegistros - 1) div Lim) + 1
  else
    Result.Paginacao.TotalPaginas := 0;
end;

function TTarefaService.ObterPorId(Id: Integer): TTarefaResponseDto;
begin
  var Tarefa := FRepo.ObterPorId(Id);
  if Tarefa = nil then
    raise Exception.Create('Tarefa não encontrada');

  Result := MapearParaDto(Tarefa);
end;

function TTarefaService.Criar(Request: TCriarTarefaRequest): TTarefaResponseDto;
begin
  if Trim(Request.Titulo) = '' then
    raise Exception.Create('O título da tarefa é obrigatório.');

  if Length(Request.Titulo) > 150 then
    raise Exception.Create('O título excede o limite máximo de 150 caracteres.');

  if Length(Request.Descricao) > 1000 then
    raise Exception.Create('A descrição excede o limite máximo de 1000 caracteres.');

  ValidarPrioridade(Request.Prioridade);

  var NovaTarefa := TTarefa.Create;
  NovaTarefa.Titulo := Request.Titulo;
  NovaTarefa.Descricao := Request.Descricao;
  NovaTarefa.Prioridade := Request.Prioridade;
  NovaTarefa.Status := 'PENDENTE';
  NovaTarefa.DataCriacao := Now;

  var Criada := FRepo.Criar(NovaTarefa);
  Result := MapearParaDto(Criada);
end;

function TTarefaService.Atualizar(Request: TAtualizarTarefaRequest): TTarefaResponseDto;
begin
  var Tarefa := FRepo.ObterPorId(Request.Id);
  if Tarefa = nil then
    raise Exception.Create('Tarefa não encontrada');

  if Trim(Request.Titulo) = '' then
    raise Exception.Create('O título da tarefa é obrigatório.');

  if Length(Request.Titulo) > 150 then
    raise Exception.Create('O título excede o limite máximo de 150 caracteres.');

  if Length(Request.Descricao) > 1000 then
    raise Exception.Create('A descrição excede o limite máximo de 1000 caracteres.');

  ValidarPrioridade(Request.Prioridade);

  Tarefa.Titulo := Request.Titulo;
  Tarefa.Descricao := Request.Descricao;
  Tarefa.Prioridade := Request.Prioridade;

  var Atualizada := FRepo.Atualizar(Tarefa);
  Result := MapearParaDto(Atualizada);
end;

function TTarefaService.AtualizarStatus(Request: TAtualizarStatusRequest): TTarefaResponseDto;
begin
  var Tarefa := FRepo.ObterPorId(Request.Id);
  if Tarefa = nil then
    raise Exception.Create('Tarefa não encontrada');

  var StatusAtual := UpperCase(Trim(Tarefa.Status));
  var NovoStatus := UpperCase(Trim(Request.Status));

  if StatusAtual = 'CONCLUIDA' then
    raise Exception.Create('Transição inválida: A tarefa já está concluída e não permite modificações.');

  var Valido := False;
  if StatusAtual = 'PENDENTE' then
    Valido := (NovoStatus = 'EM_ANDAMENTO') or (NovoStatus = 'CANCELADA');
  if StatusAtual = 'EM_ANDAMENTO' then
    Valido := (NovoStatus = 'CONCLUIDA') or (NovoStatus = 'CANCELADA') or (NovoStatus = 'PENDENTE');
  if StatusAtual = 'CANCELADA' then
    Valido := (NovoStatus = 'PENDENTE');

  if not Valido then
    raise Exception.Create('Transição de status inválida de ' + StatusAtual + ' para ' + NovoStatus);

  Tarefa.Status := NovoStatus;
  if NovoStatus = 'CONCLUIDA' then
    Tarefa.DataConclusao.Value := Now;

  var Atualizada := FRepo.Atualizar(Tarefa);
  Result := MapearParaDto(Atualizada);
end;

procedure TTarefaService.Remover(Id: Integer);
begin
  var Tarefa := FRepo.ObterPorId(Id);
  if Tarefa = nil then
    raise Exception.Create('Tarefa não encontrada');

  FRepo.Remover(Tarefa);
end;

function TTarefaService.ObterEstatisticas: TEstatisticasResponseDto;
begin
  Result := FRepo.ObterEstatisticas;
end;

end.
