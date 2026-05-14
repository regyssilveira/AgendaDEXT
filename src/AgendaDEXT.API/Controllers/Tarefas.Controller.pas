unit Tarefas.Controller;

interface

uses
  System.SysUtils,
  Dext,
  Dext.Entity,
  Dext.Web,
  Tarefa.DTOs,
  Tarefa.Interfaces;

type
  [ApiController('/api/tarefas')]
  TTarefasController = class
  private
    FService: ITarefaService;
  public
    constructor Create(Service: ITarefaService);

    [HttpGet]
    function ListarTarefas([FromQuery] Status: string; [FromQuery] Prioridade: Integer; [FromQuery] Ordem: string; [FromQuery] Page: Integer; [FromQuery] Limit: Integer): IResult;

    [HttpGet('/{id}')]
    function ObterTarefa(Id: Integer): IResult;

    [HttpPost]
    function CriarNovaTarefa([Body] Request: TCriarTarefaRequest): IResult;

    [HttpPut('/{id}')]
    function AtualizarTarefaCompleta(Id: Integer; [Body] Request: TAtualizarTarefaRequest): IResult;

    [HttpPut('/{id}/status')]
    function ModificarStatusTarefa(Id: Integer; [Body] Request: TAtualizarStatusRequest): IResult;

    [HttpDelete('/{id}')]
    function RemoverTarefa(Id: Integer): IResult;
  end;

implementation

constructor TTarefasController.Create(Service: ITarefaService);
begin
  inherited Create;
  FService := Service;
end;

function TTarefasController.ListarTarefas([FromQuery] Status: string; [FromQuery] Prioridade: Integer; [FromQuery] Ordem: string; [FromQuery] Page: Integer; [FromQuery] Limit: Integer): IResult;
begin
  var Paginadas := FService.Listar(Status, Prioridade, Ordem, Page, Limit);
  Result := Results.Ok(Paginadas);
end;

function TTarefasController.ObterTarefa(Id: Integer): IResult;
begin
  try
    var Dto := FService.ObterPorId(Id);
    Result := Results.Ok(Dto);
  except
    on E: Exception do
      Result := Results.StatusCode(404, '{"sucesso":false,"mensagem":"' + E.Message + '","detalhes":null}');
  end;
end;

function TTarefasController.CriarNovaTarefa([Body] Request: TCriarTarefaRequest): IResult;
begin
  var Dto := FService.Criar(Request);
  Result := Results.Created('/api/tarefas/' + IntToStr(Dto.Id), Dto);
end;

function TTarefasController.AtualizarTarefaCompleta(Id: Integer; [Body] Request: TAtualizarTarefaRequest): IResult;
begin
  var Req := Request;
  Req.Id := Id; // Garante o ID vindo da rota
  try
    var Dto := FService.Atualizar(Req);
    Result := Results.Ok(Dto);
  except
    on E: Exception do
      Result := Results.StatusCode(404, '{"sucesso":false,"mensagem":"' + E.Message + '","detalhes":null}');
  end;
end;

function TTarefasController.ModificarStatusTarefa(Id: Integer; [Body] Request: TAtualizarStatusRequest): IResult;
begin
  var Req := Request;
  Req.Id := Id;
  try
    var Dto := FService.AtualizarStatus(Req);
    Result := Results.Ok(Dto);
  except
    on E: Exception do
      // Transições inválidas retornam 422 Unprocessable Entity
      Result := Results.StatusCode(422, '{"sucesso":false,"mensagem":"' + E.Message + '","detalhes":null}');
  end;
end;

function TTarefasController.RemoverTarefa(Id: Integer): IResult;
begin
  try
    FService.Remover(Id);
    Result := Results.Ok('{"sucesso":true,"mensagem":"Tarefa removida com sucesso"}');
  except
    on E: Exception do
      Result := Results.StatusCode(404, '{"sucesso":false,"mensagem":"' + E.Message + '","detalhes":null}');
  end;
end;

initialization
  TTarefasController.ClassName;

end.

