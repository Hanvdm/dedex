unit DeDeComponentForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ActnList, ExtCtrls, StdCtrls, Menus, CustomizeDlg, ActnColorMaps,
  ActnMan, ToolWin, ActnCtrls, ActnMenus, XPStyleActnCtrls, Tabs, DockTabSet,
  ButtonGroup, CategoryButtons, ValEdit, AppEvnts, CheckLst, Grids, Mask,
  Buttons, ExtDlgs, FileCtrl, TabNotBk, Outline, DdeMan, OleServer, CmAdmCtl,
  OleCtnrs, MPlayer, ShellAnimations, XPMan, ComCtrls, ImgList, ActnPopup,
  dblookup, DBGrids, xmldom, WideStrings, FMTBcd, ADODB, DBTables, TConnect,
  MConnect, DBClient, SConnect, ObjBrkr, SimpleDS, SqlExpr, DB, DBCGrids,
  DBCtrls, Xmlxform, Provider, DBGridEh, PropFilerEh, MemTableDataEh,
  IdWhoIsServer, IdUnixTimeUDPServer, IdTimeServer, IdUnixTimeServer,
  IdTimeUDPServer, IdTelnetServer, IdSystatUDPServer, IdSystatServer,
  IdSocksServer, IdSMTPServer, IdRSHServer, IdRemoteCMDServer, IdRexecServer,
  IdQOTDUDPServer, IdQotdServer, IdPOP3Server, IdNNTPServer, IdMappedPortUDP,
  IdMappedTelnet, IdMappedPOP3, IdMappedPortTCP, IdMappedFTP, IdIrcServer,
  IdIMAP4Server, IdIdentServer, IdCustomHTTPServer, IdHTTPServer,
  IdHTTPProxyServer, IdExplicitTLSClientServerBase, IdFTPServer, IdFingerServer,
  IdEchoUDPServer, IdEchoServer, IdDNSServer, IdDiscardUDPServer,
  IdDiscardServer, IdDICTServer, IdDayTimeUDPServer, IdDayTimeServer,
  IdChargenUDPServer, IdChargenServer, IdIPMCastServer, IdSimpleServer,
  IdCustomTCPServer, IdTCPServer, IdCmdTCPServer, IdUDPServer, IdWhois,
  IdUnixTimeUDP, IdUnixTime, IdTimeUDP, IdTime, IdTelnet, IdSystat, IdSysLog,
  IdSNTP, IdSNPP, IdSNMP, IdSMTPRelay, IdSMTPBase, IdSMTP, IdRSH,
  IdRemoteCMDClient, IdRexec, IdQOTDUDP, IdQotd, IdPOP3, IdNNTP, IdLPR, IdIRC,
  IdMessageClient, IdIMAP4, IdIdent, IdHTTP, IdGopher, IdFTP, IdFSP, IdFinger,
  IdEchoUDP, IdEcho, IdDNSResolver, IdDICT, IdDayTimeUDP, IdDayTime, IdRawBase,
  IdRawClient, IdIcmpClient, IdIPMCastBase, IdIPMCastClient, IdCmdTCPClient,
  IdUDPBase, IdUDPClient, IdBaseComponent, IdComponent, IdTCPConnection,
  IdTCPClient, BDEDataDriverEh, DBXDataDriverEh, ADODataDriverEh,
  IBXDataDriverEh, DataDriverEh, MemTableEh, PropStorageEh, PrViewEh, DBSumLst,
  DBCtrlsEh, DBLookupEh, PrnDbgeh, GridsEh;

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
    tsDataAccess: TTabSheet;
    ds1: TDataSource;
    ds2: TClientDataSet;
    dtstprvdr2: TDataSetProvider;
    xmltrnsfrm1: TXMLTransform;
    xmltrnsfrmprvdr1: TXMLTransformProvider;
    xmltrnsfrmclnt1: TXMLTransformClient;
    tsDataControls: TTabSheet;
    dbgrd1: TDBGrid;
    dbnvgr1: TDBNavigator;
    dbtxt1: TDBText;
    dbedt1: TDBEdit;
    dbmmo1: TDBMemo;
    dbimg1: TDBImage;
    dblst1: TDBListBox;
    dbcbb1: TDBComboBox;
    dbrgrp1: TDBRadioGroup;
    dblklst2: TDBLookupListBox;
    dblkcbb2: TDBLookupComboBox;
    dbredt1: TDBRichEdit;
    dbctrlgrd1: TDBCtrlGrid;
    tsDBExpress: TTabSheet;
    con1: TSQLConnection;
    sqldtst1: TSQLDataSet;
    sqlqry1: TSQLQuery;
    sqltbl1: TSQLTable;
    sqlmntr1: TSQLMonitor;
    smpldtst1: TSimpleDataSet;
    tsDataSnap: TTabSheet;
    con2: TDCOMConnection;
    con3: TSocketConnection;
    smplbjctbrkr1: TSimpleObjectBroker;
    con4: TWebConnection;
    con5: TConnectionBroker;
    con6: TSharedConnection;
    con7: TLocalConnection;
    tsBDE: TTabSheet;
    tbl1: TTable;
    qry1: TQuery;
    strdprc1: TStoredProc;
    db1: TDatabase;
    ssn1: TSession;
    bm1: TBatchMove;
    updtsql1: TUpdateSQL;
    nstdtbl1: TNestedTable;
    tsDBGo: TTabSheet;
    con8: TADOConnection;
    cmd1: TADOCommand;
    ds3: TADODataSet;
    tbl2: TADOTable;
    qry2: TADOQuery;
    sp1: TADOStoredProc;
    con9: TRDSConnection;
    tsEHLib: TTabSheet;
    dbgrd2: TDBGridEh;
    prntdbgrdh1: TPrintDBGridEh;
    edt2: TDBEditEh;
    edt3: TDBDateTimeEditEh;
    edt4: TDBNumberEditEh;
    cbb3: TDBComboBoxEh;
    cbb4: TDBLookupComboboxEh;
    dbchckbxh1: TDBCheckBoxEh;
    dbsmlst1: TDBSumList;
    prvwbx1: TPreviewBox;
    prpstrgh1: TPropStorageEh;
    inprpstrgmnh1: TIniPropStorageManEh;
    rgprpstrgmnh1: TRegPropStorageManEh;
    mtbl1: TMemTableEh;
    dsd1: TDataSetDriverEh;
    sqldtdrvrh1: TSQLDataDriverEh;
    ibxdtdrvrh1: TIBXDataDriverEh;
    adoDD1: TADODataDriverEh;
    dbxdtdrvrh1: TDBXDataDriverEh;
    bdtdrvrh1: TBDEDataDriverEh;
    tsIndy: TTabSheet;
    idTcpClient2: TIdTCPClient;
    idTcpClient3: TIdTCPClient;
    idpclnt1: TIdUDPClient;
    idcmdtcpclnt1: TIdCmdTCPClient;
    idpmcstclnt1: TIdIPMCastClient;
    idcmpclnt1: TIdIcmpClient;
    idytm1: TIdDayTime;
    idytmdp1: TIdDayTimeUDP;
    idct1: TIdDICT;
    idnsrslvr1: TIdDNSResolver;
    idch1: TIdEcho;
    idchdp1: TIdEchoUDP;
    idfngr1: TIdFinger;
    idfsp2: TIdFSP;
    idftp2: TIdFTP;
    idgphr1: TIdGopher;
    idhtp1: TIdHTTP;
    idnt1: TIdIdent;
    idmp: TIdIMAP4;
    idrc1: TIdIRC;
    idlpr2: TIdLPR;
    idntp1: TIdNNTP;
    idp: TIdPOP3;
    idqtd1: TIdQOTD;
    idqtdp1: TIdQOTDUDP;
    idrxc1: TIdRexec;
    idrsh2: TIdRSH;
    idsmtp2: TIdSMTP;
    idsmtprly1: TIdSMTPRelay;
    idsnmp2: TIdSNMP;
    idsnp1: TIdSNPP;
    idsntp2: TIdSNTP;
    idsyslg1: TIdSysLog;
    idsyst1: TIdSystat;
    idtlnt1: TIdTelnet;
    idtm1: TIdTime;
    idtmdp1: TIdTimeUDP;
    idnxtm1: TIdUnixTime;
    idnxtmdp1: TIdUnixTimeUDP;
    idwhs1: TIdWhois;
    idpsrvr1: TIdUDPServer;
    idcmdtcpsrvr1: TIdCmdTCPServer;
    idsmplsrvr1: TIdSimpleServer;
    tcpServer1: TIdTCPServer;
    idpmcstsrvr1: TIdIPMCastServer;
    idchrgnsrvr1: TIdChargenServer;
    idchrgndpsrvr1: TIdChargenUDPServer;
    idytmsrvr1: TIdDayTimeServer;
    idytmdpsrvr1: TIdDayTimeUDPServer;
    idctsrvr1: TIdDICTServer;
    idscrdsrvr1: TIdDISCARDServer;
    idscrdpsrvr1: TIdDiscardUDPServer;
    idnsrvr1: TIdDNSServer;
    idchsrvr1: TIdECHOServer;
    idchdpsrvr1: TIdEchoUDPServer;
    idnsrvr2: TIdDNSServer;
    idchsrvr2: TIdECHOServer;
    idchdpsrvr2: TIdEchoUDPServer;
    idfngrsrvr1: TIdFingerServer;
    idftpsrvr1: TIdFTPServer;
    idhtprxysrvr1: TIdHTTPProxyServer;
    idhtpsrvr1: TIdHTTPServer;
    idntsrvr1: TIdIdentServer;
    idmp4srvr1: TIdIMAP4Server;
    idrcsrvr1: TIdIRCServer;
    idmpdftp1: TIdMappedFTP;
    idmpdp: TIdMappedPOP3;
    idmpdprtcp1: TIdMappedPortTCP;
    idmpdprtdp1: TIdMappedPortUDP;
    idmpdtlnt1: TIdMappedTelnet;
    idntpsrvr1: TIdNNTPServer;
    idp3srvr1: TIdPOP3Server;
    idqtdsrvr1: TIdQOTDServer;
    idqtdpsrvr1: TIdQotdUDPServer;
    idrxcsrvr1: TIdRexecServer;
    idrshsrvr1: TIdRSHServer;
    idsmtpsrvr1: TIdSMTPServer;
    idscksrvr1: TIdSocksServer;
    idsystsrvr1: TIdSystatServer;
    idsystdpsrvr1: TIdSystatUDPServer;
    idtlntsrvr1: TIdTelnetServer;
    idtmdpsrvr1: TIdTimeUDPServer;
    idnxtmsrvr1: TIdUnixTimeServer;
    idnxtmdpsrvr1: TIdUnixTimeUDPServer;
    idwhsrvr1: TIdWhoIsServer;
    bvl1: TBevel;
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

//  if Assigned(frmDedeComponent) then
//    FreeAndNil(frmDedeComponent);


end.
