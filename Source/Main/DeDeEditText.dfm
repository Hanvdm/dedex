object EditTextForm: TEditTextForm
  Left = 214
  Top = 363
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  ClientHeight = 63
  ClientWidth = 464
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnDestroy = FormDestroy
  OnHide = FormHide
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 72
    Height = 13
    Caption = 'User Comment:'
  end
  object Edit1: TEdit
    Left = 8
    Top = 24
    Width = 449
    Height = 21
    TabOrder = 0
    OnKeyPress = Edit1KeyPress
  end
end
