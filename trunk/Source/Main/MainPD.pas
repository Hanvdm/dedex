unit MainPD;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    PLV: TListView;
    MLV: TListView;
    Button2: TButton;
    Label1: TLabel;
    Label2: TLabel;
    SLV: TListView;
    Label3: TLabel;
    PB: TProgressBar;
    SaveDlg: TSaveDialog;
    Label4: TLabel;
    boclbl: TLabel;
    Button3: TButton;
    Label5: TLabel;
    socLbl: TLabel;
    Button4: TButton;
    Label6: TLabel;
    bodLbl: TLabel;
    Label8: TLabel;
    soidLbl: TLabel;
    Label10: TLabel;
    soudLbl: TLabel;
    Label7: TLabel;
    soiLbl: TLabel;
    Label11: TLabel;
    sohLbl: TLabel;
    Label9: TLabel;
    itrLbl: TLabel;
    Label13: TLabel;
    itsLbl: TLabel;
    Label15: TLabel;
    rtrLbl: TLabel;
    Label17: TLabel;
    rtsLbl: TLabel;
    saLbl: TLabel;
    Label21: TLabel;
    etrLbl: TLabel;
    Label23: TLabel;
    etsLbl: TLabel;
    Label12: TLabel;
    ttrLbl: TLabel;
    Label16: TLabel;
    ttsLbl: TLabel;
    Button5: TButton;
    Button6: TButton;
    procedure Button1Click(Sender: TObject);
    procedure PLVChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure Button2Click(Sender: TObject);
    procedure MLVClick(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

uses DeDeMemDumps, DeDeClasses;

procedure TForm1.Button1Click(Sender: TObject);
var ProcessArr, ModuleArr : Array of Cardinal;
    sz,sz1,i : Cardinal;
    hProcess : THandle;
    s : String;
    inst : TListItem;
    mi : MODULEINFO;
begin
  SetLength(ProcessArr,256);
  SetLength(ModuleArr,256);
  EnumProcesses(ProcessArr[0],256,sz);
  PLV.Items.BeginUpdate;
  Try
    PLV.Items.Clear;
    For i:=0 To sz Do
      Begin
        If ProcessArr[i]=0 Then Continue;
        hProcess:=OpenProcess(PROCESS_ALL_ACCESS,False,ProcessArr[i]);
        EnumProcessModules(hProcess,ModuleArr[0],256,sz1);
        SetLength(s,256);
        //FillChar(s,256,0);
        sz1:=GetModuleBaseNameA(hProcess,ModuleArr[0],@s[1],256);
        SetLength(s,sz1);
        if s='' Then Continue;
        inst:=PLV.Items.Add;
        inst.Caption:=IntToStr(ProcessArr[i]);
        inst.SubItems.Add(s);
        GetModuleInformation(hProcess,ModuleArr[0],mi,sz1);
        inst.SubItems.Add(IntToHex(mi.SizeOfImage,8));
        inst.SubItems.Add(IntToHex(LongInt(mi.EntryPoint),8));
        inst.SubItems.Add(IntToHex(LongInt(mi.lpBaseOfDll),8));
        CloseHandle(hProcess);
      End;
   Finally
     PLV.Items.EndUpdate;
   End;
end;

procedure TForm1.PLVChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
var ProcessArr, ModuleArr : Array of Cardinal;
    sz,sz1,sz2,i, SectionCount : Cardinal;
    hProcess, hThread : THandle;
    s : String;
    inst : TListItem;
    mi : MODULEINFO;
    buff : TSectionArray;
    peHdrOffset : DWORD;
    ntHdr : IMAGE_NT_HEADERS;
    context : _CONTEXT;
    PEFile : ThePEFile;
    PEHEader : TPEHeader;
    TmpStrm : TMemoryStream;
    b : Array of Byte;
begin
  If PLV.Selected=nil Then Exit;
  MLV.Items.BeginUpdate;
  SLV.Items.BeginUpdate;
  Try
  MLV.Items.Clear;
  hProcess:=OpenProcess(PROCESS_ALL_ACCESS,False,StrToInt(PLV.Selected.Caption));
  SetLength(ModuleArr,256);
  If Not EnumProcessModules(hProcess,ModuleArr[0],256,sz) Then Exit;
  For i:=0 To sz Do
    Begin
      If ModuleArr[i]=0 Then Continue;
      inst:=MLV.Items.Add;
      inst.Caption:=IntToHex(ModuleArr[i],8);
      GetModuleInformation(hProcess,ModuleArr[i],mi,sz1);
      SetLength(s,256);
      sz1:=GetModuleBaseNameA(hProcess,ModuleArr[i],@s[1],256);
      SetLength(s,sz1);
      inst.SubItems.Add(s);
      inst.SubItems.Add(IntToHex(mi.SizeOfImage,8));
      inst.SubItems.Add(IntToHex(LongInt(mi.lpBaseOfDll),8));
      inst.SubItems.Add(IntToHex(LongInt(mi.EntryPoint),8));
    End;

  //hProcess:=OpenProcess(PROCESS_ALL_ACCESS,False,StrToInt(PLV.Selected.Caption));
  GetModuleInformation(hProcess,ModuleArr[0],mi,sz);
  EnumSections(hProcess,mi.lpBaseOfDll,buff,SectionCount);
  SLV.Items.Clear;
  For i:=1 To SectionCount Do
    Begin
      inst:=SLV.Items.Add;
      inst.Caption:=StrPas(@buff[i].Name[0]);
      inst.SubItems.Add(IntToHex(buff[i].VirtualAddress,8));
      inst.SubItems.Add(IntToHex(buff[i].Misc.VirtualSize,8));
      inst.SubItems.Add(IntToHex(buff[i].Misc.PhysicalAddress,8));
      inst.SubItems.Add(IntToHex(buff[i].PointerToRawData,8));
      inst.SubItems.Add(IntToHex(buff[i].SizeOfRawData,8));

    End;

  Finally
    MLV.Items.EndUpdate;
    SLV.Items.EndUpdate;
  End;

    // Read in the offset of the PE header
    if ( not ReadProcessMemory(hProcess,
                            Pointer(LongInt(mi.lpBaseOfDll)+$3C),
                            @peHdrOffset,
                            sizeof(peHdrOffset),
                            sz)) then exit;

    // Read in the IMAGE_NT_HEADERS.OptionalHeader.BaseOfCode field
    if ( not ReadProcessMemory(hProcess,
                            Pointer(LongInt(mi.lpBaseOfDll) + peHdrOffset),
                            @ntHdr, sizeof(ntHdr), sz)) then exit;

   boclbl.Caption:=IntToHex(ntHdr.OptionalHeader.BaseOfCode,8);
   soclbl.Caption:=IntToHex(ntHdr.OptionalHeader.SizeOfCode,8);
   bodlbl.Caption:=IntToHex(ntHdr.OptionalHeader.BaseOfData,8);
   soidlbl.Caption:=IntToHex(ntHdr.OptionalHeader.SizeOfInitializedData,8);
   soudlbl.Caption:=IntToHex(ntHdr.OptionalHeader.SizeOfUninitializedData,8);
   soiLbl.Caption:=IntToHex(ntHdr.OptionalHeader.SizeOfImage,8);
   sohlbl.Caption:=IntToHex(ntHdr.OptionalHeader.SizeOfHeaders,8);
   salbl.Caption:=IntToHex(ntHdr.OptionalHeader.SectionAlignment,8);

   // Export Data
   etrlbl.Caption:=IntToHex(ntHdr.OptionalHeader.DataDirectory[0].VirtualAddress,8);
   etslbl.Caption:=IntToHex(ntHdr.OptionalHeader.DataDirectory[0].Size,8);
   // Import Data
   itrlbl.Caption:=IntToHex(ntHdr.OptionalHeader.DataDirectory[1].VirtualAddress,8);
   itslbl.Caption:=IntToHex(ntHdr.OptionalHeader.DataDirectory[1].Size,8);
   // Resource Data
   rtrlbl.Caption:=IntToHex(ntHdr.OptionalHeader.DataDirectory[2].VirtualAddress,8);
   rtslbl.Caption:=IntToHex(ntHdr.OptionalHeader.DataDirectory[2].Size,8);
   // Fixup Data
   ttrlbl.Caption:=IntToHex(ntHdr.OptionalHeader.DataDirectory[9].VirtualAddress,8);
   ttslbl.Caption:=IntToHex(ntHdr.OptionalHeader.DataDirectory[9].Size,8);

   // Fixup Data
   //rlbl.Caption:=IntToHex(ntHdr.OptionalHeader.DataDirectory[12].VirtualAddress,8);
   //slbl.Caption:=IntToHex(ntHdr.OptionalHeader.DataDirectory[12].Size,8);

 {  DebugActiveProcess(PLV.Selected.Caption)
   SuspendThread(hThread);
   context.ContextFlags:=CONTEXT_CONTROL;
   GetThreadContext(hThread,context);
   ResumeThread(hThread);

   EIPLbl.Caption:=IntToHex(context.Eip,8);}

 { GetModuleInformation(hProcess,ModuleArr[0],mi,sz1);
  EnumSections(hProcess,mi.lpBaseOfDll,buff,sz);
  For i:=1 To sz Do
    Begin
      s:=StrPas(@buff[i].Name[0]);
      ShowMessage(s)
    End;}
  CloseHandle(hProcess);
end;

procedure TForm1.Button2Click(Sender: TObject);
Var MemStr : TMemoryStream;
    ProcessArr, ModuleArr : Array of Cardinal;
    sz,sz1,sz2,i, iSection, SectionCount, CurrSecPos, CurrSecSize : Cardinal;
    hProcess : THandle;
    s : String;
    inst : TListItem;
    mi : MODULEINFO;
    buff : TSectionArray;
    b : array [0..255] of Byte;
    sections : Array of TPEObject;
    dw, PE_HED_SIZE, PE_HED_OFFS, FIRST_SECTION : DWORD;
    OBJ_NUM : WORD;
    ntHdr : IMAGE_NT_HEADERS;
    bt : Byte;
begin
  If PLV.Selected=nil Then Exit;
  Try
    hProcess:=OpenProcess(PROCESS_ALL_ACCESS,False,StrToInt(PLV.Selected.Caption));
    SetLength(ModuleArr,256);
    //FillChar(ModuleArr,256,0);
    If Not EnumProcessModules(hProcess,ModuleArr[0],256,sz) Then Exit;
    GetModuleInformation(hProcess,ModuleArr[0],mi,sz1);
    MemStr:=TMemoryStream.Create;

    //FillChar(buff,)
    EnumSections(hProcess,mi.lpBaseOfDll,buff,SectionCount);
    SetLength(sections,SectionCount);

    Screen.Cursor:=crHourGlass;
    PB.Position:=0;
    PB.Max:=mi.SizeOfImage;
    Application.ProcessMessages;

    // Reads PE Header Offset
    ReadProcessMemory(hProcess,Pointer(LongInt(mi.lpBaseOfDll)+$3C), @PE_HED_OFFS, 4, sz);
    // Reads Object Number
    ReadProcessMemory(hProcess,Pointer(LongInt(mi.lpBaseOfDll)+PE_HED_OFFS+$6), @OBJ_NUM, 2, sz);
    // Read in the IMAGE_NT_HEADERS
    ReadProcessMemory(hProcess, Pointer(LongInt(mi.lpBaseOfDll) + PE_HED_OFFS), @ntHdr, sizeof(ntHdr), sz);

    PE_HED_SIZE:=PE_HED_OFFS+OBJ_NUM*$28;
    FIRST_SECTION:=ntHdr.OptionalHeader.FileAlignment*((PE_HED_SIZE div ntHdr.OptionalHeader.FileAlignment)+1);
    Try
      i:=0;
      // Dumping The PE Header
      Repeat
        ReadProcessMemory(hProcess,
                          Pointer(LongInt(mi.lpBaseOfDll)+i),
                          @b[0],
                          256,
                          sz);
        MemStr.WriteBuffer(b,256);
        Inc(i,256);
      Until i>=PE_HED_SIZE;

      bt:=0;
      While i<FIRST_SECTION Do
        Begin
          Inc(i);
          MemStr.WriteBuffer(bt,1);
        End;

      CurrSecPos:=0;
      iSection:=0;
      // Dumping Sections
      Repeat
        Repeat
          Inc(iSection);
          sections[iSection].RVA:=buff[iSection].VirtualAddress;
          sections[iSection].PHYSICAL_OFFSET:=MemStr.Position;
          sections[iSection].VIRTUAL_SIZE:=buff[iSection].Misc.VirtualSize;
          sections[iSection].PHYSICAL_SIZE:=buff[iSection].SizeOfRawData;
          If iSection>SectionCount Then Break;
        Until buff[iSection].SizeOfRawData<>0;
        If iSection>SectionCount Then Break;
        CurrSecPos:=buff[iSection].VirtualAddress;
        CurrSecSize:=buff[iSection].SizeOfRawData;
        //mi.lpBaseOfDll:=Pointer($400000);
        i:=0;
        Repeat
          ReadProcessMemory(hProcess,
                            Pointer(LongInt(mi.lpBaseOfDll)+CurrSecPos+i),
                            @b[0],
                            256,
                            sz);
          MemStr.WriteBuffer(b,256);
          Inc(i,256);
          If (i mod 1000) = 0 then
            begin
              PB.Position:=MemStr.Position;
              PB.Update;
              Application.ProcessMessages;
            end;
        Until i>=CurrSecSize;
      Until iSection>SectionCount;


      // Correcting Sections
     Application.ProcessMessages;
     MemStr.Seek($3C,soFromBeginning);
     MemStr.ReadBuffer(CurrSecPos,4);
     for i:=1 to 8 do
       begin
         MemStr.Seek((i-1)*$28+$F8+CurrSecPos,soFromBeginning);
         FillChar(b,8,0);
         Case i of
           1: begin b[0]:=$43; b[1]:=$4F; b[2]:=$44; b[3]:=$45; end;
           2: begin b[0]:=$44; b[1]:=$41; b[2]:=$54; b[3]:=$41; end;
           3: begin b[0]:=$42; b[1]:=$53; b[2]:=$53; end;
           4: begin b[0]:=$2E; b[1]:=$69; b[2]:=$64; b[3]:=$61; b[4]:=$74; b[5]:=$61; end;
           5: begin b[0]:=$74; b[1]:=$6C; b[2]:=$73; end;
           6: begin b[0]:=$2E; b[1]:=$72; b[2]:=$64; b[3]:=$61; b[4]:=$74; b[5]:=$61; end;
           7: begin b[0]:=$2E; b[1]:=$72; b[2]:=$65; b[3]:=$6C; b[4]:=$6F; b[5]:=$63; end;
           8: begin b[0]:=$2E; b[1]:=$72; b[2]:=$73; b[3]:=$72; b[4]:=$63; end;
         End;
         MemStr.WriteBuffer(b[0],8);
         dw:=sections[i].VIRTUAL_SIZE;
         MemStr.WriteBuffer(dw,4);
         dw:=sections[i].RVA;
         MemStr.WriteBuffer(dw,4);
         dw:=sections[i].PHYSICAL_SIZE;
         MemStr.WriteBuffer(dw,4);
         dw:=sections[i].PHYSICAL_OFFSET;
         MemStr.WriteBuffer(dw,4);
       end;

       If SaveDlg.Execute Then
           MemStr.SaveToFile(SaveDlg.FileName);
    Finally
      CloseHandle(hProcess);
      Screen.Cursor:=crDefault;
      PB.Position:=0;
      MemStr.Free;
    End;
  Except
    ShowMessage('Dumper Failed !');
  End;
end;

procedure TForm1.MLVClick(Sender: TObject);
var hProcess : THandle;
    mi : MODULEINFO;
    buff : TSectionArray;
    sz,SectionCount,i : Cardinal;
    inst : TListItem;
begin
  If PLV.Selected=nil Then Exit;
  If MLV.Selected=nil Then Exit;
  hProcess:=OpenProcess(PROCESS_ALL_ACCESS,False,StrToInt(PLV.Selected.Caption));
  GetModuleInformation(hProcess,StrToInt(MLV.Selected.Caption),mi,sz);
  EnumSections(hProcess,mi.lpBaseOfDll,buff,SectionCount);
  SLV.Items.Clear;
  For i:=1 To SectionCount Do
    Begin
      inst:=SLV.Items.Add;
      inst.Caption:=StrPas(@buff[i].Name[0]);
      inst.SubItems.Add(IntToHex(buff[i].VirtualAddress,8));
      inst.SubItems.Add(IntToHex(buff[i].Misc.VirtualSize,8));
      inst.SubItems.Add(IntToHex(buff[i].Misc.PhysicalAddress,8));
      inst.SubItems.Add(IntToHex(buff[i].PointerToRawData,8));
      inst.SubItems.Add(IntToHex(buff[i].SizeOfRawData,8));

    End;
end;

procedure TForm1.Button3Click(Sender: TObject);
var StrList : TStringList;
    i : Integer;
    s : String;
begin
  If PLV.Selected=nil Then Exit;
  StrList:=TStringList.Create;
  Try
    StrList.Add('process: '+PLV.Selected.SubItems[0]);
    StrList.Add('');
    StrList.Add(Format('BOC: %s SOC: %s BOD: %s SOD: %s S0I: %s SOH: %s',[bocLbl.Caption,socLbl.Caption,bodLbl.Caption,soidLbl.Caption, soiLbl.Caption, sohLbl.Caption]));
    StrList.Add(Format('ETR: %s ETS: %s ITR: %s ITS: %s RTR: %s RTS: %s',[etrLbl.Caption, etsLbl.Caption, itrLbl.Caption, itsLbl.Caption, rtrLbl.Caption, rtsLbl.Caption]));
    StrList.Add(Format('TTR: %s TTS: %s ',[ttrLbl.Caption, ttsLbl.Caption]));
    StrList.Add('');
    StrList.Add('            RVA       VS      PhD       RD       RS');
    For i:=0 To SLV.Items.Count-1 Do
     Begin
      s:=SLV.Items[i].Caption;
      while length(s)<8 Do s:=s+' ';
      StrList.Add(Format('%s  %s %s %s %s %s',[s, SLV.Items[i].SubItems[0], SLV.Items[i].SubItems[1], SLV.Items[i].SubItems[2], SLV.Items[i].SubItems[3], SLV.Items[i].SubItems[4]]));
     end;
    If SaveDlg.Execute
      Then StrList.SaveToFile(SaveDlg.FileName);
  Finally
    StrList.Free;
  End;

end;

procedure TForm1.Button4Click(Sender: TObject);
Var MemStr : TMemoryStream;
begin
  If PLV.Selected=nil Then Exit;
  MemStr:=TMemoryStream.Create;
  Try
    DumpProcess(StrToInt(PLV.Selected.Caption),MemStr);
    If SaveDlg.Execute Then
      MemStr.SaveToFile(SaveDlg.FileName);
  Finally
    MemStr.Free;
  End;
end;

procedure TForm1.Button5Click(Sender: TObject);
var hProcess : THandle;
begin
  If PLV.Selected=nil Then Exit;
  hProcess:=OpenProcess(PROCESS_ALL_ACCESS,False,StrToInt(PLV.Selected.Caption));
  ShowMessage(PLV.Selected.Caption+':'+IntToHex(hProcess,8));
  CloseHandle(hProcess);
end;

procedure TForm1.Button6Click(Sender: TObject);
var ctid, cpid, tid, dw : DWORD;
    sz : cardinal;
    con : _CONTEXT;
begin
  // GetLastError
  asm
    push eax
    // eax contains pointer to TIB database
    MOV EAX, FS:[$18]
    // +$34 from TIB
    MOV EAX, [EAX+$34]
    mov tid, eax
    pop eax
  end;
  showmessage('GLE: '+IntToHex(tid,8));
  asm
     // eax contains pointer to TIB database
     MOV EAX, tid
     MOV EDX, FS:[$04]
     LEA EDX, [EAX]
     POP EBX
     MOV tid, ebx
  end;
   showmessage('POP:'+IntToHex(tid,8));
  //showmessage('FS:[$34]:'+IntToHex(tid,8));
  readprocessmemory(GetCurrentProcess,Pointer(tid),@dw,2,sz);
  showmessage('PDB Pointer:'+IntToHex(dw,2));

  //ctid:=GetCurrentThreadID;
  //tid:=ctid xor tid;
  //showmessage('TID Pointer:'+IntToHex(tid,8));
  //cpid:=GetCurrentProcessID;
  //tid:=cpid xor tid;

{  readprocessmemory(GetCurrentProcess,Pointer(tid+$20),@dw,4,sz);
  showmessage('PDB Flags:'+IntToHex(dw,8));

  readprocessmemory(GetCurrentProcess,Pointer(tid+$2c),@dw,4,sz);
  showmessage('PDB Threads:'+IntToHex(dw,8));}

end;

end.
