unit Health.Controller;

interface

uses
  System.SysUtils,
  Dext,
  Dext.Entity,
  Dext.Web,
  DateFormat.Utils;

type
  [ApiController('/api/health')]
  THealthController = class
  public
    [HttpGet]
    function VerificarSaude: IResult;
  end;

implementation

function THealthController.VerificarSaude: IResult;
begin
  var Json := '{"status":"UP","timestamp":"' + TDateFormatUtils.DateTimeToIsoString(Now) + '","version":"1.0.0"}';
  Result := Results.Ok(Json);
end;

initialization
  THealthController.ClassName;

end.
