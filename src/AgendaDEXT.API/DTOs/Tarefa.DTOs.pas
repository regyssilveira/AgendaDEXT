unit Tarefa.DTOs;

interface

uses
  System.SysUtils,
  Dext,
  Dext.Web,
  Dext.Collections;

type
  TTarefaResponseDto = record
    Id: Integer;
    Titulo: string;
    Descricao: string;
    Prioridade: Integer;
    Status: string;
    DataCriacao: string;
    DataConclusao: string; // Vazio ou nulo se não houver
  end;

  TPaginacaoDto = record
    PaginaAtual: Integer;
    ItensPorPagina: Integer;
    TotalItens: Integer;
    TotalPaginas: Integer;
  end;

  TTarefasPaginadasDto = record
    Dados: IList<TTarefaResponseDto>;
    Paginacao: TPaginacaoDto;
  end;

  TCriarTarefaRequest = record
    Titulo: string;
    Descricao: string;
    Prioridade: Integer;
  end;

  TAtualizarTarefaRequest = record
    [FromRoute('id')]
    Id: Integer;
    Titulo: string;
    Descricao: string;
    Prioridade: Integer;
  end;

  TAtualizarStatusRequest = record
    [FromRoute('id')]
    Id: Integer;
    Status: string;
  end;

  TEstatisticasResponseDto = record
    TotalTarefas: Integer;
    MediaPrioridadePendentes: Double;
    TarefasConcluidasUltimos7Dias: Integer;
  end;

implementation

end.
