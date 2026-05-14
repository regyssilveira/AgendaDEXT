unit DateFormat.Utils;

interface

uses
  System.SysUtils,
  Dext.Core.SmartTypes,
  Dext.Types.Nullable;

type
  TDateFormatUtils = class
  public
    class function DateTimeToIsoString(const ADateTime: DateTimeType): string; static;
    class function NullableDateTimeToIsoString(const ANullableDateTime: Nullable<DateTimeType>): string; static;
  end;

implementation

class function TDateFormatUtils.DateTimeToIsoString(const ADateTime: DateTimeType): string;
begin
  if ADateTime = 0 then
    Result := ''
  else
    Result := FormatDateTime('yyyy-mm-dd"T"hh:nn:ss', ADateTime);
end;

class function TDateFormatUtils.NullableDateTimeToIsoString(const ANullableDateTime: Nullable<DateTimeType>): string;
begin
  if ANullableDateTime.IsNull then
    Result := ''
  else
    Result := DateTimeToIsoString(ANullableDateTime.Value);
end;

end.
