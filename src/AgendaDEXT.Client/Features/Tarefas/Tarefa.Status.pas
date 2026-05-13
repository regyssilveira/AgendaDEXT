unit Tarefa.Status;

interface

uses
  System.SysUtils,
  System.Classes,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.StdCtrls,
  Dext.UI,
  Tarefa.ViewModel;

type
  TTarefaStatusFrame = class(TFrame)
  private
    FViewModel: TTarefaStatusViewModel;
  published
    // Componentes visuais limpos padrão VCL sem anotações de Binding
    LblTitulo: TLabel;
    LblStatusAtual: TLabel;
    EdtNovoStatus: TEdit;
    LblOpcoesValidas: TLabel;
    BtnConfirmar: TButton;
    BtnVoltar: TButton;

    // Manipuladores de eventos VCL normais declarados na seção published
    procedure BtnConfirmarClick(Sender: TObject);
    procedure BtnVoltarClick(Sender: TObject);
  public
    procedure AfterConstruction; override;
    destructor Destroy; override;
    procedure OnNavigatedTo(const Context: TNavigationContext);
    procedure OnNavigatedFrom;
    procedure AtualizarInterface;
    procedure CarregarDados(Id: Integer; const Titulo, StatusAtual: string);
  end;

implementation

{$R *.dfm}

uses
  ApiClient;

procedure TTarefaStatusFrame.AfterConstruction;
begin
  inherited;
  FViewModel := TTarefaStatusViewModel.Create;
end;

destructor TTarefaStatusFrame.Destroy;
begin
  FViewModel.Free;
  inherited Destroy;
end;

procedure TTarefaStatusFrame.OnNavigatedTo(const Context: TNavigationContext);
begin
  AtualizarInterface;
end;

procedure TTarefaStatusFrame.CarregarDados(Id: Integer; const Titulo, StatusAtual: string);
begin
  FViewModel.CarregarTarefa(Id, Titulo, StatusAtual);
  AtualizarInterface;
end;

procedure TTarefaStatusFrame.OnNavigatedFrom;
begin
end;

procedure TTarefaStatusFrame.AtualizarInterface;
begin
  if LblTitulo <> nil then LblTitulo.Caption := FViewModel.TituloTarefa;
  if LblStatusAtual <> nil then LblStatusAtual.Caption := FViewModel.StatusAtual;
  if LblOpcoesValidas <> nil then LblOpcoesValidas.Caption := FViewModel.TransicoesValidas.Text;
end;

procedure TTarefaStatusFrame.BtnConfirmarClick(Sender: TObject);
begin
  if EdtNovoStatus <> nil then
    FViewModel.NovoStatus := EdtNovoStatus.Text;

  var Novo := Trim(UpperCase(FViewModel.NovoStatus));
  if (Novo <> '') and (FViewModel.TarefaId > 0) then
  begin
    var Api := TApiClient.Create;
    Api.AtualizarStatus(FViewModel.TarefaId, Novo);
    if LblOpcoesValidas <> nil then LblOpcoesValidas.Caption := 'Status alterado com sucesso!';
    // Transição imperativa preparada para retornar à listagem
  end;
end;

procedure TTarefaStatusFrame.BtnVoltarClick(Sender: TObject);
begin
  // Operação visual nativa de retorno
end;

end.
