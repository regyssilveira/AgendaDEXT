unit AgendaDEXT.Tests.DateFormatUtils;

interface

uses
  System.SysUtils,
  Dext.Testing,
  Dext.Core.SmartTypes,
  Dext.Types.Nullable,
  DateFormat.Utils;

type
  [TestFixture]
  TDateFormatUtilsTests = class
  public
    [Test]
    procedure Deve_RetornarVazio_AoFormatarDataZero;

    [Test]
    procedure Deve_FormatarData_NoPadrao_Iso8601_SemSufixoZ;

    [Test]
    procedure Deve_TratarCorretamente_DatasNulas_Nullable;
  end;

implementation

procedure TDateFormatUtilsTests.Deve_RetornarVazio_AoFormatarDataZero;
begin
  var Res := TDateFormatUtils.DateTimeToIsoString(0);
  Should(Res).Be('');
end;

procedure TDateFormatUtilsTests.Deve_FormatarData_NoPadrao_Iso8601_SemSufixoZ;
begin
  // Data: 13/05/2026 15:30:00
  var DataAlvo := EncodeDate(2026, 5, 13) + EncodeTime(15, 30, 0, 0);
  var Res := TDateFormatUtils.DateTimeToIsoString(DataAlvo);
  Should(Res).Be('2026-05-13T15:30:00');
end;

procedure TDateFormatUtilsTests.Deve_TratarCorretamente_DatasNulas_Nullable;
begin
  var DataNula: Nullable<DateTimeType>;
  // Valor default de Nullable record é IsNull = True
  var Res1 := TDateFormatUtils.NullableDateTimeToIsoString(DataNula);
  Should(Res1).Be('');

  var DataPreenchida: Nullable<DateTimeType>;
  DataPreenchida.Value := EncodeDate(2026, 1, 1);
  var Res2 := TDateFormatUtils.NullableDateTimeToIsoString(DataPreenchida);
  Should(Res2).StartWith('2026-01-01');
end;

end.
