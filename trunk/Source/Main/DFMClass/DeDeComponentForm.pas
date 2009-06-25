unit DeDeComponentForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ActnList, ExtCtrls, StdCtrls, Menus, CustomizeDlg, ActnColorMaps,
  ActnMan, ToolWin, ActnCtrls, ActnMenus, XPStyleActnCtrls, Tabs, DockTabSet,
  ButtonGroup, CategoryButtons, ValEdit, AppEvnts, CheckLst, Grids, Mask,
  Buttons, ExtDlgs, FileCtrl, TabNotBk, Outline, DdeMan, OleServer, CmAdmCtl,
  OleCtnrs, MPlayer, ShellAnimations, XPMan, ComCtrls, ImgList, ActnPopup,
  dblookup, DBGrids;

type
  TfrmDedeComponent = class(TForm)
    pgc1: TPageControl;
    ts1: TTabSheet;
    ts2: TTabSheet;
    ts3: TTabSheet;
    mm1: TMainMenu;
    pm1: TPopupMenu;
    Label1: TLabel;
    edt1: TEdit;
    mmo1: TMemo;
    btn1: TButton;
    chk1: TCheckBox;
    rb1: TRadioButton;
    lst1: TListBox;
    cbb1: TComboBox;
    grp1: TGroupBox;
    rg1: TRadioGroup;
    pnl1: TPanel;
    actlst1: TActionList;
    btn2: TBitBtn;
    btn3: TSpeedButton;
    medt1: TMaskEdit;
    strngrd1: TStringGrid;
    drwgrd1: TDrawGrid;
    img1: TImage;
    shp1: TShape;
    sb1: TScrollBox;
    chklst1: TCheckListBox;
    spl1: TSplitter;
    txt1: TStaticText;
    ctrlbr1: TControlBar;
    aplctnvnts1: TApplicationEvents;
    lst2: TValueListEditor;
    lbledt1: TLabeledEdit;
    lst3: TColorListBox;
    btn4: TCategoryButtons;
    btn5: TButtonGroup;
    dcktbst1: TDockTabSet;
    ti1: TTrayIcon;
    ts4: TTabSet;
    flwpnl1: TFlowPanel;
    grdpnl1: TGridPanel;
    am1: TActionManager;
    actmmb1: TActionMainMenuBar;
    pctnbr1: TPopupActionBar;
    acttb1: TActionToolBar;
    xpclrmp1: TXPColorMap;
    stndrdclrmp1: TStandardColorMap;
    twlghtclrmp1: TTwilightColorMap;
    dlg1: TCustomizeDlg;
    tbc1: TTabControl;
    il1: TImageList;
    redt1: TRichEdit;
    trckbr1: TTrackBar;
    pb1: TProgressBar;
    ud1: TUpDown;
    hk1: THotKey;
    hk2: THotKey;
    ani1: TAnimate;
    dtp1: TDateTimePicker;
    cal1: TMonthCalendar;
    tv1: TTreeView;
    lv1: TListView;
    hdrcntrl1: THeaderControl;
    stat1: TStatusBar;
    tlb1: TToolBar;
    clbr1: TCoolBar;
    pgscrlr1: TPageScroller;
    cbb2: TComboBoxEx;
    xpmnfst1: TXPManifest;
    shlrsrcs1: TShellResources;
    ts5: TTabSheet;
    tmr1: TTimer;
    pb2: TPaintBox;
    mp1: TMediaPlayer;
    olcntnr1: TOleContainer;
    cmdmnctlg1: TCOMAdminCatalog;
    dde1: TDdeClientConv;
    dde2: TDdeClientConv;
    dde3: TDdeClientItem;
    dde4: TDdeServerConv;
    dde5: TDdeServerItem;
    TabSheet1: TTabSheet;
    dblklst1: TDBLookupList;
    dblkcbb1: TDBLookupCombo;
    otln1: TOutline;
    nb1: TTabbedNotebook;
    nb2: TNotebook;
    hdr1: THeader;
    fllst1: TFileListBox;
    dirlst1: TDirectoryListBox;
    drvcbb1: TDriveComboBox;
    fltcbb1: TFilterComboBox;
    tsDialogs: TTabSheet;
    dlgOpen1: TOpenDialog;
    dlgSave1: TSaveDialog;
    dlgOpenPic1: TOpenPictureDialog;
    dlg2: TSavePictureDialog;
    dlg3: TOpenTextFileDialog;
    dlg4: TSaveTextFileDialog;
    dlgFont1: TFontDialog;
    dlgColor1: TColorDialog;
    dlgPnt1: TPrintDialog;
    dlgPntSet1: TPrinterSetupDialog;
    dlgFind1: TFindDialog;
    dlgReplace1: TReplaceDialog;
    dlg5: TPageSetupDialog;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmDedeComponent: TfrmDedeComponent;

implementation

{$R *.dfm}


initialization

finalization

  if Assigned(frmDedeComponent) then
    FreeAndNil(frmDedeComponent);


end.
