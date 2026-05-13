unit Tarefa.Client.DTOs;

interface

uses
  System.SysUtils,
  Dext.Collections;

type
  TTarefaDto = class
    Id: Integer;
    Titulo: string;
    Descricao: string;
    Prioridade: Integer;
    Status: string;
    DataCriacao: string;
    DataConclusao: string;
  end;

  TPaginacaoDto = class
    PaginaAtual: Integer;
    ItensPorPagina: Integer;
    TotalItens: Integer;
    TotalPaginas: Integer;
  end;

  TTarefasPaginadasDto = class
    Dados: IList<TTarefaDto>;
    Paginacao: TPaginacaoDto;
  end;

  TEstatisticasDto = class
    TotalTarefas: Integer;
    MediaPrioridadePendentes: Double;
    TarefasConcluidasUltimos7Dias: Integer;
  end;

  TCriarTarefaDto = class
    Titulo: string;
    Descricao: string;
    Prioridade: Integer;
  end;

  TAtualizarStatusDto = class
    Status: string;
  end;

implementation

end.
