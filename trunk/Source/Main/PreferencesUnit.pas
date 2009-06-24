unit PreferencesUnit;
//////////////////////////
// Last Change: 09.II.2001
//////////////////////////


interface
                      
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, jpeg;

type
  TPrefsForm = class(TForm)
    pc: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    O1: TCheckBox;
    CancelBtn: TButton;
    OKBtn: TButton;
    O2: TCheckBox;
    SRTypeRG: TRadioGroup;
    TabSheet3: TTabSheet;
    LoadSLB: TListBox;
    Label1: TLabel;
    OpenSymDlg: TOpenDialog;
    Button3: TButton;
    RmvBtn: TButton;
    TabSheet4: TTabSheet;
    Label2: TLabel;
    PlugInLB: TListBox;
    Button4: TButton;
    PlugDlg: TOpenDialog;
    AllDSFCb: TCheckBox;
    GroupBox1: TGroupBox;
    DOICB: TCheckBox;
    DOIUNKCB: TCheckBox;
    SmartCB: TCheckBox;
    GroupBox2: TGroupBox;
    DumpAllCB: TCheckBox;
    ObjPropCB: TCheckBox;
    RunParamsEdit: TEdit;
    Label3: TLabel;
    Bevel1: TBevel;
    RShE: TCheckBox;
    GroupBox3: TGroupBox;
    ImportsCB: TCheckBox;
    UnitsCB: TCheckBox;
    procedure FormShow(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure AddSBtnClick(Sender: TObject);
    procedure RemoveSBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure DOICBClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    Procedure UpdateStatus;
    procedure LoadDeDeRES;
  public
    { Public declarations }
  end;

var
  PrefsForm: TPrefsForm;

implementation

Uses DeDeReg, MainUnit, DeDeSym, DeDeConstants, DeDeRES, ASMShow;

{$R *.DFM}

procedure TPrefsForm.FormShow(Sender: TObject);
begin
  DeDeReg.LoadRegistryData(DeDeMainForm.SymbolsToLoad, True);
  O2.Checked:=DeDeReg.bWARN_ON_FILE_OVERWRITE;
  O1.Checked:=DeDeReg.bNOT_ALLOW_EXISTING_DIR;
  ObjPropCB.Checked:=DeDeReg.bObjPropRef;
  DumpAllCB.Checked:=DeDeReg.bDumpAll;
  SRTypeRG.ItemIndex:=DeDeReg.iSTRING_REF_TYPE;
  LoadSLB.Items.Assign(DeDeMainForm.SymbolsToLoad);
//  AllDSFCB.Checked:=DeDeReg.bAllDSF;
  SmartCB.Checked:=DeDeReg.bSMARTMODE;
  DOICB.Checked:=DedeReg.bUseDOI;
  DOIUNKCB.Checked:=DedeReg.bDontShowUnkRefs;
  RShE.Checked:=DedeReg.bRegisterShellExt;
  ImportsCB.Checked:=DedeReg.bImportReferences;
  UnitsCB.Checked:=DedeReg.bUnitReferences;
  UpdateStatus;

  Application.HintPause:=5000;
end;

procedure TPrefsForm.CancelBtnClick(Sender: TObject);
begin
  Close;
end;

procedure TPrefsForm.OKBtnClick(Sender: TObject);
begin
  DeDeReg.bWARN_ON_FILE_OVERWRITE:=O2.Checked;
  DeDeReg.bNOT_ALLOW_EXISTING_DIR:=O1.Checked;
  DeDeReg.iSTRING_REF_TYPE:=SRTypeRG.ItemIndex;
//  DeDeReg.bAllDSF:=AllDSFCB.Checked;
  DeDeReg.bObjPropRef:=ObjPropCB.Checked;
  DeDeReg.bDumpAll:=DumpAllCB.Checked;
  DeDeReg.bSMARTMODE:=SmartCB.Checked;
  DedeReg.bUseDOI:=DOICB.Checked;
  DedeReg.bDontShowUnkRefs:=DOIUNKCB.Checked;
  DedeReg.bRegisterShellExt:=RShE.Checked;
  DedeReg.bImportReferences:=ImportsCB.Checked;
  DedeReg.bUnitReferences:=UnitsCB.Checked;

  DeDeReg.SaveRegistryData(LoadSLB.Items, True);
  Close;
end;

procedure TPrefsForm.AddSBtnClick(Sender: TObject);
var i, loaded, failed : Integer;
    DeDeSym : TDeDeSymbol;
begin
  OpenSymDlg.InitialDir:=ExtractFileDir(Application.ExeName)+'\DSF';
  loaded:=0;
  If OpenSymDlg.Execute Then
    For i:=0 to OpenSymDlg.Files.Count-1 Do
     If FileExists(OpenSymDlg.Files[i]) Then
       If LoadSLB.Items.IndexOf(OpenSymDlg.Files[i])=-1
          Then Begin
            LoadSLB.Items.Add(OpenSymDlg.Files[i]);
            Inc(Loaded);
          End;

  If Loaded<>0 Then
    If MessageDlg(msg_load_dsf_now,mtConfirmation,[mbYes,mbNo],0)=mrYes Then
    Begin
      Loaded:=0;
      Failed:=0;
      Screen.Cursor:=crHourGlass;
      Try
      For i:=0 to OpenSymDlg.Files.Count-1 Do
       If FileExists(OpenSymDlg.Files[i]) Then
             Begin
                DeDeSym:=TDeDeSymbol.Create;
                If DeDeSym.LoadSymbol(OpenSymDlg.Files[i])
                   Then Begin
                    If DeDeSym.PatternSize=_PatternSize Then
                       Begin
                         DeDeMainForm.SymbolsList.Add(DeDeSym);
                         DeDeMainForm.SymbolsPath.Add(OpenSymDlg.Files[i]);
                         Inc(Loaded);
                       End
                       Else Begin
                         DeDeSym.Free;
                         Inc(Failed);
                       End;
                   End
                   Else begin
                     DeDeSym.Free;
                     Inc(Failed);
                   End;
              End;
         Finally
           Screen.Cursor:=crDefault;
         End;
         if Failed<>0 Then MessageDlg(Format(msg_load_status,[Loaded,Failed]),mtInformation,[mbOk],0)
                      Else MessageDlg(Format(msg_load_status1,[Loaded]),mtInformation,[mbOk],0);
    End;

  UpdateStatus;
end;

procedure TPrefsForm.RemoveSBtnClick(Sender: TObject);
var index : Integer;
    i : Integer;
begin
  index:=-1;

  If LoadSLB.SelCount=1 Then
    begin
      For i:=0 To LoadSLB.Items.Count-1 Do
        If LoadSLB.Selected[i] Then
           Begin
             index:=i;
             break;
           End;

      If Not LoadSLB.Selected[index] Then Exit;
      If MessageDlg(txt_Remove+LoadSLB.Items[Index]+txt_from_list,
         mtConfirmation,[mbYes,mbNo],0)=mrNo Then Exit;

      LoadSLB.Items.Delete(Index);
    end;

  If LoadSLB.SelCount>1 Then
    begin
      If MessageDlg(txt_Remove+IntToStr(LoadSLB.SelCount)+txt_files_from_list,mtConfirmation,[mbYes,mbNo],0)=mrNo Then Exit;
      For i:=LoadSLB.Items.Count-1 DownTo 0 Do
        If LoadSLB.Selected[i] Then
               LoadSLB.Items.Delete(i);
    end;

  UpdateStatus;
end;

procedure TPrefsForm.UpdateStatus;
begin
  RmvBtn.Enabled:=LoadSLB.Items.Count<>0;
end;

procedure TPrefsForm.LoadDeDeRES;
begin
  tabsheet2.Caption:=tab_pc_tsh1;
  tabsheet1.Caption:=tab_pc_tsh2;
  tabsheet3.Caption:=tab_pc_tsh3;
  o1.Caption:=lbl_PrefsForm_o1;
  o2.Caption:=lbl_PrefsForm_o2;
  SRTypeRG.Caption:=grp_SRTypeRG;
  ObjPropCB.Caption:=lbl_PrefsForm_ObjPropCB;
  DumpALLCB.Caption:=lbl_PrefsForm_DumpALLCB;
  Label1.Caption:=lbl_PrefsForm_Label1;
  SmartCB.Caption:=lbl_SmartEmulation;
  AllDSFCb.Caption:=lbl_PrefsForm_AllDSFCb;
  rmvBtn.Caption:=lbl_PrefsForm_rmvbtn;
  Button3.Caption:=lbl_PrefsForm_button3;
  okBtn.Caption:=lbl_PrefsForm_okBtn;
  CancelBtn.Caption:=lbl_PrefsForm_cancelBtn;
end;

procedure TPrefsForm.FormCreate(Sender: TObject);
begin
  LoadDeDeRES;
  pc.ActivePage:=TabSheet2;
end;

procedure TPrefsForm.Button4Click(Sender: TObject);
var i : Integer;
begin
  If PlugDlg.Execute Then
    For i:=0 To PlugDlg.Files.Count-1 Do
        If MainUnit.DeDePlugins_Count<MainUnit.MAX_LOADED_PLUGINS
           Then MainUnit.LoadPlugInsFromDLL(PlugDlg.Files[i])
           Else Break;

  For i:=1 to MainUnit.DeDePlugins_Count Do
    Begin
      PlugInLB.Items.Add(Format('%s (ver. %s)',[MainUnit.DeDePlugins_PluginsArray[i].sPlugInName,MainUnit.DeDePlugins_PluginsArray[i].sPlugInVersion]));
    End;

  ASMShowForm.UpdatePlugInData;  
end;

procedure TPrefsForm.DOICBClick(Sender: TObject);
begin
  if not DOICB.Checked
     then begin
       DOIUNKCB.Checked:=False;
       DOIUNKCB.Enabled:=False;
       SmartCB.Checked:=False;
       SmartCB.Enabled:=False;
     end
     else begin
       DOIUNKCB.Enabled:=True;
       SmartCB.Enabled:=True;
     end;
end;

procedure TPrefsForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Application.HintPause:=500;
end;

end.
