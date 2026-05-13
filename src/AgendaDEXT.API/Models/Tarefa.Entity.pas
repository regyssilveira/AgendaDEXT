unit Tarefa.Entity;

interface

uses
  System.SysUtils,
  Dext,
  Dext.Entity,
  Dext.Core.SmartTypes,
  Dext.Types.Nullable;

type
  TTarefaProps = record
    Id: IntType;
    Titulo: StringType;
    Descricao: StringType;
    Prioridade: IntType;
    Status: StringType;
    DataCriacao: Prop<TDateTime>;
    DataConclusao: Prop<Nullable<TDateTime>>;
    DataExclusao: Prop<Nullable<TDateTime>>;
  end;

  [Table('Tarefas')]
  TTarefa = class
  private
    FId: IntType;
    FTitulo: StringType;
    FDescricao: StringType;
    FPrioridade: IntType;
    FStatus: StringType;
    FDataCriacao: TDateTime;
    FDataConclusao: Nullable<TDateTime>;
    FDataExclusao: Nullable<TDateTime>;
  public
    class var Props: TTarefaProps;

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
    property DataCriacao: TDateTime read FDataCriacao write FDataCriacao;

    property DataConclusao: Nullable<TDateTime> read FDataConclusao write FDataConclusao;

    [SoftDelete]
    property DataExclusao: Nullable<TDateTime> read FDataExclusao write FDataExclusao;
  end;

implementation

end.
