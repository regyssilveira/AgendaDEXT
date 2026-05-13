unit Tarefa.Client.DTOs;

interface

uses
  System.SysUtils,
  Dext.Collections;

type
  TTarefaDto = record
    Id: Integer;
    Titulo: string;
    Descricao: string;
    Prioridade: Integer;
    Status: string;
    DataCriacao: string;
    DataConclusao: string;
  end;

  TPaginacaoDto = record
    PaginaAtual: Integer;
    ItensPorPagina: Integer;
    TotalItens: Integer;
    TotalPaginas: Integer;
  end;

  TTarefasPaginadasDto = record
    Dados: IList<TTarefaDto>;
    Paginacao: TPaginacaoDto;
  end;

  TEstatisticasDto = record
    TotalTarefas: Integer;
    MediaPrioridadePendentes: Double;
    TarefasConcluidasUltimos7Dias: Integer;
  end;

  TCriarTarefaDto = record
    Titulo: string;
    Descricao: string;
    Prioridade: Integer;
  end;

  TAtualizarStatusDto = record
    Status: string;
  end;

implementation

end.
