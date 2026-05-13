unit ApiKeyMiddleware;

interface

uses
  System.SysUtils,
  Dext,
  Dext.Web;

type
  TApiKeyMiddleware = class(TInterfacedObject, IMiddleware)
  private
    FConfig: IConfiguration;
  public
    constructor Create(Config: IConfiguration);
    procedure Invoke(Ctx: IHttpContext; Next: TRequestDelegate);
  end;

implementation

constructor TApiKeyMiddleware.Create(Config: IConfiguration);
begin
  inherited Create;
  FConfig := Config;
end;

procedure TApiKeyMiddleware.Invoke(Ctx: IHttpContext; Next: TRequestDelegate);
begin
  var Path := LowerCase(Ctx.Request.Path);
  
  // O endpoint de health check é acessível sem autenticação
  if (Pos('/health', Path) > 0) or (Pos('/api/health', Path) > 0) then
  begin
    Next(Ctx);
    Exit;
  end;

  var ChaveEsperada := FConfig.GetValue('Security:ApiKey', 'agenda-BDMG-dev-key-2026');
  var ChaveRecebida := Ctx.Request.Header('X-API-KEY');
  if Trim(ChaveRecebida) = '' then
    ChaveRecebida := Ctx.Request.Header('X-API-Key');

  if Trim(ChaveRecebida) <> Trim(ChaveEsperada) then
  begin
    Ctx.Response.StatusCode := 401;
    Ctx.Response.Json('{"sucesso":false,"mensagem":"Acesso não autorizado: API Key inválida ou ausente.","detalhes":null}');
    Exit; // Interrompe o pipeline
  end;

  Next(Ctx);
end;

end.
