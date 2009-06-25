object frmDedeComponent: TfrmDedeComponent
  Left = 0
  Top = 0
  Caption = 'frmDedeComponent'
  ClientHeight = 398
  ClientWidth = 563
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
  object bvl1: TBevel
    Left = 264
    Top = 184
    Width = 50
    Height = 50
  end
  object pgc1: TPageControl
    Left = 0
    Top = 0
    Width = 563
    Height = 398
    ActivePage = tsEHLib
    Align = alClient
    TabOrder = 0
    ExplicitTop = -1
    ExplicitWidth = 773
    ExplicitHeight = 653
    object ts1: TTabSheet
      Caption = 'Standard'
      ExplicitWidth = 641
      ExplicitHeight = 446
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
        ItemHeight = 13
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
      ExplicitWidth = 641
      ExplicitHeight = 446
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
        Height = 312
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
        Width = 555
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
        ExplicitWidth = 641
      end
      object acttb1: TActionToolBar
        Left = 0
        Top = 29
        Width = 555
        Height = 29
        Caption = 'acttb1'
        ColorMap.HighlightColor = 14410210
        ColorMap.BtnSelectedColor = clBtnFace
        ColorMap.UnusedColor = 14410210
        Spacing = 0
        ExplicitWidth = 641
      end
    end
    object ts3: TTabSheet
      Caption = 'Win32'
      ImageIndex = 2
      ExplicitWidth = 641
      ExplicitHeight = 446
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
        Date = 39989.648206736110000000
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
        Width = 555
        Height = 17
        Sections = <>
        ExplicitWidth = 641
      end
      object stat1: TStatusBar
        Left = 0
        Top = 351
        Width = 555
        Height = 19
        Panels = <>
        ExplicitTop = 427
        ExplicitWidth = 641
      end
      object tlb1: TToolBar
        Left = 0
        Top = 17
        Width = 555
        Height = 29
        Caption = 'tlb1'
        TabOrder = 14
        ExplicitWidth = 641
      end
      object clbr1: TCoolBar
        Left = 0
        Top = 46
        Width = 555
        Height = 75
        Bands = <>
        ExplicitWidth = 641
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
      ExplicitWidth = 641
      ExplicitHeight = 446
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
      ExplicitWidth = 641
      ExplicitHeight = 446
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
      ExplicitWidth = 641
      ExplicitHeight = 446
    end
    object tsDataAccess: TTabSheet
      Caption = 'tsDataAccess'
      ImageIndex = 6
      ExplicitWidth = 641
      ExplicitHeight = 446
    end
    object tsDataControls: TTabSheet
      Caption = 'tsDataControls'
      ImageIndex = 7
      ExplicitWidth = 641
      ExplicitHeight = 446
      object dbtxt1: TDBText
        Left = 64
        Top = 216
        Width = 65
        Height = 17
      end
      object dbgrd1: TDBGrid
        Left = 352
        Top = 232
        Width = 320
        Height = 120
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -11
        TitleFont.Name = 'Tahoma'
        TitleFont.Style = []
      end
      object dbnvgr1: TDBNavigator
        Left = 200
        Top = 288
        Width = 240
        Height = 25
        TabOrder = 1
      end
      object dbedt1: TDBEdit
        Left = 56
        Top = 248
        Width = 121
        Height = 21
        TabOrder = 2
      end
      object dbmmo1: TDBMemo
        Left = 64
        Top = 296
        Width = 185
        Height = 89
        TabOrder = 3
      end
      object dbimg1: TDBImage
        Left = 40
        Top = 168
        Width = 105
        Height = 105
        TabOrder = 4
      end
      object dblst1: TDBListBox
        Left = 24
        Top = 336
        Width = 121
        Height = 97
        ItemHeight = 13
        TabOrder = 5
      end
      object dbcbb1: TDBComboBox
        Left = 272
        Top = 328
        Width = 145
        Height = 21
        ItemHeight = 13
        TabOrder = 6
      end
      object dbrgrp1: TDBRadioGroup
        Left = 304
        Top = 232
        Width = 185
        Height = 105
        Caption = 'dbrgrp1'
        ParentBackground = True
        TabOrder = 7
      end
      object dblklst2: TDBLookupListBox
        Left = 432
        Top = 176
        Width = 121
        Height = 95
        TabOrder = 8
      end
      object dblkcbb2: TDBLookupComboBox
        Left = 160
        Top = 112
        Width = 145
        Height = 21
        TabOrder = 9
      end
      object dbredt1: TDBRichEdit
        Left = 504
        Top = 56
        Width = 185
        Height = 89
        Font.Charset = GB2312_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 10
      end
      object dbctrlgrd1: TDBCtrlGrid
        Left = 9
        Top = 50
        Width = 216
        Height = 216
        TabOrder = 11
      end
    end
    object tsDBExpress: TTabSheet
      Caption = 'tsDBExpress'
      ImageIndex = 8
      ExplicitWidth = 641
      ExplicitHeight = 446
    end
    object tsDataSnap: TTabSheet
      Caption = 'tsDataSnap'
      ImageIndex = 9
      ExplicitWidth = 641
      ExplicitHeight = 446
    end
    object tsBDE: TTabSheet
      Caption = 'tsBDE'
      ImageIndex = 10
      ExplicitWidth = 641
      ExplicitHeight = 446
    end
    object tsDBGo: TTabSheet
      Caption = 'tsDBGo'
      ImageIndex = 11
      ExplicitWidth = 641
      ExplicitHeight = 446
    end
    object tsEHLib: TTabSheet
      Caption = 'tsEHLib'
      ImageIndex = 12
      ExplicitWidth = 641
      ExplicitHeight = 446
      object edt4: TDBNumberEditEh
        Left = 384
        Top = 208
        Width = 121
        Height = 21
        EditButtons = <>
        TabOrder = 0
        Visible = True
      end
      object cbb3: TDBComboBoxEh
        Left = 240
        Top = 224
        Width = 121
        Height = 21
        EditButtons = <>
        TabOrder = 1
        Text = 'cbb3'
        Visible = True
      end
      object cbb4: TDBLookupComboboxEh
        Left = 200
        Top = 200
        Width = 121
        Height = 21
        EditButtons = <>
        TabOrder = 2
        Visible = True
      end
      object dbchckbxh1: TDBCheckBoxEh
        Left = 368
        Top = 216
        Width = 97
        Height = 17
        Caption = 'dbchckbxh1'
        TabOrder = 3
        ValueChecked = 'True'
        ValueUnchecked = 'False'
      end
    end
    object tsIndy: TTabSheet
      Caption = 'tsIndy'
      ImageIndex = 13
      ExplicitWidth = 641
      ExplicitHeight = 446
    end
  end
  object dbgrd2: TDBGridEh
    Left = 24
    Top = 7
    Width = 320
    Height = 111
    Flat = False
    FooterColor = clWindow
    FooterFont.Charset = DEFAULT_CHARSET
    FooterFont.Color = clWindowText
    FooterFont.Height = -11
    FooterFont.Name = 'Tahoma'
    FooterFont.Style = []
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
  end
  object edt2: TDBEditEh
    Left = 184
    Top = 157
    Width = 121
    Height = 12
    EditButtons = <>
    TabOrder = 2
    Text = 'edt2'
    Visible = True
  end
  object edt3: TDBDateTimeEditEh
    Left = 472
    Top = 93
    Width = 121
    Height = 12
    EditButtons = <>
    Kind = dtkDateEh
    TabOrder = 3
    Visible = True
  end
  object prvwbx1: TPreviewBox
    Left = 240
    Top = 197
    Width = 185
    Height = 32
    HorzScrollBar.Tracking = True
    VertScrollBar.Tracking = True
    AutoScroll = False
    TabOrder = 4
  end
  object mm1: TMainMenu
    Left = 24
    Top = 37
  end
  object pm1: TPopupMenu
    Left = 72
    Top = 37
  end
  object actlst1: TActionList
    Left = 16
    Top = 65533
  end
  object aplctnvnts1: TApplicationEvents
    Left = 248
    Top = 13
  end
  object ti1: TTrayIcon
    Left = 288
    Top = 13
  end
  object am1: TActionManager
    Left = 128
    Top = 5
    StyleName = 'XP Style'
  end
  object pctnbr1: TPopupActionBar
    Left = 192
    Top = 21
  end
  object xpclrmp1: TXPColorMap
    HighlightColor = 14410210
    BtnSelectedColor = clBtnFace
    UnusedColor = 14410210
    Left = 48
    Top = 77
  end
  object stndrdclrmp1: TStandardColorMap
    HighlightColor = clBtnHighlight
    UnusedColor = 14673125
    SelectedColor = clHighlight
    Left = 128
    Top = 53
  end
  object twlghtclrmp1: TTwilightColorMap
    HighlightColor = clBlack
    BtnFrameColor = clBlack
    DisabledColor = cl3DDkShadow
    Left = 232
    Top = 53
  end
  object dlg1: TCustomizeDlg
    StayOnTop = False
    Left = 184
    Top = 53
  end
  object il1: TImageList
    Left = 80
    Top = 85
  end
  object xpmnfst1: TXPManifest
    Left = 544
    Top = 221
  end
  object shlrsrcs1: TShellResources
    Left = 112
    Top = 65533
  end
  object tmr1: TTimer
    Left = 360
    Top = 45
  end
  object cmdmnctlg1: TCOMAdminCatalog
    AutoConnect = False
    ConnectKind = ckRunningOrNew
    Left = 240
    Top = 149
  end
  object dde1: TDdeClientConv
    Left = 280
    Top = 157
  end
  object dde2: TDdeClientConv
    Left = 360
    Top = 149
  end
  object dde3: TDdeClientItem
    Left = 256
    Top = 181
  end
  object dde4: TDdeServerConv
    Left = 344
    Top = 173
  end
  object dde5: TDdeServerItem
    Left = 248
    Top = 205
  end
  object dlgOpen1: TOpenDialog
    Left = 304
    Top = 69
  end
  object dlgSave1: TSaveDialog
    Left = 464
    Top = 69
  end
  object dlgOpenPic1: TOpenPictureDialog
    Left = 376
    Top = 85
  end
  object dlg2: TSavePictureDialog
    Left = 288
    Top = 109
  end
  object dlg3: TOpenTextFileDialog
    Left = 192
    Top = 125
  end
  object dlg4: TSaveTextFileDialog
    Left = 144
    Top = 141
  end
  object dlgFont1: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    Left = 216
    Top = 213
  end
  object dlgColor1: TColorDialog
    Left = 432
    Top = 205
  end
  object dlgPnt1: TPrintDialog
    Left = 248
    Top = 229
  end
  object dlgPntSet1: TPrinterSetupDialog
    Left = 136
    Top = 221
  end
  object dlgFind1: TFindDialog
    Left = 168
    Top = 149
  end
  object dlgReplace1: TReplaceDialog
    Left = 136
    Top = 189
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
    Top = 117
  end
  object ds1: TDataSource
    Left = 376
    Top = 65525
  end
  object ds2: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 448
    Top = 65517
  end
  object dtstprvdr2: TDataSetProvider
    Left = 440
    Top = 29
  end
  object xmltrnsfrm1: TXMLTransform
    Left = 440
    Top = 69
  end
  object xmltrnsfrmprvdr1: TXMLTransformProvider
    Left = 480
    Top = 125
  end
  object xmltrnsfrmclnt1: TXMLTransformClient
    Left = 408
    Top = 109
  end
  object con1: TSQLConnection
    Left = 48
    Top = 157
  end
  object sqldtst1: TSQLDataSet
    DbxCommandType = 'Dbx.SQL'
    Params = <>
    Left = 72
    Top = 237
  end
  object sqlqry1: TSQLQuery
    Params = <>
    Left = 240
    Top = 253
  end
  object sqltbl1: TSQLTable
    Left = 168
    Top = 285
  end
  object sqlmntr1: TSQLMonitor
    Left = 272
    Top = 277
  end
  object smpldtst1: TSimpleDataSet
    Aggregates = <>
    DataSet.MaxBlobSize = -1
    DataSet.Params = <>
    Params = <>
    Left = 320
    Top = 205
  end
  object con2: TDCOMConnection
    Left = 216
    Top = 61
  end
  object con3: TSocketConnection
    Left = 312
    Top = 93
  end
  object smplbjctbrkr1: TSimpleObjectBroker
    Left = 392
    Top = 141
  end
  object con4: TWebConnection
    Agent = 'DataSnap'
    URL = 'http://server.company.com/scripts/httpsrvr.dll'
    Left = 368
    Top = 165
  end
  object con5: TConnectionBroker
    Left = 352
    Top = 101
  end
  object con6: TSharedConnection
    Left = 232
    Top = 109
  end
  object con7: TLocalConnection
    Left = 192
    Top = 93
  end
  object tbl1: TTable
    Left = 424
    Top = 229
  end
  object qry1: TQuery
    Left = 288
    Top = 173
  end
  object strdprc1: TStoredProc
    Left = 296
    Top = 133
  end
  object db1: TDatabase
    SessionName = 'Default'
    Left = 304
    Top = 77
  end
  object ssn1: TSession
    Left = 336
    Top = 53
  end
  object bm1: TBatchMove
    Left = 352
    Top = 117
  end
  object updtsql1: TUpdateSQL
    Left = 424
    Top = 53
  end
  object nstdtbl1: TNestedTable
    Left = 512
    Top = 21
  end
  object con8: TADOConnection
    Left = 392
    Top = 253
  end
  object cmd1: TADOCommand
    Parameters = <>
    Left = 512
    Top = 77
  end
  object ds3: TADODataSet
    Parameters = <>
    Left = 528
    Top = 117
  end
  object tbl2: TADOTable
    Left = 448
    Top = 141
  end
  object qry2: TADOQuery
    Parameters = <>
    Left = 496
    Top = 165
  end
  object sp1: TADOStoredProc
    Parameters = <>
    Left = 424
    Top = 157
  end
  object con9: TRDSConnection
    Left = 448
    Top = 101
  end
  object prntdbgrdh1: TPrintDBGridEh
    Options = []
    PageFooter.Font.Charset = DEFAULT_CHARSET
    PageFooter.Font.Color = clWindowText
    PageFooter.Font.Height = -11
    PageFooter.Font.Name = 'Tahoma'
    PageFooter.Font.Style = []
    PageHeader.Font.Charset = DEFAULT_CHARSET
    PageHeader.Font.Color = clWindowText
    PageHeader.Font.Height = -11
    PageHeader.Font.Name = 'Tahoma'
    PageHeader.Font.Style = []
    Units = MM
    Left = 376
    Top = 21
  end
  object dbsmlst1: TDBSumList
    ExternalRecalc = False
    SumCollection = <>
    VirtualRecords = False
    Left = 424
    Top = 197
  end
  object prpstrgh1: TPropStorageEh
    Left = 312
    Top = 205
  end
  object inprpstrgmnh1: TIniPropStorageManEh
    Left = 320
    Top = 213
  end
  object rgprpstrgmnh1: TRegPropStorageManEh
    Left = 328
    Top = 221
  end
  object mtbl1: TMemTableEh
    Params = <>
    Left = 336
    Top = 229
  end
  object dsd1: TDataSetDriverEh
    Left = 344
    Top = 237
  end
  object sqldtdrvrh1: TSQLDataDriverEh
    DeleteCommand.Params = <>
    DynaSQLParams.Options = []
    GetrecCommand.Params = <>
    InsertCommand.Params = <>
    SelectCommand.Params = <>
    UpdateCommand.Params = <>
    Left = 352
    Top = 245
  end
  object ibxdtdrvrh1: TIBXDataDriverEh
    SelectCommand.Params = <>
    UpdateCommand.Params = <>
    InsertCommand.Params = <>
    DeleteCommand.Params = <>
    GetrecCommand.Params = <>
    DynaSQLParams.Options = []
    Left = 360
    Top = 253
  end
  object adoDD1: TADODataDriverEh
    SelectCommand.Parameters = <>
    UpdateCommand.Parameters = <>
    InsertCommand.Parameters = <>
    DeleteCommand.Parameters = <>
    GetrecCommand.Parameters = <>
    DynaSQLParams.Options = []
    Left = 368
    Top = 261
  end
  object dbxdtdrvrh1: TDBXDataDriverEh
    SelectCommand.Params = <>
    UpdateCommand.Params = <>
    InsertCommand.Params = <>
    DeleteCommand.Params = <>
    GetrecCommand.Params = <>
    DynaSQLParams.Options = []
    Left = 376
    Top = 269
  end
  object bdtdrvrh1: TBDEDataDriverEh
    SelectCommand.Params = <>
    UpdateCommand.Params = <>
    InsertCommand.Params = <>
    DeleteCommand.Params = <>
    GetrecCommand.Params = <>
    DynaSQLParams.Options = []
    Left = 384
    Top = 277
  end
  object idTcpClient2: TIdTCPClient
    ConnectTimeout = 0
    IPVersion = Id_IPv4
    Port = 0
    ReadTimeout = -1
    Left = 440
    Top = 365
  end
  object idTcpClient3: TIdTCPClient
    ConnectTimeout = 0
    IPVersion = Id_IPv4
    Port = 0
    ReadTimeout = -1
    Left = 360
    Top = 301
  end
  object idpclnt1: TIdUDPClient
    Port = 0
    Left = 448
    Top = 349
  end
  object idcmdtcpclnt1: TIdCmdTCPClient
    ConnectTimeout = 0
    IPVersion = Id_IPv4
    Port = 0
    ReadTimeout = -1
    CommandHandlers = <>
    ExceptionReply.Code = '500'
    ExceptionReply.Text.Strings = (
      'Unknown Internal Error')
    Left = 344
    Top = 309
  end
  object idpmcstclnt1: TIdIPMCastClient
    Bindings = <>
    DefaultPort = 0
    MulticastGroup = '224.0.0.1'
    Left = 456
    Top = 365
  end
  object idcmpclnt1: TIdIcmpClient
    Protocol = 1
    ProtocolIPv6 = 58
    IPVersion = Id_IPv4
    PacketSize = 1024
    Left = 432
    Top = 325
  end
  object idytm1: TIdDayTime
    Left = 472
    Top = 373
  end
  object idytmdp1: TIdDayTimeUDP
    Left = 472
    Top = 397
  end
  object idct1: TIdDICT
    ConnectTimeout = 0
    Host = 'dict.org'
    IPVersion = Id_IPv4
    ReadTimeout = -1
    Client = 'Indy Library 10.1.5'
    SASLMechanisms = <>
    Left = 480
    Top = 381
  end
  object idnsrslvr1: TIdDNSResolver
    QueryType = []
    WaitingTime = 5000
    AllowRecursiveQueries = True
    IPVersion = Id_IPv4
    Left = 464
    Top = 357
  end
  object idch1: TIdEcho
    Left = 472
    Top = 365
  end
  object idchdp1: TIdEchoUDP
    Left = 496
    Top = 413
  end
  object idfngr1: TIdFinger
    CompleteQuery = '@'
    Left = 344
    Top = 365
  end
  object idfsp2: TIdFSP
    Left = 496
    Top = 389
  end
  object idftp2: TIdFTP
    AutoLogin = True
    ProxySettings.ProxyType = fpcmNone
    ProxySettings.Port = 0
    Left = 504
    Top = 397
  end
  object idgphr1: TIdGopher
    Left = 512
    Top = 405
  end
  object idhtp1: TIdHTTP
    AllowCookies = True
    ProxyParams.BasicAuthentication = False
    ProxyParams.ProxyPort = 0
    Request.ContentLength = -1
    Request.Accept = 'text/html, */*'
    Request.BasicAuthentication = False
    Request.UserAgent = 'Mozilla/3.0 (compatible; Indy Library)'
    HTTPOptions = [hoForceEncodeParams]
    Left = 520
    Top = 413
  end
  object idnt1: TIdIdent
    Left = 528
    Top = 421
  end
  object idmp: TIdIMAP4
    SASLMechanisms = <>
    MilliSecsToWaitToClearBuffer = 10
    Left = 536
    Top = 429
  end
  object idrc1: TIdIRC
    ConnectTimeout = 0
    IPVersion = Id_IPv4
    ReadTimeout = -1
    CommandHandlers = <>
    ExceptionReply.Code = '500'
    ExceptionReply.Text.Strings = (
      'Unknown Internal Error')
    UserMode = []
    Left = 544
    Top = 437
  end
  object idlpr2: TIdLPR
    Queue = 'pr1'
    Left = 552
    Top = 445
  end
  object idntp1: TIdNNTP
    Left = 560
    Top = 453
  end
  object idp: TIdPOP3
    AutoLogin = True
    SASLMechanisms = <>
    Left = 568
    Top = 461
  end
  object idqtd1: TIdQOTD
    Left = 456
    Top = 429
  end
  object idqtdp1: TIdQOTDUDP
    Left = 488
    Top = 445
  end
  object idrxc1: TIdRexec
    Left = 544
    Top = 461
  end
  object idrsh2: TIdRSH
    Left = 520
    Top = 445
  end
  object idsmtp2: TIdSMTP
    SASLMechanisms = <>
    Left = 384
    Top = 421
  end
  object idsmtprly1: TIdSMTPRelay
    Left = 472
    Top = 453
  end
  object idsnmp2: TIdSNMP
    ReceiveTimeout = 5000
    Community = 'public'
    Left = 504
    Top = 413
  end
  object idsnp1: TIdSNPP
    Left = 464
    Top = 445
  end
  object idsntp2: TIdSNTP
    Port = 123
    Left = 312
    Top = 405
  end
  object idsyslg1: TIdSysLog
    Left = 576
    Top = 485
  end
  object idsyst1: TIdSystat
    Left = 248
    Top = 301
  end
  object idtlnt1: TIdTelnet
    Terminal = 'dumb'
    Left = 272
    Top = 389
  end
  object idtm1: TIdTime
    BaseDate = 2.000000000000000000
    Left = 408
    Top = 349
  end
  object idtmdp1: TIdTimeUDP
    BaseDate = 2.000000000000000000
    Left = 312
    Top = 349
  end
  object idnxtm1: TIdUnixTime
    Left = 368
    Top = 349
  end
  object idnxtmdp1: TIdUnixTimeUDP
    Left = 368
    Top = 365
  end
  object idwhs1: TIdWhois
    Host = 'whois.internic.net'
    Left = 528
    Top = 509
  end
  object idpsrvr1: TIdUDPServer
    Bindings = <>
    DefaultPort = 0
    Left = 144
    Top = 341
  end
  object idcmdtcpsrvr1: TIdCmdTCPServer
    Bindings = <>
    DefaultPort = 0
    CommandHandlers = <>
    ExceptionReply.Code = '500'
    ExceptionReply.Text.Strings = (
      'Unknown Internal Error')
    Greeting.Code = '200'
    Greeting.Text.Strings = (
      'Welcome')
    HelpReply.Code = '100'
    HelpReply.Text.Strings = (
      'Help follows')
    MaxConnectionReply.Code = '300'
    MaxConnectionReply.Text.Strings = (
      'Too many connections. Try again later.')
    ReplyTexts = <>
    ReplyUnknownCommand.Code = '400'
    ReplyUnknownCommand.Text.Strings = (
      'Unknown Command')
    Left = 600
    Top = 469
  end
  object idsmplsrvr1: TIdSimpleServer
    BoundPort = 0
    BoundPortMin = 0
    BoundPortMax = 0
    IPVersion = Id_IPv4
    Left = 448
    Top = 541
  end
  object tcpServer1: TIdTCPServer
    Bindings = <>
    DefaultPort = 0
    Left = 560
    Top = 549
  end
  object idpmcstsrvr1: TIdIPMCastServer
    MulticastGroup = '224.0.0.1'
    Port = 0
    Left = 632
    Top = 389
  end
  object idchrgnsrvr1: TIdChargenServer
    Bindings = <>
    Left = 568
    Top = 517
  end
  object idchrgndpsrvr1: TIdChargenUDPServer
    Bindings = <>
    Left = 760
    Top = 653
  end
  object idytmsrvr1: TIdDayTimeServer
    Bindings = <>
    TimeZone = 'EST'
    Left = 768
    Top = 661
  end
  object idytmdpsrvr1: TIdDayTimeUDPServer
    Bindings = <>
    TimeZone = 'EST'
    Left = 776
    Top = 669
  end
  object idctsrvr1: TIdDICTServer
    Bindings = <>
    CommandHandlers = <>
    ExceptionReply.Code = '500'
    ExceptionReply.Text.Strings = (
      'Unknown Internal Error')
    Greeting.Code = '200'
    Greeting.Text.Strings = (
      'Welcome')
    HelpReply.Code = '100'
    HelpReply.Text.Strings = (
      'Help follows')
    MaxConnectionReply.Code = '300'
    MaxConnectionReply.Text.Strings = (
      'Too many connections. Try again later.')
    ReplyTexts = <>
    ReplyUnknownCommand.Code = '400'
    ReplyUnknownCommand.Text.Strings = (
      'Unknown Command')
    Left = 784
    Top = 677
  end
  object idscrdsrvr1: TIdDISCARDServer
    Bindings = <>
    Left = 792
    Top = 685
  end
  object idscrdpsrvr1: TIdDiscardUDPServer
    Bindings = <>
    Left = 800
    Top = 693
  end
  object idnsrvr1: TIdDNSServer
    Active = False
    Bindings = <>
    TCPACLActive = False
    ServerType = stPrimary
    Left = 808
    Top = 701
  end
  object idchsrvr1: TIdECHOServer
    Bindings = <>
    Left = 816
    Top = 709
  end
  object idchdpsrvr1: TIdEchoUDPServer
    Bindings = <>
    Left = 824
    Top = 717
  end
  object idnsrvr2: TIdDNSServer
    Active = False
    Bindings = <>
    TCPACLActive = False
    ServerType = stPrimary
    Left = 832
    Top = 725
  end
  object idchsrvr2: TIdECHOServer
    Bindings = <>
    Left = 840
    Top = 733
  end
  object idchdpsrvr2: TIdEchoUDPServer
    Bindings = <>
    Left = 848
    Top = 741
  end
  object idfngrsrvr1: TIdFingerServer
    Bindings = <>
    Left = 856
    Top = 749
  end
  object idftpsrvr1: TIdFTPServer
    Bindings = <>
    DefaultPort = 21
    CommandHandlers = <>
    ExceptionReply.Code = '500'
    ExceptionReply.Text.Strings = (
      'Unknown Internal Error')
    Greeting.Code = '220'
    Greeting.Text.Strings = (
      'Indy FTP Server ready.')
    MaxConnectionReply.Code = '300'
    MaxConnectionReply.Text.Strings = (
      'Too many connections. Try again later.')
    ReplyTexts = <>
    ReplyUnknownCommand.Code = '500'
    ReplyUnknownCommand.Text.Strings = (
      'Unknown Command')
    AnonymousAccounts.Strings = (
      'anonymous'
      'ftp'
      'guest')
    SITECommands = <>
    MLSDFacts = []
    ReplyUnknownSITCommand.Code = '500'
    ReplyUnknownSITCommand.Text.Strings = (
      'Invalid SITE command.')
    Left = 864
    Top = 757
  end
  object idhtprxysrvr1: TIdHTTPProxyServer
    Bindings = <>
    CommandHandlers = <>
    ExceptionReply.Code = '500'
    ExceptionReply.Text.Strings = (
      'Unknown Internal Error')
    Greeting.Code = '200'
    HelpReply.Code = '100'
    HelpReply.Text.Strings = (
      'Help follows')
    MaxConnectionReply.Code = '300'
    MaxConnectionReply.Text.Strings = (
      'Too many connections. Try again later.')
    ReplyTexts = <>
    ReplyUnknownCommand.Code = '400'
    Left = 872
    Top = 765
  end
  object idhtpsrvr1: TIdHTTPServer
    Bindings = <>
    Left = 880
    Top = 773
  end
  object idntsrvr1: TIdIdentServer
    Bindings = <>
    Left = 888
    Top = 781
  end
  object idmp4srvr1: TIdIMAP4Server
    Bindings = <>
    DefaultPort = 143
    CommandHandlers = <>
    ExceptionReply.Code = 'BAD'
    ExceptionReply.Text.Strings = (
      'Unknown Internal Error')
    Greeting.Code = 'OK'
    Greeting.Text.Strings = (
      'Welcome')
    HelpReply.Code = 'OK'
    HelpReply.Text.Strings = (
      'Help follows')
    MaxConnectionReply.Code = 'BAD'
    MaxConnectionReply.Text.Strings = (
      'Too many connections. Try again later.')
    ReplyTexts = <>
    ReplyUnknownCommand.Code = 'BAD'
    ReplyUnknownCommand.Text.Strings = (
      'Unknown command')
    RootPath = '\imapmail'
    DefaultPassword = 'admin'
    Left = 896
    Top = 789
  end
  object idrcsrvr1: TIdIRCServer
    Bindings = <>
    DefaultPort = 6667
    CommandHandlers = <>
    ExceptionReply.Code = '500'
    ExceptionReply.Text.Strings = (
      'Unknown Internal Error')
    Greeting.Code = '200'
    Greeting.Text.Strings = (
      'Welcome')
    HelpReply.Code = '100'
    HelpReply.Text.Strings = (
      'Help follows')
    MaxConnectionReply.Code = '300'
    MaxConnectionReply.Text.Strings = (
      'Too many connections. Try again later.')
    ReplyTexts = <>
    ReplyUnknownCommand.Code = '400'
    ReplyUnknownCommand.Text.Strings = (
      'Unknown Command')
    Left = 904
    Top = 797
  end
  object idmpdftp1: TIdMappedFTP
    Bindings = <>
    Left = 912
    Top = 805
  end
  object idmpdp: TIdMappedPOP3
    Bindings = <>
    Greeting.Code = '+OK'
    Greeting.Text.Strings = (
      'POP3 proxy ready')
    ReplyUnknownCommand.Code = '-ERR'
    ReplyUnknownCommand.Text.Strings = (
      'command must be either USER or QUIT')
    UserHostDelimiter = '#'
    Left = 920
    Top = 813
  end
  object idmpdprtcp1: TIdMappedPortTCP
    Bindings = <>
    DefaultPort = 0
    MappedPort = 0
    Left = 928
    Top = 821
  end
  object idmpdprtdp1: TIdMappedPortUDP
    Bindings = <>
    DefaultPort = 53
    MappedPort = 0
    Left = 936
    Top = 829
  end
  object idmpdtlnt1: TIdMappedTelnet
    Bindings = <>
    Left = 944
    Top = 837
  end
  object idntpsrvr1: TIdNNTPServer
    Bindings = <>
    CommandHandlers = <>
    ExceptionReply.Code = '500'
    ExceptionReply.Text.Strings = (
      'Command not recognized')
    Greeting.Code = '200'
    Greeting.Text.Strings = (
      'Welcome')
    HelpReply.Code = '100'
    HelpReply.Text.Strings = (
      'Help follows')
    MaxConnectionReply.Code = '300'
    MaxConnectionReply.Text.Strings = (
      'Too many connections. Try again later.')
    ReplyTexts = <>
    ReplyUnknownCommand.Code = '400'
    ReplyUnknownCommand.Text.Strings = (
      'Unknown Command')
    OverviewFormat.Strings = (
      'Subject:'
      'From:'
      'Date:'
      'Message-ID:'
      'References:'
      'Bytes:'
      'Lines:')
    Left = 952
    Top = 845
  end
  object idp3srvr1: TIdPOP3Server
    Bindings = <>
    CommandHandlers = <>
    ExceptionReply.Code = '-ERR'
    ExceptionReply.Text.Strings = (
      'Unknown Internal Error')
    Greeting.Code = '+OK'
    Greeting.Text.Strings = (
      'Welcome to Indy POP3 Server')
    HelpReply.Code = '+OK'
    HelpReply.Text.Strings = (
      'Help follows')
    MaxConnectionReply.Code = '-ERR'
    MaxConnectionReply.Text.Strings = (
      'Too many connections. Try again later.')
    ReplyTexts = <>
    ReplyUnknownCommand.Code = '-ERR'
    ReplyUnknownCommand.Text.Strings = (
      'Sorry, Unknown Command')
    Left = 960
    Top = 853
  end
  object idqtdsrvr1: TIdQOTDServer
    Bindings = <>
    Left = 968
    Top = 861
  end
  object idqtdpsrvr1: TIdQotdUDPServer
    Bindings = <>
    Left = 976
    Top = 869
  end
  object idrxcsrvr1: TIdRexecServer
    Bindings = <>
    Left = 984
    Top = 877
  end
  object idrshsrvr1: TIdRSHServer
    Bindings = <>
    Left = 992
    Top = 885
  end
  object idsmtpsrvr1: TIdSMTPServer
    Bindings = <>
    CommandHandlers = <>
    ExceptionReply.Code = '500'
    ExceptionReply.Text.Strings = (
      'Unknown Internal Error')
    Greeting.Code = '220'
    Greeting.Text.Strings = (
      'Welcome to the INDY SMTP Server')
    MaxConnectionReply.Code = '300'
    MaxConnectionReply.Text.Strings = (
      'Too many connections. Try again later.')
    ReplyTexts = <>
    ReplyUnknownCommand.Code = '500'
    ReplyUnknownCommand.Text.Strings = (
      'Syntax Error')
    ReplyUnknownCommand.EnhancedCode.StatusClass = 5
    ReplyUnknownCommand.EnhancedCode.Subject = 5
    ReplyUnknownCommand.EnhancedCode.Details = 2
    ReplyUnknownCommand.EnhancedCode.Available = True
    ReplyUnknownCommand.EnhancedCode.ReplyAsStr = '5.5.2'
    ServerName = 'Indy SMTP Server'
    Left = 1000
    Top = 893
  end
  object idscksrvr1: TIdSocksServer
    Bindings = <>
    Socks5NeedsAuthentication = False
    AllowSocks4 = True
    AllowSocks5 = True
    Left = 1008
    Top = 901
  end
  object idsystsrvr1: TIdSystatServer
    Bindings = <>
    Left = 1016
    Top = 909
  end
  object idsystdpsrvr1: TIdSystatUDPServer
    Bindings = <>
    Left = 1024
    Top = 917
  end
  object idtlntsrvr1: TIdTelnetServer
    Bindings = <>
    LoginMessage = 'Indy Telnet Server'
    Left = 1032
    Top = 925
  end
  object idtmdpsrvr1: TIdTimeUDPServer
    Bindings = <>
    BaseDate = 2.000000000000000000
    Left = 1040
    Top = 933
  end
  object idnxtmsrvr1: TIdUnixTimeServer
    Bindings = <>
    Left = 1048
    Top = 941
  end
  object idnxtmdpsrvr1: TIdUnixTimeUDPServer
    Bindings = <>
    Left = 1056
    Top = 949
  end
  object idwhsrvr1: TIdWhoIsServer
    Bindings = <>
    Left = 1064
    Top = 957
  end
end
