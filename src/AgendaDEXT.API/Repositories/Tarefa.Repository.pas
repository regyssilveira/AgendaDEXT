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
  Dext.Core.SmartTypes;

constructor TTarefaRepository.Create(Db: TAgendaDbContext);
begin
  inherited Create;
  FDb := Db;
end;

function TTarefaRepository.Listar(StatusFiltro: string; PrioridadeFiltro: Integer; OrdemFiltro: string; Pagina, Limite: Integer; out TotalRegistros: Integer): IList<TTarefa>;
begin
  var t := TTarefa.Props;
  var Query := FDb.Tarefas.Where(t.DataExclusao.IsNull);

  if Trim(StatusFiltro) <> '' then
    Query := Query.Where(t.Status = UpperCase(Trim(StatusFiltro)));

  if PrioridadeFiltro > 0 then
    Query := Query.Where(t.Prioridade = PrioridadeFiltro);

  TotalRegistros := Query.Count;

  var Ordem := LowerCase(Trim(OrdemFiltro));
  if Ordem = 'datacriacao_asc' then
    Query := Query.OrderBy(t.DataCriacao.Asc)
  else if Ordem = 'prioridade_asc' then
    Query := Query.OrderBy(t.Prioridade.Asc)
  else if Ordem = 'prioridade_desc' then
    Query := Query.OrderBy(t.Prioridade.Desc)
  else if Ordem = 'titulo_asc' then
    Query := Query.OrderBy(t.Titulo.Asc)
  else if Ordem = 'titulo_desc' then
    Query := Query.OrderBy(t.Titulo.Desc)
  else
    Query := Query.OrderBy(t.DataCriacao.Desc); // Padrão: mais recentes primeiro

  var SkipCount := (Pagina - 1) * Limite;
  if SkipCount < 0 then SkipCount := 0;

  Result := Query.Skip(SkipCount).Take(Limite).ToList;
end;

function TTarefaRepository.ObterPorId(Id: Integer): TTarefa;
begin
  var t := TTarefa.Props;
  Result := FDb.Tarefas.Where((t.Id = Id) and (t.DataExclusao.IsNull)).FirstOrDefault;
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
  // Soft delete implementado alterando o campo DataExclusao
  Tarefa.DataExclusao := Now;
  FDb.Tarefas.Update(Tarefa);
  FDb.SaveChanges;
end;

function TTarefaRepository.ObterEstatisticas: TEstatisticasResponseDto;
begin
  var t := TTarefa.Props;
  
  // 1. Total de tarefas ativas
  Result.TotalTarefas := FDb.Tarefas.Where(t.DataExclusao.IsNull).Count;

  // 2. Média de prioridade de tarefas pendentes
  var ListaPendentes := FDb.Tarefas.Where((t.Status = 'PENDENTE') and (t.DataExclusao.IsNull)).ToList;
  var SomaPrioridade: Double := 0;
  for var Item in ListaPendentes do
    SomaPrioridade := SomaPrioridade + Item.Prioridade;
  
  if ListaPendentes.Count > 0 then
    Result.MediaPrioridadePendentes := SomaPrioridade / ListaPendentes.Count
  else
    Result.MediaPrioridadePendentes := 0;

  // 3. Tarefas concluídas nos últimos 7 dias
  var DataLimite := Now - 7;
  Result.TarefasConcluidasUltimos7Dias := FDb.Tarefas
    .Where((t.Status = 'CONCLUIDA') and (t.DataExclusao.IsNull) and (t.DataConclusao >= DataLimite))
    .Count;
end;

end.
