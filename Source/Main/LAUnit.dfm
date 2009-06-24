object LSForm: TLSForm
  Left = 359
  Top = 287
  BorderIcons = []
  BorderStyle = bsDialog
  ClientHeight = 257
  ClientWidth = 400
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 32
    Width = 368
    Height = 104
    Caption = 
      '   The author of DeDe wants to make clear here that you have not' +
      ' received '#13#10'the permission to sell dissasembly code produced wit' +
      'h the help of this software'#13#10'or otherwize gain money using DeDe.' +
      #13#10'    It'#39's from the beginning that the author has always emphasi' +
      'zed on keeping '#13#10'Dede free for use for everyone. This software i' +
      's owned by DaFixer and is '#13#10'protected by copyright law and inter' +
      'national copyright treaty. Therefore, you '#13#10'must treat this Soft' +
      'ware like any other copyrighted material. Every attempt at '#13#10'try' +
      'ing to earn money out of DeDe or his produced results will not b' +
      'e tolerated.'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object Label2: TLabel
    Left = 88
    Top = 8
    Width = 200
    Height = 13
    Caption = 'END USER LICENSE STATEMENT'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label3: TLabel
    Left = 16
    Top = 144
    Width = 378
    Height = 52
    Caption = 
      '    Well ... just dont use my sources in your programs without m' +
      'entioning at '#13#10'least my name somewhere in your program'#39's about b' +
      'ox :) If you want to use '#13#10'my sources or knowladge you can find ' +
      'in the sources for commersial software '#13#10'i expect some profit fo' +
      'r this. Im not greedy so just contact me to make the deal :) '
  end
  object Button1: TButton
    Left = 104
    Top = 216
    Width = 75
    Height = 25
    Caption = 'I Agree'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 216
    Top = 216
    Width = 75
    Height = 25
    Caption = 'I Disagree'
    TabOrder = 1
    OnClick = Button2Click
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 344
    Top = 216
  end
end
