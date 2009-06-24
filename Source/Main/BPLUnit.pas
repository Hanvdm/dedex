unit BPLUnit;
//////////////////////////
// Last Change: 28.VIII.2001
//////////////////////////

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Mask, ComCtrls, ExtCtrls, ImgList, Spin, Buttons,
  DeDeConstants, rxToolEdit;

type
  TBPL = class(TForm)
    StatusBar: TStatusBar;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    Label2: TLabel;
    FileEdit: TFilenameEdit;
    Button1: TButton;
    Panel1: TPanel;
    Label5: TLabel;
    Label4: TLabel;
    statusLbl: TLabel;
    DVGB: TGroupBox;
    d3cb: TCheckBox;
    d4cb: TCheckBox;
    d5cb: TCheckBox;
    GroupBox1: TGroupBox;
    FixCB: TCheckBox;
    ParamCB: TCheckBox;
    IncPCB: TCheckBox;
    LogMemo: TMemo;
    PB: TProgressBar;
    CommentEdit: TEdit;
    SymFile: TFilenameEdit;
    Panel2: TPanel;
    Label1: TLabel;
    DCUFileEdit: TFilenameEdit;
    Button2: TButton;
    Panel3: TPanel;
    Label3: TLabel;
    Label6: TLabel;
    DCUstatuLbl: TLabel;
    DCUDVGB: TGroupBox;
    dcud3cb: TCheckBox;
    dcud4cb: TCheckBox;
    dcud5cb: TCheckBox;
    DCULogMemo: TMemo;
    DCUPB: TProgressBar;
    DCUCommentEdit: TEdit;
    DCUSymFile: TFilenameEdit;
    GroupBox2: TGroupBox;
    DCUParamCB: TCheckBox;
    DCUExcludeCB: TCheckBox;
    dcud2cb: TCheckBox;
    DetailsPanel: TPanel;
    CDCUPB: TProgressBar;
    Label7: TLabel;
    CurrDCULbl: TLabel;
    d6cb: TCheckBox;
    dcud6cb: TCheckBox;
    procedure SymFileBeforeDialog(Sender: TObject; var Name: String;
      var Action: Boolean);
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FileEditBeforeDialog(Sender: TObject; var Name: String;
      var Action: Boolean);
    procedure FileEditChange(Sender: TObject);
    procedure Panel2MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure DCUFileEditChange(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
    ClassesList : TStringList;
    Procedure CutUnitName(Var AsData : String; isD3 : Boolean);
    function GetSymMode : Byte;
    function DCUGetSymMode : Byte;
    procedure ParseFunctionName(var s : String);
    procedure AddNewDCU_DSF(sProcDecl : String; buffer : TSymBuffer; size : Integer;  Progress : Byte; bAddIT : Boolean);
  public
    { Public declarations }
  end;

var
  BPL: TBPL;

implementation

{$R *.DFM}
Uses DeDeClasses, DisASM, HEXTools, DeDeBPL, DeDeDCUDumper,
     DeDePFiles, DeDeRES, DeDeSym, MainUnit;

// Used with DCU DSF file generation because of parsing OnNewProcEvent()     
var DataB, DataS : TMemoryStream;
    GlobiRecNum, iFakeCount, GlobiFakeCount : Integer;

procedure TBPL.SymFileBeforeDialog(Sender: TObject; var Name: String;
  var Action: Boolean);
begin
   SymFile.InitialDir:=ExtractFileDir(Application.ExeName)+'\DSF';
end;

procedure TBPL.Button1Click(Sender: TObject);
Var MemData, DataB, DataS : TMemoryStream;
    ExportList, SymbolList : TStringList;
    RVAList : TList;
    HM : HModule;
    PEFile : ThePeFile;
    //PEHeader : TPEHeader;
    PEExports : TPEExports;
    i,j,iRecNum,iCount : Integer;
    s,sym : String;
    p : Pointer;
    sz : Cardinal;
    buff : TSymBuffer;
    DASM : TDisAsm;
    bIsDCL : Boolean;
begin
 If DeDeMainForm.FbProcessed then
   If MessageDlg('This operation will affect the currently processed target! Do you want ot continue?',mtWarning,[mbYes,mbNo],0)=mrNo then Exit;

 If SymFile.FileName='' Then
    Begin
      ShowMessage(err_select_dsf_name);
      Exit;
    End;

 If FileExists(SymFile.FileName) Then
   Begin
    If MessageDlg(Format(wrn_fileexists,[SymFile.FileName]),mtWarning,[mbYes,mbNo],0)=mrNo Then Exit;
    DeleteFile(SymFile.FileName);
   End;
     
 LogMemo.Clear;
 ClassesList.Clear;
 ClassesList.Add('Dumped Classes:');
 ClassesList.Add('');
 ExportList:=TStringList.Create;
 SymbolList:=TStringList.Create;
 DASM:=TDisAsm.Create;
 LogMemo.Lines.Add(msg_load_exp_names);

 Screen.Cursor:=crHourGlass;
 MemData:=TMemoryStream.Create;
 DataB:=TMemoryStream.Create;
 DataS:=TMemoryStream.Create;
 RVAList:=TList.Create;
 PEFile:=ThePeFile.Create(FileEdit.FileName);
 Try
   DeDeClasses.PEFile:=PEFile;
   //PEHeader is used for PE files only
   PEHeader.Dump(PEFile);

   DeDeSym.BPLPEHeader:=PEHeader;
   i:=PEHeader.GetSectionIndex('.edata');
   if i=-1 Then Raise Exception.Create(err_no_exports);
   PEExports.Process(PEHeader.Objects[i].PHYSICAL_OFFSET,PEHeader.Objects[i].RVA);
   For i:=0 To PEExports.Number_of_Name_Pointers Do
     Begin
       s:=PEExports.FUNC_DATA[i].Name;
       ExportList.Add(s);
     End;
   LogMemo.Lines[0]:=LogMemo.Lines[0]+msg_done1;

   LogMemo.Lines.Add(msg_load_package);
   HM:=LoadPackage(FileEdit.FileName);
   LogMemo.Lines[1]:=LogMemo.Lines[1]+msg_done1;
   LogMemo.Lines.Add(msg_load_exp_sym);
   PB.Max:=2*(ExportList.Count-1);
   PB.Position:=0;

   // For Delphi3 DCL Procedure Name Correction Compability
   bIsDCL:=UpperCase(Copy(FileEdit.FileName,Length(FileEdit.FileName)-2,3))='DPL';

   Try
     For i:=0 To ExportList.Count-1 Do
      Begin
       s:=ExportList[i];
       If Copy(s,1,5)='@$xp$' Then Continue;
       If s='' Then Continue;
       //StatusLbl.Caption:=s;
       //StatusLbl.Update;
       PB.Position:=i;
       PB.Update;
       p:=GetProcAddress(HM,PChar(s));
       If Not ReadProcessMemory(GetCurrentProcess,p,@buff[1],_PatternSize,sz)
          Then LogMemo.Lines.Add('!error! reading '+s+' address')
          Else Begin
            CutUnitName(s, bIsDCL);
            If s='' Then Continue;
            SymbolList.Add(s);
            RVAList.Add(p);

            sym:='';
            For j:=0 to _PatternSize do sym:=sym+IntToHex(buff[j],2);

            MemData.WriteBuffer(buff,_PatternSize);
          End;
      End;
   Finally
     LogMemo.Lines[2]:=LogMemo.Lines[2]+msg_done1;
     LogMemo.Lines.Add(msg_unload_package);
     UnloadPackage(HM);
     LogMemo.Lines[3]:=LogMemo.Lines[3]+msg_done1;
   End;

   LogMemo.Lines.Add(format(msg_dasm_exp,[IntToStr(SymbolList.Count)]));
   MemData.Seek(0,soFromBeginning);

   iRecNum:=0;
   iCount:=SymbolList.Count-1;

   Glob_B5:=0;Glob_B6:=0;Glob_B7:=0;Glob_B10:=0;
   // Tova beshe bozata !!!
   i:=-1;
   Repeat
     Inc(i);
     StatusLbl.Caption:=SymbolList[i];
     StatusLbl.Update;
     PB.Position:=PB.Position+1;
     PB.Update;

     MemData.ReadBuffer(buff,_PatternSize);
     If UnlinkCalls(buff,0,DWORD(RVAList[i])) Then
       Begin
       // Saves Symbols
        DataB.WriteBuffer(buff,_PatternSize);
        sym:=SymbolList[i];
        If( not bisDCL) and (FixCB.Checked) Then ParseFunctionName(sym);
        j:=Length(sym);
        DataS.WriteBuffer(j,1);
        DataS.WriteBuffer(sym[1],j);
        inc(iRecNum);
        // End of save symbols
       End;
   Until i>=iCount;

   PB.Position:=2*ExportList.Count;
   PB.Update;
   StatusLbl.Caption:='';
   StatusLbl.Update;
   LogMemo.Lines[4]:=LogMemo.Lines[4]+msg_done1;
   LogMemo.Update;


   LogMemo.Lines.Add(msg_saveing_file);
   if iRecNum<>0
       then SaveBPLSymbolFile(DataB,DataS,SymFile.FileName,GetSymMode,_PatternSize,iRecNum,CommentEdit.Text)
       else ShowMessage('No DSF patterns to save!');
   //SaveBPLSymbolFile(DataB,DataS,SymFile.FileName,GetSymMode,_PatternSize,iRecNum,CommentEdit.Text);
   LogMemo.Lines[5]:=LogMemo.Lines[5]+msg_done1;
   LogMemo.Update;
   j:=DataB.Size+DataS.Size;
   ShowMessage(msg_dsf_success);
   LogMemo.Clear;
 Finally
   ExportList.Free;
   SymbolList.Free;
   RVAList.Free;
   PEFile.Free;
   DASM.Free;
   Screen.Cursor:=crDefault;
   DataB.Free;
   DataS.Free;
   MemData.Free;
   PB.Position:=0;
   StatusLbl.Caption:='';
 End;

end;

procedure TBPL.CutUnitName(Var AsData: String; isD3 : Boolean);
//var i : Integer;
begin
  If (not isD3) and (Pos('$',AsData)=0) Then AsData:='';
  If AsData='' Then Exit;
  If AsData[1]='@' Then AsData:=Copy(AsData,2,Length(AsData)-1);
  //i:=Pos('@',AsData);
  //If i<>0 Then AsData:=Copy(AsData,i+1,Length(AsData)-i+2);
end;

function TBPL.GetSymMode: Byte;
var b : Byte;
begin
 Result:=0;
 If d3cb.checked Then b:=1 else b:=0;
 Result:=Result+b;
 If d4cb.checked Then b:=1 else b:=0;
 Result:=Result+b*2;
 If d5cb.checked Then b:=1 else b:=0;
 Result:=Result+b*4;
 If dcud6cb.checked Then b:=1 else b:=0;
 Result:=Result+b*16;
end;

function TBPL.DCUGetSymMode: Byte;
var b : Byte;
begin
 Result:=0;
 If dcud3cb.checked Then b:=1 else b:=0;
 Result:=Result+b;
 If dcud4cb.checked Then b:=1 else b:=0;
 Result:=Result+b*2;
 If dcud5cb.checked Then b:=1 else b:=0;
 Result:=Result+b*4;
 If dcud2cb.checked Then b:=1 else b:=0;
 Result:=Result+b*8;
 If dcud6cb.checked Then b:=1 else b:=0;
 Result:=Result+b*16;
end;

procedure TBPL.ParseFunctionName(var s: String);
var i : Integer;
    sf,sp : String;
begin
  {$IFDEF DEBUG}
  //Memo1.Lines.Add(s);
  {$ENDIF}
  i:=Pos('$',s);
  // Saves function name
  sf:=Copy(s,1,i-1);
  // saves function params
  sp:=Copy(s,i,Length(s)-i+1);

  ParseExportName(sf);
  If ParamCB.Checked Then ParseExportParam(sp);

  If Copy(sp,1,2)='; ' Then sp:=Copy(sp,3,Length(sp)-2);
  If Copy(sp,Length(s)-1,2)='; ' Then sp:=Copy(s,1,Length(sp)-2);
  If Copy(sp,Length(s),1)=' ' Then sp:=Copy(s,1,Length(sp)-1);
  If (Copy(sf,Length(sf),1)='.') Then sf:=sf+'Create';

  If Not IncPCB.Checked Then sp:='';
  s:=sf+'('+sp+')';

  {$IFDEF DEBUG}
  //Memo1.Lines.Add(s);
  //Memo1.Lines.Add('');
  {$ENDIF}
end;

procedure TBPL.FormCreate(Sender: TObject);
begin
  ClassesList:=TStringList.Create;
end;

procedure TBPL.FormDestroy(Sender: TObject);
begin
  ClassesList.Free;
end;

procedure TBPL.FileEditBeforeDialog(Sender: TObject; var Name: String;
  var Action: Boolean);
var s : String;
begin
  SetLength(s,100);
  GetSystemDirectory(@s[1],length(s));
  FileEdit.InitialDir:=s;
end;

procedure TBPL.FileEditChange(Sender: TObject);
begin
  CommentEdit.Text:=GetPackageDescription(PChar(FileEdit.FileName));
  SymFile.FileName:=ExtractFileDir(Application.ExeName)+'\DSF\'+ChangeFileExt(ExtractFileName(FileEdit.FileName),'.dsf');
end;




procedure TBPL.Panel2MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  If (ssAlt in Shift) and (ssShift in Shift) and (ssCtrl in Shift)
    Then ShowMessageFmt(' 5 bytes: %d %s  6 bytes: %d %s  7 bytes: %d %s 10 bytes: %d',[Glob_B5,#13,Glob_B6,#13,Glob_B7,#13,Glob_B10]);
end;

procedure TBPL.DCUFileEditChange(Sender: TObject);
begin
  DCUCommentEdit.Text:=ExtractFileName(DCUFileEdit.FileName);
  DCUSymFile.FileName:=ExtractFileDir(Application.ExeName)+'\DSF\'+ChangeFileExt(ExtractFileName(DCUFileEdit.FileName),'.dsf');
end;

procedure TBPL.Button2Click(Sender: TObject);
var TmpList, LogList : TStringList;
    s : String;
    iPos, idx, i, cnt, iCurrCnt : Integer;
    //ImplParser : TImplementationParser;
    NewParser : TNewDCU2DSFParser;
begin
  LogMemo.Lines.Clear;

  TmpList:=TStringList.Create;
  LogList:=TStringList.Create;
  Screen.Cursor:=crHourGlass;
  DataB:=TMemoryStream.Create;
  DataS:=TMemoryStream.Create;
  CurrDCULbl.Caption:='';
  CDCUPB.Max:=DCUFileEdit.DialogFiles.Count-1;
  CDCUPB.Position:=0;
  CDCUPB.Update;

  DetailsPanel.Visible:=DCUFileEdit.DialogFiles.Count>1;

  GlobiRecNum:=0;
  GlobiFakeCount:=0;

  Try
    For idx:=0 to DCUFileEdit.DialogFiles.Count-1 do
     Begin
      CDCUPB.Position:=idx;
      CDCUPB.Update;

      CurrDCULbl.Caption:=ExtractFileName(DCUFileEdit.DialogFiles[idx]);
      // STEP 0 - Disassembling File
      DCULogMemo.Lines.Add('Disassembling '+ExtractFileName(DCUFileEdit.DialogFiles[idx])+' ...');
      GlobPreParsOK:=False;
      ProcessFile(DCUFileEdit.DialogFiles[idx],TmpList,True);
      if not GlobPreParsOK
           then LogList.Add(Format('Possible pre-parser failure in: %s warning:%d',[ExtractFileName(DCUFileEdit.DialogFiles[idx]),GlobPreParseWarning]));

      DCULogMemo.Lines[0]:=DCULogMemo.Lines[0]+msg_done1;

      // STEP 1 - Analizing and adding
      DCULogMemo.Lines.Add('Analizing ...');
      s:=TmpList.Text;
      iPos:=POS('implementation',s);
      TmpList.Text:=Copy(s,iPos+14,Length(s)-iPos-13);
      DCULogMemo.Lines[1]:=DCULogMemo.Lines[1]+msg_done1;

      // STEP 2 - Building DSF patterns
      DCULogMemo.Lines.Add('Building DSF patterns ...');
      GlobPreParseWarning:=$0;
      NewParser.InitParse(TmpList,AddNewDCU_DSF);
      Try
        iCurrCnt:=GlobiRecNum;
        iFakeCount:=0;
        NewParser.ParseIt;
        iCurrCnt:=GlobiRecNum+iFakeCount-iCurrCnt;
        DCULogMemo.Lines[2]:=DCULogMemo.Lines[2]+msg_done1;

        // STEP 3 - Verifying
        //DCULogMemo.Lines.Add(msg_verifying_file);
        cnt:=0;
        for i:=0 to TMPList.Count-1 Do
         begin
           if Copy(TMPList[i],1,8)='function' then inc(cnt);
           if Copy(TMPList[i],1,9)='procedure' then inc(cnt);
         end;

        if iCurrCnt<>cnt then
          if GlobPreParseWarning=$DEDE
           then LogList.Add(Format('File too compilated to parse: %s error: dasm',[ExtractFileName(DCUFileEdit.DialogFiles[idx])]))
           else LogList.Add(Format('File too compilated to parse: %s skiped:%d',[ExtractFileName(DCUFileEdit.DialogFiles[idx]),cnt-iCurrCnt]));

        Inc(GlobiFakeCount, iFakeCount);

      Finally
        DCUstatuLbl.Caption:='';
        DCUstatuLbl.Update;
        DCUPB.Position:=0;
        DCUPB.Update;
      End;

     End; {For idx}
  Finally
    // STEP 4 - Saving DSF file
    DCULogMemo.Lines.Add(msg_saveing_file);
    if GlobiRecNum<>0
      then SaveBPLSymbolFile(DataB,DataS,DCUSymFile.FileName,DCUGetSymMode,_PatternSize,GlobiRecNum,DCUCommentEdit.Text)
      else ShowMessage('No DSF patterns to save!');
    //SaveBPLSymbolFile(DataB,DataS,DCUSymFile.FileName,DCUGetSymMode,_PatternSize,GlobiRecNum,DCUCommentEdit.Text);
    DCULogMemo.Lines[3]:=LogMemo.Lines[3]+msg_done1;
    DCULogMemo.Update;

    TmpList.Free;

    if LogList.Count<>0
       then LogList.SaveToFile(ChangeFileExt(DCUSymFile.FileName,'.log'));
    LogList.Free;

    DCUStatuLbl.Caption:=Format('%d DSF idents added. %d procs skiped (unnamed or long less than 7 bytes)',[GlobiRecNum,GlobiFakeCount]);
    DCUStatuLbl.Update;
    ShowMessage(msg_dsf_success);
    DCULogMemo.Clear;

    DataB.Free;
    DataS.Free;

    CurrDCULbl.Caption:='';
    CDCUPB.Position:=0;
    CDCUPB.Update;

    Screen.Cursor:=crDefault;
    DetailsPanel.Visible:=False;
  End;
end;

procedure TBPL.AddNewDCU_DSF(sProcDecl: String; buffer: TSymBuffer;
  size: Integer; Progress : Byte; bAddIT : Boolean);
var j : Byte;
    s,sDCUName : String;

    // To avoid the fucking out of memory
    // when passing param of the proc as var param to other proc
    buff : TSymBuffer;
begin
  if not bAddIT then
    begin
      Inc(iFakeCount);
      Exit;
    end;

  s:='';
  For j:=1 to Length(sProcDecl) do
    if sProcDecl[j]>=#32 then s:=s+sProcDecl[j];

  if DCUParamCB.Checked Then s:=DCUFixParams(s);

  if Copy(s,1,9)='procedure' then s:=Copy(s,10,Length(s)-9);
  if Copy(s,1,8)='function' then s:=Copy(s,9,Length(s)-8);

  // Skip procs that starts with '_NF_'
  s:=Trim(s);
  if Copy(s,1,4)='_NF_' then
    begin
      Inc(iFakeCount);
      exit;
    end;

  sDCUName:=CurrDCULbl.Caption;
  sDCUName:=Copy(sDCUName,1,Length(sDCUName)-3);
  if ansiuppercase(sDCUName)+';'=ansiuppercase(Trim(s)) then s:='Initialization;';
  s:=sDCUName+Trim(s);

  if DCUExcludeCB.Checked then s:=DCUExculdeParamNames(s);


  // To avoid the fucking out of memory
  // when passing param of the proc as var param to other proc
  Buff:=buffer;

  If UnlinkCalls(buff) Then
    Begin
        DataB.WriteBuffer(buff[1],_PatternSize);
        j:=Length(s);
        DataS.WriteBuffer(j,1);
        DataS.WriteBuffer(s[1],j);
        Inc(GlobiRecNum);
        DCUstatuLbl.Caption:=s;
        DCUstatuLbl.Update;
    end;
  DCUPB.Position:=Progress;
  DCUPB.Update;
  Application.ProcessMessages;
end;

end.
