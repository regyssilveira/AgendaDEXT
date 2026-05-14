unit AgendaDEXT.Tests.TarefaService;

interface

uses
  System.SysUtils,
  Dext.Testing,
  Dext.Mocks,
  Tarefa.Entity,
  Tarefa.DTOs,
  Tarefa.Interfaces,
  Tarefa.Service;

type
  [TestFixture]
  TTarefaServiceTests = class
  private
    FService: ITarefaService;
    FMockRepo: Mock<ITarefaRepository>;
  public
    [Setup]
    procedure Setup;

    [Test]
    procedure Deve_LancarExcecao_AoCriarTarefa_ComTituloVazio;

    [Test]
    [TestCase(0)]
    [TestCase(6)]
    procedure Deve_LancarExcecao_AoCriarTarefa_ComPrioridadeInvalida(Prioridade: Integer);

    [Test]
    procedure Deve_CriarTarefa_E_RetornarDto_ComSucesso;

    [Test]
    procedure Deve_BloquearAlteracaoStatus_QuandoTarefaJaEstiverConcluida;

    [Test]
    procedure Deve_PreencherDataConclusao_AoModificarStatusParaConcluida;
  end;

implementation

procedure TTarefaServiceTests.Setup;
begin
  // Criação do mock dinâmico da interface ITarefaRepository
  FMockRepo := Mock<ITarefaRepository>.Create;
  // Instancia a camada de serviço real injetando o proxy gerado pela engine
  FService := TTarefaService.Create(FMockRepo.Instance);
end;

procedure TTarefaServiceTests.Deve_LancarExcecao_AoCriarTarefa_ComTituloVazio;
begin
  var Req: TCriarTarefaRequest;
  Req.Titulo := '   ';
  Req.Descricao := 'Desc';
  Req.Prioridade := 3;

  var Lancou := False;
  try
    FService.Criar(Req);
  except
    on E: Exception do
    begin
      Lancou := True;
      Should(E.Message).Contain('título');
    end;
  end;
  
  Should(Lancou).BeTrue;

  // Atesta que o repositório nunca foi acionado para salvar lixo
  FMockRepo.Received(Times.Never).Criar(Arg.Any<TTarefa>);
end;

procedure TTarefaServiceTests.Deve_LancarExcecao_AoCriarTarefa_ComPrioridadeInvalida(Prioridade: Integer);
begin
  var Req: TCriarTarefaRequest;
  Req.Titulo := 'Tarefa de Teste';
  Req.Descricao := 'Desc';
  Req.Prioridade := Prioridade;

  var Lancou := False;
  try
    FService.Criar(Req);
  except
    on E: Exception do
    begin
      Lancou := True;
      Should(E.Message).Contain('prioridade');
    end;
  end;
  
  Should(Lancou).BeTrue;
  FMockRepo.Received(Times.Never).Criar(Arg.Any<TTarefa>);
end;

procedure TTarefaServiceTests.Deve_CriarTarefa_E_RetornarDto_ComSucesso;
begin
  // Arrange
  var Req: TCriarTarefaRequest;
  Req.Titulo := 'Validar Cobertura';
  Req.Descricao := 'Testes 100% ativos';
  Req.Prioridade := 5;

  var TarefaMockada := TTarefa.Create;
  try
    TarefaMockada.Id := 10;
    TarefaMockada.Titulo := Req.Titulo;
    TarefaMockada.Descricao := Req.Descricao;
    TarefaMockada.Prioridade := Req.Prioridade;
    TarefaMockada.Status := 'PENDENTE';
    TarefaMockada.DataCriacao := EncodeDate(2026, 5, 13);

    // Configura o Mock para interceptar e devolver a entidade simulada
    FMockRepo.Setup.Returns(TarefaMockada).When.Criar(Arg.Any<TTarefa>);

    // Act
    var Res := FService.Criar(Req);

    // Assert
    Should(Res.Id).Be(10);
    Should(Res.Titulo).Be('Validar Cobertura');
    Should(Res.Status).Be('PENDENTE');
    Should(Res.DataCriacao).StartWith('2026-05-13');

    // Verify
    FMockRepo.Received(Times.Once).Criar(Arg.Any<TTarefa>);
  finally
    TarefaMockada.Free; // Libera instância de heap alocada no teste
  end;
end;

procedure TTarefaServiceTests.Deve_BloquearAlteracaoStatus_QuandoTarefaJaEstiverConcluida;
begin
  var TarefaConcluida := TTarefa.Create;
  try
    TarefaConcluida.Id := 1;
    TarefaConcluida.Status := 'CONCLUIDA';

    FMockRepo.Setup.Returns(TarefaConcluida).When.ObterPorId(1);

    var Req: TAtualizarStatusRequest;
    Req.Id := 1;
    Req.Status := 'PENDENTE';

    var Lancou := False;
    try
      FService.AtualizarStatus(Req);
    except
      on E: Exception do
      begin
        Lancou := True;
        Should(E.Message).Contain('já está concluída');
      end;
    end;

    Should(Lancou).BeTrue;
    FMockRepo.Received(Times.Never).Atualizar(Arg.Any<TTarefa>);
  finally
    TarefaConcluida.Free;
  end;
end;

procedure TTarefaServiceTests.Deve_PreencherDataConclusao_AoModificarStatusParaConcluida;
begin
  var TarefaAndamento := TTarefa.Create;
  try
    TarefaAndamento.Id := 2;
    TarefaAndamento.Status := 'EM_ANDAMENTO';
    // DataConclusao inicia nula

    FMockRepo.Setup.Returns(TarefaAndamento).When.ObterPorId(2);
    // Configura o Atualizar para devolver a própria instância alterada
    FMockRepo.Setup.Returns(TarefaAndamento).When.Atualizar(Arg.Any<TTarefa>);

    var Req: TAtualizarStatusRequest;
    Req.Id := 2;
    Req.Status := 'CONCLUIDA';

    var Res := FService.AtualizarStatus(Req);

    Should(Res.Status).Be('CONCLUIDA');
    Should(Res.DataConclusao).NotBe(''); // Certifica que foi preenchida com a data ISO real
    
    FMockRepo.Received(Times.Once).Atualizar(Arg.Any<TTarefa>);
  finally
    TarefaAndamento.Free;
  end;
end;

end.
