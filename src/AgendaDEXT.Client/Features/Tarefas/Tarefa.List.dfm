object TarefaListFrame: TTarefaListFrame
  Left = 0
  Top = 0
  Width = 800
  Height = 600
  TabOrder = 0
  object LblTotalTarefas: TLabel
    Left = 16
    Top = 16
    Width = 100
    Height = 16
    Caption = '0'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object LblMediaPrioridade: TLabel
    Left = 136
    Top = 16
    Width = 100
    Height = 16
    Caption = '0.0'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object LblConcluidas7Dias: TLabel
    Left = 256
    Top = 16
    Width = 100
    Height = 16
    Caption = '0'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object LblStatusRodape: TLabel
    Left = 16
    Top = 560
    Width = 760
    Height = 16
    Anchors = [akLeft, akBottom]
    Caption = 'Pronto'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object EdtFiltroStatus: TEdit
    Left = 16
    Top = 48
    Width = 150
    Height = 23
    TabOrder = 0
    TextHint = 'Status...'
  end
  object BtnFiltrar: TButton
    Left = 176
    Top = 46
    Width = 75
    Height = 25
    Caption = 'Filtrar'
    TabOrder = 1
    OnClick = BtnFiltrarClick
  end
  object BtnLimparFiltros: TButton
    Left = 256
    Top = 46
    Width = 100
    Height = 25
    Caption = 'Limpar Filtros'
    TabOrder = 2
    OnClick = BtnLimparFiltrosClick
  end
  object BtnAdicionar: TButton
    Left = 480
    Top = 46
    Width = 90
    Height = 25
    Caption = 'Adicionar'
    TabOrder = 3
    OnClick = BtnAdicionarClick
  end
  object BtnModificarStatus: TButton
    Left = 576
    Top = 46
    Width = 110
    Height = 25
    Caption = 'Alterar Status'
    TabOrder = 4
    OnClick = BtnModificarStatusClick
  end
  object BtnRemover: TButton
    Left = 692
    Top = 46
    Width = 80
    Height = 25
    Caption = 'Remover'
    TabOrder = 5
    OnClick = BtnRemoverClick
  end
  object StringGridTarefas: TStringGrid
    Left = 16
    Top = 88
    Width = 760
    Height = 420
    Anchors = [akLeft, akTop, akRight, akBottom]
    ColCount = 5
    FixedCols = 0
    RowCount = 2
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSelect]
    TabOrder = 6
  end
  object BtnAnterior: TButton
    Left = 16
    Top = 520
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = '< Anterior'
    TabOrder = 7
    OnClick = BtnAnteriorClick
  end
  object BtnProxima: TButton
    Left = 104
    Top = 520
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Pr'#243'xima >'
    TabOrder = 8
    OnClick = BtnProximaClick
  end
end
