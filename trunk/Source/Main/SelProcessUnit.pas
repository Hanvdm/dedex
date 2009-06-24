unit SelProcessUnit;
//////////////////////////
// Last Change: 21.II.2001
//////////////////////////

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, DeDeMemDumps, ExtCtrls, DeDeClasses;

type
  TMemDmpForm = class(TForm)
    PLV: TListView;
    Label1: TLabel;
    DmpBtn: TButton;
    CancelBtn: TButton;
    Button1: TButton;
    Label2: TLabel;
    Label3: TLabel;
    ProcDescrLbl: TLabel;
    Bevel1: TBevel;
    Bevel2: TBevel;
    RVABtn: TButton;
    procedure FormShow(Sender: TObject);
    procedure DmpBtnClick(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure PLVChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure PLVKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure RVABtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    dv : DWORD;
    procedure LoadDeDeRES;
  public
    { Public declarations }
    MemDmp : TMemoryStream;
    FsProcessName : String;
    FbDumpable : Boolean;
    Procedure ShowProcesses;
    Procedure ShowProcesses95;
    Procedure RefreshControls;
  end;

var
  MemDmpForm: TMemDmpForm;

implementation

{$R *.DFM}


Uses HexTools, tlhelp32, EPFindUnit, DeDeRES;
{ TForm1 }

procedure TMemDmpForm.ShowProcesses;
var ProcessArr, ModuleArr : Array of Cardinal;
    sz,sz1, sz2,i : Cardinal;
    hProcess : THandle;
    s : String;
    inst : TListItem;
    mi : MODULEINFO;
begin
  PLV.Items.Clear;
  SetLength(ProcessArr,256);
  SetLength(ModuleArr,256);
  EnumProcesses(ProcessArr[0],256,sz);
  PLV.Items.BeginUpdate;
  PLV.Items.Clear;
  Try
    For i:=0 To sz Do
      Begin
        If ProcessArr[i]=0 Then Continue;
        hProcess:=OpenProcess(PROCESS_ALL_ACCESS,False,ProcessArr[i]);
        EnumProcessModules(hProcess,ModuleArr[0],256,sz1);
        SetLength(s,256);
        //FillChar(s,256,0);
        sz1:=GetModuleBaseNameA(hProcess,ModuleArr[0],@s[1],256);
        SetLength(s,sz1);
        GetModuleInformation(hProcess,ModuleArr[0],mi,sz1);
        if s<>'' then
          begin
            inst:=PLV.Items.Add;
            inst.Caption:=IntToHex(ProcessArr[i],4);
            inst.SubItems.Add(s);
            inst.SubItems.Add(IntToHex(mi.SizeOfImage,8));
            inst.SubItems.Add(IntToHex(LongInt(mi.EntryPoint),8));
            inst.SubItems.Add(IntToHex(LongInt(mi.lpBaseOfDll),8));
          end;
        CloseHandle(hProcess);
      End;
   Finally
     PLV.Items.EndUpdate;
   End;
end;

procedure TMemDmpForm.FormShow(Sender: TObject);
begin
  CancelBtn.Enabled:=True;

  DmpBtn.Enabled:=False;
  RVABtn.Enabled:=False;
  
  ProcDescrLbl.Caption:='';
  Application.ProcessMessages;
end;

procedure TMemDmpForm.DmpBtnClick(Sender: TObject);
Var MemStr : TMemoryStream;
    BoC,PoC,ImB : DWORD;
begin
  If PLV.Selected=nil Then Exit;
  Try
    MemStr:=TMemoryStream.Create;
    DumpProcess(HEX2DWORD(PLV.Selected.Caption),MemStr,BoC,PoC,ImB);
    If MemStr.Size=0 Then Exit;
    MemDmp:=TMemoryStream.Create;
    MemDmp.LoadFromStream(MemStr);
    FsProcessName:=PLV.Selected.SubItems[0];
  Except
    ShowMessage('Dumper Failed !');
  End;
  Close;
end;

procedure TMemDmpForm.CancelBtnClick(Sender: TObject);
begin
  MemDmp:=nil;
  Close;
end;

procedure TMemDmpForm.Button1Click(Sender: TObject);
begin
  PLV.Items.Clear;
  If IsWin9x
    Then ShowProcesses95
    Else ShowProcesses;
end;

procedure TMemDmpForm.PLVChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
var s  : String;
begin
  If PLV.Selected=nil Then Exit;
  Screen.Cursor:=crHourGlass;
  Try
    if UpperCase(PLV.Selected.SubItems[0])='KERNEL32.DLL'
      then dv:=$FFFD
      else dv:=MemGetDelphiVersionOfAProcess(HEX2DWORD(PLV.Selected.Caption));
  Finally
    Screen.Cursor:=crDefault;
  End;

//  $0    : 'D3';
//  $B4   : 'BCB4'
//  $114  : 'D4';
//  $120  : 'D5' or 'BCB5'
//  $FFFF : 'Unknown';
//  $FFF0 : 'D2'

  Case dv of
    $0    : s:='Delphi 3 '+txt_program;
    $B4   : s:='CBuilder 4 '+txt_program;
    $114  : s:='Delphi 4 '+txt_program;
    $120  : s:='Delphi 5 '+txt_program;
    $121  : s:='CBuilder 5 '+txt_program;
    $15C, $160
          : s:='Delphi 6 '+txt_program;
    $FFF0 : s:='Delphi 2 '+txt_program;
    $FFFD : s:='Kernel32.dll';
    $FFFF : s:=txt_not_available;
    $FFFE : s:=txt_old_version
    else    s:=txt_unk_ver;
  end;

  FbDumpable:=(dv=$0) or (dv=$114) or (dv=$120) or (dv=$15C) or (dv=$FFFE) or (dv=$FFF0);
  RefreshControls;
  ProcDescrLbl.Caption:=s;
end;

procedure TMemDmpForm.PLVKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var MemStr : TMemoryStream;
    BoC,PoC,ImB : DWORD;
begin
  If PLV.Selected=nil Then Exit;
  if (ssShift in Shift) and (ssAlt in Shift) and (ssCtrl in Shift) then
    case Key of
       ORD('I') : SaveProcessInformation(StrToInt(PLV.Selected.Caption),ExtractFileDir(Application.ExeName)+'\procinf_dmp.txt');
       ORD('D') : begin
                   MemStr:=TMemoryStream.Create;
                   DumpProcess(StrToInt(PLV.Selected.Caption), MemStr, BoC,PoC,ImB);
                   MemStr.SaveToFile(ExtractFileDir(Application.ExeName)+'\dump.dmp');
                   MemStr.Free;
                  end;
    end;
end;

procedure TMemDmpForm.ShowProcesses95;
var hSnapShot : THandle;
    lppe : tlhelp32.tagPROCESSENTRY32;
    m : tlhelp32.tagMODULEENTRY32;
    li : TListItem;
    context : _CONTEXT;
begin
   hSnapShot:=CreateToolhelp32Snapshot(TH32CS_SNAPALL, GetCurrentProcessID);
   If hSnapShot<>INVALID_HANDLE_VALUE Then
    Begin
     lppe.dwSize:=sizeof(PROCESSENTRY32);
     Fillchar(lppe.szExeFile,MAX_PATH,0);
     Process32First(hSnapShot,lppe);
     Module32First(hSnapShot,m);
     li:=PLV.Items.Add;
     li.Caption:=IntToHex(lppe.th32ProcessID,8);
     li.Subitems.Add(ExtractFileName(StrPas(@lppe.szExeFile[0])));
     li.SubItems.Add(IntToHex(m.modBaseSize,8));
     li.SubItems.Add('-');
     li.SubItems.Add(IntToHex(DWORD(Pointer(m.modBaseAddr)),8));

     While Process32Next(hSnapShot,lppe) Do
       Begin
         Module32Next(hSnapShot,m);
         li:=PLV.Items.Add;
         li.Caption:=IntToHex(lppe.th32ProcessID,8);
         li.Subitems.Add(ExtractFileName(StrPas(@lppe.szExeFile[0])));
         li.SubItems.Add(IntToHex(m.modBaseSize,8));

//         context.ContextFlags:=CONTEXT_FULL;
//         SuspendThread()
//         GetThreadSelectorEntry();
//         ResumeThread();
         li.SubItems.Add('-');
         li.SubItems.Add(IntToHex(DWORD(Pointer(m.modBaseAddr)),8));
      End;
    CloseHandle(hSnapShot);
   End
   Else Raise Exception.Create(err_failed_enum_proc);
end;

procedure TMemDmpForm.RefreshControls;
begin
  DmpBtn.Enabled:=FbDumpable;
  RVABtn.Enabled:=FbDumpable or (dv=$FFF0);
end;

procedure TMemDmpForm.RVABtnClick(Sender: TObject);
var MemStr : TMemoryStream;
    dw, DVer : DWORD;
    s : String;
    BoC,PoC,ImB : DWORD;
begin
  If PLV.Selected=nil Then Exit;
  Screen.Cursor:=crHourGlass;
  Try
    MemStr:=TMemoryStream.Create;
    DumpProcess(HEX2DWORD(PLV.Selected.Caption),MemStr,BoC,PoC,ImB);

    Case dv of
        $FFF0 : DVer:=2;
           0  : DVer:=3;
        $114  : DVer:=4;
        $120  : DVer:=5;
        $15C  : DVer:=6;
    end;
    
    dw:=GetRVAEntryPoint(MemStr,$400000,0,0,DVer);
    if DW<>0 then begin
       {s:=Format('RVA Entry Point Found at: %s'#13#13+
        'Calculation is made with:'#13'ImageBase=400000h, CodeRVA=1000h, CodePhys=400h'#13#13+
        'In PEHeader should be written: %s'
        ,[DWORD2HEX(dw+$400C00),DWORD2HEX(dw+$C00)]);
       MessageBox(0,PChar(s),PChar('DeDe EP-Finder v0.2'),0);}
       EPFindForm.ImB:=ImB;
       EPFindForm.BoC:=BoC;
       EPFindForm.PoC:=PoC;
       EPFindForm.EP:=dw;
       EPFindForm.sFileName:=PLV.Selected.SubItems[0];
       EPFindForm.ShowModal;
     end
     else MessageBox(0,PChar(err_epf_failed),PChar(txt_epf_version),0);
  Finally
    MemStr.Free;
    Screen.Cursor:=crDefault;
  End;
end;

procedure TMemDmpForm.LoadDeDeRES;
begin
  PLV.Columns[0].Caption:=lv_PLV_col0;
  PLV.Columns[1].Caption:=lv_PLV_col1;
  PLV.Columns[2].Caption:=lv_PLV_col2;
  PLV.Columns[3].Caption:=lv_PLV_col3;
  PLV.Columns[4].Caption:=lv_PLV_col4;

  Label1.Caption:=lbl_MemDmpForm_Label1;
  Label2.Caption:=lbl_MemDmpForm_Label2;
  Label3.Caption:=lbl_MemDmpForm_Label3;
  ProcDescrLbl.Caption:=lbl_MemDmpForm_ProcDescrLbl;

  DmpBtn.Caption:=lbl_MemDmpForm_DumpBtn;
  RVABtn.Caption:=lbl_MemDmpForm_RVABtn;
  CancelBtn.Caption:=lbl_MemDmpForm_CancelBtn;
  Button1.Caption:=lbl_MemDmpForm_Button1;
end;

procedure TMemDmpForm.FormCreate(Sender: TObject);
begin
  LoadDeDeRES;
end;

end.

