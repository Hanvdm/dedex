object EditExprForm: TEditExprForm
  Left = 438
  Top = 204
  BorderStyle = bsDialog
  ClientHeight = 58
  ClientWidth = 196
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 68
    Height = 13
    Caption = 'Display Name:'
  end
  object Edit1: TEdit
    Left = 8
    Top = 24
    Width = 181
    Height = 21
    TabOrder = 0
    OnKeyPress = Edit1KeyPress
  end
end
