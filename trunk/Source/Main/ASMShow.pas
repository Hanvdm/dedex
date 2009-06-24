unit ASMShow;
//////////////////////////
// Last Change:  4-11-2001
//////////////////////////

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons, ComCtrls, ImgList, Menus, DeDe_SDK, rxPlacemnt;

type
  TASMShowForm = class(TForm)
    Panel1: TPanel;
    MainPanel: TPanel;
    ASMList: TListBox;
    PrevBtn: TSpeedButton;
    NextBtn: TSpeedButton;
    ProcCB: TComboBox;
    ProcRVA: TComboBox;
    Panel3: TPanel;
    Splitter1: TSplitter;
    ProcTree: TTreeView;
    ImageList1: TImageList;
    CopyBtn: TSpeedButton;
    FindTxtBtn: TSpeedButton;
    FindDlg: TFindDialog;
    DoubleRightClickTimer: TTimer;
    MainMenu1: TMainMenu;
    Navigation1: TMenuItem;
    Next1: TMenuItem;
    Previous1: TMenuItem;
    N1: TMenuItem;
    Disassemble1: TMenuItem;
    N2: TMenuItem;
    Close1: TMenuItem;
    Edit1: TMenuItem;
    Copy1: TMenuItem;
    SelectAll1: TMenuItem;
    N3: TMenuItem;
    FindText1: TMenuItem;
    miPlugins: TMenuItem;
    N4: TMenuItem;
    ChangeFont1: TMenuItem;
    FontDlg: TFontDialog;
    A1: TMenuItem;
    SBar: TStatusBar;
    PopupMenu1: TPopupMenu;
    Copy2: TMenuItem;
    FP: TFormPlacement;
    VarsPanel: TPanel;
    Splitter2: TSplitter;
    CommentBtn: TSpeedButton;
    VarBtn: TSpeedButton;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    VarLV: TListView;
    GroupBox1: TGroupBox;
    LocRB: TRadioButton;
    GlobRB: TRadioButton;
    InitRegGrp: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    edxEdit: TEdit;
    eaxEdit: TEdit;
    Label3: TLabel;
    ecxEdit: TEdit;
    Label4: TLabel;
    ebxEdit: TEdit;
    Label6: TLabel;
    Label5: TLabel;
    esiEdit: TEdit;
    ediEdit: TEdit;
    SaveBtn: TSpeedButton;
    LoadBtn: TSpeedButton;
    OpenDlg: TOpenDialog;
    TabSheet3: TTabSheet;
    ListBox1: TListBox;
    SaveDlg: TSaveDialog;
    procedure ASMListDblClick(Sender: TObject);
    procedure PrevBtnClick(Sender: TObject);
    procedure ProcCBChange(Sender: TObject);
    procedure NextBtnClick(Sender: TObject);
    procedure ProcTreeChange(Sender: TObject; Node: TTreeNode);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ProcTreeClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure CopyBtnClick(Sender: TObject);
    procedure ASMListDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FindTxtBtnClick(Sender: TObject);
    procedure ASMListMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure DoubleRightClickTimerTimer(Sender: TObject);
    procedure Close1Click(Sender: TObject);
    procedure SelectAll1Click(Sender: TObject);
    procedure FindDlgFind(Sender: TObject);
    procedure miPluginsClick(Sender: TObject);
    procedure Disassemble1Click(Sender: TObject);
    procedure ChangeFont1Click(Sender: TObject);
    procedure ASMListKeyPress(Sender: TObject; var Key: Char);
    procedure A1Click(Sender: TObject);
    procedure ASMListClick(Sender: TObject);
    procedure CommentBtnClick(Sender: TObject);
    procedure LocRBClick(Sender: TObject);
    procedure GlobRBClick(Sender: TObject);
    procedure VarLVDblClick(Sender: TObject);
    procedure VarBtnClick(Sender: TObject);
    procedure ASMListKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure eaxEditKeyPress(Sender: TObject; var Key: Char);
    procedure SaveBtnClick(Sender: TObject);
    procedure LoadBtnClick(Sender: TObject);
  private
    { Private declarations }
    DASMListings : TList;
    DASMIndex : TStringList;
    DASMInitEmulData : TStringList;
    FbDRCH : Boolean;
    FsTextToFind, FsAdvMore, FsAdvRegs : String;
    procedure ClearDASMListings;
    Function OffsetInSameProc(sOffs : String) : Boolean;
    Procedure _GotoLine(sOffs : String; bSaveJump : Boolean = True); overload;
    Procedure _GotoLine(wLine : LongInt; bSaveJump : Boolean = True); overload;
    Procedure PlugInClick(Sender : TObject);
    Procedure ShowDSFPattern(rva : String);
  public
    { Public declarations }
    procedure SelectNode;
    function GetNodeWithCaption(sCap : String) : TTreeNode;
    procedure HandleDoubleRightClick;
    procedure UpdatePlugInData;
    procedure InitEmul;
    procedure InitEmulationUsingRegisterString(sRegStr : String; sMoreOptions : String);
    procedure EditASMComment(rva : Longint);
    procedure SetEmulParams(sData : String);
  end;

var
  ASMShowForm: TASMShowForm;

Function _GetCallReference(dwVirtOffset : DWORD; var sReference : String; var btRefType : Byte; btMode : Byte = 0) : Boolean;
Function _GetObjectName(dwVirtOffset : DWORD; var sObjName : String) : Boolean;
Function _GetFieldReference(dwVirtOffset : DWORD; var sReference : String) : Boolean;
Function GetCurrFirstRVA : String;

procedure AddCommentsToListing(aDasmList : TStringList; ProcRVA : DWORD);

implementation

{$R *.DFM}

Uses DeDeDisASM, HEXTools, ClipBrd, DeDeClassEmulator, 
  MainUnit, ShowPluginUnit, DeDeConstants, DeDeClasses, DeDeSym, DeDeReg,
  DeDeExpressions,
  // [ LC ]
  DeDeEditText, Asm2Pas, EditExprUnit, DeDeDUF;

var wLineNum : LongInt;
    LastColor: DWORD;
    sLastJumpRva : LongInt;
    FbShowDSFPattern : Boolean;

Procedure TruncAll(Var s : String);
Begin
  While Copy(s,1,1)=' ' Do s:=Copy(s,2,Length(s)-1);
  While Copy(s,Length(s),1)=' ' Do s:=Copy(s,1,Length(s)-1);
End;

Function GetCurrFirstRVA : String;
var i{, j} : Integer;

Begin
  With ASMShowForm.ASMList Do
    Begin
      For i:=0 to Items.Count-1 Do
        begin
          Result:=Copy(Items[i],1,8);
          if Length(Result)<>8 then continue;
          //Skip commented lines
          If Pos(Result[1],'1234567890ABCDEF')=0 then continue;
          
          if not IsInSection(HEX2DWORD(Result),'CODE') then continue;
          break;
        end;
    End;
End;


procedure AddCommentsToListing(aDasmList : TStringList; ProcRVA : DWORD);
var
   cmt, s, q, vars : string;
   i, j, k , l: integer;
   RVA : longword;

   procedure a;
   begin
      cmt := '';
      if Copy(s, 9, 2) = '  ' then begin
         RVA := HEX2DWORD(Copy(s, 1, 8));
         GetComment(RVA, k, cmt);
      end; { if }
   end;

begin

   for i:=0 to aDasmList.Count-1 do begin
      s := aDasmList[i];
      j := Pos(#13#10, s);
      while j <> 0 do begin
         a;
         q := Copy(s, 1, j - 1);
         k := Pos('{ ', q);
         if k > 0 then q := Trim(Copy(q, 1, k - 1));

         // Seek variables
         vars:='';
         for l:=0 to ExpressionCount-1 do
           if (Expressions[l].RVA=ProcRVA) or (Expressions[l].RVA=0) then
              if (Expressions[l].Comment<>'') and (Pos(Expressions[l].Name,q)<>0)
                then vars:=Expressions[l].Comment+'; '+vars;

         if Trim(cmt) <> '' then
            ASMShowForm.ASMList.Items.Add(q+' { '+vars+cmt+' } ')
         else
            if vars<>'' then ASMShowForm.ASMList.Items.Add(q+' { '+vars+' } ')
                        else ASMShowForm.ASMList.Items.Add(q);
                        
         s := Copy(s, j + 2, Length(s) - j);
         j := Pos(#13#10, s);
      end; { while }

      a;
      k := Pos('{ ', s);
      if k > 0 then s := Trim(Copy(s, 1, k - 1));

      // Seek variables
      vars:='';
      for l:=0 to ExpressionCount-1 do
        if (Expressions[l].RVA=ProcRVA)or (Expressions[l].RVA=0) then
           if (Expressions[l].Comment<>'') and (Pos(Expressions[l].Name,s)<>0)
             then vars:=Expressions[l].Comment+'; '+vars;

      if Trim(cmt) <> '' then
         ASMShowForm.ASMList.Items.Add(s +' { '+vars+cmt+' } ')
      else
        if vars<>'' then ASMShowForm.ASMList.Items.Add(s+' { '+vars+' } ')
                    else ASMShowForm.ASMList.Items.Add(s);
   end; { for }

   ASMShowForm.LocRBClick(ASMShowForm);
end;


procedure DisAsm(s : String; bBack : Boolean = True);
var
   ss, sEmulResult : String;
   DasmList : TStringList;
   i : Integer;
begin
  if bBack then begin
       i:=ASMShowForm.DASMIndex.IndexOf(s);
       if i=-1 then bBack:=False
               else begin
                 DasmList:=TStringList(ASMShowForm.DASMListings[i]);
                 ASMShowForm.SetEmulParams(ASMShowForm.DASMInitEmulData[i]);
                 ASMShowForm.InitRegGrp.Tag:=i;
               end;
  end; { if }

   if not bBack then begin
       ////////////////////////////////////////////////////////////////////////////////////
       // Emulate the last procedure till the new call in order to init registers
       // for the new emulation properly
       ss:=DWORD2HEX(RVAConverter.GetPhys(HEX2DWORD(GetCurrFirstRVA)));
       PEStream.Seek(HEX2DWORD(ss),soFromBeginning);

       // Initialize emulation of the previous proc from the saved
       // in DASMInitEmulData register data string
       GlobCustomEmulInit:=True;
       i:=ASMShowForm.DASMIndex.IndexOf(GetCurrFirstRVA);
       if i<>-1 then
         begin
           sEmulResult:=ASMShowForm.DASMInitEmulData[i];
           ASMShowForm.InitEmulationUsingRegisterString(sEmulResult,sEmulResult+',TTL=100');
         end;

       // Emulate to the RVA from where our new proc is called
       DisassembleProc('','',DasmList,False,True,True,HEX2DWORD(ASMShowForm.ASMList.Items[ASMShowForm.ASMList.Itemindex]));

       // Prepare the emulation resulting register data string for later use
       sEmulResult:=Format('EAX=%s,ECX=%s,EDX=%s,EBX=%s,ESI=%s,EDI=%s',
         [GetRegVal(rgEAX),GetRegVal(rgECX),GetRegVal(rgEDX),GetRegVal(rgEBX),GetRegVal(rgESI),GetRegVal(rgEDI)]);

       // And clear the stack
       DeDeClassEmulator.ClearStack;
       //
       /////////////////////////////////////////////////////////////////////////////////////

       ss:=DWORD2HEX(RVAConverter.GetPhys(HEX2DWORD(s)));
       If RVAConverter.GetPhys(HEX2DWORD(s))>PEStream.Size Then Exit;
       PEStream.Seek(HEX2DWORD(ss),soFromBeginning);
       DisassembleProc('','',DasmList,False,True);
       GlobCustomEmulInit:=False;

       // Add disassembly listing RVA/Name
       ASMShowForm.DASMIndex.Add(s);

       // Add Initial Emulation Values String
       ASMShowForm.DASMInitEmulData.Add(sEmulResult);
       ASMShowForm.SetEmulParams(sEmulResult);
       ASMShowForm.InitRegGrp.Tag:=ASMShowForm.DASMInitEmulData.Count-1;
   end; { if }
   
   ASMShowForm.ASMList.Items.BeginUpdate;
   ASMShowForm.ASMList.Clear;
   ASMShowForm.Caption:='Proc_'+s;
   AddCommentsToListing(DasmList,HEX2DWORD(s));
   ASMShowForm.ASMList.Items.EndUpdate;

   If (bBack) and (wLineNum>0) Then begin
     SendMessage(ASMShowForm.ASMList.Handle,WM_VSCROLL,MakeLong(SB_THUMBPOSITION,wLineNum div MaxWord),0);
     ASMShowForm.ASMList.ItemIndex:=Word(wLineNum);
     ASMShowForm.ASMList.Selected[Word(wLineNum)]:=True;
   end; { if }
   ASMShowForm.ASMList.SetFocus;

   // Instead of Freeing Disaasembly Result String List (DasmList.Free)
   // It is added in DASMListings TList. Will be freed OnFormClose
   if not bBack then ASMShowForm.DASMListings.Add(DasmList);
end;

procedure TASMShowForm.Disassemble1Click(Sender: TObject);
var
   ss, s, sEmulResult : String;
   DasmList : TStringList;
   i, idx : Integer;
begin
   s:=Copy(ASMList.Items[0],1,8);
   idx:=ASMShowForm.DASMIndex.IndexOf(s);
   if idx=-1 then exit;

   ss:=DWORD2HEX(RVAConverter.GetPhys(HEX2DWORD(s)));
   If RVAConverter.GetPhys(HEX2DWORD(s))>PEStream.Size Then Exit;
   PEStream.Seek(HEX2DWORD(ss),soFromBeginning);


   ASMShowForm.InitEmul;

   Screen.Cursor:=crHourGlass;
   Try
     DisassembleProc('','',DasmList,False,True);
     ASMShowForm.ASMList.Items.BeginUpdate;
     ASMShowForm.ASMList.Clear;
     ASMShowForm.Caption:='Proc_'+s;
     AddCommentsToListing(DasmList,HEX2DWORD(s));
     ASMShowForm.ASMList.Items.EndUpdate;
     ASMShowForm.ASMList.SetFocus;
   Finally
     Screen.Cursor:=crDefault;
   End;
   // Update the DASMListings TList.
   TStringList(ASMShowForm.DASMListings.Items[idx]).Free;
   ASMShowForm.DASMListings.Items[idx]:=DasmList;
end;


Function IsJumpInstruction(ins1 : String) : Boolean;
Begin
  Result:=
    (ins1='jmp') or
    (ins1='jo') or
    (ins1='jno') or
    (ins1='jb') or
    (ins1='jnb') or
    (ins1='je') or
    (ins1='jne') or
    (ins1='jbe') or
    (ins1='jnbe') or
    (ins1='js') or
    (ins1='jns') or
    (ins1='jp') or
    (ins1='jnp') or
    (ins1='jl') or
    (ins1='jnl') or
    (ins1='jle') or
    (ins1='jnle') or
    (ins1='jz') or
    (ins1='jnz');
End;

procedure TASMShowForm.ASMListDblClick(Sender: TObject);
var s, rva : string;
    node : TTreeNode;
begin
  s:=Trim(ASMList.Items[ASMList.ItemIndex]);
  if s='' then exit;
  If Pos('call',s)<>0 Then
    Begin
      wLineNum:=MakeLong(ASMList.ItemIndex,ASMList.TopIndex);
      rva:=Copy(s,Pos('call',s)+4,Length(s)-Pos('call',s));
      TruncAll(rva);
      If (Length(rva)>1) and (rva[1] in ['0'..'9']) Then
       Begin

        // If Ctrl+Alt+Shift Pressed then Only show the DSF Pattern
        if FbShowDSFPattern then
          begin
            ShowDSFPattern(rva);
            Exit;
          end;

        Screen.Cursor:=crHourGlass;
        Try
          DisAsm(rva, False);
        Finally
          Screen.Cursor:=crDefault;
        End;
        If ProcCB.Items.IndexOf('Proc_'+rva)=-1
         Then Begin
            ProcCB.Items.Add('Proc_'+rva);
            ProcRVA.Items.Add(rva);
            Caption:='Proc_'+rva;
            ProcCB.ItemIndex:=ProcCB.Items.IndexOf('Proc_'+rva);
            node:=ProcTree.Items.AddChild(ProcTree.Selected,'Proc_'+rva);
            node.ImageIndex:=1;
            node.Parent.Expand(False);
            node.Data:=Pointer(0);
            ProcTree.Selected.Data:=Pointer(wLineNum);

            sLastJumpRva:=0;
            ProcTree.OnChange:=nil;
            Try
              ProcTree.Selected:=node;
            Finally
              ProcTree.OnChange:=ProcTreeChange;
            End;
         End
         Else Begin
           ProcCB.ItemIndex:=ProcCB.Items.IndexOf('Proc_'+rva);
           SelectNode;
         End;
       End;
    End

    Else Begin
      // Not a call. Test if it is jump
      //
      // 12345678901234567890123456789012345678901234567890
      //          1         2         3         4
      // xxxxxxxx   yyyyyy                 jmp     zzzzzzzz
      // 0044C7AA   0F8C91010000           jl      0044C941

      rva:=Trim(Copy(s,35,3));
      if IsJumpInstruction(rva) then
        begin
          wLineNum:=MakeLong(ASMList.ItemIndex,ASMList.TopIndex);
          rva:=Copy(s+#32,43,9); if rva[1]='$' then rva:=Copy(rva,2,8);
          TruncAll(rva);
          if rva='dword ptr' then exit;
          if OffsetInSameProc(rva)
            then begin _GotoLine(rva); exit; end
            else If MessageDlg('The offset '+rva+' is not in this proc. Disassemble ?',mtConfirmation,[mbYes,mbNo],0)=mrNo then Exit;

          If (Length(rva)>1) and (rva[1] in ['0'..'9']) Then
           Begin
            Screen.Cursor:=crHourGlass;
            Try
              DisAsm(rva, False);
            Finally
              Screen.Cursor:=crDefault;
            End;
            If ProcCB.Items.IndexOf('Proc_'+rva)=-1
             Then Begin
                ProcCB.Items.Add('Proc_'+rva);
                ProcRVA.Items.Add(rva);
                Caption:='Proc_'+rva;
                ProcCB.ItemIndex:=ProcCB.Items.IndexOf('Proc_'+rva);
                node:=ProcTree.Items.AddChild(ProcTree.Selected,'Proc_'+rva);
                node.ImageIndex:=1;
                node.Parent.Expand(False);
                node.Data:=Pointer(0);
                ProcTree.Selected.Data:=Pointer(wLineNum);

                ProcTree.OnChange:=nil;
                Try
                  ProcTree.Selected:=node;
                Finally
                  ProcTree.OnChange:=ProcTreeChange;
                End;
             End
             Else Begin
               ProcCB.ItemIndex:=ProcCB.Items.IndexOf('Proc_'+rva);
               SelectNode;
             End;
           End;
        end
        else CommentBtnClick(self);
    End;

end;


procedure TASMShowForm.PrevBtnClick(Sender: TObject);
begin
  If ProcTree.Selected=nil Then Exit;
  If ProcTree.Selected.Parent=nil Then Exit;
  ProcTree.Selected:=ProcTree.Selected.Parent;
end;

procedure TASMShowForm.ProcCBChange(Sender: TObject);
var rva : String;
begin
  rva:=ProcRVA.Items[ProcCB.ItemIndex];
  Screen.Cursor:=crHourGlass;
  Try
    DisAsm(rva, True);
  Finally
    Screen.Cursor:=crDefault;
    SelectNode;
  End;
end;

procedure TASMShowForm.NextBtnClick(Sender: TObject);
var inst : TTreeNode;
begin
  If ProcCB.ItemIndex<ProcCB.Items.Count-1
    Then Begin
     ProcCB.ItemIndex:=ProcCB.ItemIndex+1;
     inst:=GetNodeWithCaption(ProcCB.Items[ProcCB.ItemIndex]);
     if inst<>nil then wLineNum:=LongInt(inst.Data)
                  else wLineNum:=0;
     ProcCBChange(self);
   End;
end;

procedure TASMShowForm.ProcTreeChange(Sender: TObject; Node: TTreeNode);
var s : String;
begin
  If ProcTree.Selected=nil Then Exit;
  s:=ProcTree.Selected.Text;
  wLineNum:=LongInt(ProcTree.Selected.Data);
  ProcCB.ItemIndex:=ProcCB.Items.IndexOf(s);
  ProcCBChange(self);
end;

procedure TASMShowForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  ProcTree.OnChange:=nil;
  ProcTree.OnClick:=nil;
  Try
    ProcTree.Items.Clear;
    ClearDASMListings;
  Finally
    ProcTree.OnChange:=ProcTreeChange;
    ProcTree.OnClick:=ProcTreeClick;
  End;
end;

procedure TASMShowForm.ProcTreeClick(Sender: TObject);
var s : String;
begin
  If ProcTree.Selected=nil Then Exit;
  s:=ProcTree.Selected.Text;
  wLineNum:=LongInt(ProcTree.Selected.Data);
  ProcCB.ItemIndex:=ProcCB.Items.IndexOf(s);
  ProcCBChange(self);
end;

procedure TASMShowForm.FormShow(Sender: TObject);
var inst : TStringList;
    iPos : Integer;
begin
  ProcTree.OnChange:=nil;
  Try
    ProcTree.Selected:=ProcTree.TopItem;
    inst:=TStringList.Create;
    inst.Assign(ASMlist.Items);
    if inst.Count=0 then inst.Add('00000666 Blah');
    DASMListings.Add(inst);
    DASMIndex.Add(Copy(inst[0],1,8));
    iPos:=Pos('.',Caption);

    DASMInitEmulData.Add('EAX='+Copy(Caption,1,iPos-1)+',ECX=,EDX=,EBX=,ESI=,EDI=');
    SetEmulParams('EAX='+Copy(Caption,1,iPos-1)+',ECX=,EDX=,EBX=,ESI=,EDI=');
    InitRegGrp.Tag:=DASMInitEmulData.Count-1;

    SBar.Panels[0].Text:=' '+DeDeMainForm.ProjectNameLbl.Caption;
  Finally
    ProcTree.OnChange:=ProcTreeChange;
  End;
end;

procedure TASMShowForm.SelectNode;
var i : Integer;
    s : String;
begin
  ProcTree.OnChange:=nil;
  ProcTree.OnClick:=nil;
  Try
    s:=ProcCB.Items[ProcCB.ItemIndex];
    For i:=0 To ProcTree.Items.Count-1 Do
      If ProcTree.Items.Item[i].Text=s Then
        Begin
          ProcTree.Selected:=ProcTree.Items.Item[i];
          break;
        End;
  Finally
    ProcTree.OnChange:=ProcTreeChange;
    ProcTree.OnClick:=ProcTreeClick;
  End;
end;

function TASMShowForm.GetNodeWithCaption(sCap : String) : TTreeNode;
var i : Integer;
begin
  Result:=nil;
  ProcTree.OnChange:=nil;
  ProcTree.OnClick:=nil;
  Try
    For i:=0 To ProcTree.Items.Count-1 Do
      If ProcTree.Items.Item[i].Text=sCap Then
        Begin
          Result:=ProcTree.Items.Item[i];
          break;
        End;
  Finally
    ProcTree.OnChange:=ProcTreeChange;
    ProcTree.OnClick:=ProcTreeClick;
  End;
end;

procedure TASMShowForm.CopyBtnClick(Sender: TObject);
var i : Integer;
    s : String;
begin
  s:='';
  For i:=0 To ASMList.Items.Count-1 Do
       If ASMList.Selected[i] Then s:=s+ASMList.Items[i]+#13#10;

 If s<>'' Then  ClipBoard.AsText:=s;
end;

procedure TASMShowForm.ASMListDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var C1,C2,C3,C4,C5,C6 : DWORD;
    q, r, s : String;
    i : integer;
begin
 s := ASMList.Items[Index];
 i := Length(s) * (Control as TListBox).Canvas.Font.Size;
 if i > AsmList.ScrollWidth then AsmList.ScrollWidth := i;

 With (Control as TListBox).Canvas Do
  Begin
    If odSelected in State
      Then Begin
        C1:=clWhite;
        C2:=clGreen xor $00FFFFFF;
        C3:=clRed xor $00FFFFFF;
        C4:=clBlue xor $00FFFFFF;
        C5:=clNavy xor $00FFFFFF;
        C6:=clMaroon xor $00FFFFFF;
      End
      Else Begin
        C1:=clBlack;
        C2:=clGreen;
        C3:=clRed;
        C4:=clBlue;
        C5:=clNavy;
        C6:=clMaroon;
      End;

    // the normal color is black
    (Control as TListBox).Canvas.Font.Color:=C1;

    // dark blue stuff
    If (Pos(sREF_TEXT_END,s)<>0) Then (Control as TListBox).Canvas.Font.Color:=C5;
    If (Pos(sREF_TEXT_EXCEPT,s)<>0) Then (Control as TListBox).Canvas.Font.Color:=C5;
    If (Pos(sREF_TEXT_FINALLY,s)<>0) Then (Control as TListBox).Canvas.Font.Color:=C5;
    If (Pos(sREF_TEXT_TRY,s)<>0) Then (Control as TListBox).Canvas.Font.Color:=C5;

    //------------------
    // maroon references
    //------------------

    // possible DOI references
    If Pos(sREF_TEXT_POSSIBLE_TO+' ',s)<>0 then (Control as TListBox).Canvas.Font.Color:=C6;

    // DOI references
    If Pos(sREF_TEXT_REF_TO+' ',s)<>0 then (Control as TListBox).Canvas.Font.Color:=C6;

    // for published methods
    If Pos(sREF_TEXT_PUBLISHED,s)<>0 Then (Control as TListBox).Canvas.Font.Color:=C6;

    // the blue dsf and import functions
    If Pos(sREF_TEXT_REF_DSF,s)<>0 Then (Control as TListBox).Canvas.Font.Color:=C4;
    If Pos(sREF_TEXT_REF_DSF_OR,s)<>0 then (Control as TListBox).Canvas.Font.Color:=C4;

    // some green string references
    If Pos(sREF_TEXT_REF_STRING,s)<>0 then (Control as TListBox).Canvas.Font.Color:=C2;
    If Pos(sREF_TEXT_REF_STRING_OR,s)<>0 then (Control as TListBox).Canvas.Font.Color:=C2;

    LastColor:=(Control as TListBox).Canvas.Font.Color;
    FillRect(Rect);
    r := (Control as TListBox).Items[Index];
    i := Pos('{', r);
    if i > 0 then begin
       q := Trim(Copy(r, 1, i - 1));
       TextOut(Rect.Left + 2, Rect.Top, q);
       Delete(r, 1, i - 1);
       r := Trim(r);
       i := (Control as TListBox).Canvas.Font.Size * (Length(q) - 1);
       (Control as TListBox).Canvas.Font.Color := clTeal;
       TextOut(Rect.Left + 2 + i, Rect.Top, r);
    end else begin
       TextOut(Rect.Left + 2, Rect.Top, r);
    end; { if }
  End;
end;

procedure TASMShowForm.FormCreate(Sender: TObject);
begin
  DASMListings:=TList.Create;
  DASMIndex:=TStringList.Create;
  DASMInitEmulData:=TStringList.Create;
  FP.IniFileName:=DeDeReg.GlobDeDeINIFileName;
  // Now it is always visible
  //AdvancedEmulatorOption1.Visible:=GlobMORE;
end;

procedure TASMShowForm.FormDestroy(Sender: TObject);
begin
  DASMInitEmulData.Free;
  DASMListings.Free;
  DASMIndex.Free;
end;

procedure TASMShowForm.ClearDASMListings;
var i : Integer;
    inst : TStringList;
begin
  for i:=DASMListings.Count-1 downto 0 Do
    begin
      inst:=TStringList(DASMListings[i]);
      if inst=nil then inst.Free;
    end;
  DASMIndex.Clear;
  DASMListings.Clear;
  DASMInitEmulData.Clear;
end;

procedure TASMShowForm.InitEmulationUsingRegisterString(sRegStr : String; sMoreOptions : String);
var EmulData : TStringList;
    FsEAXClass : String;
begin
  if not GlobBEmulation then Exit;
  EmulData:=TStringList.Create;
  Try
   Try
    EmulData.CommaText:=sRegStr;

    // Init DeDeDisASM.ClsDmp according to the EAX custom value
    FsEAXClass:=EmulData.Values[REGISTERS__[rgEAX]];
    if FsEAXClass='' then FsEAXClass:='TObject';
    DeDeDisASM.ClsDmp:=DeDeMainForm.ClassesDumper.GetClass(FsEAXClass);

    InitNewEmulation('','','','');

    SetRegisters(
      EmulData.Values[REGISTERS__[rgEAX]],
      EmulData.Values[REGISTERS__[rgEBX]],
      EmulData.Values[REGISTERS__[rgECX]],
      EmulData.Values[REGISTERS__[rgEDX]],
      EmulData.Values[REGISTERS__[rgESI]],
      EmulData.Values[REGISTERS__[rgEDI]]
      );

    EmulData.CommaText:=sMoreOptions;
    if EmulData.Values['TTL']='' then EmulData.Values['TTL']:='100';
    SetEmulationSettings(
      EmulData.Values[REGISTERS__[rgEAX]],
      EmulData.Values[REGISTERS__[rgEBX]],
      EmulData.Values[REGISTERS__[rgECX]],
      EmulData.Values[REGISTERS__[rgEDX]],
      EmulData.Values[REGISTERS__[rgESI]],
      EmulData.Values[REGISTERS__[rgEDI]],
      EmulData.Values['TTL']);
    Except
      ShowMessage('CustomInitEmulation() Failed!');
    End;
  Finally
    EmulData.Free;
  End;
end;

procedure TASMShowForm.InitEmul;
begin
  FsAdvMore:='';// NO MORE SUPPORTED addEdit.Text;
  FsAdvRegs:=Format('EAX=%s,ECX=%s,EDX=%s,EBX=%s,ESI=%s,EDI=%s',
     [eaxEdit.Text,ecxEdit.Text,edxEdit.Text,ebxEdit.Text,esiEdit.Text,ediEdit.Text]);

  InitEmulationUsingRegisterString(FsAdvRegs,FsAdvMore);
end;

function TASMShowForm.OffsetInSameProc(sOffs: String): Boolean;
var sf,st : String;
begin
  Result:=False;
  If ASMList.ItemIndex=-1 then exit;
  sf:=GetCurrFirstRVA; sf:=Copy(sf,1,8);
  st:=ASMList.Items[ASMList.Items.Count-2]; st:=Copy(st,1,8);
  Result:=(sOffs>=sf) and (sOffs<=st);
end;


procedure TASMShowForm._GotoLine(sOffs: String; bSaveJump : Boolean = True);
var wLineNum, delta, bck{, bki} : Word;
begin
   delta:=(ASMList.TopIndex);
   For wLineNum:=0 to ASMList.Items.Count-1 Do
     if Copy(ASMList.Items[wLineNum],1,8)=sOffs then
       begin
         SendMessage(ASMShowForm.ASMList.Handle,
                     WM_VSCROLL,MakeLong(SB_THUMBPOSITION,wLineNum div MaxWord),0);
         With ASMList Do
           Begin
             bck:=ItemIndex;
             ItemIndex:=Word(wLineNum);
             Selected[Word(wLineNum)]:=True;
             Selected[Word(bck)]:=False;
             if bSaveJump then sLastJumpRva:=MakeLong(bck,delta)
                          else sLastJumpRva:=0;
             break;
            End;

       end;
    ASMListClick(self);       
end;

procedure TASMShowForm.FindTxtBtnClick(Sender: TObject);
begin
  sLastJumpRva:=MakeLong(ASMList.ItemIndex, ASMList.TopIndex);
  FindDlg.Execute;
End;

procedure TASMShowForm.ASMListMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FbShowDSFPattern:=[ssShift,ssCtrl,ssAlt] * Shift = [ssShift,ssCtrl,ssAlt];

  if Button=mbRight then
    if not FbDRCH then
      begin
        FbDRCH:=True;
        DoubleRightClickTimer.Enabled:=True;
      end
      else begin
        HandleDoubleRightClick;
      end;
end;

procedure TASMShowForm.DoubleRightClickTimerTimer(Sender: TObject);
begin
  FbDRCH:=False;
  DoubleRightClickTimer.Enabled:=False;
end;

procedure TASMShowForm.HandleDoubleRightClick;
begin
   if sLastJumpRva<>0 then _GotoLine(sLastJumpRva,False);
end;

procedure TASMShowForm.Close1Click(Sender: TObject);
begin
  Close;
end;

procedure TASMShowForm.SelectAll1Click(Sender: TObject);
var i,j : Integer;
begin
  ASMList.Items.BeginUpdate;
  Try
    j:=ASMList.TopIndex;
    For i:=0 to ASMList.Items.Count-1 Do ASMList.Selected[i]:=True;
  Finally
    ASMList.Items.EndUpdate;
    SendMessage(ASMShowForm.ASMList.Handle,WM_VSCROLL,MakeLong(SB_THUMBPOSITION,j),0);
  End;

end;

procedure TASMShowForm.FindDlgFind(Sender: TObject);
var i, iFrom, iTo : Integer;
    bDown, bMatchCase, bFound : Boolean;
    s, sSearch : String;
begin
  // Find Next
  FsTextToFind:=FindDlg.FindText;
  bDown:=frDown in FindDlg.Options;
  bMatchCase:=frMatchCase in FindDlg.Options;
  bFound:=False;

  With ASMList Do
   Begin
     iFrom:=ItemIndex; iTo:=Items.Count-1;
     if not bMatchCase then sSearch:=UpperCase(FsTextToFind)
                       else sSearch:=FsTextToFind;

     Items.BeginUpdate;
     Screen.Cursor:=crHourGlass;
     Try
      if bDown then
        begin
          if iFrom=iTo then iFrom:=iTo-1;
          For i:=iFrom+1 to iTo do
            begin
              s:=Items[i];
              if not bMatchCase then s:=UpperCase(s);
              if Pos(sSearch,s)<>0 then
                begin
                  s:=Copy(s,1,8);
                  _GotoLine(MakeLong(i,i),False);
                  bFound:=True;
                  Break;
                end;
            end
        end
        else begin
          if iFrom=0 then iFrom:=1;
          For i:=iFrom-1 downto 0 do
            begin
              s:=Items[i];
              if not bMatchCase then s:=UpperCase(s);
              if Pos(sSearch,s)<>0 then
                begin
                  s:=Copy(s,1,8);
                  _GotoLine(MakeLong(i,i),False);
                  bFound:=True;
                  Break;
                end;
            end;
          end;

     Finally
       Items.EndUpdate;
       Screen.Cursor:=crDefault;
     End;

     if not bFound then ShowMessage('Search text not found');
   End;
end;

procedure TASMShowForm._GotoLine(wLine: LongInt; bSaveJump: Boolean);
var idx,bk : Integer;
begin
  idx:=ASMList.ItemIndex;
  bk:=ASMList.TopIndex;
  SendMessage(ASMShowForm.ASMList.Handle,
               WM_VSCROLL,MakeLong(SB_THUMBPOSITION, wLine div MaxWord),0);
  ASMList.ItemIndex:=(LoWord(wLine));
  ASMList.Selected[LoWord(wLine)]:=True;
  ASMList.Selected[idx]:=False;
  if bSaveJump then sLastJumpRva:=MakeLong(idx,bk)
               else sLastJumpRva:=0;
  ASMListClick(self);
end;

procedure TASMShowForm.miPluginsClick(Sender: TObject);
begin
  If MainUnit.DeDePlugins_Count=0 Then ShowMessage('Load plugins from Options|Configuration|Plugins first');
end;

Function _GetCallReference(dwVirtOffset : DWORD; var sReference : String; var btRefType : Byte; btMode : Byte = 0) : Boolean;
Begin

End;


Function _GetObjectName(dwVirtOffset : DWORD; var sObjName : String) : Boolean;
Begin
End;


Function _GetFieldReference(dwVirtOffset : DWORD; var sReference : String) : Boolean;
Begin
End;

procedure TASMShowForm.UpdatePlugInData;
var i : Integer;
    inst : TMenuItem;
begin
  For i:=miPlugins.Count-1 downto 0 do miPlugins.Delete(i);

  For i:=1 To MainUnit.DeDePlugins_Count Do
    Begin
      inst:=TMenuItem.Create(miPlugIns);
      inst.Caption:=MainUnit.DeDePlugins_PluginsArray[i].sPlugInName;
      inst.OnClick:=PlugInClick;
      miPlugins.Add(inst);
    End;
end;

procedure TASMShowForm.PlugInClick(Sender: TObject);
var i, idx, int_idx : Integer;
    _In : TListGenIN;
    _Out: TListGenOUT;
    dw : DWORD;
begin
  idx:=miPlugIns.IndexOf((Sender as TMenuItem))+1; // It is 1-based
  int_idx:=MainUnit.DeDePlugins_PluginsArray[idx].InternalIndex;

  for i:=0 to ASMList.Items.Count do
   begin
    dw:=HEX2DWORD(ASMList.Items[i]);
    if dw<>0 then break;
   end;

  _In.dwStartAddress:=dw;
  _Out.Listing:=TStringList.Create;
  Try
    // Check for correct offsets
    MainUnit.bPlugInsFixRelative:=
      (MainUnit.DeDePlugins_PluginsArray[idx].PlugInType and ptFixRelativeOffsets)<>0;

    MainUnit.DeDePlugins_PluginsArray[idx].StartPlugInProc(int_idx,_In,_Out);

    if (MainUnit.DeDePlugins_PluginsArray[idx].PlugInType and ptOwnerShow)=0
        Then Begin
           ShowPlugInForm.Memo.Lines.Assign(_Out.Listing);
           ShowPlugInForm.ShowModal;
        End
        Else; // The Plugin will show the result by itself
  Finally
    _Out.Listing.Free;
  End;
end;

procedure TASMShowForm.ShowDSFPattern(rva : String);
var phPos : DWORD;
    buff  : TSymBuffer;
    s     : String;
    i     : Integer;
begin
  phPos:=Hex2DWORD(rva)
         -PEHeader.IMAGE_BASE
         -PEHeader.Objects[1].RVA
         +PEHeader.Objects[1].PHYSICAL_OFFSET;

  With PEStream Do
    Begin
      BeginSearch;
      Try
        Seek(phPos,soFromBeginning);
        ReadBuffer(buff[1],_PatternSize);
        UnlinkCalls(buff,0,Hex2DWORD(rva));

        s:='';
        For i:=1 To _PatternSize Do s:=s+Byte2Hex(buff[i]);

        InputBox(rva,'DSF_ID',s);

      Finally
        EndSearch;
      End;
    End;
end;

procedure TASMShowForm.ChangeFont1Click(Sender: TObject);
var s : String;
begin
  If FontDlg.Execute then
    begin
      s:=FontDlg.Font.Name;
      if (s='Webdings') or (s='Wingdings') or (s='Marlett')
         then begin
           ShowMessage('You crazy or what ??? :))');
           Exit;
         end;
      if (s='Symbol')
         then begin
           ShowMessage('WOW! Man you defenitely roxx :))');
         end;
      if FontDlg.Font.Size>14
         then begin
           ShowMessage('You blind or what ??? :))');
           Exit;
         end;
      ASMList.Font:=FontDlg.Font;
    end;
end;

// [ LC ]
procedure TASMShowForm.ASMListKeyPress(Sender: TObject; var Key: Char);
begin
   case Key of
    ';' : CommentBtnClick(self);
   end; { case }
end;

procedure TASMShowForm.A1Click(Sender: TObject);
begin
  ShowMessage('Not implemented yet!'); Exit;
  Asm2PasForm.Show;
end;

procedure TASMShowForm.ASMListClick(Sender: TObject);
var i : Integer;
    s : String;
    dwRVA, dwPh : DWORD;
begin
  i:=-1;
  Repeat
    Inc(i);
    s:=ASMList.Items[ASMList.ItemIndex+i]+#32;
  until (s[1] in ['0'..'9']) or (ASMList.ItemIndex+i>=ASMList.Items.Count-1);

  if (s[1] in ['0'..'9']) then
    begin
      s:=Copy(s,1,8);
      dwRVA:=HEX2DWORD(s);
      if DeDeDisAsm.OffsetInSegment(dwRVA,'CODE')
        then begin
          i:=PEHeader.GetSectionIndexEx('CODE');
          if i=255 then i:=1;
          dwPh:= dwRVA-PEHeader.IMAGE_BASE-PEHeader.Objects[i].RVA+PEHeader.Objects[i].PHYSICAL_OFFSET;
          s:=' Phys Offset: '+DWORD2HEX(dwPh);
        end
        else s:='';
      SBar.Panels[1].Text:=s;
    end
    else SBar.Panels[1].Text:='';
end;

procedure TASMShowForm.EditASMComment(rva : Longint);
var j : longint;
    prevComment : string;
begin
   EditTextForm.Edit1.Clear;
   if GetComment(RVA, j, prevComment) then begin
      EditTextForm.Edit1.Text := prevComment;
   end; { if }
   EditTextForm.Show;
   EditComment(RVA);
end;

procedure TASMShowForm.CommentBtnClick(Sender: TObject);
var i, RVA : Longint;
    prevComment : String;
begin
    i := AsmList.ItemIndex;
    while i <= (AsmList.Count - 1) do begin
      prevComment := AsmList.Items.Strings[i];
      if Copy(prevComment, 9, 2) = '  ' then begin
         RVA := HEX2DWORD(Copy(prevComment, 1, 8));
         AsmList.ItemIndex := i;
         break;
      end else begin
         inc(i);
      end; { if }
    end; { while }

//   '0054E9F7   A164844000             mov     eax, dword ptr [$408464]'
//   '12345678901234567890123456789012345'
//   '         1         2         3 '
   EditTextForm.Caption:=Copy(AsmList.Items.Strings[i],35,Length(AsmList.Items.Strings[i])-34);
   EditASMComment(RVA);
end;

procedure TASMShowForm.LocRBClick(Sender: TObject);
var i : Integer;
    li : TListItem;
begin
  if LocRB.Checked then
    begin
    VarLv.Clear;
    for i:=0 to ExpressionCount-1 do
      begin
        if GetCurrFirstRVA<>DWORD2HEX(Expressions[i].RVA) then continue;
        li:=VarLv.Items.Add;
        li.Caption:=Expressions[i].Name;
        li.SubItems.Add(Expressions[i].Comment);
        li.Data:=Pointer(Expressions[i].RVA);
      end;
    end;
end;

procedure TASMShowForm.GlobRBClick(Sender: TObject);
var i : Integer;
    sRVA : String;
    li : TListItem;
begin
  if GlobRB.Checked then
    begin
      VarLv.Clear;
      for i:=0 to ExpressionCount-1 do
        begin
          if Expressions[i].RVA<>0 then Continue;
          li:=VarLv.Items.Add;
          li.Caption:=Expressions[i].Name;
          li.SubItems.Add(Expressions[i].Comment);
          li.Data:=nil;
        end;
    end;
end;

procedure TASMShowForm.VarLVDblClick(Sender: TObject);
begin
  if VarLV.Selected=nil then exit;

  EditExprForm.Caption:=VarLV.Selected.Caption;
  EditExprForm.Edit1.Text:=VarLV.Selected.SubItems[0];
  EditExprForm.ShowModal;

  if EditExprForm.ModalResult<>mrCancel then
    begin
      VarLV.Selected.SubItems[0]:=EditExprForm.Edit1.Text;
      EditExpression(Longint(VarLV.Selected.Data),VarLV.Selected.Caption,VarLV.Selected.SubItems[0]);
      Disassemble1Click(Self);
    end;
end;

procedure TASMShowForm.VarBtnClick(Sender: TObject);
begin
  if VarsPanel.Width=0
    then begin
      VarsPanel.Width:=221;
      Splitter2.Visible:=True;
      VarBtn.Caption:='->';
      VarBtn.Hint:='Hide Advanced Panel';
    end
    else begin
      VarsPanel.Width:=0;
      Splitter2.Visible:=False;
      VarBtn.Caption:='<-';
      VarBtn.Hint:='Show Advanced Panel';
    end;
end;

procedure TASMShowForm.ASMListKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (ssCtrl in Shift) and (Chr(Key) in ['f','F'])
    then FindTxtBtnClick(Self);
end;

procedure TASMShowForm.SetEmulParams(sData: String);
var tmp : TStringList;
begin
  tmp:=TStringList.Create;
  try
    tmp.CommaText:=sData;
    eaxEdit.Text:=tmp.Values['EAX'];
    edxEdit.Text:=tmp.Values['EDX'];
    ecxEdit.Text:=tmp.Values['ECX'];
    ebxEdit.Text:=tmp.Values['EBX'];
    esiEdit.Text:=tmp.Values['ESI'];
    ediEdit.Text:=tmp.Values['EDI'];
  finally
    tmp.free;
  end;
end;

procedure TASMShowForm.eaxEditKeyPress(Sender: TObject; var Key: Char);
var i : Integer;
begin
  i:=InitRegGrp.Tag;
  if (i>=DASMInitEmulData.Count) or (i<0) then exit;
  DASMInitEmulData[i]:=Format('EAX=%s,ECX=%s,EDX=%s,EBX=%s,ESI=%s,EDI=%s',
     [eaxEdit.Text,ecxEdit.Text,edxEdit.Text,ebxEdit.Text,esiEdit.Text,ediEdit.Text]);
end;

procedure TASMShowForm.SaveBtnClick(Sender: TObject);
var DUF : TDufFile;
    i : Integer;
begin
  SaveDlg.InitialDir:=ExtractFileDir(Application.ExeName)+'\Projects';
  If SaveDlg.Execute then
    begin
      DUF:=TDufFile.Create;
      try
        DUF.DUFVersion:=CURR_DUFF_VERSION;

        DUF.ExpressionCount:=ExpressionCount;
        SetLength(DUF.Expressions,ExpressionCount);
        DUF.ExpressionCount:=0;
        for i:=0 to ExpressionCount-1 do
          if Expressions[i].Comment<>'' then
            begin
               DUF.Expressions[DUF.ExpressionCount]:=Expressions[i];
               DUF.ExpressionCount:=DUF.ExpressionCount+1;
            end;

        DUF.CommentsCount:=CommentsCount;
        SetLength(DUF.Comments,CommentsCount);
        for i:=0 to CommentsCount-1 do DUF.Comments[i]:=Comments[i];


        DUF.EmulationCount:=0;
        DUF.SaveToFile(SaveDlg.FileName);
      finally
        DUF.Free;
      end;
    end;
end;

procedure TASMShowForm.LoadBtnClick(Sender: TObject);
var DUF : TDufFile;
    i : Integer;
begin
  OpenDlg.InitialDir:=ExtractFileDir(Application.ExeName)+'\Projects';
  If OpenDlg.Execute then
    begin
      DUF:=TDufFile.Create;
      Try
        DUF.LoadFromFile(OpenDlg.FileName);

        ExpressionCount:=DUF.ExpressionCount;
        SetLength(Expressions,ExpressionCount);
        for i:=0 to DUF.ExpressionCount-1 do Expressions[i]:=DUF.Expressions[i];

        CommentsCount:=DUF.CommentsCount;
        SetLength(Comments,DUF.CommentsCount);
        for i:=0 to DUF.CommentsCount-1 do Comments[i]:=DUF.Comments[i];

        EmulationCount:=DUF.EmulationCount;
        SetLength(Emulations,DUF.EmulationCount);
        for i:=0 to DUF.EmulationCount-1 do Emulations[i]:=DUF.Emulations[i];
      Finally
        DUF.Free;
      End;

      GlobRBClick(Self);
      LocRBClick(Self);
      Disassemble1Click(self);
    end;
end;

initialization
  LastColor:=clBlack;

end.