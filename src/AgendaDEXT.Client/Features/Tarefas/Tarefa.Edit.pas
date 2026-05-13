unit Tarefa.Edit;

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
  TTarefaEditFrame = class(TFrame)
  private
    FViewModel: TTarefaEditViewModel;
  published
    // Controles visuais limpos padrão VCL sem atributos de Binding
    EdtTitulo: TEdit;
    EdtDescricao: TEdit;
    EdtPrioridade: TEdit;
    LblErros: TLabel;
    BtnSalvar: TButton;
    BtnCancelar: TButton;

    // Manipuladores de eventos manuais VCL normais declarados na seção published
    procedure BtnSalvarClick(Sender: TObject);
    procedure BtnCancelarClick(Sender: TObject);
  public
    procedure AfterConstruction; override;
    destructor Destroy; override;
    procedure OnNavigatedTo(const Context: TNavigationContext);
    procedure OnNavigatedFrom;
    procedure AtualizarInterface;
  end;

implementation

{$R *.dfm}

uses
  ApiClient;

procedure TTarefaEditFrame.AfterConstruction;
begin
  inherited;
  FViewModel := TTarefaEditViewModel.Create;
end;

destructor TTarefaEditFrame.Destroy;
begin
  FViewModel.Free;
  inherited Destroy;
end;

procedure TTarefaEditFrame.OnNavigatedTo(const Context: TNavigationContext);
begin
  FViewModel.Limpar;
  AtualizarInterface;
end;

procedure TTarefaEditFrame.OnNavigatedFrom;
begin
end;

procedure TTarefaEditFrame.AtualizarInterface;
begin
  if EdtTitulo <> nil then EdtTitulo.Text := FViewModel.Titulo;
  if EdtDescricao <> nil then EdtDescricao.Text := FViewModel.Descricao;
  if EdtPrioridade <> nil then EdtPrioridade.Text := IntToStr(FViewModel.Prioridade);
  if LblErros <> nil then LblErros.Caption := FViewModel.Errors.Text;
end;

procedure TTarefaEditFrame.BtnSalvarClick(Sender: TObject);
begin
  if EdtTitulo <> nil then FViewModel.Titulo := EdtTitulo.Text;
  if EdtDescricao <> nil then FViewModel.Descricao := EdtDescricao.Text;
  if EdtPrioridade <> nil then FViewModel.Prioridade := StrToIntDef(EdtPrioridade.Text, 3);

  if FViewModel.Validar then
  begin
    var Api := TApiClient.Create;
    Api.CriarTarefa(FViewModel.ObterDtoCriacao);
    if LblErros <> nil then LblErros.Caption := 'Tarefa criada com sucesso!';
    // Hook preparado para voltar nativamente na pilha VCL
  end
  else
  begin
    if LblErros <> nil then LblErros.Caption := FViewModel.Errors.Text;
  end;
end;

procedure TTarefaEditFrame.BtnCancelarClick(Sender: TObject);
begin
  // Ação imperativa de cancelamento e retorno na orquestração visual
end;

end.
