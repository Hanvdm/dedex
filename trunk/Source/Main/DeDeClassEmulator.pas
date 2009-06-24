unit DeDeClassEmulator;
//////////////////////////
// Last Change: 8.II.2001
//////////////////////////

interface

uses Classes, DeDeBSS, DeDeClassHandle, DeDeOffsInf, MainUnit;

Type DWORD = LongWord;

Var EAX, EBX, ECX, EDX, ESI, EDI, EBP : String;
Var dwEAX, dwEBX, dwECX, dwEDX, dwESI, dwEDI, dwEBP : DWORD;
var ESP, Loc_Names, Loc_StrVals : TStringList;
Var dwESP, Loc_Vars : TList;
Var OffsInfArchive : TOffsInfArchive;


Procedure InitNewEmulation(_eax, _ebx, _ecx, _edx : String);
Procedure InitNewEmulationEx(_eax, _ebx, _ecx, _edx, _ExpireCount : String);
procedure SetRegisters(_eax, _ebx, _ecx, _edx, _esi, _edi : String);
procedure SetEmulationSettings(_eax, _ebx, _ecx, _edx, _esi, _edi, _ttl : String);
Procedure EmulateInstruction(Instruction : String; size : Integer; sIns, sOp : String);
Procedure LoadOffsetInfos(FsFileName : String);

Type TRegister = (rgEAX, rgEBX, rgECX, rgEDX, rgESI, rgEDI, rgEBP, rgESP);

const registers_ : Array [TRegister] of String =
                 ('eax','ebx','ecx','edx','esi','edi','ebp','esp');

const REGISTERS__ : Array [TRegister] of String =
                 ('EAX','EBX','ECX','EDX','ESI','EDI','EBP','ESP');

function GetRegVal(reg : TRegister) : String;
function Str2TRegister(sReg : String) : TRegister;
procedure SetRegVal(reg : TRegister; sVal : String); overload;
procedure SetRegVal(reg : TRegister; sVal : dword); overload;
procedure ClearRegister(reg : TRegister);

Type GetPropertyFunction = function (sObjectClass : String) : String;

Var GetProperty : GetPropertyFunction;

    ClsDmp : TClassesDumper;

    bReference : Boolean;

    sReference : String;
    sNewClass  : String;

    DELTA_VMT : Byte;

var ExpireCount : Integer = 100;
var ExpireCounter : Array [TRegister] of Integer;

    bAddOffsRef : Boolean;
    regAddOffsRef : TRegister;
    sAddOffsRef : String;
    
function IsInSection(dwOffset : DWORD; sSectName : String) : Boolean;
procedure ClearStack;

implementation

uses DeDeClasses, HEXTools, DeDeDisAsm, DeDeConstants, DeDeREG, DeDeExpressions;

var bEBPStack : Boolean;

procedure AddGlobVar(sExpr : String; bPRT : Boolean = false);
begin
  if bPRT then AddNewExpression(0,'[$'+sExpr+']','')
          else AddNewExpression(0,'$'+sExpr,'');
end;

function Str2TRegister(sReg : String) : TRegister;
begin
  if sReg='eax' then Result:=rgEAX;
  if sReg='ebx' then Result:=rgEBX;
  if sReg='ecx' then Result:=rgECX;
  if sReg='edx' then Result:=rgEDX;
  if sReg='esi' then Result:=rgESI;
  if sReg='edi' then Result:=rgEDI;
  if sReg='ebp' then Result:=rgEBP;
  if sReg='esp' then Result:=rgESP;
end;

Procedure LoadOffsetInfos(FsFileName : String);
begin
  OffsInfArchive.Extract(FsFileName);
end;

procedure SetRegVal(reg : TRegister; sVal : String); overload;
begin
  case reg of
   rgEAX: EAX:=sVal;
   rgEBX: EBX:=sVal;
   rgECX: ECX:=sVal;
   rgEDX: EDX:=sVal;
   rgESI: ESI:=sVal;
   rgEDI: EDI:=sVal;
   rgEBP: EBP:=sVal;
  end;

 ExpireCounter[reg]:=ExpireCount;
end;

procedure ClearRegister(reg : TRegister);
begin
  case reg of
   rgEAX: EAX:='';
   rgEBX: EBX:='';
   rgECX: ECX:='';
   rgEDX: EDX:='';
   rgESI: ESI:='';
   rgEDI: EDI:='';
   rgEBP: EBP:='';
  end;
end;


function GetRegVal(reg : TRegister) : String;
begin
  case reg of
   rgEAX: Result:=EAX;
   rgEBX: Result:=EBX;
   rgECX: Result:=ECX;
   rgEDX: Result:=EDX;
   rgESI: Result:=ESI;
   rgEDI: Result:=EDI;
   rgEBP: Result:=EBP;
  end;
end;


procedure SetRegVal(reg : TRegister; sVal : DWORD); overload;
begin
  case reg of
   rgEAX: dwEAX:=sVal;
   rgEBX: dwEBX:=sVal;
   rgECX: dwECX:=sVal;
   rgEDX: dwEDX:=sVal;
   rgESI: dwESI:=sVal;
   rgEDI: dwEDI:=sVal;
   rgEBP: dwEBP:=sVal;
  end;
end;

function GetRegValDW(reg : TRegister) : DWORD;
begin
  case reg of
   rgEAX: Result:=dwEAX;
   rgEBX: Result:=dwEBX;
   rgECX: Result:=dwECX;
   rgEDX: Result:=dwEDX;
   rgESI: Result:=dwESI;
   rgEDI: Result:=dwEDI;
   rgEBP: Result:=dwEBP;
  end;
end;

function IsInSection(dwOffset : DWORD; sSectName : String) : Boolean;
var idx : Integer;
begin
  result:=false;
  idx:=PEHEader.GetSectionIndexEx(sSectName);
  if idx=-1 then exit;
  result:=     (dwOffset>=PEHeader.IMAGE_BASE+PEHeader.Objects[idx].RVA)
           and (dwOffset<=PEHeader.IMAGE_BASE+PEHeader.Objects[idx].RVA+PEHEader.Objects[idx].VIRTUAL_SIZE);
end;

function IsBSSOffset(dw : DWORD) : boolean;
begin
  Result:=IsInSection(dw,'BSS');
end;

function IsDATAOffset(dw : DWORD) : boolean;
begin
  Result:=IsInSection(dw,'DATA');
end;

function IsCODEOffset(dw : DWORD) : boolean;
begin
  Result:=IsInSection(dw,'CODE');
end;


procedure SetRegisters(_eax, _ebx, _ecx, _edx, _esi, _edi : String);
var boza : TClassDumper;
begin
  EAX:=_eax;
  EBX:=_ebx;
  ECX:=_ecx;
  EDX:=_edx;
  ESI:=_esi;
  EDI:=_edi;
  EBP:='';

  dwEAX:=0;
  dwEBX:=0;
  dwECX:=0;
  dwEDX:=0;
  dwESI:=0;
  dwEDI:=0;

  if _eax<>'' then
    begin
     boza:=ClsDmp.GetClass(_eax);
     if boza.FdwBSSOffset.Count>1
       then dwEAX:=DWORD(ClsDmp.GetClass(_eax).FdwBSSOffset[1]);
    end;
  if _ebx<>'' then
    if ClsDmp.GetClass(_ebx).FdwBSSOffset.Count>1 then  dwEBX:=DWORD(ClsDmp.GetClass(_ebx).FdwBSSOffset[1]);
  if _ecx<>'' then
    if ClsDmp.GetClass(_ecx).FdwBSSOffset.Count>1 then  dwECX:=DWORD(ClsDmp.GetClass(_ecx).FdwBSSOffset[1]);
  if _edx<>'' then
    if ClsDmp.GetClass(_edx).FdwBSSOffset.Count>1 then  dwEDX:=DWORD(ClsDmp.GetClass(_edx).FdwBSSOffset[1]);
  if _edi<>'' then
    if ClsDmp.GetClass(_edi).FdwBSSOffset.Count>1 then  dwECX:=DWORD(ClsDmp.GetClass(_edi).FdwBSSOffset[1]);
  if _esi<>'' then
    if ClsDmp.GetClass(_esi).FdwBSSOffset.Count>1 then  dwEDX:=DWORD(ClsDmp.GetClass(_esi).FdwBSSOffset[1]);

  dwEBP:=0;
end;

procedure SetEmulationSettings(_eax, _ebx, _ecx, _edx, _esi, _edi, _ttl : String);
begin
  if EAX='' then
    begin
       EAX:=_eax;
       dwEAX:=0;
       if _eax<>'' then
         if ClsDmp.GetClass(_eax).FdwBSSOffset.Count>1 then dwEAX:=DWORD(ClsDmp.GetClass(_eax).FdwBSSOffset[1]);
    end;

  if EBX='' then
    begin
       EBX:=_ebx;
       dwEBX:=0;
       if _ebx<>'' then
         if ClsDmp.GetClass(_ebx).FdwBSSOffset.Count>1 then dwEBX:=DWORD(ClsDmp.GetClass(_ebx).FdwBSSOffset[1]);
    end;

  if ECX='' then
    begin
       ECX:=_ecx;
       dwECX:=0;
       if _ecx<>'' then
         if ClsDmp.GetClass(_ecx).FdwBSSOffset.Count>1 then dwECX:=DWORD(ClsDmp.GetClass(_ecx).FdwBSSOffset[1]);
    end;

  if EDX='' then
    begin
       EDX:=_edx;
       dwEDX:=0;
       if _edx<>'' then
         if ClsDmp.GetClass(_edx).FdwBSSOffset.Count>1 then dwEDX:=DWORD(ClsDmp.GetClass(_edx).FdwBSSOffset[1]);
    end;

  if ESI='' then
    begin
       ESI:=_esi;
       dwESI:=0;
       if _esi<>'' then
         if ClsDmp.GetClass(_esi).FdwBSSOffset.Count>1 then dwESI:=DWORD(ClsDmp.GetClass(_esi).FdwBSSOffset[1]);
    end;

  if EDI='' then
    begin
       EDI:=_edi;
       dwEDI:=0;
       if _edi<>'' then
         if ClsDmp.GetClass(_edi).FdwBSSOffset.Count>1 then dwEDI:=DWORD(ClsDmp.GetClass(_edi).FdwBSSOffset[1]);
    end;


  EBP:='';
  dwEBP:=0;

  ExpireCount:=HEX2DWORD(_ttl);
end;


Procedure InitNewEmulation(_eax, _ebx, _ecx, _edx : String);
var RegIdx : TRegister;
begin
  ClsDmp:=DeDeMainForm.ClassesDumper;
  SetRegisters(_eax, _ebx, _ecx, _edx, '', '');

  ClearStack;

  bEBPStack:=False;

  DELTA_VMT:=76;
  If DelphiVersion='D3' Then DELTA_VMT:=64;
  If DelphiVersion='D2' Then DELTA_VMT:=44;

  For RegIdx:=rgEAX to rgESP do ExpireCounter[RegIdx]:=$100;
  
  bAddOffsRef:=False;
end;

procedure ClearStack;
begin
  ESP.Clear;
  dwESP.Clear;
  Loc_Names.Clear;
  Loc_Vars.Clear;
  Loc_StrVals.Clear;
end;

Procedure InitNewEmulationEx(_eax, _ebx, _ecx, _edx, _ExpireCount : String);
begin
  ClsDmp:=DeDeMainForm.ClassesDumper;
  SetRegisters(_eax, _ebx, _ecx, _edx, '', '');

  ClearStack;

  bEBPStack:=False;

  ExpireCount:=HEX2DWORD(_ExpireCount);

  DELTA_VMT:=76;
  If DelphiVersion='D3' Then DELTA_VMT:=64;
  If DelphiVersion='D2' Then DELTA_VMT:=44;

  bAddOffsRef:=False;
end;


procedure movRegister_Register(reg1,reg2 : TRegister);
begin
  if reg1=reg2 then exit;
  SetRegVal(reg1,GetRegVal(reg2));
  SetRegVal(reg1,GetRegValDW(reg2));
end;

procedure xchgRegister_Register(reg1,reg2 : TRegister);
var sVal : String;
    dwVal : DWORD;
begin
  if reg1=reg2 then exit;
  sVal:=GetRegVal(reg2);
  dwVal:=GetRegValDW(reg2);
  SetRegVal(reg2,GetRegVal(reg1));
  SetRegVal(reg2,GetRegValDW(reg1));
  SetRegVal(reg1,sVal);
  SetRegVal(reg1,dwVal);
end;


procedure movRegister_ptrRegister(reg1,reg2 : TRegister);
var dw : DWORD;
    i,j : Integer;
begin
  // mov reg1, [reg2]
  SetRegVal(reg1,GetRegVal(reg2));

  // No support for now !
  exit;


  dw:=GetRegValDW(reg2);
  if dw<>0 then
    begin
      if IsDATAOffset(dw) then
         begin
           for i:=0 to ClsDmp.Classes.Count-1 do
            for j:=0 to TClassDumper(ClsDmp.Classes[i]).FdwDATAPrt.Count-1 do
             if DWORD(TClassDumper(ClsDmp.Classes[i]).FdwDATAPrt[j])=dw
              then begin
                SetRegVal(reg1,TClassDumper(ClsDmp.Classes[i]).FsClassName);
                SetRegVal(reg1,DWORD(TClassDumper(ClsDmp.Classes[i]).FdwBSSOffset[j]));
                bReference:=True;
                sReference:=sREF_TEXT_POSSIBLE_TO+' '+GetRegVal(reg1);
                break;
              end;
         end;

      if IsBSSOffset(dw) then
         begin
           for i:=0 to ClsDmp.Classes.Count-1 do
            for j:=0 to TClassDumper(ClsDmp.Classes[i]).FdwBSSOffset.Count-1 do
             if DWORD(TClassDumper(ClsDmp.Classes[i]).FdwBSSOffset[j])=dw
             then begin
               SetRegVal(reg1,Copy(TClassDumper(ClsDmp.Classes[i]).FsClassName,2,Length(TClassDumper(ClsDmp.Classes[i]).FsClassName)-1));
               SetRegVal(reg1,DWORD(TClassDumper(ClsDmp.Classes[i]).FdwHeapPtr[j]));
               bReference:=True;
               sReference:=sREF_TEXT_POSSIBLE_TO+' '+GetRegVal(reg1);
               break;
             end;
         end;
    end;
end;

procedure movptr_Register(reg : TRegister; Offs : DWORD);
var i, j : Integer;
    ptr : DWORD;
begin
  if IsDATAOffset(Offs) then
    begin
     // mov register pointer to global var
     ptr:=DeDeMainForm.ClassesDumper.BSS.GetData(Offs);
     if IsBSSOffset(ptr) then
       begin
          SetRegVal(reg,'GlobalVar_'+DWORD2HEX(ptr));
          AddGlobVar(DWORD2HEX(Offs),true);
          SetRegVal(reg,0);
          bReference:=True;
          sReference:=sREF_TEXT_REF_TO+' pointer to '+GetRegVal(reg);
       end;
    end;

  if IsBSSOffset(Offs) then
    begin
     // mov register pointer to class instance!!!
     for i:=0 to ClsDmp.Classes.Count-1 do
       for j:=0 to TClassDumper(ClsDmp.Classes[i]).FdwBSSOffset.Count-1 do
         if DWORD(TClassDumper(ClsDmp.Classes[i]).FdwBSSOffset[j])=Offs
         then begin
           If TClassDumper(ClsDmp.Classes[i]).IsBSSDATAClass(j) then
             begin
               SetRegVal(reg,Copy(TClassDumper(ClsDmp.Classes[i]).FsClassName,2,Length(TClassDumper(ClsDmp.Classes[i]).FsClassName)-1));
               SetRegVal(reg,DWORD(TClassDumper(ClsDmp.Classes[i]).FdwHeapPtr[j]));
             end
             else begin
               SetRegVal(reg,'GlobalVar_'+DWORD2HEX(Offs));
               AddGlobVar(DWORD2HEX(Offs));
               SetRegVal(reg,0);
             end;
           bReference:=True;
           sReference:=sREF_TEXT_POSSIBLE_TO+' '+GetRegVal(reg);
           exit;
         end;

       SetRegVal(reg,'GlobalVar_'+DWORD2HEX(Offs));
       AddGlobVar(DWORD2HEX(Offs));
       SetRegVal(reg,0);
       bReference:=True;
       sReference:=sREF_TEXT_REF_TO+' '+GetRegVal(reg);
    end;
end;

procedure movRegister_ptr(reg : TRegister; Offs : DWORD);
var prt : DWORD;
    i,j : Integer;
    s : String;
begin
  if Offs=0 then SetRegVal(reg,0);
  SetRegVal(reg,'');
 
  if IsDATAOffset(Offs) then
    begin
     // mov register pointer to the class !!!
     for i:=0 to ClsDmp.Classes.Count-1 do
       for j:=0 to TClassDumper(ClsDmp.Classes[i]).FdwDATAPrt.Count-1 do
        if DWORD(TClassDumper(ClsDmp.Classes[i]).FdwDATAPrt[j])=Offs
         then begin
           SetRegVal(reg,TClassDumper(ClsDmp.Classes[i]).FsClassName);
           SetRegVal(reg,DWORD(TClassDumper(ClsDmp.Classes[i]).FdwBSSOffset[j]));
           bReference:=True;
           sReference:=sREF_TEXT_REF_TO+' '+GetRegVal(reg)+' instance';
           exit;
         end;
         
     // mov register pointer to global var
     prt:=DeDeMainForm.ClassesDumper.BSS.GetData(Offs);
     While IsDATAOffset(prt) Do prt:=DeDeMainForm.ClassesDumper.BSS.GetData(prt);
     
     if IsBSSOffset(prt) then
       begin
          SetRegVal(reg,'GlobalVar_'+DWORD2HEX(prt));
          AddGlobVar(DWORD2HEX(Offs),true);
          SetRegVal(reg,prt);
          bReference:=True;
          sReference:=sREF_TEXT_REF_TO+' pointer to '+GetRegVal(reg);
       end;
    end;

  if IsBSSOffset(Offs) then
    begin
     // mov register pointer to class instance!!!
     for i:=0 to ClsDmp.Classes.Count-1 do
       for j:=0 to TClassDumper(ClsDmp.Classes[i]).FdwBSSOffset.Count-1 do
         if DWORD(TClassDumper(ClsDmp.Classes[i]).FdwBSSOffset[j])=Offs
         then begin
           If TClassDumper(ClsDmp.Classes[i]).IsBSSDATAClass(j) then
             begin
               SetRegVal(reg,Copy(TClassDumper(ClsDmp.Classes[i]).FsClassName,2,Length(TClassDumper(ClsDmp.Classes[i]).FsClassName)-1));
               SetRegVal(reg,DWORD(TClassDumper(ClsDmp.Classes[i]).FdwHeapPtr[j]));
             end
             else begin
               SetRegVal(reg,'GlobalVar_'+DWORD2HEX(Offs));
               AddGlobVar(DWORD2HEX(Offs));
               SetRegVal(reg,0);
             end;
           bReference:=True;
           sReference:=sREF_TEXT_REF_TO+' '+GetRegVal(reg);
           break;
         end;
    end;

  if IsCODEOffset(Offs) then
    begin
     // For Record types recognition
     Inc(Offs,4);
     // mov register pointer to the class !!!
     for i:=0 to ClsDmp.Classes.Count-1 do
       begin
        // Check For Objects (Offset = Selfpointer To the Class)
        if DWORD(TClassDumper(ClsDmp.Classes[i]).FdwSelfPrt)=Offs
         then begin
           SetRegVal(reg,TClassDumper(ClsDmp.Classes[i]).FsClassName);
           SetRegVal(reg,0);
           bReference:=True;
           sReference:=sREF_TEXT_REF_TO+' object '+GetRegVal(reg);
           break;
         end;

              // Normal Class
        if    (DWORD(TClassDumper(ClsDmp.Classes[i]).FdwVMTPtr)=Offs+DELTA_VMT-4)
              // Class without selfpointer
           or (DWORD(TClassDumper(ClsDmp.Classes[i]).FdwSelfPrt)=Offs+4)
         then begin
           SetRegVal(reg,TClassDumper(ClsDmp.Classes[i]).FsClassName);
           SetRegVal(reg,0);
           bReference:=True;
           sReference:=sREF_TEXT_REF_TO+' class '+GetRegVal(reg);
           break;
         end;
       end; {for}

      if not bReference then
        // Try to find the *next* class/object/type name
        if (DeDeMainForm.ClassRefInCode(Offs,s))
         then begin
           SetRegVal(reg,s);
           SetRegVal(reg,0);
           bReference:=True;
           sReference:=sREF_TEXT_REF_TO+' class '+GetRegVal(reg);
         end;
    end; {IsCODEOffset}
end;


procedure pushRegister(reg : TRegister);
begin
  case reg of
   rgEAX: dwESP.Add(Pointer(dwEAX));
   rgEBX: dwESP.Add(Pointer(dwEBX));
   rgECX: dwESP.Add(Pointer(dwECX));
   rgEDX: dwESP.Add(Pointer(dwEDX));
   rgESI: dwESP.Add(Pointer(dwESI));
   rgEDI: dwESP.Add(Pointer(dwEDI));
   rgEBP: dwESP.Add(Pointer(dwEBP));
   rgESP: dwESP.Add(nil);
  end;
end;


procedure popRegister(reg : TRegister);

  procedure _Pop(var dw : DWORD);
  begin
    dw:=DWORD(dwESP[0]);
    dwESP.Delete(0);
  end;

begin
  case reg of
   rgEAX: _Pop(dwEAX);
   rgEBX: _Pop(dwEBX);
   rgECX: _Pop(dwECX);
   rgEDX: _Pop(dwEDX);
   rgESI: _Pop(dwESI);
   rgEDI: _Pop(dwEDI);
   rgEBP: _Pop(dwEBP);
   rgESP: dwESP.Delete(0);
  end;
end;


procedure movRegister_StackVar(reg : TRegister; val : DWORD);
var idx : Integer;
    dw : DWORD;
begin
  idx:=Loc_Names.IndexOf(DWORD2HEX(val));
  if idx<>-1 then begin
    dw:=DWORD(Loc_Vars[idx]);
    movRegister_ptr(reg, dw);

    // Added in case BSS has not been dumped or bBSS=False
    if Loc_StrVals[idx]<>'' then SetRegVal(reg,Loc_StrVals[idx]);
   end;
end;

procedure movStackVar_Register(reg : TRegister; val : DWORD);
var idx : Integer;
begin
  idx:=Loc_Names.IndexOf(DWORD2HEX(val));
  if idx=-1 then begin
    Loc_Names.Add(DWORD2HEX(val));
    Loc_StrVals.Add('');
    Loc_Vars.Add(nil);
    idx:=Loc_Names.Count-1;
   end;

  Loc_Vars[idx]:=(Pointer(GetRegValDW(reg)));
  
  // Added in case BSS has not been dumped or bBSS=False
  Loc_StrVals[idx]:=GetRegVal(reg);
end;

function dGetOffset(s : String) : DWORD;
var i : Integer;
    ss : String;
    b : boolean;
begin
  b:=False;
  ss:='';
  for i:=1 to Length(s) do
    begin
      if s[i]=']' then b:=false;
      if b then ss:=ss+s[i];
      if s[i]='$' then b:=true;
    end;
  Result:=HEX2DWORD(ss);
end;

function dGetStackVar(s : String) : DWORD;
var i : Integer;
    ss : String;
    b,bb : boolean;
begin
  b:=False;
  bb:=False;
  ss:='';
  for i:=1 to Length(s) do
    begin
      if s[i]=']' then b:=false;
      if b then ss:=ss+s[i];
      if s[i]='-' then bb:=True;
      if (s[i]='$') and bb then b:=true;
    end;
  Result:=HEX2DWORD(ss);
end;

Procedure movRegOffset(reg : TRegister; sInstr : String);
var Offs : DWORD;
    s,sCN : String;
    i,j : Integer;
begin
   ClearRegister(reg);
   
   offs:=Pos('$',sInstr);
   sCN:=Copy(sInstr,offs-1,Length(sInstr)-Offs+2);
   s:='';
   For offs:=1 to Length(sCN) do
    if sCN[offs] in ['0'..'9','A'..'F'] then s:=s+sCN[offs];

   offs:=HEX2DWORD(s);

  if IsBSSOffset(Offs) then
    begin
     // mov register pointer to class instance!!!
     for i:=0 to ClsDmp.Classes.Count-1 do
       for j:=0 to TClassDumper(ClsDmp.Classes[i]).FdwBSSOffset.Count-1 do
         if DWORD(TClassDumper(ClsDmp.Classes[i]).FdwBSSOffset[j])=Offs
         then begin
           If TClassDumper(ClsDmp.Classes[i]).IsBSSDATAClass(j) then
             begin
               SetRegVal(reg,Copy(TClassDumper(ClsDmp.Classes[i]).FsClassName,2,Length(TClassDumper(ClsDmp.Classes[i]).FsClassName)-1));
               SetRegVal(reg,DWORD(TClassDumper(ClsDmp.Classes[i]).FdwHeapPtr[j]));
             end
             else begin
               SetRegVal(reg,'GlobalVar_'+DWORD2HEX(Offs));
               AddGlobVar(DWORD2HEX(Offs));
               SetRegVal(reg,0);
             end;
           bReference:=True;
           sReference:=sREF_TEXT_POSSIBLE_TO+' '+GetRegVal(reg);
           break;
         end;
    end;
end;

procedure OffsInfReference(reg : TRegister; sInstr : String);
var RefType : TRefOffsInfType;
   sCN,s,sDestReg        : String;
   offs     : DWORD;
   ClsBoza : TClassDumper;
begin
 // Default
 RefType:=rtMOV;

 // Dynamic Index
 if Pos('mov     bx, $',sInstr)<>0 then RefType:=rtDynCall
   // Call Reference
   else if Pos('call    dword ptr [',sInstr)<>0 then RefType:=rtCALL
     // Property Reference
     else if Pos('mov',sInstr)<>0 then RefType:=rtMOV;

   offs:=Pos('$',sInstr);
   if offs=0 then exit;

   sCN:=Copy(sInstr,offs-1,Length(sInstr)-Offs+2);
   s:='';
   For offs:=1 to Length(sCN) do
    if sCN[offs] in ['0'..'9','A'..'F'] then s:=s+sCN[offs];

   offs:=HEX2DWORD(s);

   // This check should avoid from getting invalid references
   // from 'add reg,imm_data' instructions
   bReference:=False;
   if offs>$FFFF then
     begin
       sDestReg:=Copy(sInstr,9,3);
       ClearRegister(Str2TRegister(sDestReg));
       exit;
     end;

   if sCN[1]='-' then offs:=not offs;

   // Getting Class Name
   sCN:=GetRegVal(reg);
   // Adding Class Prefix if needed
   if (sCN<>'') and (sCN[1]<>'T') then sCN:='T'+sCN;

   if sCN='' then
     if RefType<>rtDynCall then begin
                               sCN:='<UnknownType>';
                               if bDontShowUnkRefs then Exit;

                           end
                           else sCN:='TPersistent';  {Dinamic Calls are first met in TPersistent}

   if ClsDmp.GetClass(sCN)<>nil then
      begin
        // In the case the class is in dumped classes
        sReference:=TFieldData(ClsDmp.GetClass(sCN).FieldData).GetFieldName(offs);
        sNewClass:=DeDeDisASM.GetControlClassEx(sCN,sReference);

        // If no such field is found try to find it among the parent class fields using DOI data
        if sReference=''
          then if ClsDmp.GetClass(sCN).FbClassFlag=$07
             //then OffsInfArchive.GetReference('TForm',offs,RefType,sReference,sNewClass)
             then OffsInfArchive.GetReference(sCN,offs,RefType,sReference,sNewClass)
             else OffsInfArchive.GetReference(sCN,offs,RefType,sReference,sNewClass)
          // Add the reference text in the case of control references
          else sReference:=sREF_TEXT_CONTROL+' '+sReference+':'+sNewClass;
      end
      else OffsInfArchive.GetReference(sCN,offs,RefType,sReference,sNewClass);

   // There is found reference !
   if sReference<>'' then
     begin
       bReference:=True;
       if RefType=rtMOV then
          begin
            // When it is MOV instruction it must be emulated
            sDestReg:=Copy(sInstr,9,3);
            SetRegVal(Str2TRegister(sDestReg),sNewClass);
            SetRegVal(Str2TRegister(sDestReg),0);
            ClsBoza:=ClsDmp.GetClass(sNewClass);
            if ClsBoza<>nil then
               if ClsBoza.FdwBSSOffset.Count>1
                    then SetRegVal(Str2TRegister(sDestReg),DWORD(ClsBoza.FdwBSSOffset[1]));
          end;
     end
     else begin
       Case RefType of
         rtMOV     : begin
                       sReference:=sREF_POSSIBLE_FIELD+' '+sCN+'.OFFS_'+s;
                       sDestReg:=Copy(sInstr,9,3);
                       ClearRegister(Str2TRegister(sDestReg));
                     end;
         rtCall    : sReference:=sREF_POSSIBLE_VIRT_METH+' '+sCN+'.OFFS_'+s;
         rtDynCall : sReference:=sREF_POSSIBLE_DYN_METH+' '+sCN+'.OFFS_'+s;
       End;
       bReference:=True;
     end;
end;

function ByteToBin(b : Byte) : String;
begin
  Result:='';
  while b<>0 do
    begin
      if b mod 2 = 0 then Result:='0'+Result
                     else Result:='1'+Result;
      b:=b div 2;
    end;
  while length(Result)<8 do Result:='0'+Result;
end;

function BinToByte(s : String) : Byte;
const power2_dta : array [0..7] of Byte = (1,2,4,8,16,32,64,128);
var i : Integer;
Begin
 Result:=0;
 For i:=Length(s) downto 1 Do
   Result:=Result+(Integer(s[i]='1'))*power2_dta[8-i];
End;

function Decode_REG_mask(s:String) : Integer; overload;
var cs : Byte;
begin
  cs:=BinToByte(s);
  case cs of
   0: Result:=ORD(rgEAX);
   1: Result:=ORD(rgECX);
   2: Result:=ORD(rgEDX);
   3: Result:=ORD(rgEBX);
   4: Result:=ORD(rgESP);
   5: Result:=ORD(rgEBP);
   6: Result:=ORD(rgESI);
   7: Result:=ORD(rgEDI)
   else Result:=-1;
  end;
end;

function Decode_REG_mask(cs:Byte; bExtended : Boolean) : Integer; overload;
begin
  if bExtended
   Then case cs of
     0: Result:=ORD(rgEAX);
     1: Result:=ORD(rgECX);
     2: Result:=ORD(rgEDX);
     3: Result:=ORD(rgEBX);
     4: Result:=ORD(rgESP);
     5: Result:=ORD(rgEBP);
     6: Result:=ORD(rgESI);
     7: Result:=ORD(rgEDI)
     else Result:=-1;
   end
   else Case cs of
     // This shit acctually returns which 32bit
     // register will be affected. The real decoding
     // should return Al,CL,DL,BL,AH,CH,DX,BH
     0: Result:=ORD(rgEAX);
     1: Result:=ORD(rgECX);
     2: Result:=ORD(rgEDX);
     3: Result:=ORD(rgEBX);
     4: Result:=ORD(rgEAX);
     5: Result:=ORD(rgECX);
     6: Result:=ORD(rgEDX);
     7: Result:=ORD(rgEBX)
     else Result:=-1;
   end;
end;


/////////////////////////////////////////////////////////////////////////////
// supported masks so far:
//
// '11 reg1 reg2'
// 'mod reg r/m'
// '11 111 reg'
/////////////////////////////////////////////////////////////////////////////
Procedure DecodeOperandInfo(b : Byte; sMask : String; w : Byte; var i1,i2,i3 : Integer);
var bExtended : Boolean;
    // bitmask : String;
begin
//  bitmask:=ByteToBin(b);
  bExtended:=w=1;

  if sMask='11 reg1 reg2' then
    begin
      i1:=(B and $C0) shr 6;
      i2:=Decode_REG_mask((B and $38) shr 3, bExtended);
      i3:=Decode_REG_mask(B and $07, bExtended);
    end;

  if sMask='mod reg r/m' then
    begin
      i3:=(B and $C0) shr 6;
      i2:=(B and $38) shr 3;
      i1:=Decode_REG_mask(B and $07, bExtended);
    end;

  if sMask='11 111 reg' then
    begin
      i1:=(B and $C0) shr 6;
      i2:=(B and $38) shr 3;
      i3:=Decode_REG_mask(B and $07, bExtended);
    end;
end;

procedure CL_Reg_to_Reg(sInstruction : String);
var i1,i2,i3 : Integer;
begin
   ///////////////////////////////
   // "register1 to register2"  //
   // "register2 to register1"  //
   ///////////////////////////////
   DecodeOperandInfo(ORD(sInstruction[2]),'11 reg1 reg2',ORD(sInstruction[1]) mod 2, i1,i2,i3);
   if i1=3 {i1 = 11} then
     begin
       if (ORD(sInstruction[1]) and $02) = 0 then ClearRegister(TRegister(i3));
       if (ORD(sInstruction[1]) and $01) = 0 then ClearRegister(TRegister(i2));
     end;
end;

procedure CL_Mod_Reg_RM(sInstruction : String);
var i1,i2,i3 : Integer;
begin
   ///////////////////////////
   // "memory to register"  //
   ///////////////////////////
   DecodeOperandInfo(ORD(sInstruction[2]),'mod reg r/m',ORD(sInstruction[1]) mod 2, i1,i2,i3);
   if i1<>3 {not register, register selector} then ClearRegister(TRegister(i2));
end;

procedure CL_Reg_to_Reg_0F(sInstruction : String);
var i1,i2,i3 : Integer;
begin
   ///////////////////////////////
   // "register1 to register2"  //
   // "register2 to register1"  //
   ///////////////////////////////
   DecodeOperandInfo(ORD(sInstruction[2]),'11 reg1 reg2',1, i1,i2,i3);
   if i1=3 {i1 = 11} then
     begin
       if (ORD(sInstruction[1]) and $02) = 0 then ClearRegister(TRegister(i3));
       if (ORD(sInstruction[1]) and $01) = 0 then ClearRegister(TRegister(i2));
     end;
end;

procedure CL_Mod_Reg_RM_0F(sInstruction : String);
var i1,i2,i3 : Integer;
begin
   ///////////////////////////
   // "memory to register"  //
   ///////////////////////////
   DecodeOperandInfo(ORD(sInstruction[2]),'mod reg r/m',1, i1,i2,i3);
   if i1<>3 {not register, register selector} then ClearRegister(TRegister(i2));
end;

procedure CL_Imm_to_A;
begin
   ////////////////////////////////////
   // "immediate to AL, AX, or EAX"  //
   ////////////////////////////////////
   ClearRegister(rgEAX);
end;

Function Min(X,Y : Integer) : Integer;
Begin
  If X<Y Then Result:=X Else Result:=Y;
End;

{*******************************************************************************
********************************************************************************
******
******       Pseudo Emulator of class operations and reference finder
******
********************************************************************************
********************************************************************************
}
// Instruction is a string containing the OPCODES
// size is the size in bytes of instruction
// sIns and sOp are the ASM Instruction and Operands representing the instruction
//
Procedure EmulateInstruction(Instruction : String; size : Integer; sIns, sOp : String);
var //RegIdx : TRegister;
    i1,i2,i3,ii1,ii2,ii3,_i1,_i2,_i3 : Integer;
    InstructionOF : String;
begin
  bReference:=False;

  //////////////////////////////////////////////////////////////////////////////
  //                THE x86 INSTRUCTION SET GROUPED BY OPCODES                //
  //////////////////////////////////////////////////////////////////////////////
  //                                                                          //
  //     Include only instructions that affect registers eax ... edi because  //
  //  those registers are included in class emulation. Also includes          //
  //  (FF : 10 010 reg) and (FF : 01 010 reg) call [reg+offs] instructions    //
  //  that are handles to search DOI method references.                       //
  //     The (8B : 11 reg1 reg2) mov reg1, reg2 instruction is emulated in    //
  //  DeDeDisAsm.ControlRef() function and EmulateInstruction() is not called //
  //  if that function returns any reference. Also note that this function    //
  //  can return reference for CMP and LEA(??) instructions!                  //
  //////////////////////////////////////////////////////////////////////////////

  // This is called I1 to be known
  DecodeOperandInfo(ORD(Instruction[2]),'11 reg1 reg2',1, i1,i2,i3);
  DecodeOperandInfo(ORD(Instruction[3]),'11 reg1 reg2',1, ii1,ii2,ii3);
  InstructionOF:=Copy(Instruction,1,Length(Instruction)-1);
  
  Case ORD(Instruction[1]) of
   $00,{add reg2, reg1}
   $01 {add reg2, reg1}
      : case I1 of
          3 :  {add reg2, reg1}  CL_Reg_to_Reg(Instruction)
        end;
        
   $02,{add reg1, reg2}
   $03 {add reg1, reg2}
      : case I1 of
          3 :  {add reg2, reg1}  CL_Reg_to_Reg(Instruction)
          else {add reg, memory}
            if     (i2=7) {i2 = 111}
               and (i1=2) {i1 = 10}
                {add reg32, imm_32bit_data}
            then OffsInfReference(TRegister(i3), sOp)
            else CL_Mod_Reg_RM(Instruction);
        end;

   $04,{add reg8, imm_data}
   $05 {add reg8, imm_data}
      : CL_Imm_to_A;

   $08,{or reg2, reg1}
   $09 {or reg2, reg1}
      : case I1 of
          3 :  {or reg2, reg1}  CL_Reg_to_Reg(Instruction)
        end;

   $0A,{or reg1, reg2}
   $0B {or reg1, reg2}
      : case I1 of
          3 :  {or reg2, reg1}  CL_Reg_to_Reg(Instruction)
          else {or reg, memory} CL_Mod_Reg_RM(Instruction);
        end;

   $0C,{or reg8, imm_data}
   $0D {or reg8, imm_data}
      : CL_Imm_to_A;

   $0F : case ORD(Instruction[2]) of

           $00 : if (II1=3) then
                  case II2 of
                    0 : {sltd reg} ClearRegister(TRegister(II3));
                    1 : { str reg} ClearRegister(TRegister(II3));
                  end;

           $01 : if (II1=3) then
                  case II2 of
                    3 : {smsw reg} ClearRegister(TRegister(II3));
                  end;

           $02 : case II1 of
                   3 :  {lar reg1, reg2 } CL_Reg_to_Reg_0F(InstructionOF)
                   else {lar reg, memory} CL_Mod_Reg_RM_0F(InstructionOF);
                 end;

           $40..$4F
               : case II1 of
                   3 :  {cmov__ reg1, reg2 } CL_Reg_to_Reg_0F(InstructionOF)
                   else {cmov__ reg, memory} CL_Mod_Reg_RM_0F(InstructionOF);
                 end;

           $90..$9F
               : if (II1=3 {11}) and (II2=0 {000})
                  then {set__ reg} ClearRegister(TRegister(II3));

           $A2 : begin
                   {cpuid}
                   ClearRegister(rgEAX);
                   ClearRegister(rgECX);
                   ClearRegister(rgEDX);
                   ClearRegister(rgEBX);
                 end;

           $A4, {shld reg1, reg2, imm_data }
           $A5  {shld reg1, reg2, cl }
               : if II1 = 3 then
                 begin
                   ClearRegister(TRegister(II2));
                   ClearRegister(TRegister(II3));
                 end;

           $AB : case II1 of
                   3 :  {bts reg1, reg2 } CL_Reg_to_Reg_0F(InstructionOF)
                   else {bts reg, memory} CL_Mod_Reg_RM_0F(InstructionOF);
                 end;

           $AC, {shrd reg1, reg2, imm_data }
           $AD  {shrd reg1, reg2, cl }
               : if II1 = 3 then
                 begin
                   ClearRegister(TRegister(II2));
                   ClearRegister(TRegister(II3));
                 end;

           $AF : case II1 of
                   3 :  {imul reg1, reg2 } CL_Reg_to_Reg_0F(InstructionOF)
                   else {imul reg, memory} CL_Mod_Reg_RM_0F(InstructionOF);
                 end;

           $B0,
           $B1 : case II1 of
                   3 :  {cmpxchg reg1, reg2}
                       begin
                         DecodeOperandInfo(ORD(Instruction[3]),'11 reg1 reg2',ORD(Instruction[2]) mod 2, _i1,_i2,_i3);
                         ClearRegister(TRegister(_i2));
                         ClearRegister(TRegister(_i3));
                       end;
                   else {cmpxchg reg1, memory}
                       begin
                         DecodeOperandInfo(ORD(Instruction[3]),'mod reg r/m',ORD(Instruction[2]) mod 2, _i1,_i2,_i3);
                         ClearRegister(TRegister(_i2));
                       end
                 end;

           $B3 : case II1 of
                   3 :  {btr reg1, reg2 } CL_Reg_to_Reg_0F(InstructionOF)
                   else {btr reg, memory} CL_Mod_Reg_RM_0F(InstructionOF);
                 end;

           $B6,
           $B7 : case II1 of
                   3 :  {movzx reg1, reg2 } CL_Reg_to_Reg_0F(InstructionOF)
                   else {movzx reg, memory} CL_Mod_Reg_RM_0F(InstructionOF);
                 end;

           $BB : case II1 of
                   3 :  {btc reg1, reg2 } CL_Reg_to_Reg_0F(InstructionOF)
                   else {btc reg, memory} CL_Mod_Reg_RM_0F(InstructionOF);
                 end;

           $BC : case II1 of
                   3 :  {bsf reg1, reg2 } CL_Reg_to_Reg_0F(InstructionOF)
                   else {bsf reg, memory} CL_Mod_Reg_RM_0F(InstructionOF);
                 end;

           $BD : case II1 of
                   3 :  {bsr reg1, reg2 } CL_Reg_to_Reg_0F(InstructionOF)
                   else {bsr reg, memory} CL_Mod_Reg_RM_0F(InstructionOF);
                 end;

           $BE,
           $BF : case II1 of
                   3 :  {movsx reg1, reg2 } CL_Reg_to_Reg_0F(InstructionOF)
                   else {movsx reg, memory} CL_Mod_Reg_RM_0F(InstructionOF);
                 end;

           $C0,
           $C1 : begin
                  DecodeOperandInfo(ORD(Instruction[2]),'11 reg1 reg2', ORD(Instruction[2]) mod 2, _i1,_i2,_i3);
                  if _i1=3 then begin
                   {xadd reg1, reg2 }
                      ClearRegister(TRegister(_i2));
                      ClearRegister(TRegister(_i3))
                    end;
                 end;

           $C8..$CF
               : begin
                  {bswap}
                  DecodeOperandInfo(ORD(Instruction[2]),'11 111 reg', 1 , _i1,_i2,_i3);
                  ClearRegister(TRegister(_i3));
                 end;

         end; // 0F subfunctions

   $10,{adc reg2, reg1}
   $11 {adc reg2, reg1}
      : case I1 of
          3 :  {adc reg2, reg1}  CL_Reg_to_Reg(Instruction);
        end;

   $12,{adc reg1, reg2}
   $13 {adc reg1, reg2}
      : case I1 of
          3 :  {adc reg2, reg1}  CL_Reg_to_Reg(Instruction)
          else {adc reg, memory} CL_Mod_Reg_RM(Instruction);
        end;
   $14,{adc reg8, imm_data}
   $15 {adc reg32, imm_data}
      : CL_Imm_to_A;

   $18,{sbb reg2, reg1}
   $19 {sbb reg2, reg1}
      : case I1 of
          3 :  {sbb reg2, reg1}  CL_Reg_to_Reg(Instruction);
        end;

   $1A,{sbb reg1, reg2}
   $1B {sbb reg1, reg2}
      : case I1 of
          3 :  {sbb reg2, reg1}  CL_Reg_to_Reg(Instruction)
          else {sbb reg, memory} CL_Mod_Reg_RM(Instruction);
        end;

   $1C,{sbb reg8, imm_data}
   $1D {sbb reg32, imm_data}
      : CL_Imm_to_A;

   $20,{and reg2, reg1}
   $21 {and reg2, reg1}
      : case I1 of
          3 :  {and reg2, reg1}  CL_Reg_to_Reg(Instruction);
        end;

   $22,{and reg1, reg2}
   $23 {and reg1, reg2}
      : case I1 of
          3 :  {and reg2, reg1}  CL_Reg_to_Reg(Instruction)
          else {and reg, memory} CL_Mod_Reg_RM(Instruction);
        end;
   $24,{and reg8, imm_data}
   $25 {and reg32, imm_data}
      : CL_Imm_to_A;

   $27: {daa} ClearRegister(rgEAX);

   $28,{sub reg2, reg1}
   $29 {sub reg2, reg1}
      : case I1 of
          3 :  {sub reg2, reg1}  CL_Reg_to_Reg(Instruction);
        end;

   $2A,{sub reg1, reg2}
   $2B {sub reg1, reg2}
      : case I1 of
          3 :  {sub reg2, reg1}  CL_Reg_to_Reg(Instruction)
          else {sub reg, memory} CL_Mod_Reg_RM(Instruction);
        end;

   $2C,{sub reg8, imm_data}
   $2D {sub reg32, imm_data}
      : CL_Imm_to_A;

   $2F: {das} ClearRegister(rgEAX);

   $30,{xor reg2, reg1}
   $31 {xor reg2, reg1}
      : case I1 of
          3 :  {xor reg2, reg1}  CL_Reg_to_Reg(Instruction);
        end;

   $32,{xor reg1, reg2}
   $33 {xor reg1, reg2}
      : case I1 of
          3 :  {xor reg2, reg1}  CL_Reg_to_Reg(Instruction)
          else {xor reg, memory} CL_Mod_Reg_RM(Instruction);
        end;

   $34,{sub reg8, imm_data}
   $35 {sub reg32, imm_data}
      : CL_Imm_to_A;

   $37: {aaa} ClearRegister(rgEAX);
   $3F: {aas} ClearRegister(rgEAX);

   $40..$47, {inc reg}
   $48..$4F  {dec reg}
      : begin
          DecodeOperandInfo(ORD(Instruction[1]),'11 111 reg', 1, _i1,_i2,_i3);
          ClearRegister(TRegister(_i3));
        end;

   $50..$57, {push reg}
   $58..$5F  {pop reg}
      : begin
          DecodeOperandInfo(ORD(Instruction[1]),'11 111 reg', 1, _i1,_i2,_i3);
          ClearRegister(TRegister(_i3));
        end;

   $66 {??}
      : if ORD(Instruction[2])=$BB {MOV BX, IMM_DATA}
        // Which is for the dynamic metods call DOI stuff
        then OffsInfReference(rgEAX, sOp);

   $69,{imul reg1, reg2, imm_data}
   $6B {imul reg, memory, imm_data}
      : ClearRegister(TRegister(i2));

   $80,
   $81,
   $82,
   $83
      : begin
          /////////////////////////////
          // "immediate to register" //
          /////////////////////////////
          DecodeOperandInfo(ORD(Instruction[2]),'11 111 reg', Min(ORD(Instruction[1]) mod 2,1), _i1,_i2,_i3);
          if _i1=3 {i1= 11} then
           begin
             {i2 = 000 -> add reg, imm_data}
             {i2 = 001 ->  or reg, imm_data}
             {i2 = 010 -> adc reg, imm_data}
             {i2 = 011 -> sbb reg, imm_data}
             {i2 = 100 -> and reg, imm_data}
             {i2 = 101 -> sub reg, imm_data}
             {i2 = 110 -> xor reg, imm_data}
             ClearRegister(TRegister(_i3));
           end;
        end;

   $86,
   $87  {xchg reg, memory}
      : if I1=3 then xchgRegister_Register(TRegister(I2),TRegister(I3))
                else ClearRegister(TRegister(I2));

   $88 {mov reg1, reg2}
      : ClearRegister(TRegister(i3));

   $89  {mov reg1, reg2}
      : case I1 of
          3 :  {mov reg1, reg2 }  movRegister_ptrRegister(TRegister(i3), TRegister(i2))
          else case ORD(Instruction[2]) of
            $45: {mov [ebp-xx], eax} movStackVar_Register(rgEAX,dGetStackVar(sOp));
            $4D: {mov [ebp-xx], ecx} movStackVar_Register(rgECX,dGetStackVar(sOp));
            $55: {mov [ebp-xx], edx} movStackVar_Register(rgEDX,dGetStackVar(sOp));
            $5D: {mov [ebp-xx], ebx} movStackVar_Register(rgEBX,dGetStackVar(sOp));
            $75: {mov [ebp-xx], esi} movStackVar_Register(rgESI,dGetStackVar(sOp));
            $7D: {mov [ebp-xx], edi} movStackVar_Register(rgEDI,dGetStackVar(sOp));
            $B8 : {mov eax, imm_data} movRegOffset(rgeax, sOp);
            $B9 : {mov ecx, imm_data} movRegOffset(rgecx, sOp);
            $BA : {mov edx, imm_data} movRegOffset(rgedx, sOp);
            $BB : {mov ebx, imm_data} movRegOffset(rgebx, sOp);
            $BC : {mov esp, imm_data} movRegOffset(rgesp, sOp);
            $BD : {mov ebp, imm_data} movRegOffset(rgebp, sOp);
            $BE : {mov esi, imm_data} movRegOffset(rgesi, sOp);
            $BF : {mov edi, imm_data} movRegOffset(rgedi, sOp)
            Else ClearRegister(TRegister(i3));
           end;
        end;

   $8A {mov reg2, reg1}
      : ClearRegister(TRegister(i2));

   $8B  {mov reg2, reg1}
      : case I1 of
          3 :  {mov reg2, reg1}  movRegister_ptrRegister(TRegister(i2), TRegister(i3))
          else case ORD(Instruction[2]) of
            $05: {mov eax, [offset]} movRegister_ptr(rgEAX, dGetOffset(sOp));
            $0D: {mov ecx, [offset]} movRegister_ptr(rgECX, dGetOffset(sOp));
            $15: {mov edx, [offset]} movRegister_ptr(rgEDX, dGetOffset(sOp));
            $1D: {mov ebx, [offset]} movRegister_ptr(rgEBX, dGetOffset(sOp));
            $35: {mov esi, [offset]} movRegister_ptr(rgESI, dGetOffset(sOp));
            $3D: {mov edi, [offset]} movRegister_ptr(rgEDI, dGetOffset(sOp));
            $45: {mov eax, [ebp-xx]} movRegister_StackVar(rgEAX,dGetStackVar(sOp));
            $4D: {mov ecx, [ebp-xx]} movRegister_StackVar(rgECX,dGetStackVar(sOp));
            $55: {mov edx, [ebp-xx]} movRegister_StackVar(rgEDX,dGetStackVar(sOp));
            $5D: {mov ebx, [ebp-xx]} movRegister_StackVar(rgEBX,dGetStackVar(sOp));
            $75: {mov esi, [ebp-xx]} movRegister_StackVar(rgESI,dGetStackVar(sOp));
            $7D: {mov edi, [ebp-xx]} movRegister_StackVar(rgEDI,dGetStackVar(sOp));
            Else
            // Only in casses like MOV REG, [EAX+EAX+Offs] -> REG should be cleared
            // All the other casses are for DOI MOV References
             case i3 of
                // Here we have only then MOV REG, [REG] case
                // MOV REG, [REG+Offs] is handled by DeDeDisAsm.ControlRef()
                0 : movRegister_ptrRegister(TRegister(i2), rgEAX);
                4 : ClearRegister(TRegister(i2));
                6 : OffsInfReference(TRegister(i3), sOp);
                7 : {mov REG, [REG1+n*REG2+Offset]}
                else ;
             end;
           end
        end;

   $8D {lea reg, memory}
      : ClearRegister(TRegister(i2));

   $8F
      : begin
          ////////////////
          // "register" //
          ////////////////
          DecodeOperandInfo(ORD(Instruction[2]),'11 111 reg', Min(ORD(Instruction[1]) mod 2,1), _i1,_i2,_i3);
          if _i1=3 {i1= 11} then
           begin
             {i2 = 000 ->  pop reg}
             ClearRegister(TRegister(_i3));
           end;
        end;

   $90..$97
      : begin
          DecodeOperandInfo(ORD(Instruction[1]),'11 111 reg', Min(ORD(Instruction[1]) mod 2,1), _i1,_i2,_i3);
          xchgRegister_Register(rgEAX, TRegister(_i3));
        end;

   $98: {cwd} ClearRegister(rgEAX);
   $99: {cwd} ClearRegister(rgEDX);
   $9F: {lahf} ClearRegister(rgEDX);

   $A0: {mov  al,  byte ptr [offset]} movRegister_ptr(rgEAX, dGetOffset(sOp));
   $A1: {mov eax, dword ptr [offset]} movRegister_ptr(rgEAX, dGetOffset(sOp));
   $A2: {mov  byte ptr [offset], al } movptr_Register(rgEAX, dGetOffset(sOp));
   $A3: {mov dword ptr [offset], eax} movptr_Register(rgEAX, dGetOffset(sOp));

   $B0..$B7 {mov reg, imm_data}
       : begin
           DecodeOperandInfo(ORD(Instruction[1]),'11 111 reg', 0, _i1,_i2,_i3);
           ClearRegister(TRegister(_i3));
         end;

   $B8..$BF {mov reg, imm_data}
       : begin
           DecodeOperandInfo(ORD(Instruction[1]),'11 111 reg', 1, _i1,_i2,_i3);
           movRegOffset(TRegister(_i3), sOp);
         end;

   $C0,
   $C1
      : begin
          DecodeOperandInfo(ORD(Instruction[2]),'11 111 reg', Min(ORD(Instruction[1]) mod 2,1), _i1,_i2,_i3);
            if _i1=3 {i1 = 11} then
            begin
              if _i2 in [0, {i2 = 000 -> rol reg, imm_data}
                         1, {i2 = 001 -> ror reg, imm_data}
                         2, {i2 = 010 -> rcl reg, imm_data}
                         3, {i2 = 011 -> rcr reg, imm_data}
                         4, {i2 = 100 -> shl reg, imm_data}
                         5, {i2 = 101 -> shl reg, imm_data}
                         7] {i2 = 111 -> sar reg, imm_data}
                 then ClearRegister(TRegister(_i3));
            end;
         end;

   $C6, {mov reg, imm_data}
   $C7  {mov reg, imm_data}
      : begin
          DecodeOperandInfo(ORD(Instruction[2]),'11 111 reg', ORD(Instruction[1]) mod 2, _i1,_i2,_i3);
          ClearRegister(TRegister(_i3));
        end;
   $D0,
   $D1
      : begin
          DecodeOperandInfo(ORD(Instruction[2]),'11 111 reg', Min(ORD(Instruction[1]) mod 2,1), _i1,_i2,_i3);
            if _i1=3 {i1 = 11} then
            begin
              if _i2 in [0, {i2 = 000 -> rol reg, 1}
                         1, {i2 = 001 -> ror reg, 1}
                         2, {i2 = 010 -> rcl reg, 1}
                         3, {i2 = 011 -> rcr reg, 1}
                         4, {i2 = 100 -> shl reg, 1}
                         5, {i2 = 101 -> shl reg, 1}
                         7] {i2 = 111 -> sar reg, 1}
                 then ClearRegister(TRegister(_i3));
            end;
         end;

   $D2,
   $D3
      : begin
          DecodeOperandInfo(ORD(Instruction[2]),'11 111 reg', Min(ORD(Instruction[1]) mod 2,1), _i1,_i2,_i3);
            if _i1=3 {i1 = 11} then
            begin
              if _i2 in [0, {i2 = 000 -> rol reg, cl}
                         1, {i2 = 001 -> ror reg, cl}
                         2, {i2 = 010 -> rcl reg, cl}
                         3, {i2 = 011 -> rcr reg, cl}
                         4, {i2 = 100 -> shl reg, cl}
                         5, {i2 = 101 -> shl reg, cl}
                         7] {i2 = 111 -> sar reg, cl}
                 then ClearRegister(TRegister(_i3));
            end;
         end;

   $D4: {aam} if Instruction[2]=#$0A then ClearRegister(rgEAX);
   $D5: {aad} if Instruction[2]=#$0A then ClearRegister(rgEAX);

   $F6,
   $F7
      : begin
          DecodeOperandInfo(ORD(Instruction[2]),'11 111 reg', Min(ORD(Instruction[1]) mod 2,1), _i1,_i2,_i3);
            if _i1=3 {i1 = 11} then
            begin
              if _i2 in [2, {i2 = 010 -> not reg}
                         3, {i2 = 011 -> neg reg}
                         4, {i2 = 100 -> mul reg}
                         5, {i2 = 101 -> imul reg}
                         6, {i2 = 110 -> div reg}
                         7] {i2 = 110 -> idiv reg}
                 then
                 if (ORD(Instruction[1]) mod 2) =0
                   then ClearRegister(rgEAX)
                   else begin
                     ClearRegister(rgEAX);
                     ClearRegister(rgEDX);
                   end;
            end
            else begin
              if _i2= 5 {i2 = 101 -> imul reg}
                 then ClearRegister(rgEAX);
            end;
        end;
   $FE,
   $FF
      : begin
          DecodeOperandInfo(ORD(Instruction[2]),'11 111 reg', ORD(Instruction[1]) mod 2, _i1,_i2,_i3);
            if _i1=3 {i1 = 11} then
              begin
                {i2 = 000 -> inc reg}
                {i2 = 001 -> dec reg}
                {i2 = 010 -> call reg}
                {i2 = 110 -> push reg}
                ClearRegister(TRegister(_i3));
              end;

            if (_i1 in [1,2] {i1 = 01, 10}) and (_i2=2 {i2 = 010}) and (ORD(Instruction[1])=$FF)
              Then begin
                // The DOI CALL [REG+Offs] references case
                OffsInfReference(TRegister(i3), sOp);
              end;
        end;
  End;


  ////////////////////////////////////////////////////////////////
  // Because of bad emulation 
  //
  // One of them is a call to procedure or function
  // In future return type could be saved in DSF file for the
  // functions that will change EAX apropritely
  ////////////////////////////////////////////////////////////////
  // This stuff has been removed because the emulator had been
  // improved a lot !!!
  ////////////////////////////////////////////////////////////////
  // Dec Time-To-Live
  //-------------------------------------------------------------------------------------
  // For RegIdx:=rgEAX to rgESP do Dec(ExpireCounter[RegIdx]);
  //
  // Check for expired values and clear them
  //-------------------------------------------------------------------------------------
  // For RegIdx:=rgEAX to rgESP do if ExpireCounter[RegIdx]<0 then ClearRegister(RegIdx);
  ///////////////////////////////////////////////////////////////////////////////////////
end;


initialization
  ESP:=TStringList.Create;
  Loc_Names:=TStringList.Create;
  Loc_StrVals:=TStringList.Create;
  dwESP:=TList.Create;
  Loc_Vars:=TList.Create;
  OffsInfArchive:=TOffsInfArchive.Create;

finalization
  ESP.Free;
  Loc_Names.Free;
  Loc_StrVals.Free;
  dwESP.Free;
  Loc_Vars.Free;
  OffsInfArchive.Free;

end.
