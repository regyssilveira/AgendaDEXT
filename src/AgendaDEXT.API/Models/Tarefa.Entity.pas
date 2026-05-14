unit Tarefa.Entity;

interface

uses
  System.SysUtils,
  Dext,
  Dext.Entity,
  Dext.Core.SmartTypes,
  Dext.Types.Nullable;

type
  [Table('Tarefas')]
  TTarefa = class
  private
    FId: IntType;
    FTitulo: StringType;
    FDescricao: StringType;
    FPrioridade: IntType;
    FStatus: StringType;
    FDataCriacao: DateTimeType;
    FDataConclusao: Nullable<DateTimeType>;
    FDataExclusao: Nullable<DateTimeType>;
  public
    [PK, AutoInc]
    property Id: IntType read FId write FId;

    [Required, MaxLength(150)]
    property Titulo: StringType read FTitulo write FTitulo;

    [MaxLength(1000)]
    property Descricao: StringType read FDescricao write FDescricao;

    [Required]
    property Prioridade: IntType read FPrioridade write FPrioridade;

    [Required, MaxLength(30)]
    property Status: StringType read FStatus write FStatus;

    [CreatedAt]
    property DataCriacao: DateTimeType read FDataCriacao write FDataCriacao;

    property DataConclusao: Nullable<DateTimeType> read FDataConclusao write FDataConclusao;

    [DeletedAt]
    property DataExclusao: Nullable<DateTimeType> read FDataExclusao write FDataExclusao;
  end;

implementation

end.
