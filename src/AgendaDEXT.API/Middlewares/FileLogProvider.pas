unit FileLogProvider;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  System.SyncObjs,
  System.IOUtils,
  Dext.Utils,
  Dext.Logging;

const
  DEFAULT_MAX_LOG_SIZE_BYTES = 10 * 1024 * 1024; // Padrão de 10 MB por arquivo

type
  TAsyncFileLogWriter = class;

  TFileLogger = class(TAbstractLogger)
  private
    FCategoryName: string;
    FWriter: TAsyncFileLogWriter;
  protected
    procedure Log(ALevel: TLogLevel; const AMessage: string; const AArgs: array of const); override;
    procedure Log(ALevel: TLogLevel; const AException: Exception; const AMessage: string; const AArgs: array of const); override;
    function IsEnabled(ALevel: TLogLevel): Boolean; override;
    function BeginScope(const AMessage: string; const AArgs: array of const): IDisposable; override;
    function BeginScope(const AState: TObject): IDisposable; override;
  public
    constructor Create(const ACategoryName: string; AWriter: TAsyncFileLogWriter);
  end;

  TFileLoggerProvider = class(TInterfacedObject, ILoggerProvider)
  private
    FWriter: TAsyncFileLogWriter;
  public
    // Permite configurar o diretório de destino e o tamanho máximo com valores-padrão inteligentes (Open/Closed Principle)
    constructor Create(const ALogDirectory: string = ''; AMaxFileSizeBytes: Int64 = DEFAULT_MAX_LOG_SIZE_BYTES);
    destructor Destroy; override;
    function CreateLogger(const ACategoryName: string): ILogger;
    procedure Dispose;
  end;

  TLogWorkerThread = class(TThread)
  private
    FWriter: TAsyncFileLogWriter;
    FCurrentDate: string;
    FCurrentPart: Integer;
    FFileStream: TFileStream;
    FStreamWriter: TStreamWriter;
    procedure RotateLogFileIfNeeded;
    procedure CloseLogFile;
  protected
    procedure Execute; override;
  public
    constructor Create(AWriter: TAsyncFileLogWriter);
    destructor Destroy; override;
  end;

  TAsyncFileLogWriter = class
  private
    FQueue: TQueue<string>;
    FLock: TCriticalSection;
    FSignal: TEvent;
    FWorkerThread: TLogWorkerThread;
    FLogDirectory: string;
    FMaxFileSizeBytes: Int64;
  public
    constructor Create(const ALogDirectory: string; AMaxFileSizeBytes: Int64);
    destructor Destroy; override;
    procedure Log(const AMessage: string);
    function DequeueAll(AList: TList<string>): Boolean;
    procedure FlushAndStop;
    property LogDirectory: string read FLogDirectory;
    property MaxFileSizeBytes: Int64 read FMaxFileSizeBytes;
  end;

implementation

{ TFileLoggerProvider }

constructor TFileLoggerProvider.Create(const ALogDirectory: string; AMaxFileSizeBytes: Int64);
begin
  inherited Create;
  FWriter := TAsyncFileLogWriter.Create(ALogDirectory, AMaxFileSizeBytes);
end;

destructor TFileLoggerProvider.Destroy;
begin
  Dispose;
  FreeAndNil(FWriter);
  inherited Destroy;
end;

function TFileLoggerProvider.CreateLogger(const ACategoryName: string): ILogger;
begin
  Result := TFileLogger.Create(ACategoryName, FWriter);
end;

procedure TFileLoggerProvider.Dispose;
begin
  if FWriter <> nil then
    FWriter.FlushAndStop;
end;

{ TFileLogger }

constructor TFileLogger.Create(const ACategoryName: string; AWriter: TAsyncFileLogWriter);
begin
  inherited Create;
  FCategoryName := ACategoryName;
  FWriter := AWriter;
end;

function TFileLogger.BeginScope(const AMessage: string; const AArgs: array of const): IDisposable;
begin
  Result := TNullDisposable.Create;
end;

function TFileLogger.BeginScope(const AState: TObject): IDisposable;
begin
  Result := TNullDisposable.Create;
end;

function TFileLogger.IsEnabled(ALevel: TLogLevel): Boolean;
begin
  Result := ALevel <> TLogLevel.None;
end;

procedure TFileLogger.Log(ALevel: TLogLevel; const AMessage: string; const AArgs: array of const);
var
  LMsg, LFormattedLog: string;
  LLevelStr: string;
begin
  if not IsEnabled(ALevel) then Exit;

  case ALevel of
    TLogLevel.Trace       : LLevelStr := 'TRCE';
    TLogLevel.Debug       : LLevelStr := 'DBUG';
    TLogLevel.Information : LLevelStr := 'INFO';
    TLogLevel.Warning     : LLevelStr := 'WARN';
    TLogLevel.Error       : LLevelStr := 'FAIL';
    TLogLevel.Critical    : LLevelStr := 'CRIT';
  else
    LLevelStr := '    ';
  end;

  LMsg := TLogFormatter.FormatMessage(AMessage, AArgs);

  LFormattedLog := Format('[%s] [%s] [%s] %s', [
    FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Now),
    LLevelStr,
    FCategoryName,
    LMsg
  ]);

  if FWriter <> nil then
    FWriter.Log(LFormattedLog);
end;

procedure TFileLogger.Log(ALevel: TLogLevel; const AException: Exception; const AMessage: string; const AArgs: array of const);
begin
  if not IsEnabled(ALevel) then Exit;

  Log(ALevel, AMessage, AArgs);
  if AException <> nil then
  begin
    var LExceptionLog := Format('[%s] [EXCP] [%s] %s: %s', [
      FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Now),
      FCategoryName,
      AException.ClassName,
      AException.Message
    ]);
    if FWriter <> nil then
      FWriter.Log(LExceptionLog);
  end;
end;

{ TAsyncFileLogWriter }

constructor TAsyncFileLogWriter.Create(const ALogDirectory: string; AMaxFileSizeBytes: Int64);
begin
  inherited Create;
  FLogDirectory := ALogDirectory.Trim;
  if FLogDirectory.IsEmpty then
    FLogDirectory := TPath.Combine(ExtractFilePath(ParamStr(0)), 'logs');

  FMaxFileSizeBytes := AMaxFileSizeBytes;
  if FMaxFileSizeBytes <= 0 then
    FMaxFileSizeBytes := DEFAULT_MAX_LOG_SIZE_BYTES; // Proteção de sanidade (Sanity check)

  FQueue := TQueue<string>.Create;
  FLock := TCriticalSection.Create;
  FSignal := TEvent.Create(nil, True, False, '');
  FWorkerThread := TLogWorkerThread.Create(Self);
end;

destructor TAsyncFileLogWriter.Destroy;
begin
  FlushAndStop;
  FreeAndNil(FSignal);
  FreeAndNil(FLock);
  FreeAndNil(FQueue);
  inherited Destroy;
end;

procedure TAsyncFileLogWriter.Log(const AMessage: string);
begin
  FLock.Acquire;
  try
    FQueue.Enqueue(AMessage);
    FSignal.SetEvent;
  finally
    FLock.Release;
  end;
end;

function TAsyncFileLogWriter.DequeueAll(AList: TList<string>): Boolean;
begin
  FLock.Acquire;
  try
    Result := FQueue.Count > 0;
    while FQueue.Count > 0 do
      AList.Add(FQueue.Dequeue);
  finally
    FLock.Release;
  end;
end;

procedure TAsyncFileLogWriter.FlushAndStop;
begin
  if FWorkerThread <> nil then
  begin
    FWorkerThread.Terminate;
    FSignal.SetEvent;
    FWorkerThread.WaitFor;
    FreeAndNil(FWorkerThread);
  end;
end;

{ TLogWorkerThread }

constructor TLogWorkerThread.Create(AWriter: TAsyncFileLogWriter);
begin
  inherited Create(False);
  FreeOnTerminate := False;
  FWriter := AWriter;
  FCurrentDate := '';
  FCurrentPart := 1;
  FFileStream := nil;
  FStreamWriter := nil;
end;

destructor TLogWorkerThread.Destroy;
begin
  CloseLogFile;
  inherited Destroy;
end;

procedure TLogWorkerThread.CloseLogFile;
begin
  if FStreamWriter <> nil then
  begin
    try
      FStreamWriter.Flush;
    except
      // Absorve potenciais falhas de I/O no fechamento
    end;
    FreeAndNil(FStreamWriter);
  end;
  if FFileStream <> nil then
    FreeAndNil(FFileStream);
end;

procedure TLogWorkerThread.RotateLogFileIfNeeded;
var
  LToday: string;
  LLogDir, LFileName: string;
  LMode: Word;
  LNeedsNewFile: Boolean;
  LTempStream: TFileStream;
begin
  LToday := FormatDateTime('yyyy-mm-dd', Now);

  // Verifica se o dia mudou ou se o stream ainda não foi inicializado
  LNeedsNewFile := (FCurrentDate <> LToday) or (FStreamWriter = nil);

  // Se o arquivo já está aberto no dia correto, verifica se ultrapassou o tamanho limite
  if not LNeedsNewFile and (FFileStream <> nil) then
  begin
    // Como o StreamWriter faz buffer em memória, garantimos o flush para ler o tamanho real no disco
    try
      FStreamWriter.Flush;
    except
    end;

    if FFileStream.Size >= FWriter.MaxFileSizeBytes then
    begin
      LNeedsNewFile := True;
      Inc(FCurrentPart); // Prepara para abrir a próxima sequência daquele dia
    end;
  end;

  if LNeedsNewFile then
  begin
    CloseLogFile;

    if FCurrentDate <> LToday then
    begin
      FCurrentDate := LToday;
      FCurrentPart := 1; // Reinicia o sequencial de partes para o novo dia
    end;

    LLogDir := FWriter.LogDirectory;

    if not TDirectory.Exists(LLogDir) then
      TDirectory.CreateDirectory(LLogDir);

    // Lógica inteligente de varredura para localizar a parte correta ativa
    // Previne sobrescrever partes consolidadas caso o servidor seja reiniciado
    while True do
    begin
      LFileName := TPath.Combine(LLogDir, Format('AgendaDEXT_API_%s_part%d.log', [FCurrentDate, FCurrentPart]));

      if TFile.Exists(LFileName) then
      begin
        LMode := fmOpenWrite or fmShareDenyWrite;
        try
          LTempStream := TFileStream.Create(LFileName, LMode);
          try
            if LTempStream.Size < FWriter.MaxFileSizeBytes then
              Break // O arquivo atual ainda tem espaço disponível
            else
              Inc(FCurrentPart); // Arquivo cheio, avança para inspecionar a próxima parte
          finally
            LTempStream.Free;
          end;
        except
          // Em caso de lock temporário de leitura por terceiros, assume esta parte para a tentativa oficial
          Break;
        end;
      end
      else
      begin
        LMode := fmCreate or fmShareDenyWrite;
        Break; // Arquivo inexistente, encontramos a nova parte a ser provisionada
      end;
    end;

    try
      FFileStream := TFileStream.Create(LFileName, LMode);
      if LMode and fmOpenWrite > 0 then
        FFileStream.Seek(0, soFromEnd);

      FStreamWriter := TStreamWriter.Create(FFileStream, TEncoding.UTF8, 32768);
    except
      on E: Exception do
      begin
        CloseLogFile;
      end;
    end;
  end;
end;

procedure TLogWorkerThread.Execute;
var
  LMessages: TList<string>;
  LMsg: string;
begin
  LMessages := TList<string>.Create;
  try
    while not Terminated do
    begin
      if FWriter.FSignal.WaitFor(1000) = wrSignaled then
        FWriter.FSignal.ResetEvent;

      if FWriter.DequeueAll(LMessages) then
      begin
        RotateLogFileIfNeeded;

        if FStreamWriter <> nil then
        begin
          try
            for LMsg in LMessages do
              FStreamWriter.WriteLine(LMsg);

            FStreamWriter.Flush;
          except
            // Resiliência de I/O para evitar queda do Worker
          end;
        end;

        LMessages.Clear;
      end
      else
      begin
        // Rotina periódica de checagem à meia-noite
        RotateLogFileIfNeeded;
      end;
    end;

    // Flush de encerramento (Graceful shutdown)
    if FWriter.DequeueAll(LMessages) then
    begin
      RotateLogFileIfNeeded;
      if FStreamWriter <> nil then
      begin
        try
          for LMsg in LMessages do
            FStreamWriter.WriteLine(LMsg);
            
          FStreamWriter.Flush;
        except
        end;
      end;
    end;

    CloseLogFile;
  finally
    LMessages.Free;
  end;
end;

end.
