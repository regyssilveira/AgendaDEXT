object TarefaEditFrame: TTarefaEditFrame
  Left = 0
  Top = 0
  Width = 400
  Height = 350
  TabOrder = 0
  object LblTitulo: TLabel
    Left = 16
    Top = 16
    Width = 35
    Height = 15
    Caption = 'T'#237'tulo'
    FocusControl = EdtTitulo
  end
  object LblDescricao: TLabel
    Left = 16
    Top = 72
    Width = 53
    Height = 15
    Caption = 'Descri'#231#227'o'
    FocusControl = EdtDescricao
  end
  object LblPrioridade: TLabel
    Left = 16
    Top = 184
    Width = 85
    Height = 15
    Caption = 'Prioridade (1-5)'
    FocusControl = EdtPrioridade
  end
  object LblErros: TLabel
    Left = 16
    Top = 240
    Width = 360
    Height = 30
    Anchors = [akLeft, akTop, akRight]
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
    WordWrap = True
  end
  object EdtTitulo: TEdit
    Left = 16
    Top = 35
    Width = 360
    Height = 23
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
  end
  object EdtDescricao: TEdit
    Left = 16
    Top = 91
    Width = 360
    Height = 80
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    TabOrder = 1
  end
  object EdtPrioridade: TEdit
    Left = 16
    Top = 203
    Width = 100
    Height = 23
    TabOrder = 2
    Text = '3'
  end
  object BtnSalvar: TButton
    Left = 220
    Top = 280
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Salvar'
    TabOrder = 3
    OnClick = BtnSalvarClick
  end
  object BtnCancelar: TButton
    Left = 301
    Top = 280
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Cancelar'
    TabOrder = 4
    OnClick = BtnCancelarClick
  end
end
