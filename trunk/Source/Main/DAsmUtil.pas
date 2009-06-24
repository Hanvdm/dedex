unit DAsmUtil;
(*
The main disassembler module of the DCU32INT utility by Alexei Hmelnov.
----------------------------------------------------------------------------
E-Mail: alex@monster.icc.ru
http://monster.icc.ru/~alex/DCU/
----------------------------------------------------------------------------

See the file "readme.txt" for more details.

------------------------------------------------------------------------
                             IMPORTANT NOTE:
This software is provided 'as-is', without any expressed or implied warranty.
In no event will the author be held liable for any damages arising from the
use of this software.
Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute it
freely, subject to the following restrictions:
1. The origin of this software must not be misrepresented, you must not
   claim that you wrote the original software.
2. Altered source versions must be plainly marked as such, and must not
   be misrepresented as being the original software.
3. This notice may not be removed or altered from any source
   distribution.
*)
interface

uses
  FixUp;

const
  nf =  $40000000;
  nm =  nf-1;
  hEA = $7FFFFFFF;

  function Identic(I: integer): integer;
  function ReadByte(var B: integer): boolean;
  function UnReadByte: boolean;
  procedure SetPrefix(V: integer);
  procedure SetSuffix(V: integer);
  procedure SetOpName(V: integer);
  procedure SetCmdArg(V: integer);
  procedure SetOpPrefix(V: integer);
  procedure SetSeg(V: integer);
  function GetSeg: integer;
  function imPtr: boolean;
  //function im(DS: integer): boolean;
  function ImmedBW(DS: integer): boolean;
  //function imSExt(DS: integer): boolean;
  function imInt(DS: integer): boolean;
  function jmpOfs(DS: integer): boolean;
  function getEA(W: integer;var M,A: integer): boolean;
  function getImmOfsEA(W: integer;var A: integer): boolean;
  procedure setEASize(DS: integer);
  procedure setOS;
  procedure setAS;
  function GetAS: integer;
  function GetOS: integer;

type
  THBMName = integer;

  PBMTblProc = ^TBMTblProc;
  TBMTblProc = array[byte]of THBMName;

  TBMOpRec = string[7];

const
 {Command arguments}
  caReg    = 1;
  caEffAdr = 2;
  caImmed  = 3;
  caVal    = 4;
  caJmpOfs = 5;
  caInt    = 6;
  caMask   = $f;

const
  dsByte   = 1;
  dsWord   = 2;
  dsDbl    = 3;
  dsQWord  = 4;
  dsTWord  = 5;
  dsPtr    = 6;
  dsMask   = $7;
  dsToSize: array[0..7] of Cardinal = (0,1,2,4,8,10,4,0);

const
  hAX=0;
  hCX=1;
  hDX=2;
  hBX=3;
  hSP=4;
  hBP=5;
  hSI=6;
  hDI=7;
  hPresent=8;
  hWReg=$10;

const
  hBXF=hBX+hPresent;
  hBPF=hBP+hPresent;
  hSIF=(hSI+hPresent)shl 4;
  hDIF=(hDI+hPresent)shl 4;

const
  RMS : array[0..7] of Byte = (
    hBXF+hSIF,
    hBXF+hDIF,
    hBPF+hSIF,
    hBPF+hDIF,
         hSIF,
         hDIF,
    hBPF,
    hBXF
  ) ;
const
  hES=0;
  hCS=1;
  hSS=2;
  hDS=3;
  hFS=4;
  hGS=5;

  hNoSeg=7;
  hDefSeg=8;
  DefEASeg : array[0..7] of Byte = (
    hDS, hDS, hSS, hSS, hDS, hDS, hDS, hDS
  ) ;

type
  TRegNum=0..7;
  PEffAddr=^TEffAddr;
  TEffAddr=record
    hSeg:Byte;{0,dSize3,Seg4}
    hBase:Byte;{Index4,Base4}
    dOfs:Byte;{OfsSize3,Ofs5}
    SS: Byte;
    Fix: PFixupRec;
  end ;

  TCmArg=record
    Kind:integer{Byte};
    Inf:integer{Byte};
    Fix: PFixupRec;
  end ;

  PCmdInfo=^TCmdInfo;
  TCmdInfo=record
    PrefSize:Byte;
    hCmd:integer;
    EA:TEffAddr;
    Cnt:Byte;
    Arg:array[1..3] of TCmArg;
  end ;

var
  OpSeg: Byte;
  Cmd: TCmdInfo;
  CmdPrefix,CmdSuffix: integer;
  PrefixCnt: integer;
  PrefixTbl: array[0..10] of integer;
const
  AdrIs32Deft: boolean = true;
const
  OpIs32Deft: boolean = true;
  WordSize: array[boolean]of Byte = (2,4);
var
  AdrIs32: boolean;
  OpIs32: boolean;

var
  CodePtr, PrevCodePtr: PChar;

procedure ClearCommand;

function ReadCommand: boolean;

procedure ShowCommand;

var
  RegTbl:array[0..2] of PBMTblProc;
  SegRegTbl: PBMTblProc;

implementation

uses
  SysUtils, op, DCU_In, DCU_Out;


var {For unread}
  fxState0: TFixupState;

procedure ClearCommand;
begin
  PrevCodePtr := CodePtr;
  fillChar(Cmd,SizeOf(Cmd),0);
  OpSeg:=hDefSeg;
  CmdPrefix := 0;
  CmdSuffix := 0;
  PrefixCnt := 0;
  AdrIs32 := AdrIs32Deft;
  OpIs32 := OpIs32Deft;
  SaveFixupState(fxState0);
end ;

(*
function ReadCodeByte(var B: Byte): boolean;
{ This procedure can use fixup information to prevent parsing commands }
{ which contradict fixups }
var
  Fx: PFixupRec;
  F: Byte;
begin
  Result := false;
  if CodePtr>=CodeEnd then
    Exit {Memory block finished};
  SkipFixups(CodePtr-CodeStart);
  if CodePtr<FixUpEnd then
    Exit {Code can't be inside FixUp};
  repeat
    Fx := CurFixup(CodePtr-CodeStart);
    if Fx=Nil then
      Break;
    F := TByte4(Fx^.OfsF)[3];
    if F<fxStart then begin
      SetFixEnd;
      Exit {Code can't be inside FixUp};
    end ;
    if F=fxStart then begin
      if CodePtr>PrevCodePtr then
        Exit {Can't be inside a command};
     end
    else {if F=fxEnd then}
      Exit {Can't be inside a code};
  until not NextFixup(CodePtr-CodeStart);
  B := Byte(CodePtr^);
  Inc(CodePtr);
  Result := true;
end ;
*)

function ReadCodeByte(var B: Byte): boolean;
{ This procedure can use fixup information to prevent parsing commands }
{ which contradict fixups }
begin
  Result := ChkNoFixupIn(CodePtr,1);
  if not Result then
    Exit;
  B := Byte(CodePtr^);
  Inc(CodePtr);
  Result := true;
end ;

function ReadImmedData(Size:Cardinal; var Res: Byte; var Fix: PFixupRec): boolean;
begin
  Result := GetFixupFor(CodePtr,Size,false,Fix);
  if not Result then
    Exit;
  Res := CodePtr-PrevCodePtr;
  Inc(CodePtr,Size);
end ;

function Identic(I: integer): integer;
begin
  Result := i;
end ;

function ReadByte(var B: integer): boolean;
var
  B0: Byte;
begin
  Result := ReadCodeByte(B0);
  B := B0;
end ;

function UnReadByte: boolean;
begin
  Result := false;
  if CodePtr<=PrevCodePtr then
    Exit;
  Dec(CodePtr);
 {May be it's not necessary here, but it will be safer to playback fixups:}
  RestoreFixupState(fxState0);
  SkipFixups(CodePtr-CodeStart);
  Result := true;
end ;

procedure SetPrefix(V: integer);
begin
  CmdPrefix := V;
end ;

procedure SetSuffix(V: integer);
begin
  CmdSuffix := V;
end ;

procedure SetOpName(V: integer);
begin
  Cmd.hCmd := V;
end ;

procedure SetCmdArg(V: integer);
begin
//    Result := false;
  if Cmd.Cnt>=3 then
    Exit;
  Inc(Cmd.Cnt);
  with Cmd.Arg[Cmd.Cnt] do
   if V=hEA then
     Cmd.Arg[Cmd.Cnt].Kind := caEffAdr
   else if (V and nf)<>0 then begin
     Kind := caReg;
     Inf := V and nm;
    end
   else {if (V and $FFFFFF00)=0 then} begin
     Kind := caVal;
     Inf := V;
    end
   {else
     Exit};
end ;

procedure SetOpPrefix(V: integer);
begin
  PrefixTbl[PrefixCnt] := V;
  Inc(PrefixCnt);
end ;

procedure SetSeg(V: integer);
begin
  OpSeg := V;
end ;

function GetSeg: integer;
begin
  Result := OpSeg;
end ;

function im(DSize: integer): boolean;
const
  SizeTbl: array[1..6] of Cardinal = (
     SizeOf(Byte),
     SizeOf(Word),
     SizeOf(LongInt),
     8,
     10,
     SizeOf(Pointer)
  );
  PtrSize: array[boolean] of integer = (4,6);
var
  Size: Cardinal;
  imOfs: Byte;
begin
  Result := false;
  if Cmd.Cnt>=3 then
    Exit;
  Inc(Cmd.Cnt);
  if DSize=dsPtr then
    Size := PtrSize[OpIs32]
  else
    Size := SizeTbl[DSize];
  with Cmd.Arg[Cmd.Cnt] do begin
    Kind := caImmed+(DSize shl 4);
    if not ReadImmedData(Size,ImOfs,Fix) then
      Exit;
    Inf := ImOfs;
  end ;
  Result := true;
end ;

function imPtr: boolean;
begin
  Result := im(dsPtr);
end ;

function ImmedBW(DS: integer): boolean;
const
  BWTbl: array[0..3] of Byte = (dsByte,dsWord,dsDbl,dsQWord);
begin
  Result := im(BWTbl[DS and 3]);
end ;
(*
function imSExt(S,W: integer): boolean;
const
  BWTbl: array[0..1] of Byte = (dsByte,dsWord);
var
  SExt: Byte;
begin
  Result := false;
  SExt := S and $1;
  if not im(BWTbl[(W and 1)and not (SExt){��� SExt - ������������ ������. ����}])
  then
    Exit;
  if SExt<>0 then
   with Cmd.Arg[Cmd.Cnt] do
     Kind := Kind and not caMask or caInt;
  Result := true;
end ;
*)

function imInt(DS: integer): boolean;
begin
  Result := ImmedBW(DS);
  if Result then
   with Cmd.Arg[Cmd.Cnt] do
     Kind := caInt+(Kind and not caMask);
end ;

function jmpOfs(DS: integer): boolean;
begin
  Result := ImmedBW(DS);
  if Result then
   with Cmd.Arg[Cmd.Cnt] do
     Kind := caJmpOfs+(Kind and not caMask);
end ;

function getEA(W: integer;var M,A: integer): boolean;
var
  CurB,Up2,Lo3,SIB : Byte ;
  OpSize:byte;
  imOfs: Byte;
begin
  Result := false;
  OpSize := (W and 3);
  if OpSize>=3 then
    Exit;
  if not ReadCodeByte(CurB) then
    Exit;
  Up2 := CurB shr 6 ;
  Lo3 := CurB and 7 ;
  M := (CurB shr 3)and $7;
  if Up2=3 then
    A := RegTbl[OpSize]^[Lo3]
  else begin
    A := hEA;
    if AdrIs32 then begin
      Cmd.EA.hBase := Lo3+hPresent;
      if Lo3=hSP then begin {SIB}
        if not ReadCodeByte(SIB) then
          Exit;
        Cmd.EA.SS := SIB shr 6;
        Lo3 := SIB and 7 ;
        if (Lo3=hBP)and(Up2=0) then begin
          Up2 := 2;
          Lo3 := 0;
         {Base=EBP & mod=0 => Base=None & disp32}
         end
        else
          Inc(Lo3,hPresent);
        SIB := (SIB shr 3)and 7{Index};
        if SIB<>hSP then
          SIB := SIB+hPresent
        else
          SIB := 0;
        Cmd.EA.hBase := Lo3+SIB shl 4;
       end
      else if (Up2=0)and(Lo3 = hBP) then begin
        Cmd.EA.hBase := 0;
        if not ReadImmedData(SizeOf(LongInt),ImOfs,Cmd.EA.Fix) then
          Exit;
        Cmd.EA.dOfs := dsDbl shl 5 or ImOfs;
        Lo3 := 0;{For OpSeg}
      end;
     end
    else begin
      Cmd.EA.hBase := RMS[Lo3];
      if (Up2=0)and(Lo3 = 6) then begin
        Cmd.EA.hBase := 0;
        if not ReadImmedData(SizeOf(Word),ImOfs,Cmd.EA.Fix) then
          Exit;
        Cmd.EA.dOfs := dsWord shl 5 or ImOfs;
        Lo3 := 0;{For OpSeg}
      end ;
    end ;
    Case Up2 of
      1: begin
        if not ReadImmedData(SizeOf(Byte),ImOfs,Cmd.EA.Fix) then
          Exit;
        Cmd.EA.dOfs := dsByte shl 5 or ImOfs;
      end ;
      2: begin
        if not ReadImmedData(WordSize[AdrIs32],ImOfs,Cmd.EA.Fix) then
          Exit;
        Cmd.EA.dOfs := (dsWord+Ord(AdrIs32)){dsWord} shl 5 or ImOfs; 
      end ;
    End ;
    {GetMemStr := GetSegStr+'['+MS+']' ;}
    if OpSeg=hDefSeg then
      OpSeg := hDefSeg or DefEASeg[Lo3 and 7];
    Cmd.EA.hSeg := OpSeg or (OpSize+1)shl 4;
  end ;
  Result := CodePtr<=CodeEnd;
end ;

function getImmOfsEA(W: integer;var A: integer): boolean;
var
  CurB,Up2,Lo3 : Byte ;
  OpSize:byte;
  imOfs: Byte;
begin
  Result := false;
  OpSize := W and $1;
  if OpSize>0 then
    OpSize := 1+Ord(OpIs32);
  A := hEA;
  if not ReadImmedData(WordSize[AdrIs32],ImOfs,Cmd.EA.Fix) then
    Exit;
  Cmd.EA.dOfs := (dsWord+Ord(AdrIs32)){dsWord} shl 5 or ImOfs;
  if OpSeg=hDefSeg then
    OpSeg := hDefSeg or hDS;
  Cmd.EA.hSeg := OpSeg or (OpSize+1)shl 4;
  Result := CodePtr<=CodeEnd;
end ;

procedure setEASize(DS: integer);
var
  S: Byte;
begin
  S := DS;
  if S>=7 then
    Exit;
  Cmd.EA.hSeg := Cmd.EA.hSeg and $f or S shl 4;
end ;

procedure setOS;
begin
  OpIs32 := not OpIs32Deft;
end ;

procedure setAS;
begin
  AdrIs32 := not AdrIs32Deft;
end ;

function GetAS: integer;
begin
  Result := Ord(AdrIs32);
end ;

function GetOS: integer;
begin
  Result := Ord(OpIs32);
end ;

function ReadCommand: boolean;
begin
  ClearCommand;
  Result := ReadOp;
end ;

procedure WriteBMOpName(hN: THBMName);
begin
  PutS(GetOpName(hN));
end ;

procedure WriteInt(i:integer);
begin
  PutSFmt('%d',[i]);
end ;

procedure WriteImmed(hDSize,Ofs:Byte; MayBeAddr: boolean; Fix: PFixupRec);
var
  DP,DP1: Pointer;
  IsAddr: boolean;
  A: Pointer;
  Fixed: boolean;
  V: LongInt;
begin
  DP := PrevCodePtr+Ofs;
  Fixed := ReportFixUp(Fix);
//  if (ReportFixUp(Cardinal(DP)-Cardinal(CodeStart),hDSize and dsMask,DP)=0{<>0})
//  then begin
    IsAddr := MayBeAddr and((Ord(AdrIs32Deft)+dsWord)=hDSize);
    if IsAddr then begin
      if hDSize=dsWord then
        LongInt(A) := Word(DP^)
      else
        LongInt(A) := LongInt(DP^);
//      StartStrInfo(siDataAddr,A);
    end ;
    if Fixed and(hDSize and dsMask<>dsDbl) then
      PutS('+');
    Case hDSize and dsMask of
      dsByte: PutSFmt('$%2.2x',[Byte(DP^)]);
      dsWord: PutSFmt('$%4.4x',[Word(DP^)]);
      dsDbl: begin
          V := LongInt(DP^);
          if Fixed then begin
            Fixed := V=0;
            if not Fixed then
              PutS('+');
          end ;
          if not Fixed then
            PutSFmt('$%8.8x',[V]);
        end ;
      dsPtr:  if not OpIs32 then
                PutSFmt('$%8.8x',[LongInt(DP^)])
              else begin
                DP1 := DP;
                Inc(integer(DP1),4);
                PutSFmt('$%4.4x:$%8.8x',[Word(DP1^),LongInt(DP^)]);
              end ;
      dsQWord: PutS(CharDumpStr(DP^,8));
      dsTWord: PutS(CharDumpStr(DP^,10));
    else
      PutS('?Immed');
    End ;
//    if IsAddr then
//      EndStrInfo;
//  end ;
end ;

function WriteIntData(SignRq,FixSignRq: boolean;hDSize,Ofs:Byte; Fix: PFixupRec): LongInt;
var
  DP: Pointer;
  DOfs: LongInt;
  Fixed: boolean;
  V: LongInt;
begin
  DP := PrevCodePtr+Ofs;
  Case hDSize and dsMask of
    dsByte: DOfs := ShortInt(DP^);
    dsWord: DOfs := SmallInt(DP^);
    dsDbl:  DOfs := LongInt(DP^);
  else
    PutS('?Int');
    Exit;
  End ;
  if SignRq and ((DOfs>0)or FixSignRq and FixupOk(Fix)) then
    PutS('+');
//  if (ReportFixUp(Cardinal(DP)-Cardinal(CodeStart),hDSize and dsMask,DP)=0{<>0})
//  then
   Fixed := ReportFixUp(Fix);
   if Fixed and(hDSize and dsMask<>dsDbl) then
     PutS('+');
   Case hDSize and dsMask of
     dsByte: WriteInt(ShortInt(DP^));
     dsWord: WriteInt(SmallInt(DP^));
     dsDbl: begin
       V := LongInt(DP^);
       if Fixed then begin
         Fixed := V=0;
         if not Fixed then
           PutS('+');
       end ;
       if not Fixed then
         WriteInt(LongInt(DP^));
     end ;
   End ;
  WriteIntData := DOfs;
end ;

procedure WriteJmpOfs(hDSize,Ofs:Byte; Fix: PFixupRec);
var
  DOfs: LongInt;
begin
  DOfs := WriteIntData(true,false,hDSize,Ofs,Fix);
  if Fix=Nil then begin
    PutS('; (');
    PutSFmt('0x%x',[(CodePtr-CodeBase)+DOfs]);
    PutS(')');
  end ;
end ;

function ReportImmed(IsInt,SignRq: boolean;DSF,hDSize,SegN,Ofs:Byte;
  Fix: PFixupRec): boolean;
var
  RepRes: Byte;
begin
  {if ReportDataRefsOn then
    RepRes := ReportDataRefs(SignRq,DSF,hDSize,SegN,Ofs)
  else}
    RepRes := 0;
  if RepRes>1 then
    PutS('{');
  if (not IsInt)or(RepRes>0) then begin
    if SignRq then
      PutS('+');
    WriteImmed(hDSize,Ofs,RepRes>0,Fix);
   end
  else
    WriteIntData(SignRq,true,hDSize,Ofs,Fix);
  if RepRes>1 then
    PutS('}');
  ReportImmed := RepRes>1;
end ;

procedure WriteEA;
var
  SegN,DSF: Byte;
  Cnt:integer;
  RepRes: boolean;

  procedure Plus;
  begin
    if Cnt>0 then
      PutS('+');
    Inc(Cnt);
  end ;

  procedure WriteReg(hReg,SS:Byte);
  const
    ScaleStr: array[0..3] of String[3] = ('','2*','4*','8*');
  begin
    if hReg and hPresent=0 then
      Exit;
    Plus;
    if (SS>0)and(SS<=3) then begin
      PutS(ScaleStr[SS]);
    end ;
    WriteBMOpName(RegTbl[1+Ord(AdrIs32)]^[hReg and $7]);
  end ;

begin
  DSF := (Cmd.EA.hSeg shr 4)and dsMask;
  Case DSF of
    0:;
    dsByte: PutS('BYTE');
    dsWord: PutS('WORD');
    dsDbl:  PutS('DWORD');
    dsPtr:  PutS('DWORD');
    dsQWord:PutS('QWORD');
    dsTWord:PutS('TWORD');
  else
    PutS('?');
  End ;
  if DSF<>0 then
    PutS(' PTR ')
  else
    PutS(' ');
  SegN := Cmd.EA.hSeg and $f;
  if SegN<hDefSeg then begin
    WriteBMOpName(SegRegTbl^[segN]);
    PutS(':');
  end ;
  Cnt := 0;
  PutS('[');
  WriteReg(Cmd.EA.hBase and $f,0);
  WriteReg(Cmd.EA.hBase shr 4,Cmd.EA.SS);
  if Cmd.EA.dOfs<>0 then
    ReportImmed(Cnt>0,Cnt>0,DSF,
            Cmd.EA.dOfs shr 5,SegN and $7,Cmd.EA.dOfs and $1f,Cmd.EA.Fix);
  PutS(']');
end ;

procedure WriteArg(const A: TCmArg);
begin
  Case A.Kind and caMask of
    caReg: WriteBMOpName(A.Inf);
    caEffAdr:WriteEA;
    caVal: PutSFmt('$%x',[A.Inf]);
    caImmed: ReportImmed(false,false,0,A.Kind shr 4,hCS,A.Inf,A.Fix);
           {WriteImmed(A.Kind shr 4,A.Inf,false);}
    caJmpOfs: WriteJmpOfs(A.Kind shr 4,A.Inf,A.Fix);
    caInt: ReportImmed(true,false,0,A.Kind shr 4,hCS,A.Inf,A.Fix);
           {WriteIntData(false,falseA.Kind shr 4,A.Inf);}
  else
    PutS('?');
  End ;
end ;

procedure ShowCommand;
var
  i: integer;
  OpName: String[10];
  SeprChar: Char;
begin
//  ReportCommandMem;
  for i:=0 to PrefixCnt-1 do begin
    WriteBMOpName(PrefixTbl[i]);
    PutS(' ');
  end ;
  OpName := GetOpName(Cmd.hCmd);
  SeprChar := ' ';
  if OpName[Length(OpName)]='_' then
    Dec(Byte(OpName[0]))
  else begin
    if CmdSuffix=0 then begin
      Inc(Byte(OpName[0]));
      OpName[Length(OpName)] := ' ';
    end ;
    SeprChar := ',';
  end ;
  if CmdPrefix<>0 then
    WriteBMOpName(CmdPrefix);
  PutS(OpName);
  if CmdSuffix<>0 then begin
    WriteBMOpName(CmdSuffix);
    PutS(' ');
  end ;
  for i:=1 to Cmd.Cnt do begin
    if i>1 then begin
      PutS(SeprChar);
      SeprChar := ',';
    end ;
    WriteArg(Cmd.Arg[i]);
  end ;
end ;

end.
