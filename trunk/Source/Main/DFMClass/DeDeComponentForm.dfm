object frmDedeComponent: TfrmDedeComponent
  Left = 0
  Top = 0
  Caption = 'frmDedeComponent'
  ClientHeight = 474
  ClientWidth = 649
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = mm1
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object pgc1: TPageControl
    Left = 0
    Top = 0
    Width = 649
    Height = 474
    ActivePage = tsDialogs
    Align = alClient
    TabOrder = 0
    object ts1: TTabSheet
      Caption = 'Standard'
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 391
      object Label1: TLabel
        Left = 112
        Top = 56
        Width = 31
        Height = 13
        Caption = 'Label1'
      end
      object edt1: TEdit
        Left = 176
        Top = 56
        Width = 121
        Height = 21
        TabOrder = 0
        Text = 'edt1'
      end
      object mmo1: TMemo
        Left = 320
        Top = 32
        Width = 185
        Height = 89
        Lines.Strings = (
          'mmo1')
        TabOrder = 1
      end
      object btn1: TButton
        Left = 32
        Top = 144
        Width = 75
        Height = 25
        Caption = 'btn1'
        TabOrder = 2
      end
      object chk1: TCheckBox
        Left = 144
        Top = 144
        Width = 97
        Height = 17
        Caption = 'chk1'
        TabOrder = 3
      end
      object rb1: TRadioButton
        Left = 272
        Top = 144
        Width = 113
        Height = 17
        Caption = 'rb1'
        TabOrder = 4
      end
      object lst1: TListBox
        Left = 424
        Top = 144
        Width = 121
        Height = 97
        ItemHeight = 13
        TabOrder = 5
      end
      object cbb1: TComboBox
        Left = 32
        Top = 208
        Width = 145
        Height = 21
        ItemHeight = 0
        TabOrder = 6
        Text = 'cbb1'
      end
      object grp1: TGroupBox
        Left = 232
        Top = 184
        Width = 185
        Height = 105
        Caption = 'grp1'
        TabOrder = 7
      end
      object rg1: TRadioGroup
        Left = 56
        Top = 256
        Width = 185
        Height = 105
        Caption = 'rg1'
        TabOrder = 8
      end
      object pnl1: TPanel
        Left = 272
        Top = 295
        Width = 185
        Height = 41
        Caption = 'pnl1'
        TabOrder = 9
      end
    end
    object ts2: TTabSheet
      Caption = 'Additional'
      ImageIndex = 1
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 391
      object btn3: TSpeedButton
        Left = 97
        Top = 115
        Width = 23
        Height = 22
      end
      object img1: TImage
        Left = 272
        Top = 168
        Width = 105
        Height = 33
      end
      object shp1: TShape
        Left = 408
        Top = 184
        Width = 65
        Height = 17
      end
      object spl1: TSplitter
        Left = 0
        Top = 58
        Height = 388
        ExplicitLeft = 376
        ExplicitTop = 248
        ExplicitHeight = 100
      end
      object btn2: TBitBtn
        Left = 16
        Top = 112
        Width = 75
        Height = 25
        Caption = 'btn2'
        TabOrder = 0
      end
      object medt1: TMaskEdit
        Left = 136
        Top = 112
        Width = 121
        Height = 21
        TabOrder = 1
        Text = 'medt1'
      end
      object strngrd1: TStringGrid
        Left = 272
        Top = 104
        Width = 320
        Height = 57
        TabOrder = 2
      end
      object drwgrd1: TDrawGrid
        Left = 8
        Top = 168
        Width = 241
        Height = 57
        TabOrder = 3
      end
      object sb1: TScrollBox
        Left = 16
        Top = 248
        Width = 185
        Height = 17
        TabOrder = 4
      end
      object chklst1: TCheckListBox
        Left = 232
        Top = 231
        Width = 121
        Height = 41
        ItemHeight = 13
        TabOrder = 5
      end
      object txt1: TStaticText
        Left = 392
        Top = 240
        Width = 24
        Height = 17
        Caption = 'txt1'
        TabOrder = 6
      end
      object ctrlbr1: TControlBar
        Left = 456
        Top = 224
        Width = 100
        Height = 50
        TabOrder = 7
      end
      object lst2: TValueListEditor
        Left = 16
        Top = 278
        Width = 306
        Height = 52
        TabOrder = 8
      end
      object lbledt1: TLabeledEdit
        Left = 352
        Top = 288
        Width = 121
        Height = 21
        EditLabel.Width = 32
        EditLabel.Height = 13
        EditLabel.Caption = 'lbledt1'
        TabOrder = 9
      end
      object lst3: TColorListBox
        Left = 496
        Top = 280
        Width = 121
        Height = 41
        ItemHeight = 16
        TabOrder = 10
      end
      object btn4: TCategoryButtons
        Left = 20
        Top = 344
        Height = 36
        ButtonFlow = cbfVertical
        Categories = <>
        RegularButtonColor = 14410210
        SelectedButtonColor = 12502986
        TabOrder = 11
      end
      object btn5: TButtonGroup
        Left = 136
        Top = 336
        Height = 44
        Items = <>
        TabOrder = 12
      end
      object dcktbst1: TDockTabSet
        Left = 264
        Top = 336
        Width = 185
        Height = 21
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
      end
      object ts4: TTabSet
        Left = 488
        Top = 336
        Width = 185
        Height = 21
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
      end
      object flwpnl1: TFlowPanel
        Left = 20
        Top = 386
        Width = 185
        Height = 41
        Caption = 'flwpnl1'
        TabOrder = 15
      end
      object grdpnl1: TGridPanel
        Left = 240
        Top = 392
        Width = 185
        Height = 41
        Caption = 'grdpnl1'
        ColumnCollection = <
          item
            Value = 50.000000000000000000
          end
          item
            Value = 50.000000000000000000
          end>
        ControlCollection = <>
        RowCollection = <
          item
            Value = 50.000000000000000000
          end
          item
            Value = 50.000000000000000000
          end>
        TabOrder = 16
      end
      object actmmb1: TActionMainMenuBar
        Left = 0
        Top = 0
        Width = 641
        Height = 29
        Caption = 'actmmb1'
        ColorMap.HighlightColor = 14410210
        ColorMap.BtnSelectedColor = clBtnFace
        ColorMap.UnusedColor = 14410210
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clMenuText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        PersistentHotKeys = True
        Spacing = 0
        ExplicitTop = 3
      end
      object acttb1: TActionToolBar
        Left = 0
        Top = 29
        Width = 641
        Height = 29
        Caption = 'acttb1'
        ColorMap.HighlightColor = 14410210
        ColorMap.BtnSelectedColor = clBtnFace
        ColorMap.UnusedColor = 14410210
        Spacing = 0
        ExplicitLeft = 320
        ExplicitTop = 56
        ExplicitWidth = 150
      end
    end
    object ts3: TTabSheet
      Caption = 'Win32'
      ImageIndex = 2
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 391
      object tbc1: TTabControl
        Left = 320
        Top = 24
        Width = 289
        Height = 41
        TabOrder = 0
      end
      object redt1: TRichEdit
        Left = 128
        Top = 104
        Width = 185
        Height = 89
        Font.Charset = GB2312_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        Lines.Strings = (
          'redt1')
        ParentFont = False
        TabOrder = 1
      end
      object trckbr1: TTrackBar
        Left = 312
        Top = 96
        Width = 150
        Height = 45
        TabOrder = 2
      end
      object pb1: TProgressBar
        Left = 496
        Top = 80
        Width = 150
        Height = 16
        TabOrder = 3
      end
      object ud1: TUpDown
        Left = 368
        Top = 144
        Width = 16
        Height = 24
        TabOrder = 4
      end
      object hk1: THotKey
        Left = 496
        Top = 120
        Width = 121
        Height = 19
        HotKey = 32833
        TabOrder = 5
      end
      object hk2: THotKey
        Left = 3
        Top = 149
        Width = 121
        Height = 19
        HotKey = 32833
        TabOrder = 6
      end
      object ani1: TAnimate
        Left = 24
        Top = 208
        Width = 100
        Height = 57
      end
      object dtp1: TDateTimePicker
        Left = 352
        Top = 208
        Width = 186
        Height = 21
        Date = 39989.569169918980000000
        Time = 39989.569169918980000000
        TabOrder = 8
      end
      object cal1: TMonthCalendar
        Left = 3
        Top = 208
        Width = 267
        Height = 154
        Date = 39989.574844282400000000
        TabOrder = 9
      end
      object tv1: TTreeView
        Left = 296
        Top = 247
        Width = 121
        Height = 34
        Indent = 19
        TabOrder = 10
      end
      object lv1: TListView
        Left = 312
        Top = 287
        Width = 250
        Height = 34
        Columns = <>
        TabOrder = 11
      end
      object hdrcntrl1: THeaderControl
        Left = 0
        Top = 0
        Width = 641
        Height = 17
        Sections = <>
        ExplicitLeft = 480
        ExplicitTop = 248
        ExplicitWidth = 0
      end
      object stat1: TStatusBar
        Left = 0
        Top = 427
        Width = 641
        Height = 19
        Panels = <>
        ExplicitLeft = 448
        ExplicitTop = 272
        ExplicitWidth = 0
      end
      object tlb1: TToolBar
        Left = 0
        Top = 17
        Width = 641
        Height = 29
        Caption = 'tlb1'
        TabOrder = 14
        ExplicitLeft = 496
        ExplicitTop = 248
        ExplicitWidth = 150
      end
      object clbr1: TCoolBar
        Left = 0
        Top = 46
        Width = 641
        Height = 75
        Bands = <>
        ExplicitTop = 52
      end
      object pgscrlr1: TPageScroller
        Left = 448
        Top = 157
        Width = 150
        Height = 45
        TabOrder = 16
      end
      object cbb2: TComboBoxEx
        Left = 312
        Top = 327
        Width = 145
        Height = 22
        ItemsEx = <>
        ItemHeight = 16
        TabOrder = 17
        Text = 'cbb2'
      end
    end
    object ts5: TTabSheet
      Caption = 'system'
      ImageIndex = 3
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object pb2: TPaintBox
        Left = 448
        Top = 72
        Width = 105
        Height = 105
      end
      object mp1: TMediaPlayer
        Left = 152
        Top = 120
        Width = 253
        Height = 30
        TabOrder = 0
      end
      object olcntnr1: TOleContainer
        Left = 25
        Top = 144
        Width = 121
        Height = 121
        Caption = 'olcntnr1'
        TabOrder = 1
      end
    end
    object TabSheet1: TTabSheet
      Caption = 'Win3.1'
      ImageIndex = 4
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object dblklst1: TDBLookupList
        Left = 80
        Top = 144
        Width = 121
        Height = 97
        TabOrder = 0
      end
      object dblkcbb1: TDBLookupCombo
        Left = 272
        Top = 112
        Width = 121
        Height = 25
        TabOrder = 1
      end
      object otln1: TOutline
        Left = 456
        Top = 88
        Width = 121
        Height = 97
        ItemHeight = 13
        TabOrder = 2
        ItemSeparator = '\'
      end
      object nb1: TTabbedNotebook
        Left = 448
        Top = 40
        Width = 300
        Height = 250
        TabFont.Charset = DEFAULT_CHARSET
        TabFont.Color = clBtnText
        TabFont.Height = -11
        TabFont.Name = 'Tahoma'
        TabFont.Style = []
        TabOrder = 3
        object TTabPage
          Left = 4
          Top = 24
          Caption = 'Default'
        end
      end
      object nb2: TNotebook
        Left = 216
        Top = 272
        Width = 150
        Height = 150
        TabOrder = 4
        object TPage
          Left = 0
          Top = 0
          Caption = 'Default'
        end
      end
      object hdr1: THeader
        Left = 72
        Top = 288
        Width = 250
        Height = 25
        TabOrder = 5
      end
      object fllst1: TFileListBox
        Left = 40
        Top = 248
        Width = 145
        Height = 97
        ItemHeight = 13
        TabOrder = 6
      end
      object dirlst1: TDirectoryListBox
        Left = 408
        Top = 224
        Width = 145
        Height = 97
        ItemHeight = 16
        TabOrder = 7
      end
      object drvcbb1: TDriveComboBox
        Left = 320
        Top = 232
        Width = 145
        Height = 19
        TabOrder = 8
      end
      object fltcbb1: TFilterComboBox
        Left = 72
        Top = 376
        Width = 145
        Height = 21
        TabOrder = 9
      end
    end
    object tsDialogs: TTabSheet
      Caption = 'tsDialogs'
      ImageIndex = 5
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
    end
  end
  object mm1: TMainMenu
    Left = 24
    Top = 72
  end
  object pm1: TPopupMenu
    Left = 72
    Top = 72
  end
  object actlst1: TActionList
    Left = 16
    Top = 32
  end
  object aplctnvnts1: TApplicationEvents
    Left = 248
    Top = 48
  end
  object ti1: TTrayIcon
    Left = 288
    Top = 48
  end
  object am1: TActionManager
    Left = 128
    Top = 40
    StyleName = 'XP Style'
  end
  object pctnbr1: TPopupActionBar
    Left = 192
    Top = 56
  end
  object xpclrmp1: TXPColorMap
    HighlightColor = 14410210
    BtnSelectedColor = clBtnFace
    UnusedColor = 14410210
    Left = 48
    Top = 112
  end
  object stndrdclrmp1: TStandardColorMap
    HighlightColor = clBtnHighlight
    UnusedColor = 14673125
    SelectedColor = clHighlight
    Left = 128
    Top = 88
  end
  object twlghtclrmp1: TTwilightColorMap
    HighlightColor = clBlack
    BtnFrameColor = clBlack
    DisabledColor = cl3DDkShadow
    Left = 232
    Top = 88
  end
  object dlg1: TCustomizeDlg
    StayOnTop = False
    Left = 184
    Top = 88
  end
  object il1: TImageList
    Left = 80
    Top = 120
  end
  object xpmnfst1: TXPManifest
    Left = 544
    Top = 256
  end
  object shlrsrcs1: TShellResources
    Left = 112
    Top = 32
  end
  object tmr1: TTimer
    Left = 360
    Top = 80
  end
  object cmdmnctlg1: TCOMAdminCatalog
    AutoConnect = False
    ConnectKind = ckRunningOrNew
    Left = 240
    Top = 184
  end
  object dde1: TDdeClientConv
    Left = 280
    Top = 192
  end
  object dde2: TDdeClientConv
    Left = 360
    Top = 184
  end
  object dde3: TDdeClientItem
    Left = 256
    Top = 216
  end
  object dde4: TDdeServerConv
    Left = 344
    Top = 208
  end
  object dde5: TDdeServerItem
    Left = 248
    Top = 240
  end
  object dlgOpen1: TOpenDialog
    Left = 304
    Top = 104
  end
  object dlgSave1: TSaveDialog
    Left = 464
    Top = 104
  end
  object dlgOpenPic1: TOpenPictureDialog
    Left = 376
    Top = 120
  end
  object dlg2: TSavePictureDialog
    Left = 288
    Top = 144
  end
  object dlg3: TOpenTextFileDialog
    Left = 192
    Top = 160
  end
  object dlg4: TSaveTextFileDialog
    Left = 144
    Top = 176
  end
  object dlgFont1: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    Left = 216
    Top = 248
  end
  object dlgColor1: TColorDialog
    Left = 432
    Top = 240
  end
  object dlgPnt1: TPrintDialog
    Left = 248
    Top = 264
  end
  object dlgPntSet1: TPrinterSetupDialog
    Left = 136
    Top = 256
  end
  object dlgFind1: TFindDialog
    Left = 168
    Top = 184
  end
  object dlgReplace1: TReplaceDialog
    Left = 136
    Top = 224
  end
  object dlg5: TPageSetupDialog
    MinMarginLeft = 0
    MinMarginTop = 0
    MinMarginRight = 0
    MinMarginBottom = 0
    MarginLeft = 2500
    MarginTop = 2500
    MarginRight = 2500
    MarginBottom = 2500
    PageWidth = 21000
    PageHeight = 29700
    Left = 40
    Top = 152
  end
end
