unit ApiClient;

interface

uses
  System.SysUtils,
  System.IniFiles,
  Dext.Net.RestClient,
  Dext.Net.RestRequest,
  Dext.Threading.Async,
  Dext.Collections,
  Tarefa.Client.DTOs;

type
  {$M+} // OBRIGATÓRIO: Permite mockagem limpa do cliente nos testes unitários da UI
  IApiClient = interface
    ['{F2C8D105-B943-417A-A12B-3C9E87A5B912}']
    function ListarTarefas(Status: string; Prioridade: Integer; Pagina: Integer): TTarefasPaginadasDto;
    function CriarTarefa(const Dto: TCriarTarefaDto): TTarefaDto;
    function AtualizarStatus(Id: Integer; const NovoStatus: string): TTarefaDto;
    procedure RemoverTarefa(Id: Integer);
    function ObterEstatisticas: TEstatisticasDto;
  end;
  {$M-}

  TApiClient = class(TInterfacedObject, IApiClient)
  private
    FClient: TRestClient;
    procedure ConfigurarCliente;
  public
    constructor Create;
    function ListarTarefas(Status: string; Prioridade: Integer; Pagina: Integer): TTarefasPaginadasDto;
    function CriarTarefa(const Dto: TCriarTarefaDto): TTarefaDto;
    function AtualizarStatus(Id: Integer; const NovoStatus: string): TTarefaDto;
    procedure RemoverTarefa(Id: Integer);
    function ObterEstatisticas: TEstatisticasDto;
  end;

implementation

constructor TApiClient.Create;
begin
  inherited Create;
  ConfigurarCliente;
end;

procedure TApiClient.ConfigurarCliente;
begin
  var ArquivoIni := ChangeFileExt(ParamStr(0), '.ini');
  if not FileExists(ArquivoIni) then
    ArquivoIni := ExtractFilePath(ParamStr(0)) + 'client.ini';

  var Ini := TIniFile.Create(ArquivoIni);
  try
    var Protocolo := Ini.ReadString('Server', 'Protocol', 'http');
    var Host := Ini.ReadString('Server', 'Host', 'localhost');
    var Porta := Ini.ReadInteger('Server', 'Port', 9005);
    var ApiKey := Ini.ReadString('Security', 'ApiKey', 'agenda-BDMG-dev-key-2026');

    var BaseUrl := Format('%s://%s:%d', [Protocolo, Host, Porta]);
    
    // Instancia a TRestClient record nativamente com pool embutido
    FClient := TRestClient.Create(BaseUrl);
    
    // Anexa o provedor de autenticação de API Key
    FClient.ApiKey('X-API-KEY', ApiKey);
  finally
    Ini.Free;
  end;
end;

function TApiClient.ListarTarefas(Status: string; Prioridade: Integer; Pagina: Integer): TTarefasPaginadasDto;
begin
  var Req := FClient.Get('/api/tarefas');
  
  if Trim(Status) <> '' then
    Req := Req.QueryParam('status', Status);
    
  if Prioridade > 0 then
    Req := Req.QueryParam('prioridade', IntToStr(Prioridade));
    
  if Pagina > 1 then
    Req := Req.QueryParam('page', IntToStr(Pagina));

  // Executa de forma síncrona não-congelante ou bloqueante segura e desserializa magicamente
  Result := Req.Execute<TTarefasPaginadasDto>.Await;
end;

function TApiClient.CriarTarefa(const Dto: TCriarTarefaDto): TTarefaDto;
begin
  Result := FClient.Post('/api/tarefas')
    .Body(Dto)
    .Execute<TTarefaDto>
    .Await;
end;

function TApiClient.AtualizarStatus(Id: Integer; const NovoStatus: string): TTarefaDto;
begin
  var Payload: TAtualizarStatusDto;
  Payload.Status := NovoStatus;

  Result := FClient.Put(Format('/api/tarefas/%d/status', [Id]))
    .Body(Payload)
    .Execute<TTarefaDto>
    .Await;
end;

procedure TApiClient.RemoverTarefa(Id: Integer);
begin
  var Res := FClient.Delete(Format('/api/tarefas/%d', [Id])).Await;
  if not Res.IsSuccess then
    raise Exception.Create('Falha ao remover tarefa: ' + Res.ContentString);
end;

function TApiClient.ObterEstatisticas: TEstatisticasDto;
begin
  Result := FClient.Get<TEstatisticasDto>('/api/estatisticas').Await;
end;

end.
