unit DeDeMemDumps;
{$A+,B-,C+,D+,E-,F-,G+,H+,I+,J+,K-,L+,M-,N+,O+,P+,Q-,R-,S-,T-,U-,V+,W-,X+,Y+,Z1}

{$MINSTACKSIZE $00004000}

{$MAXSTACKSIZE $00100000}

{$IMAGEBASE $00400000}

{$APPTYPE GUI}

interface

uses Windows, Classes;


Type MODULEINFO = Record
       lpBaseOfDll : Pointer;
       SizeOfImage : DWORD ;
       EntryPoint : Pointer;
     end;

Type TEnumProcesses = Function (var buffer; cb : DWORD;  var cbNeeded : DWORD): Boolean;  stdcall;
     TEnumProcessModules = Function (hProcess : THandle; var buffer; cb : DWORD; var lpcbNeeded : DWORD) : Boolean; stdcall;
     TGetModuleBaseNameA = Function (hProcess : THandle; hModule : HMODULE; lpFilename : Pointer; nsize : DWORD) : DWORD; stdcall;
     TGetModuleInformation = function (hProcess : THandle; HMODULE : hModule; var lpmodinfo : MODULEINFO; cb : DWORD) : Boolean; stdcall;


Var  EnumProcesses : TEnumProcesses;
     EnumProcessModules : TEnumProcessModules;
     GetModuleBaseNameA : TGetModuleBaseNameA;
     GetModuleInformation : TGetModuleInformation;


var IsWin9x : Boolean;

Type PIMAGE_SECTION_HEADER = ^IMAGE_SECTION_HEADER;
     TSectionArray  = Array [0..64] of IMAGE_SECTION_HEADER;


Procedure EnumSections(hProcess : THandle; PProcessBase : Pointer; Var buffer : TSectionArray ; var Secnum : Cardinal);
Procedure DumpProcess(PID : DWORD; var MemStr : TMemoryStream; var BoC, PoC, ImB : DWORD);

Function MemGetDelphiVersionOfAProcess(PID : Int64) : DWORD;
Function MemGetDelphiVersion(MemStr : TMemoryStream; ImageBase, CodeRVA, CodeSize, HeaderSize : DWORD) : DWORD;
procedure SaveProcessInformation(PID : DWORD; AsFileName : String);

function GetRVAEntryPoint(MemStr : TMemoryStream; IMB, BOC, SOC : DWORD; DelphiVersion : Integer; bShowWarning : Boolean = true) : DWORD;


implementation

uses DeDeClasses, SysUtils, Dialogs, tlhelp32, DeDeSym, HEXTools, DeDeConstants, DeDeRES;

Procedure EnumSections(hProcess : THandle; PProcessBase : Pointer; Var buffer : TSectionArray; var Secnum : Cardinal);
var peHdrOffset : DWORD;
    cBytesMoved : DWORD;
    ntHdr : IMAGE_NT_HEADERS;
    pSection : PIMAGE_SECTION_HEADER;
    section : IMAGE_SECTION_HEADER;
    i : Shortint;
Begin
    // Read in the offset of the PE header
    if ( not ReadProcessMemory(hProcess,
                            Pointer(LongInt(PProcessBase)+$3C),
                            @peHdrOffset,
                            sizeof(peHdrOffset),
                            cBytesMoved)) then exit;

    // Read in the IMAGE_NT_HEADERS.OptionalHeader.BaseOfCode field
    if ( not ReadProcessMemory(hProcess,
                            Pointer(LongInt(PProcessBase) + peHdrOffset),
                            @ntHdr, sizeof(ntHdr), cBytesMoved)) then exit;


    pSection := Pointer(LongInt(PProcessBase)+peHdrOffset+4
                + sizeof(ntHdr.FileHeader)
                + ntHdr.FileHeader.SizeOfOptionalHeader);

    FillChar(section,0,sizeof(section));
    Secnum:=ntHdr.FileHeader.NumberOfSections;
    for i:=1 to ntHdr.FileHeader.NumberOfSections do
      Begin
        if ( not ReadProcessMemory(hProcess,
                                 Pointer(DWORD(pSection)+(i-1)*40),
                                 @section, 40,
                                 cBytesMoved)) then exit;
          buffer[i]:=section;
     End;
end;

procedure LinkPSAPI;
var hMdl : HMODULE;
begin
 If   ((GetVersion and $F0000000)=0)
   or ((GetVersion and $0000000F)=5) Then
    Begin
       hMdl:=LoadLibrary('PSAPI.DLL');
       @EnumProcesses:=GetProcAddress(hMdl,PChar('EnumProcesses'));
       @EnumProcessModules:=GetProcAddress(hMdl,PChar('EnumProcessModules'));
       @GetModuleBaseNameA:=GetProcAddress(hMdl,PChar('GetModuleBaseNameA'));
       @GetModuleInformation:=GetProcAddress(hMdl,PChar('GetModuleInformation'));
    End;
end;


procedure LinkToolHelp32;
var hMdl : HMODULE;
    err  : Cardinal;
    p : Pointer;
begin
 If IsWin9x Then
    Begin
    End;
end;

Function MemGetDelphiVersion(MemStr : TMemoryStream; ImageBase, CodeRVA, CodeSize, HeaderSize : DWORD) : DWORD;
const IDS = 'TControl';
      arrBoolean : Array [0..7] of byte = ($07,$42,$6F,$6F,$6C,$65,$61,$6E);
var b1, b2 : Byte;
    dw, dw1, bkup, Delta, i : DWORD;
    s : String;
    buff : Array of Byte;
    bD2, bClassFound : Boolean;

    function InCODE(DW : DWORD) : boolean;
    begin
     result:=(dw>ImageBase+(CodeRVA)) and (dw<ImageBase+(CodeRVA)+CodeSize)
    end;

begin
  Result:=$FFFE;
  bD2:=False;
  Delta:=ImageBase+CodeRVA-HeaderSize;

  MemStr.Seek(HeaderSize+5,soFromBeginning);
  //MemStr.Seek(HeaderSize+1,soFromBeginning); FOR Delphi 2
  SetLength(buff,9);
  MemStr.ReadBuffer(buff[0],9);
  If Not CompareMem(@buff[0],@arrBoolean[0],8)
    Then begin
      // Check For Delphi 2
      MemStr.Seek(HeaderSize+1,soFromBeginning);
      SetLength(buff,9);
      MemStr.ReadBuffer(buff[0],9);
      If Not CompareMem(@buff[0],@arrBoolean[0],8)
        Then bD2:=False
        Else bD2:=True;
    end;
  if bD2 then Result:=$FFF0
         else Result:=$FFFF;


  MemStr.Seek(HeaderSize,soFromBeginning);
  Repeat
    MemStr.ReadBuffer(dw,4);
    bkup:=MemStr.Position;
    bClassFound:=dw-Delta=MemStr.Position;

    If bClassFound Then
      Begin
        MemStr.ReadBuffer(b1,1);
        if b1<=16 Then
         begin
            //Nasty anti-tirck for nasty dump-hide trick
            if CodeSize=0 then CodeSize:=$7F000000;
            MemStr.ReadBuffer(b2,1);
            SetLength(s,b2);
            MemStr.ReadBuffer(s[1],b2);
            MemStr.ReadBuffer(dw,4);
            If InCODE(dw) then
              begin
               dw1:=dw-Delta;
               MemStr.Seek(dw1-40,soFromBeginning);
               MemStr.ReadBuffer(dw,4);
               If s=IDS then begin
                 Result:=dw;
                 exit;
               end;
              end;
          end;
       end;
       MemStr.seek(bkup,soFromBeginning);
  Until (MemStr.Position>=CodeSize);

{  MemStr.Seek(CodeRVA+5,soFromBeginning);
  SetLength(s,3);
  MemStr.ReadBuffer(s[1],3);

  // Correction for BCB5
  if s='C++' then if dw=$120 then Result:=$121;
}

//  $0    : 'D3';
//  $B4   : 'BCB4'
//  $114  : 'D4';
//  $120  : 'D5';
//  $121  : 'BCB5';
//  $15C, $160 : D6
//  $FFFF : 'Unknown';
//  $FFF0 : 'D2'
end;


Function MemGetDelphiVersionOfAProcess(PID : Int64) : DWORD;
var hProcess : THandle;
    ModuleArr : Array of Cardinal;
    mi : MODULEINFO;
    ntHdr : IMAGE_NT_HEADERS;
    peHdrOffset, SOC, sz : DWORD;
    sections : TSectionArray;
    MemStr : TMemoryStream;
    buff : Array of Byte;
    hSnapShot : THandle;
    lppe : PROCESSENTRY32;
    m : MODULEENTRY32;
Begin
    hProcess:=OpenProcess(PROCESS_ALL_ACCESS,False,PID);
    MemStr:=TMemoryStream.Create;
    mi.lpBaseOfDll:=nil;
    Try
      If IsWin9x Then
        Begin
           hSnapShot:=CreateToolhelp32Snapshot(TH32CS_SNAPALL, PID);
           If hSnapShot<>INVALID_HANDLE_VALUE Then
            Begin
             Fillchar(lppe.szExeFile,259,0);
             m.dwSize:=SizeOf(MODULEENTRY32);
             lppe.dwSize:=SizeOf(PROCESSENTRY32);
             Process32First(hSnapShot,lppe);
             Module32First(hSnapShot,m);

             While Process32Next(hSnapShot,lppe) do
              begin
                Module32Next(hSnapShot,m);
                if lppe.th32ProcessID=PID
                   then begin
                     mi.lpBaseOfDll:=Pointer(m.modBaseAddr);
                     mi.lpBaseOfDll:=Pointer($400000);
                     break;
                   end;
              end;

             CloseHandle(hSnapShot);
            End;

         If mi.lpBaseOfDll=nil Then Exit; 
        End
        Else Begin
          SetLength(ModuleArr,256);
          EnumProcessModules(hProcess,ModuleArr[0],256,sz);
          GetModuleInformation(hProcess,ModuleArr[0],mi,sz);
        End;  

      ReadProcessMemory(hProcess,Pointer(LongInt(mi.lpBaseOfDll)+$3C),@peHdrOffset, sizeof(peHdrOffset),sz);
      ReadProcessMemory(hProcess,Pointer(LongInt(mi.lpBaseOfDll) + peHdrOffset),@ntHdr, sizeof(ntHdr), sz);

      EnumSections(hProcess,mi.lpBaseOfDll,sections,sz);

      // Dump Header
      SetLength(buff,ntHdr.OptionalHeader.SizeOfHeaders);
      ReadProcessMemory(hProcess,mi.lpBaseOfDll,@buff[0],ntHdr.OptionalHeader.SizeOfHeaders,sz);
      MemStr.WriteBuffer(buff[0],ntHdr.OptionalHeader.SizeOfHeaders);
            
      if ntHdr.OptionalHeader.SizeOfCode<sections[1].Misc.VirtualSize
         then SOC:=sections[1].Misc.VirtualSize
         else SOC:=ntHdr.OptionalHeader.SizeOfCode;

      // Dump Code
      SetLength(buff,SOC);
      ReadProcessMemory(hProcess,Pointer(LongInt(mi.lpBaseOfDll)+ntHdr.OptionalHeader.BaseOfCode),@buff[0],SOC,sz);
      MemStr.WriteBuffer(buff[0],SOC);

      Result:=MemGetDelphiVersion(MemStr,ntHdr.OptionalHeader.ImageBase,ntHdr.OptionalHeader.BaseOfCode,ntHdr.OptionalHeader.SizeOfCode,ntHdr.OptionalHeader.SizeOfHeaders);
    Finally
      CloseHandle(hProcess);
      MemStr.Free;
    End
End;

Procedure DumpProcess(PID : DWORD; var MemStr : TMemoryStream; var BoC, PoC, ImB : DWORD);
var hProcess : THandle;
    ModuleArr : Array of Cardinal;
    sz : Cardinal;
    ntHdr : IMAGE_NT_HEADERS;
    mi : MODULEINFO;
    peHdrOffset, SOC : DWORD;
    buff : Array of Byte;
    i : Integer;
    dw, ResPhys : DWORD;
    Objects : Array [1..8] of TPEObject;
    sections : TSectionArray;
    b : array [0..7] of Byte;
    SecNum : Word;
    s : String;
    dw1,{dw2,dw3,dw4,dw5,dw6,dw7,dw8,} PEP : DWORD;
    hSnapShot : THandle;
    lppe : tlhelp32.PROCESSENTRY32;
    m : tlhelp32.tagMODULEENTRY32;
    DVer : Integer;
Begin
    hProcess:=OpenProcess(PROCESS_ALL_ACCESS,False,PID);
    Try
     mi.lpBaseOfDll:=nil;

     if isWin9x then
      begin
       hSnapShot:=CreateToolhelp32Snapshot(TH32CS_SNAPALL, GetCurrentProcessID);
       If hSnapShot<>INVALID_HANDLE_VALUE Then
        Begin
         lppe.dwSize:=sizeof(PROCESSENTRY32);
         Fillchar(lppe.szExeFile,259,0);
         Process32First(hSnapShot,lppe);
         Module32First(hSnapShot,m);

         While Process32Next(hSnapShot,lppe) Do
           Begin
             Module32Next(hSnapShot,m);
             if lppe.th32ProcessID=PID then
                begin
                   mi.lpBaseOfDll:=Pointer(m.modBaseAddr);
                   mi.lpBaseOfDll:=Pointer($400000);
                   Break;
                end;
           end;
        end;
        CloseHandle(hSnapShot);
      end
      else begin
        SetLength(ModuleArr,256);
        EnumProcessModules(hProcess,ModuleArr[0],256,sz);
        GetModuleInformation(hProcess,ModuleArr[0],mi,sz);
      end;

      if mi.lpBaseOfDll=nil Then Raise Exception.Create(err_invalid_process);

      ReadProcessMemory(hProcess,Pointer(LongInt(mi.lpBaseOfDll)+$3C),@peHdrOffset, sizeof(peHdrOffset),sz);
      ReadProcessMemory(hProcess,Pointer(LongInt(mi.lpBaseOfDll) + peHdrOffset),@ntHdr, sizeof(ntHdr), sz);

      EnumSections(hProcess,mi.lpBaseOfDll,sections,sz);
      MemStr.Clear;

      // UPX Check
      s:=StrPas(@sections[1].Name[0]);
      If s='UPX0' Then
         If MessageDlg(wrn_upx,mtWarning,[mbYes,mbNo],0)=idNo Then Exit;

      // NeoLite Check
      s:=StrPas(@sections[sz].Name[0]);
      If s='.neolit' Then
         If MessageDlg(wrn_neolit,mtWarning,[mbYes,mbNo],0)=idNo Then Exit;

      // Dump Header
      SetLength(buff,ntHdr.OptionalHeader.SizeOfHeaders);
      ReadProcessMemory(hProcess,mi.lpBaseOfDll,@buff[0],ntHdr.OptionalHeader.SizeOfHeaders,sz);
      MemStr.WriteBuffer(buff[0],ntHdr.OptionalHeader.SizeOfHeaders);

      if ntHdr.OptionalHeader.SizeOfCode<sections[1].Misc.VirtualSize
         then SOC:=sections[1].Misc.VirtualSize
         else SOC:=ntHdr.OptionalHeader.SizeOfCode;

      // Dump Code
      SetLength(buff,SOC);
      ReadProcessMemory(hProcess,Pointer(LongInt(mi.lpBaseOfDll)+ntHdr.OptionalHeader.BaseOfCode),@buff[0],SOC,sz);
      MemStr.WriteBuffer(buff[0],SOC);

      // Finds The Program Entry Point
      dw1:=MemGetDelphiVersion(MemStr,ntHdr.OptionalHeader.ImageBase,ntHdr.OptionalHeader.BaseOfCode,ntHdr.OptionalHeader.SizeOfCode,ntHdr.OptionalHeader.SizeOfHeaders);
      Case dw1 of
        $FFF0 : DVer:=2;
           0  : DVer:=3;
        $114  : DVer:=4;
        $120  : DVer:=5;
        $15C  : DVer:=6;
      end;
      dw1:=GetRVAEntryPoint(MemStr,$400000,0,0,DVer,false);
      PEP:=dw1+ntHdr.OptionalHeader.BaseOfCode-ntHdr.OptionalHeader.SizeOfHeaders;

      MemStr.Seek(0,soFromEnd);
      // Dump Resources
      SetLength(buff,ntHdr.OptionalHeader.DataDirectory[2].Size);
      ReadProcessMemory(hProcess,Pointer(LongInt(mi.lpBaseOfDll)+ntHdr.OptionalHeader.DataDirectory[2].VirtualAddress),@buff[0],ntHdr.OptionalHeader.DataDirectory[2].Size,sz);
      ResPhys:=MemStr.Size;
      MemStr.WriteBuffer(buff[0],ntHdr.OptionalHeader.DataDirectory[2].Size);


      // Correct PEHeader

      // CODE Section Data
      Objects[1].RVA:=ntHdr.OptionalHeader.BaseOfCode;
      Objects[1].VIRTUAL_SIZE:=SOC;
      Objects[1].PHYSICAL_SIZE:=SOC;
      Objects[1].PHYSICAL_OFFSET:=ntHdr.OptionalHeader.SizeOfHeaders;

      //Return the base of code and physical offset for for corrections
      BoC:=Objects[1].RVA;
      PoC:=Objects[1].PHYSICAL_OFFSET;
      ImB:=ntHdr.OptionalHeader.ImageBase;

      // .idata Section Data (No Import references with packed executables)
      Objects[4].RVA:=0;
      Objects[4].VIRTUAL_SIZE:=0;
      Objects[4].PHYSICAL_SIZE:=0;
      Objects[4].PHYSICAL_OFFSET:=0;

      // .rsrc Section Data
      Objects[8].RVA:=ntHdr.OptionalHeader.SizeOfHeaders;
      Objects[8].VIRTUAL_SIZE:=ntHdr.OptionalHeader.DataDirectory[2].Size;
      Objects[8].PHYSICAL_SIZE:=ntHdr.OptionalHeader.DataDirectory[2].Size;
      Objects[8].PHYSICAL_OFFSET:=ResPhys;

      // Setting Flags
      Objects[1].FLAGS:=$60000020;
      Objects[2].FLAGS:=$C0000040;
      Objects[3].FLAGS:=$C0000000;
      Objects[4].FLAGS:=$C0000040;
      Objects[5].FLAGS:=$C0000000;
      Objects[6].FLAGS:=$50000040;
      Objects[7].FLAGS:=$50000040;
      Objects[8].FLAGS:=$50000040;

      // Setting object number to 8
      MemStr.Seek($06+peHdrOffset,soFromBeginning);
      SecNum:=8;
      MemStr.WriteBuffer(SecNum,2);
      
      // Setting Program Entry Point
      MemStr.Seek($28+peHdrOffset,soFromBeginning);
      MemStr.WriteBuffer(PEP,4);


      // Setting objects data
      For i:=1 To 8 Do
        Begin
           // Goto to the begining of a section record in PE HEader
           MemStr.Seek((i-1)*$28+$F8+peHdrOffset,soFromBeginning);

           // Change Section Names
           FillChar(b,8,0);
           Case i of
             1: begin b[0]:=$43; b[1]:=$4F; b[2]:=$44; b[3]:=$45; end;                       {CODE}
             2: begin b[0]:=$44; b[1]:=$41; b[2]:=$54; b[3]:=$41; end;                       {DATA}
             3: begin b[0]:=$42; b[1]:=$53; b[2]:=$53; end;                                  {BSS}
             4: begin b[0]:=$2E; b[1]:=$69; b[2]:=$64; b[3]:=$61; b[4]:=$74; b[5]:=$61; end; {.idata}
             5: begin b[0]:=$74; b[1]:=$6C; b[2]:=$73; end;                                  {.tls}
             6: begin b[0]:=$2E; b[1]:=$72; b[2]:=$64; b[3]:=$61; b[4]:=$74; b[5]:=$61; end; {.rdata}
             7: begin b[0]:=$2E; b[1]:=$72; b[2]:=$65; b[3]:=$6C; b[4]:=$6F; b[5]:=$63; end; {.reloc}
             8: begin b[0]:=$2E; b[1]:=$72; b[2]:=$73; b[3]:=$72; b[4]:=$63; end;            {.rsrc}
           End;
           MemStr.WriteBuffer(b[0],8);
           dw:=Objects[i].VIRTUAL_SIZE;
           MemStr.WriteBuffer(dw,4);
           dw:=Objects[i].RVA;
           MemStr.WriteBuffer(dw,4);
           dw:=Objects[i].PHYSICAL_SIZE;
           MemStr.WriteBuffer(dw,4);
           dw:=Objects[i].PHYSICAL_OFFSET;
           MemStr.WriteBuffer(dw,4);
           MemStr.Seek(12,soFromCurrent);
           dw:=Objects[i].FLAGS;
           MemStr.WriteBuffer(dw,4);
        End;
   Finally
     CloseHandle(hProcess);
   End;
End;


procedure SaveProcessInformation(PID : DWORD; AsFileName : String);
var StrList : TStringList;
    i : Integer;
    s : String;
    hProcess : THandle;
    ModuleArr : Array of Cardinal;
    sz,SectionCount : Cardinal;
    mi : MODULEINFO;
    buff : TSectionArray;
    peHdrOffset : DWORD;
    ntHdr : IMAGE_NT_HEADERS;
begin
  hProcess:=OpenProcess(PROCESS_ALL_ACCESS,False,PID);
  Try
    SetLength(ModuleArr,256);
    EnumProcessModules(hProcess,ModuleArr[0],256,sz);
    GetModuleInformation(hProcess,ModuleArr[0],mi,sz);
    EnumSections(hProcess,mi.lpBaseOfDll,buff,SectionCount);
    ReadProcessMemory(hProcess,Pointer(LongInt(mi.lpBaseOfDll)+$3C), @peHdrOffset, sizeof(peHdrOffset), sz);
    ReadProcessMemory(hProcess,Pointer(LongInt(mi.lpBaseOfDll) + peHdrOffset), @ntHdr, sizeof(ntHdr), sz);

    StrList:=TStringList.Create;

    Try
      StrList.Add(Format('BOC: %8x SOC: %8x BOD: %8x SOD: %8x S0I: %8x SOH: %8x',[
          ntHdr.OptionalHeader.BaseOfCode,
          ntHdr.OptionalHeader.SizeOfCode,
          ntHdr.OptionalHeader.BaseOfData,
          ntHdr.OptionalHeader.SizeOfInitializedData,
          ntHdr.OptionalHeader.SizeOfImage,
          ntHdr.OptionalHeader.SizeOfHeaders]));
      StrList.Add(Format('ETR: %8x ETS: %8x ITR: %8x ITS: %8x RTR: %8x RTS: %8x',[
          ntHdr.OptionalHeader.DataDirectory[0].VirtualAddress,
          ntHdr.OptionalHeader.DataDirectory[0].Size,
          ntHdr.OptionalHeader.DataDirectory[1].VirtualAddress,
          ntHdr.OptionalHeader.DataDirectory[1].Size,
          ntHdr.OptionalHeader.DataDirectory[2].VirtualAddress,
          ntHdr.OptionalHeader.DataDirectory[2].Size]));

      StrList.Add(Format('TTR: %8x TTS: %8x ',[
          ntHdr.OptionalHeader.DataDirectory[9].VirtualAddress,
          ntHdr.OptionalHeader.DataDirectory[9].Size]));
          
      StrList.Add('');
      StrList.Add('            RVA       VS      PhD       RD       RS     Flgs');
      For i:=1 To SectionCount Do
       Begin
        s:=StrPas(@buff[i].Name[0]);
        while length(s)<8 Do s:=s+' ';
        StrList.Add(Format('%s  %8x %8x %8x %8x %8x %8x',[
           s,
           buff[i].VirtualAddress,
           buff[i].Misc.VirtualSize,
           buff[i].Misc.PhysicalAddress,
           buff[i].PointerToRawData,
           buff[i].SizeOfRawData,
           buff[i].Characteristics]));
       end;

       StrList.SaveToFile(AsFileName);
    Finally
      StrList.Free;
    End;
  Finally
    CloseHandle(hProcess);
  End;
end;

// Returns the RVA entrypoint of a Delphi program
//
// MemStr is the memorystream
// BOC is the RVA of CodeBase, SOC is the Size of Code, IMB is the ImageBase
// DelphiVersion is the DelphiVersion
//
// Idea of finding RVAEntry point is that shortly after that is called InitInstance proc
// that can be recognized using DSF recognition engine. After this proc is found is searched
// of Call InitInstance. Then this can be also recognized: 
//
// 55                     push    ebp
// 8BEC                   mov     ebp, esp
// 83C4F4                 add     esp, -$0C
// 53                     push    ebx {Only some times} 
// B808324F00             mov     eax, $004F3208
// E82837F1FF             call    00406D40 ; InitInstance
//
// Finally the push ebp RVA is the Result
//
// The Result acctualy is the offset from the beggining of the dump
// the real RVA EntryPoint can be found adding:
// ImageBase+CodeBase-CodePhys (Normaly $400C00 = $401000-$400)
//
function GetRVAEntryPoint(MemStr : TMemoryStream; IMB, BOC, SOC : DWORD; DelphiVersion : Integer; bShowWarning : Boolean = true) : DWORD;
var dw, iiDW : DWORD;
    l : LongInt;
    buff : TSymBuffer;
begin
  iiDW:=0;
  Result:=0;
  For l:=0 to MemStr.Size-sizeOf(buff)-1 Do
    begin
      MemStr.Seek(l,soFromBeginning);
      MemStr.ReadBuffer(buff,sizeof(buff));

      If DelphiVersion=2 then
       begin
          If (buff[1]=$E8) and (buff[6]=$6A) and (buff[7]=$00) and (buff[8]=$E8) and (buff[13]=$89)
           then begin
              UnlinkCalls(buff);
              if CompareMem(@buff[1], @D2_Ident[1], 49) then
                begin
                  // InitInstance Procedure Found
                  iiDW:=l;
                  break;
                end;
           end;
       end; {Delphi2 Recognition}

      If DelphiVersion=3 then
       begin
          If (buff[1]=$50) and (buff[2]=$6A) and (buff[3]=$00) and (buff[4]=$E8) and (buff[9]=$BA)
           then begin
              UnlinkCalls(buff);
              if CompareMem(@buff[1], @D3_Ident[1], 49) then
                begin
                  // InitInstance Procedure Found
                  iiDW:=l;
                  break;
                end;
           end;
       end; {Delphi3 Recognition}


      If DelphiVersion in [4,5] then
       begin
          If (buff[1]=$50) and (buff[2]=$6A) and (buff[3]=$00) and (buff[4]=$E8) and (buff[9]=$BA)
           then begin
              UnlinkCalls(buff);
              if CompareMem(@buff[1], @D4_Ident[1], 49) then
                begin
                  // InitInstance Procedure Found
                  iiDW:=l;
                  break;
                end;
           end;
       end; {Delphi4,5 Recognition}

      If DelphiVersion in [6] then
       begin
          If (buff[1]=$53) and (buff[2]=$8B) and (buff[3]=$D8) and (buff[4]=$33) and (buff[13]=$E8)
           then begin
              UnlinkCalls(buff);
              if CompareMem(@buff[1], @D6_Ident[1], 49) then
                begin
                  // InitInstance Procedure Found
                  iiDW:=l;
                  break;
                end;
           end;
       end; {Delphi6 Recognition}
    end;



  if iiDW=0 then
   begin
     exit;
   end;


  // Seek the EntryPoint
  FillChar(buff,sizeOf(buff),0);
  For l:=iiDW to MemStr.Size-17 Do
   begin
      MemStr.Seek(l,soFromBeginning);
      MemStr.ReadBuffer(buff,17);


      If DelphiVersion=2 then
       begin
          If    (buff[1]=$55) and (buff[2]=$8B) and (buff[3]=$EC) and (buff[4]=$83)
            and (buff[5]=$C4) and (buff[6]=$F4) and (buff[7]=$E8)
           then begin
              dw:=iiDW-l-11;

              // Calc Relative Call to InitInstance
              RVA_Ident3[7]:=Byte(dw);
              RVA_Ident3[8]:=Byte(dw shr 8);
              RVA_Ident3[9]:=Byte(dw shr 16);
              RVA_Ident3[10]:=Byte(dw shr 24);
              if CompareMem(@buff[1], @RVA_Ident3[0], 11) then
                  begin
                    // RVAEntryPoint Found
                    Result:=l;
                    break;
                  end;
               end;
      end; {Delphi 2 RVA Entry Point Finder}

      If DelphiVersion in [3,4,5,6] then
       begin
          If (buff[1]=$55) and (buff[2]=$8B) and (buff[3]=$EC) and (buff[4]=$83)
            and (((buff[7]=$B8) and (buff[12]=$E8)) or (((buff[8]=$B8) and (buff[13]=$E8))))
           then begin
              dw:=iiDW-l-16;

              // Delphi 4,5
              // Manualy UnlinkCalls/Movs
              if (buff[7]=$B8) and (buff[6]=$F4) then
               begin
                buff[8]:=0;
                buff[9]:=0;
                buff[10]:=0;
                buff[11]:=0;
                // Calc Relative Call to InitInstance
                RVA_Ident1[12]:=Byte(dw);
                RVA_Ident1[13]:=Byte(dw shr 8);
                RVA_Ident1[14]:=Byte(dw shr 16);
                RVA_Ident1[15]:=Byte(dw shr 24);
                if CompareMem(@buff[1], @RVA_Ident1[0], 16) then
                  begin
                    // RVAEntryPoint Found
                    Result:=l;
                    break;
                  end;
               end;

              // Delphi 6
              // Manualy UnlinkCalls/Movs
              if (buff[7]=$B8) and (buff[6]=$F0) then
               begin
                buff[8]:=0;
                buff[9]:=0;
                buff[10]:=0;
                buff[11]:=0;
                // Calc Relative Call to InitInstance
                RVA_Ident4[12]:=Byte(dw);
                RVA_Ident4[13]:=Byte(dw shr 8);
                RVA_Ident4[14]:=Byte(dw shr 16);
                RVA_Ident4[15]:=Byte(dw shr 24);
                if CompareMem(@buff[1], @RVA_Ident4[0], 16) then
                  begin
                    // RVAEntryPoint Found
                    Result:=l;
                    break;
                  end;
               end;


              // Delphi 3
              if buff[8]=$B8 then
               begin
                buff[9]:=0;
                buff[10]:=0;
                buff[11]:=0;
                buff[12]:=0;
                // Calc Relative Call to InitInstance
                dw:=dw-1;
                RVA_Ident2[13]:=Byte(dw);
                RVA_Ident2[14]:=Byte(dw shr 8);
                RVA_Ident2[15]:=Byte(dw shr 16);
                RVA_Ident2[16]:=Byte(dw shr 24);
                if CompareMem(@buff[1], @RVA_Ident2[0], 17) then
                  begin
                    // RVAEntryPoint Found
                    Result:=l;
                    break;
                  end;
               end;

           end;
       end; {Delphi4,5,6 RVAEntryPoint Finder}
   end;

  if Result<>0 then exit;

  // Try to find the call to initinstance
  // Seek B800000000E8xxyyzztt
  RVA_Ident1[1]:=$B8;
  RVA_Ident1[2]:=0;
  RVA_Ident1[3]:=0;
  RVA_Ident1[4]:=0;
  RVA_Ident1[5]:=0;
  RVA_Ident1[6]:=$E8;
  For l:=iiDW to MemStr.Size-10 Do
   begin
      MemStr.Seek(l,soFromBeginning);
      MemStr.ReadBuffer(buff,10);

      dw:=iiDW-l-10;

      // Manualy UnlinkCalls/Movs
      if (buff[1]=$B8) and (buff[6]=$E8) then
       begin
        buff[2]:=0;
        buff[3]:=0;
        buff[4]:=0;
        buff[5]:=0;
        // Calc Relative Call to InitInstance
        RVA_Ident1[7]:=Byte(dw);
        RVA_Ident1[8]:=Byte(dw shr 8);
        RVA_Ident1[9]:=Byte(dw shr 16);
        RVA_Ident1[10]:=Byte(dw shr 24);
        if CompareMem(@buff[1], @RVA_Ident1[1], 9) then
          begin
            // RVAEntryPoint Found
            Result:=l;
            break;
          end;
       end;
   end;

   if Result=0 then exit;
   For l:=Result downto Result-20 Do
     begin
       MemStr.Seek(l,soFromBeginning);
       MemStr.ReadBuffer(buff,1);
       if buff[1]=$55 then
         begin
           if bShowWarning then ShowMessage('Warning: If the found entrypoint i not on "push ebp" instruction, then its on the first "puh ebp" before the shown RVA');
           Result:=l;
           Exit;
         end;
     end;
end;

initialization
  LinkPSAPI;
  IsWin9x:=(GetVersion and $F0000000)<>0;
  LinkToolHelp32;

end.
