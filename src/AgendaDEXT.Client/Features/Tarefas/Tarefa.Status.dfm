object TarefaStatusFrame: TTarefaStatusFrame
  Left = 0
  Top = 0
  Width = 350
  Height = 250
  TabOrder = 0
  object LblTitulo: TLabel
    Left = 16
    Top = 16
    Width = 318
    Height = 18
    Anchors = [akLeft, akTop, akRight]
    Caption = 'T'#237'tulo da Tarefa'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object LblStatusAtualBase: TLabel
    Left = 16
    Top = 48
    Width = 65
    Height = 15
    Caption = 'Status Atual:'
  end
  object LblStatusAtual: TLabel
    Left = 96
    Top = 48
    Width = 59
    Height = 15
    Caption = 'PENDENTE'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object LblNovoStatusBase: TLabel
    Left = 16
    Top = 80
    Width = 67
    Height = 15
    Caption = 'Novo Status:'
    FocusControl = EdtNovoStatus
  end
  object LblOpcoesValidasBase: TLabel
    Left = 16
    Top = 140
    Width = 92
    Height = 15
    Caption = 'Op'#231#245'es V'#225'lidas:'
  end
  object LblOpcoesValidas: TLabel
    Left = 16
    Top = 160
    Width = 318
    Height = 30
    Anchors = [akLeft, akTop, akRight]
    Caption = 'EM_ANDAMENTO, CANCELADA'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clGreen
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
    WordWrap = True
  end
  object EdtNovoStatus: TEdit
    Left = 16
    Top = 99
    Width = 318
    Height = 23
    Anchors = [akLeft, akTop, akRight]
    CharCase = ecUpperCase
    TabOrder = 0
  end
  object BtnConfirmar: TButton
    Left = 176
    Top = 208
    Width = 80
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Confirmar'
    TabOrder = 1
    OnClick = BtnConfirmarClick
  end
  object BtnVoltar: TButton
    Left = 262
    Top = 208
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Voltar'
    TabOrder = 2
    OnClick = BtnVoltarClick
  end
end
