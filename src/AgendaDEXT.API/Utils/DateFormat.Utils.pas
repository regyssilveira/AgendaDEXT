unit DateFormat.Utils;

interface

uses
  System.SysUtils,
  Dext.Types.Nullable;

type
  TDateFormatUtils = class
  public
    class function DateTimeToIsoString(const ADateTime: TDateTime): string; static;
    class function NullableDateTimeToIsoString(const ANullableDateTime: Nullable<TDateTime>): string; static;
  end;

implementation

class function TDateFormatUtils.DateTimeToIsoString(const ADateTime: TDateTime): string;
begin
  if ADateTime = 0 then
    Result := ''
  else
    Result := FormatDateTime('yyyy-mm-dd"T"hh:nn:ss', ADateTime);
end;

class function TDateFormatUtils.NullableDateTimeToIsoString(const ANullableDateTime: Nullable<TDateTime>): string;
begin
  if ANullableDateTime.IsNull then
    Result := ''
  else
    Result := DateTimeToIsoString(ANullableDateTime.Value);
end;

end.
