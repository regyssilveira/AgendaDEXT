unit FileLogProvider;

interface

uses
  System.SysUtils,
  Dext.Utils,
  Dext.Logging;

type
  TfileLogger = class(TAbstractLogger)
  private
    FCategoryName: string;
  protected
    procedure Log(ALevel: TLogLevel; const AMessage: string; const AArgs: array of const); override;
    procedure Log(ALevel: TLogLevel; const AException: Exception; const AMessage: string; const AArgs: array of const); override;
    function IsEnabled(ALevel: TLogLevel): Boolean; override;
    function BeginScope(const AMessage: string; const AArgs: array of const): IDisposable; override;
    function BeginScope(const AState: TObject): IDisposable; override;
  public
    constructor Create(const ACategoryName: string);
  end;

  TFileLoggerProvider = class(TInterfacedObject, ILoggerProvider)
  public
    function CreateLogger(const ACategoryName: string): ILogger;
    procedure Dispose;
  end;

implementation

{ TFileLoggerProvider }

function TFileLoggerProvider.CreateLogger(const ACategoryName: string): ILogger;
begin
  Result := TFileLogger.Create(ACategoryName);
end;

procedure TFileLoggerProvider.Dispose;
begin
  // Nothing to dispose
end;

{ TfileLogger }

constructor TfileLogger.Create(const ACategoryName: string);
begin
  inherited Create;
  FCategoryName := ACategoryName;
end;

function TfileLogger.BeginScope(const AMessage: string; const AArgs: array of const): IDisposable;
begin
  Result := TNullDisposable.Create;
end;

function TfileLogger.BeginScope(const AState: TObject): IDisposable;
begin
  Result := TNullDisposable.Create;
end;

function TfileLogger.IsEnabled(ALevel: TLogLevel): Boolean;
begin
  Result := ALevel <> TLogLevel.None;
end;

procedure TfileLogger.Log(ALevel: TLogLevel; const AMessage: string; const AArgs: array of const);
var
  LMsg: string;
  LLevelStr: string;
begin
  if not IsEnabled(ALevel) then Exit;

  case ALevel of
    TLogLevel.Trace       : LLevelStr := 'trce';
    TLogLevel.Debug       : LLevelStr := 'dbug';
    TLogLevel.Information : LLevelStr := 'info';
    TLogLevel.Warning     : LLevelStr := 'warn';
    TLogLevel.Error       : LLevelStr := 'fail';
    TLogLevel.Critical    : LLevelStr := 'crit';
  else
    LLevelStr := '    ';
  end;

  LMsg := TLogFormatter.FormatMessage(AMessage, AArgs);

  SafeWriteLn(Format('%s: %s' + sLineBreak + '      %s', [LLevelStr, FCategoryName, LMsg]));
end;

procedure TfileLogger.Log(ALevel: TLogLevel; const AException: Exception; const AMessage: string; const AArgs: array of const);
begin
  if not IsEnabled(ALevel) then Exit;

  Log(ALevel, AMessage, AArgs);
  if AException <> nil then
    SafeWriteLn(Format('      %s: %s', [AException.ClassName, AException.Message]));
end;

end.
