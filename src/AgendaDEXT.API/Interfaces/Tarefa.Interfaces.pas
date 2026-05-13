unit Tarefa.Interfaces;

interface

uses
  System.SysUtils,
  Dext,
  Dext.Collections,
  Tarefa.Entity,
  Tarefa.DTOs;

type
  ITarefaRepository = interface
    ['{3E60B20D-C178-4A1C-8D47-73B2ED74D1B5}']
    function Listar(StatusFiltro: string; PrioridadeFiltro: Integer; OrdemFiltro: string; Pagina, Limite: Integer; out TotalRegistros: Integer): IList<TTarefa>;
    function ObterPorId(Id: Integer): TTarefa;
    function Criar(Tarefa: TTarefa): TTarefa;
    function Atualizar(Tarefa: TTarefa): TTarefa;
    procedure Remover(Tarefa: TTarefa);
    function ObterEstatisticas: TEstatisticasResponseDto;
  end;

  ITarefaService = interface
    ['{8A95C171-8935-4D1E-8B7C-5F9A6E9B8D83}']
    function Listar(StatusFiltro: string; PrioridadeFiltro: Integer; OrdemFiltro: string; Pagina, Limite: Integer): TTarefasPaginadasDto;
    function ObterPorId(Id: Integer): TTarefaResponseDto;
    function Criar(Request: TCriarTarefaRequest): TTarefaResponseDto;
    function Atualizar(Request: TAtualizarTarefaRequest): TTarefaResponseDto;
    function AtualizarStatus(Request: TAtualizarStatusRequest): TTarefaResponseDto;
    procedure Remover(Id: Integer);
    function ObterEstatisticas: TEstatisticasResponseDto;
  end;

implementation

end.
