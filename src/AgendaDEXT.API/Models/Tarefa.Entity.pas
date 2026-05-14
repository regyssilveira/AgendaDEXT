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
    FDataCriacao: Prop<TDateTime>;
    FDataConclusao: Prop<Nullable<TDateTime>>;
    FDataExclusao: Prop<Nullable<TDateTime>>;
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
    property DataCriacao: Prop<TDateTime> read FDataCriacao write FDataCriacao;

    property DataConclusao: Prop<Nullable<TDateTime>> read FDataConclusao write FDataConclusao;

    [SoftDelete]
    property DataExclusao: Prop<Nullable<TDateTime>> read FDataExclusao write FDataExclusao;
  end;

implementation

end.
