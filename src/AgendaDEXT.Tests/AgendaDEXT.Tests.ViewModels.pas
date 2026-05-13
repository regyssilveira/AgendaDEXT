unit AgendaDEXT.Tests.ViewModels;

interface

uses
  System.SysUtils,
  System.Classes,
  Dext.Testing,
  Dext.Mocks,
  Tarefa.Client.DTOs,
  ApiClient,
  Tarefa.ViewModel;

type
  [TestFixture]
  TViewModelsTests = class
  public
    [Test]
    procedure Deve_Validar_Edicao_ComDadosCorretos;

    [Test]
    procedure Deve_ColetarErros_NaEdicao_ComDadosIncompletos;

    [Test]
    procedure Deve_CarregarTransicoesValidas_ParaStatusPendente;
  end;

implementation

procedure TViewModelsTests.Deve_Validar_Edicao_ComDadosCorretos;
begin
  var Vm := TTarefaEditViewModel.Create;
  try
    Vm.Titulo := 'Tarefa Unitária UI';
    Vm.Descricao := 'Testando vinculação limpa';
    Vm.Prioridade := 4;

    var Valido := Vm.Validar;

    Should(Valido).BeTrue;
    Should(Vm.Errors.Count).Be(0);

    var Dto := Vm.ObterDtoCriacao;
    Should(Dto.Titulo).Be('Tarefa Unitária UI');
    Should(Dto.Prioridade).Be(4);
  finally
    Vm.Free;
  end;
end;

procedure TViewModelsTests.Deve_ColetarErros_NaEdicao_ComDadosIncompletos;
begin
  var Vm := TTarefaEditViewModel.Create;
  try
    Vm.Titulo := ''; // Vazio gera erro
    Vm.Prioridade := 9; // Fora do range gera erro

    var Valido := Vm.Validar;

    Should(Valido).BeFalse;
    Should(Vm.Errors.Count).Be(2);
    Should(Vm.Errors.Text).Contain('título');
    Should(Vm.Errors.Text).Contain('prioridade');
  finally
    Vm.Free;
  end;
end;

procedure TViewModelsTests.Deve_CarregarTransicoesValidas_ParaStatusPendente;
begin
  var Vm := TTarefaStatusViewModel.Create;
  try
    Vm.CarregarTarefa(5, 'Aprovar Pull Request', 'PENDENTE');

    Should(Vm.TarefaId).Be(5);
    Should(Vm.StatusAtual).Be('PENDENTE');
    Should(Vm.TransicoesValidas.Count).Be(2);
    Should(Vm.TransicoesValidas[0]).Be('EM_ANDAMENTO');
    Should(Vm.TransicoesValidas[1]).Be('CANCELADA');
  finally
    Vm.Free;
  end;
end;

end.
