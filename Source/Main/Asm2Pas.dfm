object Asm2PasForm: TAsm2PasForm
  Left = 113
  Top = 107
  Width = 800
  Height = 583
  Caption = 'Asm2Pas'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter2: TSplitter
    Left = 0
    Top = 73
    Width = 2
    Height = 483
    Cursor = crHSplit
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 792
    Height = 73
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object RxLabel1: TRxLabel
      Left = 8
      Top = 32
      Width = 5
      Height = 13
    end
    object Edit1: TEdit
      Left = 16
      Top = 24
      Width = 121
      Height = 21
      TabOrder = 0
    end
    object Button1: TButton
      Left = 144
      Top = 24
      Width = 75
      Height = 25
      Caption = 'Process'
      TabOrder = 1
      OnClick = Button1Click
    end
  end
  object Panel2: TPanel
    Left = 2
    Top = 73
    Width = 790
    Height = 483
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object Splitter1: TSplitter
      Left = 0
      Top = 220
      Width = 790
      Height = 2
      Cursor = crVSplit
      Align = alTop
      MinSize = 50
    end
    object GroupBox1: TGroupBox
      Left = 0
      Top = 0
      Width = 790
      Height = 220
      Align = alTop
      Caption = 'Variables'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      object ListView1: TListView
        Left = 2
        Top = 15
        Width = 786
        Height = 203
        Align = alClient
        Columns = <
          item
            Caption = 'Address'
          end
          item
            Caption = 'Name'
          end
          item
            Caption = 'Type'
          end
          item
            Caption = 'Vision'
          end>
        ColumnClick = False
        ReadOnly = True
        TabOrder = 0
        ViewStyle = vsReport
      end
    end
  end
end
