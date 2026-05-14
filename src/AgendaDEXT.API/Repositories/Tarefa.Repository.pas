unit Tarefa.Repository;

interface

uses
  System.SysUtils,
  Dext,
  Dext.Entity,
  Dext.Entity.Core,
  Dext.Web,
  Dext.Collections,
  Tarefa.Entity,
  Tarefa.DTOs,
  Tarefa.Interfaces,
  AgendaDEXT.Context;

type
  TTarefaRepository = class(TInterfacedObject, ITarefaRepository)
  private
    FDb: TAgendaDbContext;
  public
    constructor Create(Db: TAgendaDbContext);
    function Listar(StatusFiltro: string; PrioridadeFiltro: Integer; OrdemFiltro: string; Pagina, Limite: Integer; out TotalRegistros: Integer): IList<TTarefa>;
    function ObterPorId(Id: Integer): TTarefa;
    function Criar(Tarefa: TTarefa): TTarefa;
    function Atualizar(Tarefa: TTarefa): TTarefa;
    procedure Remover(Tarefa: TTarefa);
    function ObterEstatisticas: TEstatisticasResponseDto;
  end;

implementation

uses
  System.StrUtils,
  Dext.Types.Nullable,
  Dext.Core.SmartTypes;

constructor TTarefaRepository.Create(Db: TAgendaDbContext);
begin
  inherited Create;
  FDb := Db;
end;

function TTarefaRepository.Listar(StatusFiltro: string; PrioridadeFiltro: Integer; OrdemFiltro: string; Pagina, Limite: Integer; out TotalRegistros: Integer): IList<TTarefa>;
begin
  var t := Prototype.Entity<TTarefa>;
  var Query := FDb.Tarefas.QueryAll;

  if Trim(StatusFiltro) <> '' then
    Query.Where(t.Status = UpperCase(Trim(StatusFiltro)));

  if PrioridadeFiltro > 0 then
    Query.Where(t.Prioridade = PrioridadeFiltro);

  TotalRegistros := Query.Count;

  case IndexText(Trim(OrdemFiltro), ['datacriacao_asc', 'prioridade_asc', 'prioridade_desc', 'titulo_asc', 'titulo_desc']) of
    0: Query.OrderBy(t.DataCriacao.Asc);
    1: Query.OrderBy(t.Prioridade.Asc);
    2: Query.OrderBy(t.Prioridade.Desc);
    3: Query.OrderBy(t.Titulo.Asc);
    4: Query.OrderBy(t.Titulo.Desc);
  else
    Query.OrderBy(t.DataCriacao.Desc);
  end;

  var SkipCount := (Pagina - 1) * Limite;
  if SkipCount < 0 then
    SkipCount := 1;

  Result := Query.Skip(SkipCount).Take(Limite).ToList;
end;

function TTarefaRepository.ObterPorId(Id: Integer): TTarefa;
begin
  var t := Prototype.Entity<TTarefa>;
  Result := FDb.Tarefas.Where(t.Id = Id).FirstOrDefault;
end;

function TTarefaRepository.Criar(Tarefa: TTarefa): TTarefa;
begin
  FDb.Tarefas.Add(Tarefa);
  FDb.SaveChanges;

  Result := Tarefa;
end;

function TTarefaRepository.Atualizar(Tarefa: TTarefa): TTarefa;
begin
  FDb.Tarefas.Update(Tarefa);
  FDb.SaveChanges;
  Result := Tarefa;
end;

procedure TTarefaRepository.Remover(Tarefa: TTarefa);
begin
  FDb.Tarefas.Remove(Tarefa);
  FDb.SaveChanges;
end;

function TTarefaRepository.ObterEstatisticas: TEstatisticasResponseDto;
begin
  var t := Prototype.Entity<TTarefa>;
  
  // 1. Total de tarefas ativas
  Result.TotalTarefas := FDb.Tarefas.QueryAll.Count;

  // 2. Média de prioridade de tarefas pendentes
  var ListaPendentes := FDb.Tarefas.Where((t.Status = 'PENDENTE') and (t.DataExclusao.IsNull)).ToList;
  var SomaPrioridade: Double := 0;
  for var Item in ListaPendentes do
    SomaPrioridade := SomaPrioridade + Item.Prioridade.Value;
  
  if ListaPendentes.Count > 0 then
    Result.MediaPrioridadePendentes := SomaPrioridade / ListaPendentes.Count
  else
    Result.MediaPrioridadePendentes := 0;

  // 3. Tarefas concluídas nos últimos 7 dias
  var DataLimite: TDateTime := Now - 7;
  Result.TarefasConcluidasUltimos7Dias := FDb.Tarefas
    .Where(t.Status = 'CONCLUIDA')
    .Where(t.DataExclusao.IsNull)
    .Where(t.DataConclusao.Value >= DataLimite)
    .Count;
end;

end.
