unit AgendaDEXT.Context;

interface

uses
  System.SysUtils,
  Dext,
  Dext.Entity,
  Dext.Entity.Core,
  Dext.Web,
  Tarefa.Entity;

type
  TAgendaDbContext = class(TDbContext)
  private
    function GetTarefas: IDbSet<TTarefa>;
  public
    property Tarefas: IDbSet<TTarefa> read GetTarefas;
  end;

implementation

function TAgendaDbContext.GetTarefas: IDbSet<TTarefa>;
begin
  Result := Entities<TTarefa>;
end;

end.
