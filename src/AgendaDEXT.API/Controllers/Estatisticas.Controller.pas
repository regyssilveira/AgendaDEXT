unit Estatisticas.Controller;

interface

uses
  System.SysUtils,
  Dext,
  Dext.Entity,
  Dext.Web,
  Tarefa.Interfaces;

type
  [ApiController('/api/estatisticas')]
  TEstatisticasController = class
  private
    FService: ITarefaService;
  public
    constructor Create(Service: ITarefaService);

    [HttpGet]
    function ObterEstatisticasGerais: IResult;
  end;

implementation

constructor TEstatisticasController.Create(Service: ITarefaService);
begin
  inherited Create;
  FService := Service;
end;

function TEstatisticasController.ObterEstatisticasGerais: IResult;
begin
  var Dto := FService.ObterEstatisticas;
  Result := Results.Ok(Dto);
end;

initialization
  TEstatisticasController.ClassName;

end.
