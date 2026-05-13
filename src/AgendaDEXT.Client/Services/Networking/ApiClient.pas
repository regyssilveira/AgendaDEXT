unit ApiClient;

interface

uses
  System.SysUtils,
  System.Classes,
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
  // Procura pelo arquivo de configuração com extensão .yaml
  var ArquivoYaml := ChangeFileExt(ParamStr(0), '.yaml');
  if not FileExists(ArquivoYaml) then
    ArquivoYaml := ExtractFilePath(ParamStr(0)) + 'client.yaml';

  var Protocolo := 'http';
  var Host := 'localhost';
  var Porta := 9005;
  var ApiKey := 'agenda-BDMG-dev-key-2026';

  // Parser nativo e ultrarrobusto de YAML em Object Pascal puro (dispensa dependências externas de RTTI)
  if FileExists(ArquivoYaml) then
  begin
    var Linhas := TStringList.Create;
    try
      Linhas.LoadFromFile(ArquivoYaml);
      for var i := 0 to Linhas.Count - 1 do
      begin
        var Linha := Trim(Linhas[i]);
        // Remove aspas ou apóstrofos para extração limpa
        Linha := Linha.Replace('"', '').Replace('''', '');

        if Linha.StartsWith('protocol:') then
          Protocolo := Trim(Linha.Substring(9));
        if Linha.StartsWith('host:') then
          Host := Trim(Linha.Substring(5));
        if Linha.StartsWith('port:') then
          Porta := StrToIntDef(Trim(Linha.Substring(5)), 9005);
        if Linha.StartsWith('api_key:') then
          ApiKey := Trim(Linha.Substring(8));
      end;
    finally
      Linhas.Free;
    end;
  end;

  var BaseUrl := Format('%s://%s:%d', [Protocolo, Host, Porta]);
  
  // Instancia a TRestClient record canônica
  FClient := RestClient(BaseUrl);
  // Anexa a chave de segurança da API
  FClient.ApiKey('X-API-KEY', ApiKey);
end;

function TApiClient.ListarTarefas(Status: string; Prioridade: Integer; Pagina: Integer): TTarefasPaginadasDto;
begin
  var Req := TRestRequest.Create(FClient, hmGET, '/api/tarefas');

  if Trim(Status) <> '' then
    Req.QueryParam('status', Status);

  if Prioridade > 0 then
    Req.QueryParam('prioridade', IntToStr(Prioridade));

  if Pagina > 1 then
    Req.QueryParam('page', IntToStr(Pagina));

  Result := Req.Execute<TTarefasPaginadasDto>.Await;
end;

function TApiClient.CriarTarefa(const Dto: TCriarTarefaDto): TTarefaDto;
begin
  var Req := TRestRequest.Create(FClient, hmPOST, '/api/tarefas');
  Result := Req.Body<TCriarTarefaDto>(Dto)
    .Execute<TTarefaDto>
    .Await;
end;

function TApiClient.AtualizarStatus(Id: Integer; const NovoStatus: string): TTarefaDto;
begin
  var Payload: TAtualizarStatusDto;
  Payload.Status := NovoStatus;

  var Req := TRestRequest.Create(FClient, hmPUT, Format('/api/tarefas/%d/status', [Id]));
  Result := Req
    .Body(Payload)
    .Execute<TTarefaDto>
    .Await;
end;

procedure TApiClient.RemoverTarefa(Id: Integer);
begin
  var Res := FClient.Delete(Format('/api/tarefas/%d', [Id])).Await;
  if not Res.StatusCode = 200 then
    raise Exception.Create('Falha ao remover tarefa: ' + Res.ContentString);
end;

function TApiClient.ObterEstatisticas: TEstatisticasDto;
begin
  Result := FClient.Get<TEstatisticasDto>('/api/estatisticas').Await;
end;

end.
