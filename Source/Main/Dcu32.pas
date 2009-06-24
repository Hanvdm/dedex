unit DCU32;
(*
The DCU parser module of the DCU32INT utility by Alexei Hmelnov.
(All the DCU data structures are described here)
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
  SysUtils, Classes, op, DAsmUtil, DCU_In, DCU_Out, FixUp;

{$IFNDEF VER90}
 {$IFNDEF VER100}
  {$REALCOMPATIBILITY ON}
 {$ENDIF}
{$ENDIF}

const {My own (AX) codes for Delphi/Kylix versions}
  verD2=2;
  verD3=3;
  verD4=4;
  verD5=5;
  verD6=6;
  verK1=100; //Kylix

{ Internal unit types }
const
  drStop=#0;
  drStop_a='a'; //Last Tag in all files
  drStop1='c';
  drUnit='d';
  drUnit1='e'; //in implementation
  drImpType='f';
  drImpVal='g';
  drDLL='h';
  drExport='i';
  drEmbeddedProcStart='j';
  drEmbeddedProcEnd='k';
  drCBlock='l';
  drFixUp='m';
  drImpTypeDef='n'; //import of type definition by "A = type B"
  drSrc='p';
  drObj='q';
  drRes='r';
  drStop2='Ÿ'; //!!!
  drConst=#$25; //'%';
  drResStr='2';
  drType='*';
  drTypeP='&';
  drProc='(';
  drSysProc=')';
  drVoid='@';
  drVar=#$20; //' '
  drThreadVar='1';
  drVarC=#$27; //''';
  drBoolRangeDef='A';
  drChRangeDef='B';
  drEnumDef='C';
  drRangeDef='D';
  drPtrDef='E';
  drClassDef='F';
  drObjVMTDef='G';
  drProcTypeDef='H';
  drFloatDef='I';
  drSetDef='J';
  drShortStrDef='K';
  drArrayDef='L';
  drRecDef='M';
  drObjDef='N';
  drFileDef='O';
  drTextDef='P';
  drWCharRangeDef='Q'; //WideChar
  drStringDef='R';
  drVariantDef='S';
  drInterfaceDef='T';
  drWideStrDef='U';
  drWideRangeDef='V';

//Various tables
  drCodeLines=#$90;
  drLinNum=#$91;
  drStrucScope=#$92;
  drSymbolRef=#$93;
  drUnitFlags=#$96;

//Kylix specific flags
{  drUnit3=#$E0; //4-bytes record, present in almost all units
  drUnit3c=#$06; //4-bytes record, present in System, SysInit
}
  drUnit4=#$0F; //5-bytes record, was observed in QOpenBanner.dcu only

  arVal='!';
  arVar='"';
  arResult='#';
  arAbsLocVar='$';
  arLabel='+';
//Fields
  arFld=',';
  arMethod='-';
  arConstr='.';
  arDestr='/';
  arProperty='0';
  arSetDeft=#$9A;

  arCDecl=#$81;
  arPascal=#$82;
  arStdCall=#$83;
  arSafeCall=#$84;

const
  {Local flags}
  lfClass = $1;{class procedure }
  lfPrivate = $0;
  lfPublic = $2;
  lfProtected = $4;
  lfPublished = $A;
  lfScope = $0E { $0F};
  lfDeftProp = $20;
  lfOverride = $20;
  lfVirtual = $40;
  lfDynamic = $80;

type
  TProcCallTag=arCDecl..arSafeCall;

type
TDefNDX = TNDX;

PNDXTbl = ^TNDXTbl;
TNDXTbl = array[Byte]of TNDX;

PDef = ^Pointer;
PNameDef = ^TNameDef;
TNameDef = packed record
  Tag: TDCURecTag;
  Name: ShortString;
end ;

type
{ Auxiliary data types }

TDeclListKind = (dlMain,dlMainImpl,dlArgs,dlArgsT,dlEmbedded,dlFields,
  dlClass,dlInterface,dlDispInterface);

TDeclSepFlags = set of (dsComma,dsLast,dsNoFirst,dsNL,dsSoftNL,dsOfsProc);

TDeclSecKind = (skNone,skLabel,skConst,skType,skVar,skThreadVar,skResStr,
  skExport,skProc,skPrivate,skProtected,skPublic,skPublished);

TDeclSecKinds = set of TDeclSecKind;

const
  RecSecKinds: TDeclSecKinds = [];
  ProcSecKinds: TDeclSecKinds = [];
  BlockSecKinds: TDeclSecKinds = [skNone,skLabel,skConst,skType,skVar,
    skThreadVar,skResStr,skExport,skProc];
  ClassSecKinds: TDeclSecKinds = [skPrivate,skProtected,skPublic, skPublished];

type

PSrcFileRec = ^TSrcFileRec;
TSrcFileRec = record
  Next: PSrcFileRec;
  Def: PNameDef;
  FT: LongInt;
  B: Byte;
end ;

type
TDCURec = class
  Next: TDCURec;
  function GetName: PName; virtual; abstract;
  function SetMem(MOfs,MSz: Cardinal): Cardinal {Rest}; virtual;
  procedure ShowName; virtual; abstract;
  procedure Show; virtual; abstract;
  property Name: PName read GetName;
end ;

TBaseDef = class(TDCURec)
  FName: PName;
  Def: PDef;
  hUnit: integer;
  constructor Create(AName: PName; ADef: PDef; AUnit: integer);
  procedure ShowName; override;
  procedure Show; override;
  procedure ShowNamed(N: PName);
  function GetName: PName; override;
end ;

TImpKind=Char;

TImpDef = class(TBaseDef)
  ik: TImpKind;
  ImpRec: TDCURec;
  Inf: integer;
  constructor Create(AIK: TImpKind; AName: PName; AnInf: integer; ADef: PDef; AUnit: integer);
  procedure Show; override;
//  procedure GetImpRec;
end ;

TDLLImpRec = class(TBaseDef{TImpDef})
  NDX: integer;
  constructor Create(AName: PName; ANDX: integer; ADef: PDef; AUnit: integer);
  procedure Show; override;
end ;

TImpTypeDefRec = class(TImpDef{TBaseDef})
  RTTIOfs,RTTISz: Cardinal; //L: Byte;
  hImpUnit: integer;
  ImpName: PName;
  constructor Create(AName: PName; AnInf: integer; ARTTISz: Cardinal{AL: Byte}; ADef: PDef; AUnit: integer);
  procedure Show; override;
  function SetMem(MOfs,MSz: Cardinal): Cardinal {Rest}; override;
end ;

type

TNameDecl = class(TDCURec)
  Def: PNameDef;
  hDecl: integer;
  constructor Create;
  procedure ShowName; override;
  procedure Show; override;
  procedure ShowDef(All: boolean); virtual;
  function GetName: PName; override;
  function GetSecKind: TDeclSecKind; virtual;
  function IsVisible(LK: TDeclListKind): boolean; virtual;
end ;

TNameFDecl = class(TNameDecl)
  F: TNDX;
  Inf: integer;
  constructor Create;
  procedure Show; override;
  function IsVisible(LK: TDeclListKind): boolean; override;
end ;

TTypeDecl = class(TNameFDecl)
  hDef: TDefNDX;
  constructor Create;
  function IsVisible(LK: TDeclListKind): boolean; override;
  procedure Show; override;
  function SetMem(MOfs,MSz: Cardinal): Cardinal {Rest}; override;
  function GetSecKind: TDeclSecKind; override;
end ;

TVarDecl = class(TNameFDecl)
  hDT: TDefNDX;
  Ofs: Cardinal;
  constructor Create;
  procedure Show; override;
  function GetSecKind: TDeclSecKind; override;
end ;

TVarCDecl = class(TVarDecl)
  Sz: Cardinal;
  OfsR: Cardinal;
  constructor Create(OfsValid: boolean);
  procedure Show; override;
  function SetMem(MOfs,MSz: Cardinal): Cardinal {Rest}; override;
  function GetSecKind: TDeclSecKind; override;
end ;

TTypePDecl = class(TVarCDecl{TTypeDecl})
  {B1: Byte;
  constructor Create;}
  constructor Create;
  procedure Show; override;
  function IsVisible(LK: TDeclListKind): boolean; override;
end ;

TThreadVarDecl = class(TVarDecl)
  function GetSecKind: TDeclSecKind; override;
end ;

TLabelDecl = class(TNameDecl)
  Ofs: Cardinal;
  constructor Create;
  procedure Show; override;
  function GetSecKind: TDeclSecKind; override;
  function IsVisible(LK: TDeclListKind): boolean; override;
end ;

TExportDecl = class(TNameDecl)
  hSym,Index: TNDX;
  constructor Create;
  procedure Show; override;
  function GetSecKind: TDeclSecKind; override;
end ;

TLocalDecl = class(TNameDecl)
  LocFlags: TNDX;
  hDT: TDefNDX;
  NDXB: TNDX;//B: Byte; //Interface only
  Ndx: TNDX;
  constructor Create(LK: TDeclListKind);
  procedure Show; override;
  function GetSecKind: TDeclSecKind; override;
end ;

TMethodDecl = class(TLocalDecl)
  InIntrf: boolean;
  hImport: TNDX; //for property P:X read Proc{virtual,Implemented in parent class}
  constructor Create(LK: TDeclListKind);
  procedure Show; override;
end ;

{TSetDeft struc pas
  sd: Cardinal;
ends
}

TPropDecl = class(TNameDecl)
  LocFlags: TNDX;
  hDT: TNDX;
  Ndx: TNDX;
  hIndex: TNDX;
  hRead: TNDX;
  hWrite: TNDX;
  hStored: TNDX;
  hDeft: TNDX;
  constructor Create;
  procedure Show; override;
  function GetSecKind: TDeclSecKind; override;
end ;

TDispPropDecl = class(TLocalDecl)
  procedure Show; override;
end ;

TConstDeclBase = class(TNameFDecl)
  hDT: TDefNDX;
  hX: Cardinal; //Ver>4
  ValPtr: Pointer;
  ValSz: Cardinal;
  Val: integer;
  constructor Create;
  procedure ReadConstVal;
  procedure ShowValue;
  procedure Show; override;
  function GetSecKind: TDeclSecKind; override;
end ;

TConstDecl = class(TConstDeclBase)
  constructor Create;
end ;
{
TResStrDef = class(TConstDeclBase)
  NDX: TNDX;
  NDX1: TNDX;
  B1: Byte;
  B2: Byte;
  V: TNDX; //Data type again - AnsiString
  RefOfs,RefSz: Cardinal;
  constructor Create;
  procedure Show; override;
  procedure SetMem(MOfs,MSz: Cardinal); override;
end ;}

TResStrDef = class(TVarCDecl)
  OfsR: Cardinal;
  constructor Create;
  procedure Show; override;
  function GetSecKind: TDeclSecKind; override;
end ;

TSetDeftInfo=class(TNameDecl{TDCURec, but it should be included into NameDecl list})
  hConst,hArg: TDefNDX;
  constructor Create;
  procedure Show; override;
end ;

(*
TProcDeclBase = class(TNameDecl)
  CodeOfs,AddrBase: Cardinal;
  Sz: TDefNDX;
  constructor Create;
  function SetMem(MOfs,MSz: Cardinal): Cardinal {Rest}; override;
  function GetSecKind: TDeclSecKind; override;
end ;
*)

TSysProcDecl = class(TNameDecl{TProcDeclBase})
  F: TNDX;
  Ndx: TNDX;
//  CodeOfs: Cardinal;
  constructor Create;
  procedure Show; override;
  function GetSecKind: TDeclSecKind; override;
end ;

TProcCallKind = (pcRegister,pcCdecl,pcPascal,pcStdCall,pcSafeCall);

TProcDecl = class(TNameFDecl{TProcDeclBase})
  CodeOfs,AddrBase: Cardinal;
  Sz: TDefNDX;
 {---}
  B0: TNDX;
  VProc: TNDX;
  hDTRes: TNDX;
  Args: TNameDecl;
  Locals: TNameDecl;
  Embedded: TNameDecl;
  CallKind: TProcCallKind;
  IsMethod: boolean; //may be this information is encoded by some flag, but
    //I can't detect it. May be it would be enough to analyse the structure of
    //the procedure name, but this way it will be safer.
  constructor Create(AnEmbedded: TNameDecl);
  destructor Destroy; override;
  function IsUnnamed: boolean;
  function SetMem(MOfs,MSz: Cardinal): Cardinal {Rest}; override;
  function GetSecKind: TDeclSecKind; override;
  procedure ShowArgs;
  function IsProc: boolean;
  procedure ShowDef(All: boolean); override;
  procedure Show; override;
  function IsVisible(LK: TDeclListKind): boolean; override;
end ;

(*
TAtDecl = class(TNameDecl)
  //May be start of implementation?
  NDX: TNDX;
  NDX1: TNDX;
  constructor Create;
  procedure Show; virtual;
end ;
*)
type

TTypeDef = class(TBaseDef)
//  hDecl: integer;
  RTTISz: TNDX; //Size of RTTI for type, if available
  Sz: TNDX; //Size of corresponding variable
  V: TNDX;
  RTTIOfs: Cardinal;
  constructor Create;
  procedure ShowBase;
  procedure Show; override;
  function SetMem(MOfs,MSz: Cardinal): Cardinal {Rest}; override;
  function ShowValue(DP: Pointer; DS: Cardinal): integer {Size used}; virtual;
end ;

TRangeBaseDef = class(TTypeDef)
  hDTBase: TNDX;
  LH: Pointer;
  {Lo: TNDX;
  Hi: TNDX;}
  B: Byte;
  procedure GetRange(var Lo,Hi: TInt64Rec);
  function ShowValue(DP: Pointer; DS: Cardinal): integer {Size used}; override;
  procedure Show; override;
end ;

TRangeDef = class(TRangeBaseDef)
  constructor Create;
end ;

TEnumDef = class(TRangeBaseDef)
  Ndx: TNDX;
  NameTbl: TList;
  constructor Create;
  destructor Destroy; override;
  function ShowValue(DP: Pointer; DS: Cardinal): integer {Size used}; override;
  procedure Show; override;
end ;

TFloatDef = class(TTypeDef)
  B: Byte;
  constructor Create;
  function ShowValue(DP: Pointer; DS: Cardinal): integer {Size used}; override;
  procedure Show; override;
end ;

TPtrDef = class(TTypeDef)
  hRefDT: TNDX;
  constructor Create;
  function ShowRefValue(Ndx: TNDX; Ofs: Cardinal): boolean;
  function ShowValue(DP: Pointer; DS: Cardinal): integer {Size used}; override;
  procedure Show; override;
end ;

TTextDef = class(TTypeDef)
  procedure Show; override;
end ;

TFileDef = class(TTypeDef)
  hBaseDT: TNDX;
  constructor Create;
  procedure Show; override;
end ;

TSetDef = class(TTypeDef)
  BStart: Byte; //0-based start byte number
  hBaseDT: TNDX;
  constructor Create;
  function ShowValue(DP: Pointer; DS: Cardinal): integer {Size used}; override;
  procedure Show; override;
end ;

TArrayDef = class(TTypeDef)
  B1: Byte;
  hDTNdx: TNDX;
  hDTEl: TNDX;
  constructor Create;
  function ShowValue(DP: Pointer; DS: Cardinal): integer {Size used}; override;
  procedure Show; override;
end ;

TShortStrDef = class(TArrayDef)
  function ShowValue(DP: Pointer; DS: Cardinal): integer {Size used}; override;
  procedure Show; override;
end ;

TStringDef = class(TArrayDef)
  function ShowStrConst(DP: Pointer; DS: Cardinal): integer {Size used};
  function ShowRefValue(Ndx: TNDX; Ofs: Cardinal): boolean;
  function ShowValue(DP: Pointer; DS: Cardinal): integer {Size used}; override;
  procedure Show; override;
end ;

TVariantDef = class(TTypeDef)
  B: byte;
  constructor Create;
  procedure Show; override;
end ;

TObjVMTDef = class(TTypeDef)
  hObjDT: TNDX;
  Ndx1: TNDX;
  constructor Create;
  procedure Show; override;
end ;

TRecBaseDef = class(TTypeDef)
  Fields: TNameDecl;
  procedure ReadFields(LK: TDeclListKind);
  function ShowFieldValues(DP: Pointer; DS: Cardinal): integer {Size used};
  destructor Destroy; override;
end ;

TRecDef = class(TRecBaseDef)
  B2: Byte;
  constructor Create;
  function ShowValue(DP: Pointer; DS: Cardinal): integer {Size used}; override;
  procedure Show; override;
end ;

TProcTypeDef = class(TRecBaseDef)
  NDX0: TNDX;//B0: Byte; //Ver>2
  hDTRes: TNDX;
  AddStart: Pointer;
  AddSz: Cardinal; //Ver>2
  CallKind: TProcCallKind;
  constructor Create;
  function IsProc: boolean;
  function ShowValue(DP: Pointer; DS: Cardinal): integer {Size used}; override;
  function ProcStr: String;
  procedure ShowDecl(Braces: PChar);
  procedure Show; override;
end ;

TObjDef = class(TRecBaseDef)
  B03: Byte;
  hParent: TNDX;
  BFE: Byte;
  Ndx1: TNDX;
  B00: Byte;
  constructor Create;
  function ShowValue(DP: Pointer; DS: Cardinal): integer {Size used}; override;
  procedure Show; override;
end ;

TClassDef = class(TRecBaseDef)
  hParent: TNDX;
//  InstBase: TTypeDef;
  InstBaseRTTISz: TNDX; //Size of RTTI for type, if available
  InstBaseSz: TNDX; //Size of corresponding variable
  InstBaseV: TNDX;
  Ndx2: TNDX;//B00: Byte
  NdxFE: TNDX;//BFE: Byte
  Ndx00a: Byte;//B00a: Byte
  B04: Byte;
//%$IF Ver>2;
  ICnt: TNDX;
// DAdd: case @.B00b=0 of
  {DAddB0: Byte;
  DAddB1: Byte;}
  ITbl: PNDXTbl;
// endc
//$END
  constructor Create;
  destructor Destroy; override;
  function ShowValue(DP: Pointer; DS: Cardinal): integer {Size used}; override;
  procedure Show; override;
end ;

TInterfaceDef = class(TRecBaseDef)
  hParent: TNDX;
  Ndx1: TNDX;
  GUID: PGUID;
  B: Byte;
  constructor Create;
  procedure Show; override;
end ;

TVoidDef = class(TTypeDef)
  procedure Show; override;
end ;

type //AUX, not real file structures

PCodeLineRec = ^TCodeLineRec;
TCodeLineRec = record
  Ofs,L: integer;
end ;

PCodeLineTbl = ^TCodeLineTbl;
TCodeLineTbl = array[Word] of TCodeLineRec;

type

TUnit = class;

PUnitImpRec = ^TUnitImpRec;
TUnitImpFlags = set of (ufImpl,ufDLL);
TUnitImpRec = record
  Ref: TImpDef;
  Name: PName;
  Decls: TBaseDef;
//  Types: TBaseDef;
//  Addrs: TBaseDef;
  Flags: TUnitImpFlags;
  U: TUnit;
end ;

TUnit = class
protected
  FMemPtr: PChar;
  FMemSize: Cardinal;
  FVer: integer;
  FStamp,FFlags,FUnitPrior: integer;
  FFName, FUnitName: String;
  FSrcFiles: PSrcFileRec;
  FUnitImp: TList;
  FTypes: TList;
  FAddrs: TList;
  FExportNames: TStringList;
  FDecls: TNameDecl;
//  FDefs: TBaseDef;
  FTypeDefCnt: integer;
  FTypeShowStack: TList;
 {Data block}
  FDataBlPtr: PChar;
  FDataBlSize: Cardinal;
  FDataBlOfs: Cardinal;
 {Fixups}
//  FfxStart,FfxEnd: Byte;
  FFixupCnt: integer;
  FFixupTbl: PFixupTbl;
  FCodeLineCnt: integer;
  FCodeLineTbl: PCodeLineTbl;
  procedure ReadSourceFiles;
  procedure ShowSourceFiles;
  function ShowUses(PfxS: String; FRq: TUnitImpFlags): boolean;
  procedure ReadUses(TagRq: TDCURecTag);
  procedure SetListDefName(L: TList; hDef: integer; Name: PName);
  procedure AddTypeName(hDef: integer; Name: PName);
  procedure AddTypeDef(TD: TTypeDef);
  function AddAddrDef(ND: TDCURec): integer;
  procedure SetDeclMem(hDef: integer; Ofs,Sz: Cardinal);
//  procedure AddAddrName(hDef: integer; Name: PName);
  function GetTypeDef(hDef: integer): TTypeDef;
  function GetTypeName(hDef: integer): PName;
  function GetAddrDef(hDef: integer): TDCURec;
  function GetAddrName(hDef: integer): PName;
  function GetGlobalTypeDef(hDef: integer; var U: TUnit): TTypeDef;
  function GetGlobalAddrDef(hDef: integer; var U: TUnit): TDCURec;
  function GetTypeSize(hDef: integer): integer;
  function ShowTypeValue(T: TTypeDef; DP: Pointer; DS: Cardinal;
     IsConst: boolean): integer {Size used};
  function ShowGlobalTypeValue(hDef: TNDX; DP: Pointer; DS: Cardinal;
    AndRest,IsConst: boolean): integer {Size used};
  function ShowGlobalConstValue(hDef: integer): boolean;
  procedure ShowTypeDef(hDef: integer; N: PName);
  function ShowTypeName(hDef: integer): boolean;
  function TypeIsVoid(hDef: integer): boolean;
{-------------------------}
  function GetUnitImpRec(hUnit: integer): PUnitImpRec;
  function GetUnitImp(hUnit: integer): TUnit;
  procedure SetExportNames(Decl: TNameDecl);
  procedure SetEnumConsts(var Decl: TNameDecl);
  function GetExportDecl(Name: String; Stamp: integer): TNameFDecl;
  function GetExportType(Name: String; Stamp: integer): TTypeDef;
{-------------------------}
  procedure ReadDeclList(LK: TDeclListKind; var Result: TNameDecl);
  procedure LoadFixups;
  procedure LoadCodeLines;
  function GetStartFixup(Ofs: Cardinal): integer;
  function GetNextFixup(iStart: integer; Ofs: Cardinal): integer;
  procedure ShowDeclList(LK: TDeclListKind; Decl: TNameDecl; Ofs: Cardinal;
    dScopeOfs: integer; SepF: TDeclSepFlags; ValidKinds: TDeclSecKinds;
    skDefault: TDeclSecKind);
  function GetStartCodeLine(Ofs: integer): integer;
  procedure GetCodeLineRec(i: integer; var CL: TCodeLineRec);
  function RegTypeShow(T: TBaseDef): boolean;
  procedure UnRegTypeShow(T: TBaseDef);
//  function RegDataBl(BlSz: Cardinal): Cardinal;
  function GetBlockMem(BlOfs,BlSz: Cardinal; var ResSz: Cardinal): Pointer;
  procedure ShowDataBl(Ofs0,BlOfs,BlSz: Cardinal);
  procedure ShowCodeBl(Ofs0,BlOfs,BlSz: Cardinal);
public
  constructor Create(FName: String; VerRq: integer);
  destructor Destroy; override;
  procedure Show;
  function GetAddrStr(hDef: integer; ShowNDX: boolean): String;
  property UnitName: String read FUnitName;
  property FileName: String read FFName;
  property ExportDecls[Name: String; Stamp: integer]: TNameFDecl read GetExportDecl;
  property ExportTypes[Name: String; Stamp: integer]: TTypeDef read GetExportType;
  property Ver: integer read FVer;
  property Stamp: integer read FStamp;
//  property fxStart: Byte read FfxStart;
//  property fxEnd: Byte read FfxEnd;
  property AddrName[hDef: integer]: PName read GetAddrName;
end ;

var
  MainUnit: TUnit = Nil;
  CurUnit: TUnit;

implementation

uses
  DCUTbl;

const
  NoName: ShortString='?';

type
  ulong = Cardinal;

  TFileTime = ulong;

procedure FreeDCURecList(L: TDCURec);
var
  Tmp: TDCURec;
begin
  while L<>Nil do begin
    Tmp := L;
    L := L.Next;
    Tmp.Free;
  end ;
end ;

procedure FreeDCURecTList(L: TList);
var
  Tmp: TDCURec;
  i: integer;
begin
  if L=Nil then
    Exit;
  for i:=0 to L.Count-1 do begin
    Tmp := L[i];
    Tmp.Free;
  end ;
  L.Free;
end ;

function FileDateToStr(FT: TFileTime): String;
const
  DaySec=24*60*60;
begin
  if CurUnit.Ver<verK1 then
    Result := FormatDateTime('c',FileDateToDateTime(FT))
  else begin
    Result := FormatDateTime('c',EncodeDate(1970,1,1)+FT/DaySec
      {Unix Time to Delphi time});
  end ;
end ;

function GetDCURecStr(D: TDCURec; hDef: integer; ShowNDX: boolean): String;
var
  N: PName;
  ScopeCh: Char;
  Pfx: String;
  CP: PChar;
  cd: integer;
begin
  if D=Nil then
    N := @NoName
  else
    N := D.Name;
  if N^[0]=#0 then begin
    Pfx := NoNamePrefix;
    Result := Format('%x',[hDef]);
    ShowNDX := false;
   end
  else if N^[1]='.' then begin
    Pfx := DotNamePrefix;
    Result := Copy(N^,2,255);
   end
  else begin
    Result := N^;
    Pfx := '';
  end ;
  if Pfx<>'' then begin
    CP := StrScan(PChar(Pfx),'%');
    if CP<>Nil then begin
      if D=Nil then
        ScopeCh := 'N'
      else begin
        if (D is TTypeDecl)or(D is TTypeDef) then
          ScopeCh := 'T'
        else if D is TVarDecl then
          ScopeCh := 'V'
        else if D is TConstDecl then
          ScopeCh := 'C'
        else if D is TProcDecl then
          ScopeCh := 'F'
        else if D is TLabelDecl then
          ScopeCh := 'L'
        else if (D is TPropDecl)or(D is TDispPropDecl) then
          ScopeCh := 'P'
        else if D is TLocalDecl then
          ScopeCh := 'v'
        else if D is TMethodDecl then
          ScopeCh := 'M'
        else if D is TExportDecl then
          ScopeCh := 'E'
        else
          ScopeCh := 'n';
      end ;
      cd := CP-PChar(Pfx);
      SetLength(Pfx,Length(Pfx));{Make it unique}
      CP := PChar(Pfx)+cd;
      repeat
        CP^ := ScopeCh;
        CP := StrScan(CP+1,'%');
      until CP=Nil;
    end ;
    Result := Pfx+Result;
  end ;
  if ShowNDX then
    Result := Format('%s{0x%x}',[Result, hDef]);
end ;

{ TDCURec. }
function TDCURec.SetMem(MOfs,MSz: Cardinal): Cardinal {Rest};
begin
  Result := 0;
  DCUErrorFmt('Trying to set memory 0x%x[0x%x] to %s',[MOfs,MSz,Name^]);
end ;

{ TBaseDef. }
constructor TBaseDef.Create(AName: PName; ADef: PDef; AUnit: integer);
begin
  inherited Create;
  FName := AName;
  Def := ADef;
  hUnit := AUnit;
end ;

procedure TBaseDef.ShowName;
var
  U: PUnitImpRec;
  NP: PName;
begin
  NP := FName;
  if (NP=Nil)or(NP^[0]=#0) then
    NP := @NoName;
  if hUnit<0 then begin
    if NP^[0]<>#0 {Temp.} then
      PutS(GetDCURecStr(Self,-1{dummy - won't be used},false));
   end
  else begin
    U := PUnitImpRec(CurUnit.FUnitImp[hUnit]);
    PutSFmt('%s.%s',[U^.Name^,NP^]);
  end ;
end ;

procedure TBaseDef.Show;
var
  NP: PName;
begin
  NP := FName;
  if (NP=Nil)or(NP^[0]=#0) then
    NP := @NoName;
  PutS(NP^);
//  PutS('?');
//  ShowName;
end ;

procedure TBaseDef.ShowNamed(N: PName);
begin
  if ((N<>Nil)and(N=FName)or(FName=Nil)or(FName^[0]=#0)or
      (not ShowDotTypes and(FName^[1]='.')and(Self is TTypeDef)))
    and CurUnit.RegTypeShow(Self)
    {if RegTypeShow fails the type name will be shown instead of its
     definition}
  then
    try
      Show;
    finally
      CurUnit.UnRegTypeShow(Self)
    end
  else
    ShowName;
end ;

function TBaseDef.GetName: PName;
begin
  Result := FName;
  if Result=Nil then
    Result := @NoName;
end ;

{ TImpDef. }
constructor TImpDef.Create(AIK: TImpKind; AName: PName; AnInf: integer;
  ADef: PDef; AUnit: integer);
begin
  inherited Create(AName,ADef,AUnit);
  Inf := AnInf;
  ik := AIK;
end ;

procedure TImpDef.Show;
begin
  PutSFmt('%s:',[ik]);
  inherited Show;
end ;

{ TDLLImpRec. }
constructor TDLLImpRec.Create(AName: PName; ANDX: integer; ADef: PDef; AUnit: integer);
begin
  inherited Create({'A',}AName,ADef,AUnit);
  NDX := ANDX;
end ;

procedure TDLLImpRec.Show;
var
  NoName: boolean;
begin
  NoName := (FName=Nil)or(FName^[0]=#0);
  if not NoName then
    PutSFmt('name ''%s''',[FName^]);
  if NoName or(NDX<>0) then
    PutSFmt('index $%x',[NDX])
end ;

{ TImpTypeDefRec. }
constructor TImpTypeDefRec.Create(AName: PName; AnInf: integer;
  ARTTISz: Cardinal{AL: Byte}; ADef: PDef; AUnit: integer);
begin
  inherited Create('T',AName,AnInf,ADef,AUnit);
//  L := AL;
  RTTISz := ARTTISz;
  RTTIOfs := Cardinal(-1);
  hImpUnit := hUnit;
  hUnit := -1;;
  ImpName := FName;
  FName := Nil {Will be named later in the corresponding TTypeDecl};
end ;

procedure TImpTypeDefRec.Show;
var
  U: PUnitImpRec;
begin
  PutS('type'+cSoftNL);
//  ShowName;
  if hImpUnit>=0 then begin
    U := PUnitImpRec(CurUnit.FUnitImp[hImpUnit]);
    PutS(U^.Name^);
    PutS('.');
  end ;
  PutS(ImpName^);
//  PutSFmt('[%d]',[L]);
  if RTTISz>0 then begin
    Inc(AuxLevel);
    PutS('{ RTTI: ');
    Inc(NLOfs,2);
    NL;
    CurUnit.ShowDataBl(0,RTTIOfs,RTTISz);
    Dec(NLOfs,2);
    PutS('}');
    Dec(AuxLevel);
  end ;
end ;

function TImpTypeDefRec.SetMem(MOfs,MSz: Cardinal): Cardinal {Rest};
begin
  Result := 0;
  if RTTIOfs<>Cardinal(-1) then
    DCUErrorFmt('Trying to change ImpRTTI(%s) memory to 0x%x[0x%x]',
      [Name^,MOfs,MSz]);
  if RTTISz<>MSz then
    DCUErrorFmt('ImpRTTI %s: memory size mismatch (.[0x%x]<>0x%x[0x%x])',
      [Name^,RTTISz,MOfs,MSz]);
  RTTIOfs := MOfs;
end ;

{**************************************************}
{ TNameDecl. }
constructor TNameDecl.Create;
var
  N: PName;
begin
  inherited Create;
  Def := DefStart;
  N := ReadName;
  hDecl := CurUnit.AddAddrDef(Self);
end ;

procedure TNameDecl.ShowName;
begin
  PutS(GetDCURecStr(Self,hDecl,false));
end ;
{var
  N: PName;
begin
  N := Name;
  if (N^[0]<>#0) then
    PutS(N^)
  else
    PutSFmt('_N_%x',[hDecl])
end ;
}

procedure TNameDecl.Show;
begin
  ShowName;
end ;

procedure TNameDecl.ShowDef(All: boolean);
begin
  Show;
end ;

function TNameDecl.GetName: PName;
begin
  if Def=Nil then
    Result := @NoName
  else
    Result := @Def^.Name;
end ;

function TNameDecl.GetSecKind: TDeclSecKind;
begin
  Result := skNone;
end ;

function TNameDecl.IsVisible(LK: TDeclListKind): boolean;
begin
  Result := true;
end ;

{ TNameFDecl.}
constructor TNameFDecl.Create;
begin
  inherited Create;
  F := ReadUIndex;
  {if F and $1<>0 then
    raise Exception.CreateFmt('Flag 1 found: 0x%x',[F]);}
  if F and $40<>0 then
    Inf := ReadULong;
end ;

procedure TNameFDecl.Show;
begin
  inherited Show;
  Inc(AuxLevel);
  PutSFmt('{%x,%x}',[F,Inf]);
  Dec(AuxLevel);
end ;

function TNameFDecl.IsVisible(LK: TDeclListKind): boolean;
begin
  case LK of
    dlMain: Result := (F and $40<>0);
    dlMainImpl: Result := (F and $40=0);
  else
    Result := true;
  end ;
end ;

{ TTypeDecl. }
constructor TTypeDecl.Create;
begin
  inherited Create;
  hDef := ReadUIndex;
  CurUnit.AddTypeName(hDef,{hDecl,}@Def^.Name);
//  CurUnit.AddAddrDef(Self);
end ;

function TTypeDecl.IsVisible(LK: TDeclListKind): boolean;
var
  RefName: PName;
begin
  Result := inherited IsVisible(LK);
  if not Result then
    Exit;
  if ShowDotTypes or(Def=Nil) then
    Exit;
  RefName := @Def^.Name;
  Result := not((RefName^[0]>#0)and(RefName^[1]='.'));
end ;

procedure TTypeDecl.Show;
var
  RefName: PName;
begin
//  PutS('type ');
  inherited Show;
  if (Def=Nil) then
    RefName := Nil
  else
    RefName := @Def^.Name;
 (*
  RefName := CurUnit.GetTypeName(hDef);
  if (Def=Nil)or(RefName=@Def^.Name) then
    RefName := Nil;
  if RefName<>Nil then
    PutSFmt('=%s{#%d}',[RefName^,hDef])
  else
    PutSFmt('=#%d',[hDef]);
  *)
  PutS('=');
  CurUnit.ShowTypeDef(hDef,RefName);
//  PutSFmt('{#%x}',[hDef])
end ;

function TTypeDecl.SetMem(MOfs,MSz: Cardinal): Cardinal {Rest};
var
  D: TTypeDef;
begin
  Result := 0;
  D := CurUnit.GetTypeDef(hDef);
  if D=Nil then
    Exit;
  Result := D.SetMem(MOfs,MSz);
end ;

function TTypeDecl.GetSecKind: TDeclSecKind;
begin
  Result := skType;
end ;

{ TTypePDecl. }

constructor TTypePDecl.Create;
begin
  inherited Create(false);
//  B1 := ReadByte;
end ;

procedure TTypePDecl.Show;
begin
//  PutS('VMT of ');
  inherited Show;
//  PutSFmt('{B1:%x}',[B1]);
  PutS(',VMT');
end ;

function TTypePDecl.IsVisible(LK: TDeclListKind): boolean;
begin
  Result := ShowVMT;
end ;

{ TVarDecl. }
constructor TVarDecl.Create;
begin
  inherited Create;
  hDT := ReadUIndex;
  Ofs := ReadUIndex;
//  CurUnit.AddAddrDef(Self);
end ;

procedure TVarDecl.Show;
{var
  RefName: PName;}
begin
//  PutS('var ');
  inherited Show;
 (* RefName := CurUnit.GetTypeName(hDT);
  if RefName<>Nil then
    PutSFmt(':%s{#%d @%x}',[RefName^,hDT,Ofs])
  else
    PutSFmt(':{#%d @%x}',[hDT,Ofs]);
  *)
  PutS(': ');
  CurUnit.ShowTypeDef(hDT,Nil);
//  PutSFmt('{#%x @%x}',[hDT,Ofs]);
  Inc(AuxLevel);
  PutSFmt('{Ofs:0x%x}',[Ofs]);
  Dec(AuxLevel);
end ;

function TVarDecl.GetSecKind: TDeclSecKind;
begin
  Result := skVar;
end ;

{ TVarCDecl. }
constructor TVarCDecl.Create(OfsValid: boolean);
begin
  inherited Create;
  Sz := Cardinal(-1);
  OfsR := Ofs;
  if not OfsValid then
    Ofs := Cardinal(-1);
end ;

procedure TVarCDecl.Show;
var
  DP: Pointer;
  {SzShown: integer;}
  DS: Cardinal;
var
  Fix0: integer;
  MS: TFixupMemState;
begin
  inherited Show;
  Inc(NLOfs,2);
  PutS(' ='+cSoftNL);
  if Sz=Cardinal(-1) then
    PutS(' ?')
  else begin
    DP := Nil;
    if ResolveConsts then begin
      DP := CurUnit.GetBlockMem(Ofs,Sz,DS);
      if DP<>Nil then begin
        SaveFixupMemState(MS);
        SetCodeRange(CurUnit.FDataBlPtr,DP,DS);
        Fix0 := CurUnit.GetStartFixup(Ofs);
        SetFixupInfo(CurUnit.FFixupCnt-Fix0,@CurUnit.FFixupTbl^[Fix0],CurUnit);
      end ;
    end ;
    CurUnit.ShowGlobalTypeValue(hDT,DP,DS,true,false);
    if DP<>Nil then
      RestoreFixupMemState(MS);
   {
    SzShown := 0;
    if DP<>Nil then begin
      SzShown := CurUnit.ShowGlobalTypeValue(hDT,DP,Sz,true);
      if SzShown<0 then
        SzShown := 0;
    end ;
    if SzShown<Sz then
      CurUnit.ShowDataBl(SzShown,Ofs,Sz);}
  end ;
  Dec(NLOfs,2);
end ;

function TVarCDecl.SetMem(MOfs,MSz: Cardinal): Cardinal {Rest};
begin
  Result := 0;
  if Sz<>Cardinal(-1) then
    DCUErrorFmt('Trying to change typed const %s memory to 0x%x[0x%x]',
      [Name^,MOfs,MSz]);
  if Ofs=Cardinal(-1) then
    Ofs := MOfs
  else if Ofs<>MOfs then
    DCUErrorFmt('typed const %s: memory ofs mismatch (0x%x<>0x%x)',
      [Name^,Ofs,MOfs]);
  Sz := MSz;
end ;

function TVarCDecl.GetSecKind: TDeclSecKind;
begin
  Result := skConst;
end ;

{ TThreadVarDecl. }
function TThreadVarDecl.GetSecKind: TDeclSecKind;
begin
  Result := skThreadVar;
end ;

{ TLabelDecl. }
constructor TLabelDecl.Create;
begin
  inherited Create;
  Ofs := ReadUIndex;
//  CurUnit.AddAddrDef(Self);
end ;

procedure TLabelDecl.Show;
begin
//  PutS('label ');
  inherited Show;
  PutSFmt('{at $%x}',[Ofs]);
end ;

function TLabelDecl.GetSecKind: TDeclSecKind;
begin
  Result := skLabel;
end ;

//Labels can appear in the global decl. list when declared for unit init./fin.
function TLabelDecl.IsVisible(LK: TDeclListKind): boolean;
begin
  {case LK of
    dlMain: Result := false;
    dlMainImpl: Result := true;
  else
    Result := true;
  end ;}
  Result := LK<>dlMain;
end ;

{ TExportDecl. }
constructor TExportDecl.Create;
begin
  inherited Create;
  hSym := ReadUIndex;
  Index := ReadUIndex;
end ;

procedure TExportDecl.Show;
var
  D: TDCURec;
  N: PName;
begin
  D := CurUnit.GetAddrDef(hSym);
  N := Nil;
  if D=Nil then
    PutS('?')
  else begin
    D.ShowName;
    N := D.Name;
  end ;
  Inc(NLOfs,2);
  if (N<>Nil)and(Name<>Nil)and(N^<>Name^) then begin
    PutS(cSoftNL+'name'+cSoftNL);
    ShowName;
  end ;
  if Index<>0 then
    PutSFmt(cSoftNL+'index $%x',[Index]);
  Dec(NLOfs,2);
end ;

function TExportDecl.GetSecKind: TDeclSecKind;
begin
  Result := skExport;
end ;

{ TLocalDecl. }
constructor TLocalDecl.Create(LK: TDeclListKind);
var
  M,M2: boolean;
begin
  inherited Create;
  M := Def^.Tag in [arMethod,arConstr,arDestr];
  M2 := (CurUnit.Ver=verD2)and M;
  LocFlags := ReadUIndex;
  if not M2 then
    hDT := ReadUIndex
  else if M then
    Ndx := ReadUIndex
  else
    Ndx := ReadIndex;
  if LK in [dlInterface,dlDispInterface] then
    NDXB := ReadUIndex
  else
    NDXB := -1;
//    B := ReadByte;
  if not M2 then begin
    if M then
      Ndx := ReadUIndex
    else
      Ndx := ReadIndex;
   end
  else
    hDT := ReadUIndex;
  {if LK=dlArgsT then
    Exit;}
  if not(LK in [dlClass,dlInterface,dlDispInterface,dlFields]) then
  case Def^.Tag of
    arFld:  Exit ;
    arMethod,
    arConstr,
    arDestr: (*if not((LK in [dlClass,dlInterface])and(NDX1<>0{virtual?})) then*) Exit ;
  end ;
//  CurUnit.AddAddrDef(Self);
end ;

procedure TLocalDecl.Show;
const
{Register, where register variable is located,
 I am not sure that it is valid for smaller than 4 bytes variables}
  RegName: array[0..6] of String[3] =
    ('EAX','EDX','ECX','EBX','ESI','EDI','EBP');
var
  RefName: PName;
  MS: String;
begin
  MS := '';
  if ShowAuxValues then
   case Def^.Tag of
     arVal: MS := 'val ';
     arVar: MS := 'var ';
     drVar: MS := 'local ';
     arResult: MS := 'result ';
     arAbsLocVar: MS := 'local absolute ';
     arFld: MS := 'field ';
     {arMethod: MS := 'method';
     arConstr: MS := 'constructor';
     arDestr: MS := 'destructor';}
   end
  else
   case Def^.Tag of
//     arVar,drVar,arAbsLocVar: MS := 'var ';
     arVar: MS := 'var ';
     arResult: MS := 'result ';
   end ;
  if MS<>'' then
    PutS(MS);
  inherited Show;
 (* RefName := CurUnit.GetTypeName(hDT);
  if RefName<>Nil then
    PutSFmt(':%s{#%d #1:%x #2:%x}',[RefName^,hDT,Ndx1,Ndx])
  else
    PutSFmt(':{#%d #1:%x #2:%x}',[hDT,Ndx1,Ndx]);
  *)
  PutS(': ');
  CurUnit.ShowTypeDef(hDT,Nil);
//  PutSFmt('{#%x #1:%x #2:%x}',[hDT,Ndx1,Ndx]);
  Inc(AuxLevel);
  PutSFmt('{F:%x Ofs:%d',[LocFlags,integer(Ndx)]);
  if (LocFlags and $8<>0 {register})and(Def^.Tag<>arFld) then begin
    if (Ndx>=Low(RegName))and(Ndx<=High(RegName)) then
      PutSFmt('=%s',[RegName[Ndx]])
    else
      PutS('=?')
  end ;
  if NDXB<>-1 then
    PutSFmt(' NDXB:%x',[NDXB]);
  PutS('}');
  Dec(AuxLevel);
  if Def^.Tag=arAbsLocVar then
    PutSFmt(' absolute %s',[CurUnit.GetAddrStr(integer(Ndx),false)]);
end ;

function TLocalDecl.GetSecKind: TDeclSecKind;
begin
  if Def^.Tag in [arFld, arMethod, arConstr, arDestr, arProperty] then
   case LocFlags and lfScope of
     lfPrivate: Result := skPrivate;
     lfProtected: Result := skProtected;
     lfPublic: Result := skPublic;
     lfPublished: Result := skPublished;
   else
     Result := skNone{Temp};
   end
  else if Def^.Tag in [arResult,drVar,arAbsLocVar] then
    Result := skVar
  else
    Result := skNone;
end ;

{ TMethodDecl. }
constructor TMethodDecl.Create(LK: TDeclListKind);
begin
  inherited Create(LK);
  InIntrf := LK in [dlInterface,dlDispInterface];
  if Name^[0]=#0 then
    hImport := ReadUIndex; //then hDT seems to be valid index in the
      //parent class unit
end ;

procedure TMethodDecl.Show;
var
  MS: String;
  D: TDCURec;
  PD: TProcDecl absolute D;

  procedure ShowFlags;
  begin
    Inc(AuxLevel);
    PutSFmt('{F:#%x hDT:%x} ',[LocFlags,hDT]);
    if (Name^[0]=#0)and(hImport<>0) then
      PutSFmt('{hImp: #%x} ',[hImport]);
    Dec(AuxLevel);
  end ;

begin
  if LocFlags and lfClass<>0 then
    PutS('class ');
  PD := Nil;
  if ResolveMethods then begin
    D := CurUnit.GetAddrDef(Ndx);
    if (D<>Nil)and not(D is TProcDecl) then
      D := Nil;
    if D<>Nil then
      TProcDecl(D).IsMethod := true;
  end ;
  MS := '';
  case Def^.Tag of
    arMethod: begin
      if PD=Nil then
        MS := 'method '
      else if PD.IsProc then
        MS := 'procedure '
      else
        MS := 'function ';
    end ;
    arConstr: MS := 'constructor ';
    arDestr: MS := 'destructor ';
  end ;
  if not InIntrf then begin
    if MS<>'' then
      PutS(MS);
    {if (Name^[0]=#0)and(hImport<>0) then
      PutS(CurUnit.GetAddrStr(integer(hImport),true))
    else}
      ShowName;
    if PD=Nil then
      PutS(': ');
    ShowFlags;
    if PD<>Nil then begin
      PutSFmt('{%x}',[Ndx]);
      PD.ShowArgs;
     end
    else
      PutS(CurUnit.GetAddrStr(Ndx,true));
    Inc(NLOfs,2);
    if LocFlags and lfOverride<>0 then
      PutS(';'+cSoftNL+'override{');
    if LocFlags and lfVirtual<>0 then
      PutS(';'+cSoftNL+'virtual');
    if LocFlags and lfDynamic<>0 then
      PutS(';'+cSoftNL+'dynamic');
    if LocFlags and lfOverride<>0 then
      PutS('}');
    Dec(NLOfs,2);
   end
  else begin
    if MS<>'' then begin
      Inc(AuxLevel);
      PutS(MS);
      Dec(AuxLevel);
    end ;
    D := CurUnit.GetTypeDef(NDX);
    if (D<>Nil)and(D is TProcTypeDef) then begin
      Inc(AuxLevel);
      PutSFmt('{T#%x}',[hDT]);
      Dec(AuxLevel);
      PutS(TProcTypeDef(D).ProcStr);
      PutS(' ');
      ShowName;
      SoftNL;
      TProcTypeDef(D).ShowDecl(Nil);
      ShowFlags;
     end
    else begin
      ShowName;
      PutS(': ');
      ShowFlags;
      CurUnit.ShowTypeDef(Ndx,Name);
    end ;
  end ;
end ;

{ TPropDecl. }
constructor TPropDecl.Create;
begin
  inherited Create;
  LocFlags := ReadIndex;
  hDT := ReadUIndex;
  Ndx := ReadIndex;
  hIndex := ReadIndex;
  hRead := ReadUIndex;
  hWrite := ReadUIndex;
  hStored := ReadUIndex;
  hDeft := ReadIndex;
//  CurUnit.AddAddrDef(Self);
end ;

procedure TPropDecl.Show;

  procedure PutOp(Name: String; hOp: TNDX);
  var
    V: String;
  begin
    if hOp=0 then
      Exit;
    V := CurUnit.GetAddrStr(hOp,true);
    PutSFmt(cSoftNL+'%s %s',[Name,V])
  end ;

var
  D: TBaseDef;
begin
  PutS('property ');
  inherited Show;
  Inc(NLOfs,2);
  if hDT<>0 then begin
   {hDT=0 => inherited and something overrided}
    D := CurUnit.GetTypeDef(hDT);
    if (D<>Nil)and(D is TProcTypeDef)and(D.FName=Nil) then begin
      {array property}
      Inc(AuxLevel);
      PutSFmt('{T#%x}',[hDT]);
      Dec(AuxLevel);
      //SoftNL;
      Dec(NLOfs,2);
      TProcTypeDef(D).ShowDecl('[]');
      Inc(NLOfs,2);
     end
    else begin
      PutS(':');
    //  PutSFmt(':{#%x}',[hDT]);
      CurUnit.ShowTypeDef(hDT,Nil);
    end
  end ;
  if hIndex<>TNDX($80000000) then
    PutSFmt(cSoftNL+'index $%x',[hIndex]);
  PutOp('read',hRead);
  PutOp('write',hWrite);
  PutOp('stored',hStored);
  if hDeft<>TNDX($80000000) then
    PutSFmt(cSoftNL+'default $%x',[hDeft]);
  Inc(AuxLevel);
  SoftNL;
  PutSFmt('{F:#%x,Ndx:#%x}',[LocFlags,Ndx]);
  Dec(AuxLevel);
  if LocFlags and lfDeftProp<>0 then
    PutS('; default');
  Dec(NLOfs,2);
end ;

function TPropDecl.GetSecKind: TDeclSecKind;
begin
  case LocFlags and lfScope of
    lfPrivate: Result := skPrivate;
    lfProtected: Result := skProtected;
    lfPublic: Result := skPublic;
    lfPublished: Result := skPublished;
  else
    Result := skNone{Temp};
  end;
end ;

{ TDispPropDecl. }
procedure TDispPropDecl.Show;
begin
  PutS('property ');
  ShowName;
  Inc(NLOfs,2);
  PutS(':'+cSoftNL);
  CurUnit.ShowTypeDef(hDT,Nil);
  Inc(AuxLevel);
  PutSFmt('{F:%x',[LocFlags]);
  if NDXB<>-1 then
    PutSFmt(' NDXB:%x',[NDXB]);
  PutS('}');
  Dec(AuxLevel);
  if NDXB<>-1 then begin
    case NDXB and $6 of
      $2: PutS(cSoftNL+'readonly');
      $4: PutS(cSoftNL+'writeonly');
    end ;
  end ;
  PutsFmt(cSoftNL+'dispid $%x',[integer(Ndx)]);
  Dec(NLOfs,2);
end ;

{ TConstDeclBase. }
constructor TConstDeclBase.Create;
begin
  inherited Create;
//  CurUnit.AddAddrDef(Self);
end ;

procedure TConstDeclBase.ReadConstVal;
begin
  ValSz := ReadUIndex;
  if ValSz=0 then begin
    ValPtr := Nil;
    Val := ReadIndex;
    ValSz := NDXHi;
   end
  else begin
    ValPtr := ScSt.CurPos;
    SkipBlock(ValSz);
    Val := 0;
  end ;
end ;

procedure TConstDeclBase.ShowValue;
var
  DP: Pointer;
  DS: Cardinal;
  V: TInt64Rec;
  MemVal: boolean;
begin
  if ValPtr=Nil then begin
    V.Hi := ValSz;
    V.Lo := Val;
    DP := @V;
    DS := 8;
   end
  else begin
    DP := ValPtr;
    DS := ValSz;
  end ;
  MemVal := ValPtr<>Nil;
  if (CurUnit.ShowGlobalTypeValue(hDT,DP,DS,MemVal,true)<0)and not MemVal then begin
    CurUnit.ShowTypeName(hDT);
    NDXHi := V.Hi;
    PutSFmt('(%s)',[NDXToStr(V.Lo)]);
  end ;
end ;

procedure TConstDeclBase.Show;
var
  RefName: PName;
  TypeNamed: boolean;
begin
  inherited Show;
 (*
  RefName := CurUnit.GetTypeName(hDT);
  if RefName<>Nil then
    PutSFmt('=%s{#%d}(',[RefName^,hDT])
  else
    PutSFmt('={#%d}',[hDT]);
  if ValPtr=Nil then begin
    if ValSz<>0 then
      PutSFmt('$%x%8:8x',[ValSz,Val])
    else
      PutSFmt('$%x',[Val]);
  end ;
  if RefName<>Nil then
    PutS(')');
  *)
  Inc(NLOfs,2);
  PutS(' ');
  Inc(AuxLevel);
  if AuxLevel<=0 then begin
    PutS('{:'+cSoftNL);
    CurUnit.ShowTypeName(hDT);
    PutS('}'+cSoftNL)
  end ;
  Dec(AuxLevel);
  PutS('='+cSoftNL);
  Inc(AuxLevel);
  if (CurUnit.Ver>verD4)and(hX<>0{It is almost always=0}) then
    PutSFmt('{X:#%x}',[hX]);
  Dec(AuxLevel);
  ShowValue;
  Dec(NLOfs,2);
 (*
  TypeNamed := CurUnit.ShowTypeName(hDT);
  if TypeNamed then
    PutS('(');
  if ValPtr=Nil then begin
    NDXHi := ValSz;
    PutS(NDXToStr(Val));
   end
  else begin
    Inc(NLOfs,2);
    NL;
    ShowDump(ValPtr,0,ValSz,0,0,0,0,Nil,false);
    Dec(NLOfs,2);
  end ;
  if TypeNamed then
    PutS(')');
  *)
end ;

function TConstDeclBase.GetSecKind: TDeclSecKind;
begin
  Result := skConst;
end ;

{ TConstDecl. }
constructor TConstDecl.Create;
begin
  inherited Create;
  hDT := ReadUIndex;
  if CurUnit.Ver>verD4 then
    hX := ReadUIndex;
  ReadConstVal;
end ;

{ TResStrDef. }
constructor TResStrDef.Create;
begin
  inherited Create(false);
  OfsR := Ofs;
  Ofs := Cardinal(-1);
end ;

procedure TResStrDef.Show;
begin
  inherited Show; //The reference to HInstance will be shown
  Inc(NLOfs,2);
  SoftNL;
  CurUnit.ShowGlobalConstValue(hDecl+1);
  Dec(NLOfs,2);
end ;

function TResStrDef.GetSecKind: TDeclSecKind;
begin
  Result := skResStr;
end ;

{
procedure TResStrDef.Show;
begin
  PutS('res');
  inherited Show;
end ;
}
(*
constructor TResStrDef.Create;
begin
  inherited Create;
  hDT := ReadUIndex;
  NDX := ReadIndex;
  NDX1 := ReadIndex;
  B1 := ReadByte;
  B2 := ReadByte;
  V := ReadIndex;
  ReadConstVal;
  RefOfs := Cardinal(-1);
end ;

procedure TResStrDef.Show;
begin
  inherited Show;
  PutSFmt('{NDX:%x,NDX1:%x,B1:%x,B2:%x,V:%x}',[NDX,NDX1,B1,B2,V]);
  NL;
  if RefOfs<>Cardinal(-1) then begin
    PutS('{');
    CurUnit.ShowDataBl(RefOfs,RefSz);
    PutS('}');
  // NL;
  end ;
end ;

procedure TResStrDef.SetMem(MOfs,MSz: Cardinal);
begin
  if RefOfs<>Cardinal(-1) then
    DCUErrorFmt('Trying to change resourcestring memory %s',[Name^]);
  RefOfs := MOfs;
  RefSz := MSz;
end ;
*)

{ TSetDeftInfo. }
constructor TSetDeftInfo.Create;
begin
//  inherited Create;
  Def := DefStart;
  hDecl := -1;
  hConst := ReadUIndex;
  hArg := ReadUIndex;
end ;

procedure TSetDeftInfo.Show;
begin
  Inc(NLOfs,2);
  PutSFmt('Let %s :='+cSoftNL,[CurUnit.GetAddrStr(hArg,false)]);
  CurUnit.ShowGlobalConstValue(hConst);
  Dec(NLOfs,2);
end ;
(*
{ TProcDeclBase. }
constructor TProcDeclBase.Create;
begin
  inherited Create;
  CodeOfs := Cardinal(-1);
//  CurUnit.AddAddrDef(Self);
end ;

function TProcDeclBase.SetMem(MOfs,MSz: Cardinal): Cardinal {Rest};
begin
  if CodeOfs<>Cardinal(-1) then
    DCUErrorFmt('Trying to change procedure %s memory to 0x%x[0x%x]',
      [Name^,MOfs,MSz]);
  if Sz>MSz then
    DCUErrorFmt('Procedure %s: memory size mismatch (.[0x%x]>0x%x[0x%x])',
      [Name^,Sz,MOfs,MSz]);
  CodeOfs := MOfs;
  Result := MSz-Sz {it can happen for ($L file) with several procedures};
end ;

function TProcDeclBase.GetSecKind: TDeclSecKind;
begin
  Result := skProc;
end ;
*)
{ TSysProcDecl. }
constructor TSysProcDecl.Create;
begin
  inherited Create;
  F := ReadUIndex;
  Ndx := ReadIndex;
//  CurUnit.AddAddrDef(Self);
//  CodeOfs := CurUnit.RegDataBl(Sz);
end ;

function TSysProcDecl.GetSecKind: TDeclSecKind;
begin
  Result := skProc;
end ;

procedure TSysProcDecl.Show;
begin
  PutS('sysproc ');
  inherited Show;
  PutSFmt('{#%x}',[F]);
//  PutSFmt('{%x,#%x}',[F,V]);
//  NL;

//  CurUnit.ShowDataBl(CodeOfs,Sz);
end ;

{ TProcDecl. }

function ReadCallKind: TProcCallKind;
begin
  Result := pcRegister;
  if (Tag>=Low(TProcCallTag))and(Tag<=High(TProcCallTag)) then begin
    Result := TProcCallKind(Ord(Tag)-Ord(Low(TProcCallTag))+1);
    Tag := ReadTag;
  end ;
end ;

constructor TProcDecl.Create(AnEmbedded: TNameDecl);
var
  NoName: boolean;
  ArgP: ^TNameDecl;
  Loc: TNameDecl;
begin
  inherited Create;
  CodeOfs := Cardinal(-1);
 {---}
  Embedded := AnEmbedded;
  NoName := IsUnnamed;
  IsMethod := false;
  Locals := Nil;
  B0 := ReadUIndex{ReadByte};
  Sz := ReadUIndex;
  if not NoName then begin
    if CurUnit.Ver>verD2 then
      VProc := ReadIndex;
    hDTRes := ReadUIndex;
    Tag := ReadTag;
    CallKind := ReadCallKind;
    CurUnit.ReadDeclList(dlArgs,Args);
    if Tag<>drStop1 then
      TagError('Stop Tag');
    ArgP := @Args;
    while ArgP^<>Nil do begin
      Loc := ArgP^;
      if not(Loc.Def^.Tag in [arVal,arVar]) then
        Break;
      ArgP := @Loc.Next;
    end ;
    Locals := ArgP^;
    ArgP^ := Nil;
    //Tag := ReadTag;
  end ;
//  CodeOfs := CurUnit.RegDataBl(Sz);
end ;

destructor TProcDecl.Destroy;
begin
  FreeDCURecList(Locals);
  FreeDCURecList(Args);
  FreeDCURecList(Embedded);
  inherited Destroy;
end ;

function TProcDecl.IsUnnamed: boolean;
begin
  Result := (Def^.Name[0]=#0)or(Def^.Name='.')
    or(CurUnit.Ver>=verD6)and(CurUnit.Ver<verK1)and(Def^.Name='..')
    or(CurUnit.Ver>=verK1)and(Def^.Name[1]='.'){and(Def^.Name[Length(Def^.Name)]='.')};
   //In Kylix are used the names of the kind '.<X>.'
   //In Delphi 6 were noticed only names '..' 
end ;

function TProcDecl.SetMem(MOfs,MSz: Cardinal): Cardinal {Rest};
begin
  if CodeOfs<>Cardinal(-1) then
    DCUErrorFmt('Trying to change procedure %s memory to 0x%x[0x%x]',
      [Name^,MOfs,MSz]);
  if Sz>MSz then
    DCUErrorFmt('Procedure %s: memory size mismatch (.[0x%x]>0x%x[0x%x])',
      [Name^,Sz,MOfs,MSz]);
  CodeOfs := MOfs;
  Result := MSz-Sz {it can happen for ($L file) with several procedures};
end ;

function TProcDecl.GetSecKind: TDeclSecKind;
begin
  Result := skProc;
end ;

const
  CallKindName: array[TProcCallKind] of String =
    ('register','cdecl','pascal','stdcall','safecall');

function TProcDecl.IsProc: boolean;
begin
  Result := CurUnit.TypeIsVoid(hDTRes);
end ;

procedure TProcDecl.ShowArgs;
var
  NoName: boolean;
  Ofs0: Cardinal;
begin
  NoName := IsUnnamed;
  Inc(AuxLevel);
  PutSFmt('{B0:%x,Sz:%x',[B0,Sz]);
  if not NoName then begin
    if CurUnit.Ver>verD2 then
      PutSFmt(',VProc:%x',[VProc]);
  end ;
  PutS('}');
  Dec(AuxLevel);
  Ofs0 := NLOfs;
  Inc(NLOfs,2);
  if Args<>Nil then
    PutS(cSoftNL+'(');
  CurUnit.ShowDeclList(dlArgs,Args,Ofs0,2,[{dsComma,}dsNoFirst,dsSoftNL],
    ProcSecKinds,skNone);
  NLOfs := Ofs0+2;
  if Args<>Nil then
    PutS(')');
  if not IsProc then begin
    PutS(':'+cSoftNL);
    CurUnit.ShowTypeDef(hDTRes,Nil);
  end ;
  if CallKind<>pcRegister then begin
    PutS(';'+cSoftNL);
    PutS(CallKindName[CallKind]);
  end ;
  if (CurUnit.Ver>verD3)and(VProc and $1000 <> 0) then begin
    PutS(';'+cSoftNL);
    PutS('overload');
  end ;
  NLOfs := Ofs0;
end ;

procedure TProcDecl.ShowDef(All: boolean);
var
  Ofs0: Cardinal;
begin
  if IsProc then
    PutS('procedure ')
  else
    PutS('function ');
  inherited Show;
  if Def^.Name[0]=#0 then
    PutS('?');
  ShowArgs;
  if All then begin
    Ofs0 := NLOfs;
    PutS(';');
    if Locals<>Nil then
      CurUnit.ShowDeclList(dlEmbedded,Locals,Ofs0{+2},2,[dsLast,dsOfsProc],
        BlockSecKinds,skNone);
    if Embedded<>Nil then
      CurUnit.ShowDeclList(dlEmbedded,Embedded,Ofs0{+2},2,[dsLast,dsOfsProc],
        BlockSecKinds,skNone);
//    PutS('; ');
    NLOfs := Ofs0;
    NL;
    PutS('begin');
    NLOfs := Ofs0+2;
    CurUnit.ShowCodeBl(AddrBase,CodeOfs,Sz);
    NLOfs := Ofs0;
    NL;
    PutS('end');
  end ;
end ;

procedure TProcDecl.Show;
begin
  ShowDef(true);
end ;

function TProcDecl.IsVisible(LK: TDeclListKind): boolean;
begin
  case LK of
    dlMain: Result := (F and $40<>0)and not IsMethod;
  else
    Result := true;
  end ;
end ;

(*
{ TAtDecl. }
  //May be start of implementation?
constructor TAtDecl.Create;
begin
  inherited Create;
  NDX := ReadIndex;
  NDX1 := ReadIndex;
end ;

procedure TAtDecl.Show;
begin
  PutSFmt('implementation ?{NDX:%x,NDX:%x}',[NDX,NDX1]);
  inherited Show;
end ;
*)

{--------------------------------------------------------------------}
{ TTypeDef. }
constructor TTypeDef.Create;
begin
  inherited Create(Nil,DefStart,-1);
  RTTISz := ReadUIndex;
  Sz := ReadIndex{ReadUIndex};
  V := ReadUIndex;
  CurUnit.AddTypeDef(Self);
  {if V<>0 then
    CurUnit.AddAddrDef(Self);}
  RTTIOfs := Cardinal(-1){CurUnit.RegDataBl(RTTISz)};
end ;

procedure TTypeDef.ShowBase;
begin
  Inc(AuxLevel);
  PutSFmt('{Sz: %x, RTTISz: %x, V: %x}',[Sz,RTTISz,V]);
  Dec(AuxLevel);
//  PutSFmt('{Sz: %x, V: %x}',[Sz,V]);
  if RTTISz>0 then begin
    Inc(AuxLevel);
    PutS('{ RTTI: ');
    Inc(NLOfs,2);
    NL;
    CurUnit.ShowDataBl(0,RTTIOfs,RTTISz);
    Dec(NLOfs,2);
    PutS('}');
    Dec(AuxLevel);
  end ;
end ;

procedure TTypeDef.Show;
begin
  ShowBase;
end ;

function TTypeDef.SetMem(MOfs,MSz: Cardinal): Cardinal {Rest};
begin
  Result := 0;
  if RTTIOfs<>Cardinal(-1) then
    DCUErrorFmt('Trying to change RTTI(%s) memory to 0x%x[0x%x]',
      [Name^,MOfs,MSz]);
  if RTTISz<>MSz then
    DCUErrorFmt('RTTI %s: memory size mismatch (.[0x%x]<>0x%x[0x%x])',
      [Name^,RTTISz,MOfs,MSz]);
  RTTIOfs := MOfs;
end ;

function TTypeDef.ShowValue(DP: Pointer; DS: Cardinal): integer {Size used};
begin
  if Sz>DS then begin
    Result := -1;
    Exit;
  end ;
  Result := Sz;
  NL;
  ShowDump(DP,0,Sz,0,0,0,0,Nil,false);
end ;

{ TRangeBaseDef. }

procedure TRangeBaseDef.GetRange(var Lo,Hi: TInt64Rec);
var
  CP0: TScanState;
begin
  ChangeScanState(CP0,LH,18);
  ReadIndex64(Lo);
  ReadIndex64(Hi);
  RestoreScanState(CP0);
end ;

function TRangeBaseDef.ShowValue(DP: Pointer; DS: Cardinal): integer {Size used};
var
  CP0: TScanState;
  Neg: boolean;
  Lo: TNDX;
  Tag: Char;
begin
  if Sz>DS then begin
    Result := -1;
    Exit;
  end ;
  Result := Sz;
  if Def=Nil then
    Tag := drRangeDef{Just in case}
  else
    Tag := TDCURecTag(Def^);
  case Tag of
    drChRangeDef:
     if Sz=1 then begin
       PutS(CharStr(Char(DP^)));
       Exit;
     end ;
    drWCharRangeDef:
     if Sz=2 then begin
       PutS(WCharStr(WideChar(DP^)));
       Exit;
     end ;
    drBoolRangeDef: begin
      PutS(BoolStr(DP,Sz));
      Exit;
    end ;
  end ;
  ChangeScanState(CP0,LH,18);
  Lo := ReadIndex;
  Neg := NDXHi<0{Lo<0};
  RestoreScanState(CP0);
  PutS(IntLStr(DP,Sz,Neg));
end ;

procedure TRangeBaseDef.Show;
var
  Lo,Hi: TInt64Rec;
  U: TUnit;
  T: TTypeDef;

  procedure ShowVal(var V: TInt64Rec);
  begin
    if (T=Nil)or(U.ShowTypeValue(T,@V,8,true)<0) then begin
      NDXHi := V.Hi;
      PutS(NDXToStr(V.Lo));
    end ;
  end ;

begin
  inherited Show;
  Inc(AuxLevel);
  PutS('{');
//  CurUnit.ShowTypeDef(hDTBase,Nil);
  CurUnit.ShowTypeName(hDTBase);
//  PutSFmt(',#%x,B:%x}',[hDTBase,B]);
  PutSFmt(',B:%x}',[B]);
  Dec(AuxLevel);
  GetRange(Lo,Hi);
  T := CurUnit.GetGlobalTypeDef(hDTBase,U);
  ShowVal(Lo);
  PutS('..');
  ShowVal(Hi);
end ;

{ TRangeDef. }
constructor TRangeDef.Create;
var
  Lo: TNDX;
  Hi: TNDX;
begin
  inherited Create;
  hDTBase := ReadUIndex;
  LH := ScSt.CurPos;
  Lo := ReadIndex;
  Hi := ReadIndex;
  B := ReadByte;
end ;

{ TEnumDef. }
constructor TEnumDef.Create;
var
  Lo: TNDX;
  Hi: TNDX;
begin
  inherited Create;
  hDTBase := ReadUIndex;
  NDX := ReadIndex;
  LH := ScSt.CurPos;
  Lo := ReadIndex;
  Hi := ReadIndex;
  B := ReadByte;
end ;

destructor TEnumDef.Destroy;
begin
  if NameTbl<>Nil then begin
    if NameTbl.Count>0 then
      FreeDCURecList(NameTbl[0]);
    NameTbl.Free;
  end ;
  inherited Destroy;
end ;

function TEnumDef.ShowValue(DP: Pointer; DS: Cardinal): integer {Size used};
var
  V: Cardinal;
begin
  if Sz>DS then begin
    Result := -1;
    Exit;
  end ;
  Result := Sz;
  if not MemToUInt(DP,Sz,V) or (V<0) or (NameTbl = Nil) or (V >= NameTbl.Count) then begin
    ShowName;
    PutS('(');
    inherited ShowValue(DP,DS);
    PutS(')');
    Exit;
  end ;
  TConstDecl(NameTbl[V]).ShowName;
end ;

procedure TEnumDef.Show;
var
  EnumConst: TNameDecl;
  i: integer;
begin
  if NameTbl=Nil then begin
    inherited Show;
    Exit;
  end ;
  ShowBase;
  Inc(AuxLevel);
  PutS('{');
//  CurUnit.ShowTypeDef(hDTBase,Nil);
  CurUnit.ShowTypeName(hDTBase);
//  PutSFmt(',#%x,B:%x}',[hDTBase,B]);
  PutSFmt(',B:%x}',[B]);
  Dec(AuxLevel);
  Inc(NLOfs,1);
  SoftNL;
  PutS('(');
  Inc(NLOfs,1);
  for i:=0 to NameTbl.Count-1 do begin
    if i>0 then
      PutS(','+cSoftNL);
    EnumConst := NameTbl[i];
    PutS(EnumConst.Name^);
  end ;
  PutS(')');
  Dec(NLOfs,2);
end ;

{ TFloatDef. }
constructor TFloatDef.Create;
begin
  inherited Create;
  B := ReadByte;
end ;

function TFloatDef.ShowValue(DP: Pointer; DS: Cardinal): integer {Size used};
var
  E: Extended;
  N: PName;
  Ok: boolean;
begin
  if Sz>DS then begin
    Result := -1;
    Exit;
  end ;
  Result := Sz;
  Ok := true;
  case DS of
    SizeOf(Single): E := Single(DP^);
    SizeOf(Double): begin {May be TypeInfo should be used here}
      N := Name;
      if N=Nil then
        Ok := false
      else begin
        if CompareText(N^,'Double')=0 then
          E := Double(DP^)
        else if CompareText(N^,'Currency')=0 then
          E := Currency(DP^)
        else if CompareText(N^,'Comp')=0 then
          E := Comp(DP^)
        else
          Ok := false;
      end ;
    end ;
    SizeOf(Extended): E := Extended(DP^);
    SizeOf(Real): E := Real(DP^);
  else
    Ok := false;
  end ;
  if Ok then begin
    PutsFmt('%g',[E]);
    Exit;
  end ;
  Result := inherited ShowValue(DP,Sz);
end ;

procedure TFloatDef.Show;
begin
  Inc(AuxLevel);
  PutS('float');
  Dec(AuxLevel);
  inherited Show;
  Inc(AuxLevel);
  PutSFmt('{B:%x}',[B]);
  Dec(AuxLevel);
end ;

{ TPtrDef. }
constructor TPtrDef.Create;
begin
  inherited Create;
  hRefDT := ReadUIndex;
end ;

type
  TShowPtrValProc = function(Ndx: TNDX; Ofs: Cardinal): boolean of object;

procedure ShowPointer(DP: Pointer; NilStr: String; ShowVal: TShowPtrValProc);
var
  V: Pointer;
  Fix: PFixupRec;
  VOk: boolean;
  FxName: PName;
begin
  V := Pointer(DP^);
  if GetFixupFor(DP,4,true,Fix)and(Fix<>Nil) then begin
    FxName := TUnit(FixUnit).AddrName[Fix^.Ndx];
    VOk := (FxName^[0]=#0) {To prevent from decoding named blocks}
      and Assigned(ShowVal)and ShowVal(Fix^.Ndx,Cardinal(V));
    if VOk then begin
      PutS(cSoftNL+'{');
    end ;
    PutS('@');
    ReportFixup(Fix);
    if V<>Nil then
      PutSFmt('+$%x',[Cardinal(V)]);
    if VOk then begin
      PutS('}');
    end ;
   end
  else if V=Nil then
    PutS(NilStr)
  else
    PutSFmt('$%8.8x',[Cardinal(V)]);
end ;

function StrLEnd(Str: PChar; L: Cardinal): PChar; assembler;
asm
        MOV     ECX,EDX
        MOV     EDX,EDI
        MOV     EDI,EAX
        XOR     AL,AL
        REPNE   SCASB
        JCXZ    @1
        DEC     EDI
  @1:
        MOV     EAX,EDI
        MOV     EDI,EDX
end;

function TPtrDef.ShowRefValue(Ndx: TNDX; Ofs: Cardinal): boolean;
var
  U: TUnit;
  DT: TTypeDef;
  AR: TDCURec;
  DP: PChar;
  Sz: Cardinal;
  EP: PChar;
begin
  Result := false;
  if FixUnit=Nil then
    Exit;
  DT := CurUnit.GetGlobalTypeDef(hRefDT,U);
  if (DT=Nil)or(DT.Def=Nil)or(TDCURecTag(DT.Def^)<>drChRangeDef) then
    Exit;
  AR := TUnit(FixUnit).GetGlobalAddrDef(Ndx,U);
  if (AR=Nil)or not(AR is TProcDecl) then
    Exit;
  DP := TUnit(FixUnit).GetBlockMem(TProcDecl(AR).CodeOfs,TProcDecl(AR).Sz,Sz);
  if Ofs>=Sz then
    Exit;
  EP := StrLEnd(DP+Ofs,Sz-Ofs);
  if EP-DP=Sz then
    Exit;
 {We could also check that there are no fixups in the DP+Ofs..EP range}
  Result := true;
  PutS(StrConstStr(DP+Ofs,EP-(DP+Ofs)));
end ;

function TPtrDef.ShowValue(DP: Pointer; DS: Cardinal): integer {Size used};
begin
  if Sz>DS then begin
    Result := -1;
    Exit;
  end ;
  if Sz=4 then begin
    Result := Sz;
    ShowPointer(DP,'Nil',ShowRefValue);
    Exit;
  end ;
  Result := inherited ShowValue(DP,Sz);
end ;

procedure TPtrDef.Show;
begin
  inherited Show;
//  PutSFmt('^{#%x}',[hRefDT]);
  PutS('^');
  CurUnit.ShowTypeDef(hRefDT,Nil);
end ;

{ TTextDef. }
procedure TTextDef.Show;
begin
  inherited Show;
  PutS('text');
end ;

{ TFileDef. }
constructor TFileDef.Create;
begin
  inherited Create;
  hBaseDT := ReadUIndex;
end ;

procedure TFileDef.Show;
begin
  inherited Show;
  Inc(NLOfs,2);
  PutS('file of'+cSoftNL);
//  PutSFmt('file of {#%x}',[hBaseDT]);
  CurUnit.ShowTypeDef(hBaseDT,Nil);
  Dec(NLOfs,2);
end ;

{ TSetDef. }
constructor TSetDef.Create;
begin
  inherited Create;
  BStart := ReadByte;
  hBaseDT := ReadUIndex;
end ;

function TSetDef.ShowValue(DP: Pointer; DS: Cardinal): integer {Size used};
var
  U: TUnit;
  T: TTypeDef;
  Cnt,K: integer;
  V0,Lo,Hi: TInt64Rec;
  WasOn,SetOn: boolean;
  B: Byte;

  procedure ShowRange;
  begin
    if Cnt>0 then
      PutS(','+cSoftNL);
    Inc(Cnt);
    U.ShowTypeValue(T,@V0,SizeOf(V0),true);
    Dec(Lo.Lo);
    if V0.Lo<>Lo.Lo then begin
      PutS('..');
      U.ShowTypeValue(T,@Lo,SizeOf(Lo),true);
    end ;
    Inc(Lo.Lo);
  end ;

begin
  Result := -1;
  if Sz>DS then
    Exit;
  T := CurUnit.GetGlobalTypeDef(hBaseDT,U);
  if (T=Nil)or not(T is TRangeBaseDef) then
    Exit;
  TRangeBaseDef(T).GetRange(Lo,Hi);
{  if (Lo.Hi<>0)or(Hi.Hi<>0)or(Lo.Lo<0) then
    Exit;
  Cnt := Hi.Lo div 8+1-Lo.Lo div 8;
  if Cnt > Sz then
    Exit;}
  {if Lo.Lo and $7>0 then begin
    B := Byte(DP^);
    Inc(PChar(DP));
  end ;}
  Lo.Lo := BStart*8{Lo.Lo and not $7};
  Hi.Lo := (BStart+Sz)*8 - 1;
  PutS('[');
  Inc(NLOfs,2);
  Cnt := 0;
  try
    SetOn := false;
    while Lo.Lo<=Hi.Lo do begin
      K := Lo.Lo and $7;
      if K=0 then begin
        B := Byte(DP^);
        Inc(PChar(DP));
      end ;
      WasOn := SetOn;
      SetOn := B and (1 shl K)<>0;
      if WasOn<>SetOn then begin
        if WasOn then
          ShowRange
        else
          V0.Lo := Lo.Lo;
      end;
      Inc(Lo.Lo);
    end ;
    if SetOn then
      ShowRange
  finally
    Dec(NLOfs,2);
  end ;
  PutS(']');
  Result := Sz;
end ;

procedure TSetDef.Show;
begin
  inherited Show;
  PutS('set ');
  Inc(AuxLevel);
  PutSFmt('{BStart:%x} ',[BStart]);
  Dec(AuxLevel);
  Inc(NLOfs,2);
  PutS('of'+cSoftNL);
  CurUnit.ShowTypeDef(hBaseDT,Nil);
  Dec(NLOfs,2);
end ;

{ TArrayDef. }
constructor TArrayDef.Create;
begin
  inherited Create;
  B1 := ReadByte;
  hDTNdx := ReadUIndex;
  hDTEl := ReadUIndex;
end ;

function TArrayDef.ShowValue(DP: Pointer; DS: Cardinal): integer {Size used};
var
  U: TUnit;
  T: TTypeDef;
  Rest,ElSz: Cardinal;
  Cnt: integer;
begin
  Result := -1;
  if Sz>DS then
    Exit;
  T := CurUnit.GetGlobalTypeDef(hDTEl,U);
  if T=Nil then
    Exit;
  if (T.Def<>Nil)and(TDCURecTag(T.Def^)=drChRangeDef) then begin
    Result := Sz;
    PutS(StrConstStr(DP,Sz));
    Exit;
  end ;
  Rest := Sz;
  ElSz := T.Sz;
  PutS('(');
  Inc(NLOfs,2);
  try
    Cnt := 0;
    while Rest>=ElSz do begin
      if Cnt>0 then
        PutS(','+cSoftNL);
      if U.ShowTypeValue(T,DP,Rest,false)<0 then
        Exit;
      Inc(Cnt);
      Inc(PChar(DP),ElSz);
      Dec(Rest,ElSz);
    end ;
  finally
    Dec(NLOfs,2);
  end ;
  PutS(')');
  Result := Sz;
end ;

procedure TArrayDef.Show;
begin
//  PutSFmt('array{B1:%x}[{#%x}',[B1,hDTNDX]);
  PutS('array');
  Inc(NLOfs,2);
  ShowBase;
  Inc(AuxLevel);
  PutSFmt('{B1:%x}',[B1]);
  Dec(AuxLevel);
  PutS('[');
  CurUnit.ShowTypeDef(hDTNDX,Nil);
//  PutSFmt('] of {#%x}',[hDTEl]);
  PutS('] of'+cSoftNL);
  CurUnit.ShowTypeDef(hDTEl,Nil);
  Dec(NLOfs,2);
end ;

{ TShortStrDef. }
function TShortStrDef.ShowValue(DP: Pointer; DS: Cardinal): integer {Size used};
var
  U: TUnit;
  T: TTypeDef;
  Rest,ElSz: Cardinal;
  L: integer;
begin
  Result := -1;
  if Sz>DS then
    Exit;
  L := Length(PShortString(DP)^);
  if L>=Sz then
    Result := inherited ShowValue(DP,DS)
  else begin
    Result := Sz;
    PutS(StrConstStr(PChar(DP)+1,L));
  end ;
end ;

procedure TShortStrDef.Show;
begin
  if Sz=Cardinal(-1) then
    PutS('ShortString')
  else
    PutSFmt('String[%d]',[Sz-1]);
  Inc(NLOfs,2);
  ShowBase;
//  PutSFmt('{B1:%x,[#%x:',[B1,hDTNDX]);
  Inc(AuxLevel);
  PutSFmt('{B1:%x,[',[B1]);
  CurUnit.ShowTypeDef(hDTNDX,Nil);
//  PutSFmt('] of #%x:',[hDTEl]);
  PutS('] of'+cSoftNL);
  CurUnit.ShowTypeDef(hDTEl,Nil);
  PutS('}');
  Dec(AuxLevel);
  Dec(NLOfs,2);
end ;

{ TStringDef. }
function TStringDef.ShowStrConst(DP: Pointer; DS: Cardinal): integer {Size used};
var
  L: integer;
  VP: Pointer;
begin
  Result := -1;
  if DS<9 {Min size} then
    Exit;
  if integer(DP^)<>-1 then
    Exit {Reference count,-1 => ~infinity};
  VP := PChar(DP)+SizeOf(integer);
  L := integer(VP^);
  if DS<L+9 then
    Exit;
  Inc(PChar(VP),SizeOf(integer));
  if (PChar(VP)+L)^<>#0 then
    Exit;
  Result := L+9;
  PutS(StrConstStr(VP,L));
end ;

function TStringDef.ShowRefValue(Ndx: TNDX; Ofs: Cardinal): boolean;
var
  U: TUnit;
  DT: TTypeDef;
  AR: TDCURec;
  DP: PChar;
  Sz: Cardinal;
  EP: PChar;
  LP: ^integer;
  L: integer;
begin
  Result := false;
  if (FixUnit=Nil)or(Ofs<8) then
    Exit;
  AR := TUnit(FixUnit).GetGlobalAddrDef(Ndx,U);
  if (AR=Nil)or not(AR is TProcDecl) then
    Exit;
  DP := TUnit(FixUnit).GetBlockMem(TProcDecl(AR).CodeOfs,TProcDecl(AR).Sz,Sz);
  if Ofs>=Sz then
    Exit;
  L := ShowStrConst(DP+Ofs-8,Sz-Ofs+8);
  Result := L>0;
end ;

function TStringDef.ShowValue(DP: Pointer; DS: Cardinal): integer {Size used};
begin
  if Sz>DS then begin
    Result := -1;
    Exit;
  end ;
  if Sz=4 then begin
    Result := Sz;
    ShowPointer(DP,'''''',ShowRefValue);
    Exit;
  end ;
  Result := inherited ShowValue(DP,Sz);
end ;

procedure TStringDef.Show;
begin
  PutS('String');
  Inc(NLOfs,2);
  ShowBase;
//  PutSFmt('{B1:%x,[#%x:',[B1,hDTNDX]);
  Inc(AuxLevel);
  PutSFmt('{B1:%x,[',[B1]);
  CurUnit.ShowTypeDef(hDTNDX,Nil);
//  PutSFmt('] of #%x:',[hDTEl]);
  PutS('] of'+cSoftNL);
  CurUnit.ShowTypeDef(hDTEl,Nil);
  PutS('}');
  Dec(AuxLevel);
  Dec(NLOfs,2);
end ;

{ TVariantDef. }
constructor TVariantDef.Create;
begin
  inherited Create;
  if CurUnit.Ver>verD2 then
    B := ReadByte;
end ;

procedure TVariantDef.Show;
begin
  PutS('variant');
  inherited Show;
  Inc(AuxLevel);
  if CurUnit.Ver>verD2 then
    PutSFmt('{B:0x%x}',[B]);
  Dec(AuxLevel);
end ;

{ TObjVMTDef. }
constructor TObjVMTDef.Create;
begin
  inherited Create;
  hObjDT := ReadUIndex;
  NDX1 := ReadUIndex;
end ;

procedure TObjVMTDef.Show;
begin
  inherited Show;
  Inc(NLOfs,2);
  PutS('class of'+cSoftNL);
//  PutSFmt('{hObjDT:#%x,NDX1:#%x}',[hObjDT,NDX1]);
  Inc(AuxLevel);
  PutSFmt('{NDX1:#%x}',[NDX1]);
  Dec(AuxLevel);
  CurUnit.ShowTypeDef(hObjDT,Nil);
  Dec(NLOfs,2);
end ;

{ TRecBaseDef. }
procedure TRecBaseDef.ReadFields(LK: TDeclListKind);
begin
  Tag := ReadTag;
  CurUnit.ReadDeclList(LK,Fields);
  if Tag<>drStop1 then
    TagError('Stop Tag');
end ;

destructor TRecBaseDef.Destroy;
begin
  FreeDCURecList(Fields);
  inherited Destroy;
end ;

function TRecBaseDef.ShowFieldValues(DP: Pointer; DS: Cardinal): integer {Size used};
{ Attention: records with variants can't be correctly shown
  (see readme.txt for details)}
var
  Cnt: integer;
  Ofs: integer;
  Ok: boolean;
  Decl: TNameDecl;
begin
  Result := -1;
  if Sz>DS then
    Exit;
  Cnt := 0;
  Ok := true;
  Decl := Fields;
  PutS('(');
  Inc(NLOfs,2);
  try
    while Decl<>Nil do begin
      if (Decl is TLocalDecl)and(Decl.Def^.Tag = arFld) then begin
        if Cnt>0 then
          PutS(';'+cSoftNL);
        Decl.ShowName;
        PutS(': ');
        Ofs := TLocalDecl(Decl).Ndx;
        if (Ofs<0)or(Ofs>Sz)or
          (CurUnit.ShowGlobalTypeValue(TLocalDecl(Decl).hDT,PChar(DP)+Ofs,
             Sz-Ofs,false,false)<0)
        then begin
          PutS('?');
          Ok := false;
        end ;
        Inc(Cnt);
      end ;
      Decl := Decl.Next as TNameDecl;
    end ;
  finally
    PutS(')');
    if not Ok then
      inherited ShowValue(DP,DS);
    Dec(NLOfs,2);
  end ;
  Result := Sz;
end ;

{ TRecDef. }
constructor TRecDef.Create;
begin
  inherited Create;
  B2 := ReadByte;
  ReadFields(dlFields);
end ;

function TRecDef.ShowValue(DP: Pointer; DS: Cardinal): integer {Size used};
begin
  Result := ShowFieldValues(DP,DS);
end ;

procedure TRecDef.Show;
var
  Ofs0: Cardinal;
begin
  PutS('record ');
  Inc(AuxLevel);
  PutSFmt('{B2:%x}',[B2]);
  Dec(AuxLevel);
  inherited Show;
  Ofs0 := NLOfs;
  CurUnit.ShowDeclList(dlFields,Fields,Ofs0,2,[dsLast],RecSecKinds,skPublic);
  {if Args<>Nil then}
  NLOfs := Ofs0;
  NL;
  PutS('end');
end ;

{ TProcTypeDef. }
constructor TProcTypeDef.Create;
var
  CK: TProcCallKind;
begin
  inherited Create;
  if CurUnit.Ver>verD2 then
    NDX0 := ReadUIndex;//B0 := ReadByte;
  hDTRes := ReadUIndex;
  AddSz := 0;
  AddStart := ScSt.CurPos;
  Tag := ReadTag;
  while (Tag<>drEmbeddedProcStart) do begin
    if (Tag=drStop1) then
      Exit;
    CK := ReadCallKind;
    if CK=pcRegister then
      Tag := ReadTag
    else
      CallKind := CK;
    Inc(AddSz);
  end ;
  ReadFields(dlArgsT);
end ;

function TProcTypeDef.ShowValue(DP: Pointer; DS: Cardinal): integer {Size used};
begin
  if Sz>DS then begin
    Result := -1;
    Exit;
  end ;
  if Sz=4 then begin
    Result := Sz;
    ShowPointer(DP,'Nil',Nil);
    Exit;
  end ;
  Result := inherited ShowValue(DP,Sz);
end ;

function TProcTypeDef.IsProc: boolean;
begin
  Result := CurUnit.TypeIsVoid(hDTRes);
end ;

function TProcTypeDef.ProcStr: String;
begin
  if IsProc then
    Result := 'procedure'
  else
    Result := 'function';
end ;

procedure TProcTypeDef.ShowDecl(Braces: PChar);
var
  Ofs0: Cardinal;
begin
  if Braces=Nil then
    Braces := '()';
  {if B0 and $4<>0 then}
  Inc(AuxLevel);
  if CurUnit.Ver>0 then
    PutSFmt('{NDX0:#%x}',[NDX0]);
  Dec(AuxLevel);
  inherited Show;
  Inc(AuxLevel);
  PutSFmt('{AddSz:%x}',[AddSz]);
  Dec(AuxLevel);
  Ofs0 := NLOfs;
  if Fields<>Nil then begin
    PutS(Braces[0]);
    CurUnit.ShowDeclList(dlArgsT,Fields,Ofs0,2,[{dsComma,}dsNoFirst,dsSoftNL],
      ProcSecKinds,skNone);
    PutS(Braces[1]);
  end ;
  NLOfs := Ofs0+2;
  if not IsProc then begin
    PutS(':');
    SoftNL;
    CurUnit.ShowTypeDef(hDTRes,Nil);
  end ;
  if NDX0 and $10<>0 then
    PutS(cSoftNL+'of object');
  if CallKind<>pcRegister then begin
    SoftNL;
    PutS(CallKindName[CallKind]);
  end ;
  NLOfs := Ofs0;
end ;

procedure TProcTypeDef.Show;
begin
  PutS(ProcStr);
 // SoftNL;
  ShowDecl(Nil);
end ;

{ TObjDef. }
constructor TObjDef.Create;
begin
  inherited Create;
  B03 := ReadByte;
  hParent := ReadUIndex;
  BFE := ReadByte;
  NDX1 := ReadIndex;
  B00 := ReadByte;
  ReadFields(dlFields);
end ;

function TObjDef.ShowValue(DP: Pointer; DS: Cardinal): integer {Size used};
begin
  Result := ShowFieldValues(DP,DS);
end ;

procedure TObjDef.Show;
var
  Ofs0: Cardinal;
begin
  Ofs0 := NLOfs;
  Inc(NLOfs,2);
  PutS('object');
  inherited Show;
  if hParent<>0 then begin
    PutS('(');
    CurUnit.ShowTypeName(hParent);
    PutS(')');
  end ;
  Inc(AuxLevel);
  NL;
  PutSFmt('{B03:%x, BFE:%x, NDX1:%x, B00:%x)}',
    [B03, BFE, NDX1, B00]);
  CurUnit.ShowDeclList(dlFields,Fields,Ofs0,2,[dsLast],ClassSecKinds,skNone);
  {if Args<>Nil then}
  Dec(AuxLevel);
  NLOfs := Ofs0;
  NL;
  PutS('end');
end ;

{ TClassDef. }

constructor TClassDef.Create;
var
  i: integer;
begin
  inherited Create;
  hParent := ReadUIndex;
  InstBaseRTTISz := ReadUIndex;
  InstBaseSz := ReadIndex;
  InstBaseV := ReadUIndex;
  Ndx2 := ReadUIndex;
  NdxFE := ReadUIndex;
  NDX00a := ReadUIndex;
  B04 := ReadByte;
  if CurUnit.Ver>verD2 then begin
    ICnt := ReadIndex;
    if ICnt>0 then begin
      {DAddB0 := ReadByte;
      DAddB1 := ReadByte;}
      GetMem(ITbl,ICnt*2*SizeOf(TNDX));
      for i:=0 to ICnt*2-1 do
        ITbl^[i] := ReadUIndex;
    end ;
  end ;
  ReadFields(dlClass);
end ;

destructor TClassDef.Destroy;
begin
  if ITbl<>Nil then
    FreeMem(ITbl,ICnt*2*SizeOf(TNDX));
  inherited Destroy;
end ;

function TClassDef.ShowValue(DP: Pointer; DS: Cardinal): integer {Size used};
begin
  if Sz>DS then begin
    Result := -1;
    Exit;
  end ;
  if Sz=4 then begin
    Result := Sz;
    ShowPointer(DP,'Nil',Nil);
    Exit;
  end ;
  Result := inherited ShowValue(DP,Sz);
//  Result := ShowFieldValues(DP,DS);
end ;

procedure TClassDef.Show;
var
  Ofs0: Cardinal;
  i,j: integer;
begin
  Ofs0 := NLOfs;
  Inc(NLOfs,2);
  PutS('class ');
  if (hParent<>0)or(ICnt<>0) then begin
    PutS('(');
    i := 0;
    if hParent<>0 then begin
      CurUnit.ShowTypeName(hParent);
      Inc(i);
    end ;
    NDXHi := 0;
    for j:=0 to integer(ICnt)-1 do begin
      if i>0 then
        PutS(','+cSoftNL);
      CurUnit.ShowTypeName(ITbl^[2*j]);
      PutSFmt('{%s}',[NDXToStr(ITbl^[2*j+1])]);
    end ;
    PutS(')'+cSoftNL);
  end ;
  Inc(AuxLevel);
  PutSFmt('{InstBase:(Sz: %x, RTTISz: %x, V: %x),',
    [InstBaseSz,InstBaseRTTISz,InstBaseV]);
  SoftNL;
  PutSFmt('Ndx2:#%x,NdxFE:#%x,NDX00a:#%x,B04:%x',
    [Ndx2,NdxFE,NDX00a,B04]);
  PutS('}');
  Dec(AuxLevel);
  inherited Show;
  CurUnit.ShowDeclList(dlClass,Fields,Ofs0,2,[dsLast],ClassSecKinds,skNone);
  {if Args<>Nil then}
  NLOfs := Ofs0;
  NL;
  PutS('end');
end ;

{ TInterfaceDef. }
constructor TInterfaceDef.Create;
var
  LK: TDeclListKind;
begin
  inherited Create;
  hParent := ReadUIndex;
  Ndx1 := ReadIndex;
  GUID := ReadMem(SizeOf(TGUID));
  B := ReadByte;
  if (B and $4)=0 then
    LK := dlInterface
  else
    LK := dlDispInterface;
  ReadFields(LK);
end ;

procedure TInterfaceDef.Show;
var
  Ofs0: Cardinal;
begin
  Ofs0 := NLOfs;
  Inc(NLOfs,2);
//  PutSFmt('interface {Ndx1:#%x,B:%x,hParent: #%x}', [Ndx1,B,hParent]);
  PutS('interface ');
  if hParent<>0 then begin
    PutS('(');
    CurUnit.ShowTypeName(hParent);
    PutS(')');
  end ;
  Inc(AuxLevel);
  SoftNL;
  PutSFmt('{Ndx1:#%x,B:%x}', [Ndx1,B]);
  Dec(AuxLevel);
  SoftNL;
  inherited Show;
  SoftNL;
  with GUID^ do
    PutSFmt('[''{%8.8x-%4.4x-%4.4x-%2.2x%2.2x-%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x}'']',
      [D1,D2,D3,D4[0],D4[1],D4[2],D4[3],D4[4],D4[5],D4[6],D4[7]]);
  CurUnit.ShowDeclList(dlInterface,Fields,Ofs0,2,[dsLast],ClassSecKinds,skNone);
  {if Args<>Nil then}
  NLOfs := Ofs0;
  NL;
  PutS('end');
end ;

{ TVoidDef. }
procedure TVoidDef.Show;
begin
  PutS('void');
  inherited Show;
end ;

procedure TUnit.ReadSourceFiles;
var
  hSrc: integer;
  SrcFName: String;
  CP: PChar;
  FT: TFileTime;
  B: Byte;
  SFRP: ^PSrcFileRec;
  SFR: PSrcFileRec;
begin
//  NLOfs := 0;
  hSrc := 0;
  FSrcFiles := Nil;
  SFRP := @FSrcFiles;
  while (Tag=drSrc)or(Tag=drRes)or(Tag=drObj) do begin
    New(SFR);
    SFR^.Next := Nil;
    SFRP^ := SFR;
    SFRP := @SFR^.Next;
    SFR^.Def := DefStart;
    ReadName;
    SFR^.FT := ReadULong;
    SFR^.B := ReadByte;
    Tag := ReadTag;
  end ;
  if FSrcFiles=Nil then
    DCUError('No source files');
  FUnitName := ExtractFileName(FSrcFiles^.Def^.Name);
  CP := StrScan(PChar(FUnitName),'.');
  if CP<>Nil then
    SetLength(FUnitName,CP-PChar(FUnitName));
end ;

procedure TUnit.ShowSourceFiles;
var
  SFR: PSrcFileRec;
  T: TDCURecTag;
begin
  if FSrcFiles=Nil then
    Exit {Paranoic test};
  PutSFmt('unit %s;',[FUnitName]);
  Inc(AuxLevel);
  if Ver>verD2 then begin
    PutSFmt(' {Flags: 0x%x',[FFlags]);
    if Ver>verD3 then
      PutSFmt(', Priority: 0x%x',[FUnitPrior]);
    PutS('}');
  end ;
  Dec(AuxLevel);
  NL;
  PutS('{Source files:');
  NLOfs := 2;
  SFR := FSrcFiles;
  NL;
  while true do begin
    T := SFR^.Def^.Tag;
    case T of
     drObj: PutS('$L ');
     drRes: PutS('$R ');
    end ;
    PutS(SFR^.Def^.Name);
    if integer(SFR^.FT)<>-1 then
      PutSFmt(' (%s)',[FileDateToStr(SFR^.FT)]);
    SFR := SFR^.Next;
    if SFR=Nil then
      Break;
    PutS(','+cSoftNL)
  end ;
  PutS('}');
  NLOfs := 0;
  NL;
  NL;
end ;

function TUnit.ShowUses(PfxS: String; FRq: TUnitImpFlags): boolean;
var
  i,Cnt,hImp: integer;
  U: PUnitImpRec;
  Decl: TBaseDef;
  NLOfs0: Cardinal;
begin
  Result := false;
  if FUnitImp.Count=0 then
    Exit;
  Cnt := 0;
  NLOfs0 := NLOfs;
  for i:=0 to FUnitImp.Count-1 do begin
    U := FUnitImp[i];
    if FRq<>U.Flags then
      Continue;
    if Cnt>0 then
      PutS(',')
    else begin
      NL;
      PutS(PfxS);
      Inc(NLOfs,2);
    end ;
    NL;
    PutS(U^.Name^);
    Inc(Cnt);
    if ShowImpNames then begin
      Decl := U^.Decls;
      hImp := 0;
      while Decl<>Nil do begin
        if hImp>0 then begin
          {if (hImp mod 3)<>0 then
            PutS(', ')
          else begin
            PutS(',');
            NL;
          end ;}
          PutS(',');
          SoftNL;
         end
        else begin
          PutS(' {');
          Inc(NLOfs,2);
          NL;
        end ;
  //      PutSFmt('%s%x: %s',[Ch,NDX,ImpN^]);
  //      PutSFmt('%s%x: ',[Ch,NDX]);
        Decl.Show;
        Inc(hImp);
        Decl := Decl.Next as TBaseDef;
      end ;
      if hImp>0 then begin
        PutS('}');
        Dec(NLOfs,2);
      end ;
    end ;
  end ;
  NLOfs := NLOfs0;
  Result := Cnt>0;
  if Result then
    PutS(';');
end ;

procedure TUnit.ReadUses(TagRq: TDCURecTag);
var
  hUses,hImp: integer;
  UseName: PName;
  ImpN: PName;
  //B: Byte;
  RTTISz: Cardinal;
  L: LongInt;
  Ch: Char;
  hUnit: integer;
  U: PUnitImpRec;
  TR,AR: TBaseDef;
  IR: TImpDef;
  DeclEnd: ^TBaseDef;
//  TypesEnd,AddrsEnd: ^TBaseDef;
  NDX: integer;
begin
  hUses := 0;
  while Tag=TagRq do begin
    UseName := ReadName;
    {if hUses>0 then
      PutS(',')
    else begin
      PutS('uses');
      NLOfs := 2;
    end ;
    NL;
    PutS(UseName^);}
    New(U);
    FillChar(U^,SizeOf(TUnitImpRec),0);
    U^.Name := UseName;
    Ch := '?';
    case TagRq of
      drUnit1: begin Ch := 'U'; U^.Flags := [ufImpl]; end ;
      drDLL: begin Ch := 'D'; U^.Flags := [ufDLL]; end ;
    end ;
    hUnit := FUnitImp.Count;
    FUnitImp.Add(U);
    L := ReadULong;
    {TypesEnd := @U^.Types;
    AddrsEnd := @U^.Addrs;}
    DeclEnd := @U^.Decls;
    hImp := 0;
    IR := TImpDef.Create(Ch,UseName,L,Nil{DefStart},hUnit) {Unit reference};
    U^.Ref := IR;
    FAddrs.Add(IR);
    while true do begin
      Tag := ReadTag;
      case Tag of
        drImpType,drImpTypeDef: if TagRq<>drDLL then begin
          Ch := 'T';
          ImpN := ReadName;
          if Tag=drImpTypeDef then begin
            //B := ReadByte;
            RTTISz := ReadUIndex;
            {ImpN := Format('%s[%d]',[ImpN,B]);}
          end ;
          L := ReadULong;
          if Tag=drImpTypeDef then
            TR := TImpTypeDefRec.Create(ImpN,L,RTTISz{B},Nil{DefStart},hUnit)
          else
            TR := TImpDef.Create('T',ImpN,L,Nil{DefStart},hUnit);
          {TypesEnd^ := TR;
          TypesEnd := @TR.Next;}
          FTypes.Add(TR);
          FAddrs.Add(TR); {TypeInfo}
          ndx := FTypes.Count;
          FTypeDefCnt := ndx;
        end ;
        drImpVal: begin
          Ch := 'A';
          ImpN := ReadName;
          L := ReadULong;
          if TagRq<>drDLL then
            AR := TImpDef.Create('A',ImpN,L,Nil{DefStart},hUnit)
          else
            AR := TDLLImpRec.Create(ImpN,L,Nil,hUnit);
          {AddrsEnd^ := AR;
          AddrsEnd := @AR.Next;}
          FAddrs.Add(AR);
          TR := AR;
          ndx := FAddrs.Count;
        end ;
      else
        Break;
      end ;
      DeclEnd^ := TR;
      DeclEnd := @TR.Next;
(*      if hImp>0 then begin
        if (hImp mod 3)<>0 then
          PutS(', ')
        else begin
          PutS(',');
          NL;
        end ;
       end
      else begin
        PutS(' {');
        Inc(NLOfs,2);
        NL;
      end ;
//      PutSFmt('%s%x: %s',[Ch,NDX,ImpN^]);
      PutSFmt('%s%x: ',[Ch,NDX]);
      TR.Show; *)
      Inc(hImp);
    end ;
//    NLOfs := 2;
    if Tag<>drStop1 then
      DCUErrorFmt('Unexpected tag: 0x%x',[Byte(Tag)]);
(*    if hImp>0 then
      PutS('}');*)
    Inc(hUses);
    Tag := ReadTag;
  end ;
end ;

{ TUnit. }
procedure ChkListSize(L: TList; hDef: integer);
begin
  if hDef<=0 then
    Exit;
  if hDef>L.Count then begin
    if hDef>L.Capacity then
      L.Capacity := (hDef*3)div 2;
    L.Count := hDef;
  end ;
end ;

procedure TUnit.SetListDefName(L: TList; hDef: integer; Name: PName);
var
  Def: TBaseDef;
begin
  if L=Nil then
    Exit;
  if hDef<=0 then
    Exit;
  ChkListSize(L,hDef);
  Dec(hDef);
  Def := L[hDef];
  if Def=Nil then begin
    Def := TBaseDef.Create(Name,Nil,-1);
//    Def.Next := FDefs;
//    FDefs := Def;
    L[hDef] := Def;
    Exit;
  end ;
  if (Def.FName=Nil) then
    Def.FName := Name;
end ;

procedure TUnit.AddTypeName(hDef: integer; Name: PName);
begin
  SetListDefName(FTypes,hDef,Name);
end ;

procedure TUnit.AddTypeDef(TD: TTypeDef);
var
  Def: TBaseDef;
begin
  ChkListSize(FTypes,FTypeDefCnt+1);
  Def := FTypes[FTypeDefCnt];
  if Def<>Nil then begin
    if (Def.Def<>Nil) then
      DCUErrorFmt('Type def #%x override',[FTypeDefCnt+1]);
    if (Def.hUnit<>TD.hUnit) then
      DCUErrorFmt('Type def #%x unit mismatch',[FTypeDefCnt+1]);
    TD.FName := Def.Name;
    Def.FName := Nil;
    Def.Free;
  end ;
  FTypes[FTypeDefCnt] := TD;
  Inc(FTypeDefCnt);
end ;

{
procedure TUnit.AddAddrName(hDef: integer; Name: PName);
begin
  SetListDefName(FAddrs,hDef,Name);
end ;
}
function TUnit.AddAddrDef(ND: TDCURec): integer;
begin
  FAddrs.Add(ND);
  Result := FAddrs.Count;
end ;

procedure TUnit.SetDeclMem(hDef: integer; Ofs,Sz: Cardinal);
var
  D: TDCURec;
  Base,Rest: Cardinal;
begin
  if (hDef<=0)or(hDef>FAddrs.Count) then
    DCUErrorFmt('Undefined Fixup Declaration: #%x',[hDef]);
  D := FAddrs[hDef-1];
  Base := 0;
  while (D<>Nil) do begin
    if D is TProcDecl then
      TProcDecl(D).AddrBase := Base;
    Rest := D.SetMem(Ofs+Base,Sz-Base);
    if integer(Rest)<=0 then
      Break;
    Base := Sz-Rest;
    D := D.Next {Next declaration - should be procedure};
  end ;
end ;

function TUnit.GetTypeDef(hDef: integer): TTypeDef;
begin
  Result := Nil;
  if (hDef<=0)or(hDef>FTypes.Count) then
    Exit;
  Result := FTypes[hDef-1];
end ;

function TUnit.GetTypeName(hDef: integer): PName;
var
  D: TBaseDef;
begin
  Result := Nil;
  D := GetTypeDef(hDef);
  if D=Nil then
    Exit;
  Result := D.FName;
end ;

function TUnit.GetAddrDef(hDef: integer): TDCURec;
begin
  if (hDef<=0)or(hDef>FAddrs.Count) then
    Result := Nil
  else
    Result := FAddrs[hDef-1];
end ;

function TUnit.GetAddrName(hDef: integer): PName;
var
  D: TDCURec;
begin
  Result := @NoName;
  D := GetAddrDef(hDef);
  if D=Nil then
    Exit;
  Result := D.Name;
end ;

function TUnit.GetAddrStr(hDef: integer; ShowNDX: boolean): String;
begin
  Result := GetDCURecStr(GetAddrDef(hDef), hDef,ShowNDX);
end ;

function TUnit.GetGlobalTypeDef(hDef: integer; var U: TUnit): TTypeDef;
var
  D: TBaseDef;
  hUnit: integer;
  N: PName;
begin
  Result := Nil;
  U := Self;
  D := GetTypeDef(hDef);
  repeat
    if D=Nil then
      Exit;
    if (D is TTypeDef) then
      Break {Found - Ok};
    if not (D is TImpDef) then
      Exit;
    if (D is TImpTypeDefRec) then begin
      hUnit := TImpTypeDefRec(D).hImpUnit;
      N := TImpTypeDefRec(D).ImpName;
     end
    else begin
      hUnit := TImpDef(D).hUnit;
      N := TImpDef(D).Name;
    end ;
    {imported value}
    U := U.GetUnitImp(hUnit);
    if U=Nil then begin
      U := Self;
      Exit;
    end ;
    D := U.ExportTypes[N^,TImpDef(D).Inf];
  until false;
  Result := TTypeDef(D);
end ;

function TUnit.GetGlobalAddrDef(hDef: integer; var U: TUnit): TDCURec;
var
  D: TDCURec;
begin
  Result := Nil;
  U := Self;
  D := GetAddrDef(hDef);
  if D=Nil then
    Exit;
  if (D is TImpDef) then begin
    {imported value}
    U := GetUnitImp(TImpDef(D).hUnit);
    if U=Nil then begin
      U := Self;
      Exit;
    end ;
    D := U.ExportDecls[TImpDef(D).Name^,TImpDef(D).Inf];
  end ;
  Result := D;
end ;

function TUnit.GetTypeSize(hDef: integer): integer;
var
  T: TTypeDef;
  U: TUnit;
begin
  Result := -1;
  T := GetGlobalTypeDef(hDef,U);
  if T=Nil then
    Exit;
  Result := T.Sz;
end ;

function TUnit.ShowTypeValue(T: TTypeDef; DP: Pointer; DS: Cardinal;
  IsConst: boolean): integer {Size used};
var
  U0: TUnit;
  MS: TFixupMemState;
begin
  if T=Nil then begin
    Result := -1;
    Exit;
  end ;
  U0 := CurUnit;
  CurUnit := Self;
  if IsConst then begin
    SaveFixupMemState(MS);
    SetCodeRange(DP,DP,DS);
  end ;
  if IsConst and (T is TStringDef) then
    Result := TStringDef(T).ShowStrConst(DP,DS)
  else
    Result := T.ShowValue(DP,DS);
  if IsConst then
    RestoreFixupMemState(MS);
  CurUnit := U0;
end ;

function TUnit.ShowGlobalTypeValue(hDef: TNDX; DP: Pointer; DS: Cardinal;
  AndRest,IsConst: boolean): integer {Size used};
var
  T: TTypeDef;
  U: TUnit;
  SzShown: integer;
begin
  if DP=Nil then begin
    Result := -1;
    Exit;
  end ;
  T := GetGlobalTypeDef(hDef,U);
  Result := U.ShowTypeValue(T,DP,DS,IsConst);
  if not AndRest then
    Exit;
  SzShown := Result;
  if SzShown<0 then
    SzShown := 0;
  if SzShown>=DS then
    Exit;
  if (PChar(DP)>=FDataBlPtr)and(PChar(DP)<FDataBlPtr+FDataBlSize) then
    CurUnit.ShowDataBl(SzShown,PChar(DP)-FDataBlPtr,DS)
  else begin
    NL;
    ShowDump(DP,0,DS,SzShown,SzShown,0,0,Nil,false);
  end ;
end ;

function TUnit.ShowGlobalConstValue(hDef: integer): boolean;
var
  D: TDCURec;
  U,U0: TUnit;
begin
  Result := false;
  D := GetGlobalAddrDef(hDef,U);
  if (D=Nil)or not(D is TConstDecl) then
    Exit;
  U0 := CurUnit;
  CurUnit := U;
  TConstDecl(D).ShowValue;
  CurUnit := U0;
  Result := true;
end ;

procedure TUnit.ShowTypeDef(hDef: integer; N: PName);
var
  D: TBaseDef;
begin
  Inc(AuxLevel);
  PutSFmt('{T#%x}',[hDef]);
  Dec(AuxLevel);
  D := GetTypeDef(hDef);
  if D=Nil  then begin
    PutS('?');
    Exit;
  end ;
  D.ShowNamed(N);
end ;

function TUnit.ShowTypeName(hDef: integer): boolean;
var
  D: TBaseDef;
  N: PName;
begin
  Result := false;
  PutSFmt('{T#%x}',[hDef]);
  if (hDef<=0)or(hDef>FTypes.Count) then
    Exit;
  D := FTypes[hDef-1];
  if D=Nil  then
    Exit;
  N := D.FName;
  if (N=Nil)or(N^[0]=#0) then
    Exit;
  D.ShowName;
  Result := true;
end ;

function TUnit.TypeIsVoid(hDef: integer): boolean;
var
  D: TBaseDef;
begin
  Result := true;
  if (hDef<=0)or(hDef>FTypes.Count) then
    Exit;
  D := FTypes[hDef-1];
  if D=Nil  then
    Exit;
  Result := D.ClassType=TVoidDef;
end ;

function TUnit.GetUnitImpRec(hUnit: integer): PUnitImpRec;
begin
  Result := PUnitImpRec(FUnitImp[hUnit]);
end ;

function TUnit.GetUnitImp(hUnit: integer): TUnit;
var
  UI: PUnitImpRec;
begin
  UI := GetUnitImpRec(hUnit);
  if UI=Nil then begin
    Result := Nil;
    Exit;
  end ;
  Result := UI^.U;
  if Result<>Nil then begin
    if integer(Result)=-1 then
      Result := Nil;
    Exit;
  end ;
  Result := GetDCUByName(UI^.Name^,Ver,UI^.Ref.Inf);
  if Result=Nil then
    integer(UI^.U) := -1
  else
    UI^.U := Result;
end ;

procedure TUnit.SetExportNames(Decl: TNameDecl);
var
  NDX: integer;
begin
  FExportNames := TStringList.Create;
  FExportNames.Sorted := true;
  FExportNames.Duplicates := dupAccept{For overloaded functions} {dupError};
  while Decl<>Nil do begin
    if (Decl is TNameFDecl)and Decl.IsVisible(dlMain) then begin
//      if not FExportNames.Find(Decl.Name^,NDX) then
        FExportNames.AddObject(Decl.Name^,Decl);
    end ;
    Decl := Decl.Next as TNameDecl;
  end ;
end ;

procedure TUnit.SetEnumConsts(var Decl: TNameDecl);
var
  LastConst: TConstDecl;
  ConstCnt: integer;
  D: TNameDecl;
  DeclP,LastConstP: ^TNameDecl;
  TD: TTypeDef;
  Enum: TEnumDef;
  CP0: TScanState;
  Lo,Hi: integer;
  NT: TList;
begin
  DeclP := @Decl;
  LastConstP := Nil;
  LastConst := Nil;
  ConstCnt := 0;
  while DeclP^<>Nil do begin
    D := DeclP^;
    if D is TConstDecl then begin
      if (LastConst <> Nil) then
         if (LastConst.hDT = TConstDecl(D).hDT) then
            Inc(ConstCnt)
      else begin
        LastConstP := DeclP;
        LastConst := TConstDecl(D);
        ConstCnt := 1;
      end ;
     end
    else begin
      if (D is TTypeDecl)and(LastConst<>Nil) then begin
        TD := GetTypeDef(TTypeDecl(D).hDef);
        if TD is TEnumDef then begin
          Enum := TEnumDef(TD);
         {Some paranoic tests:}
          ChangeScanState(CP0,Enum.LH,18);
          Lo := ReadIndex;
          Hi := ReadIndex;
          RestoreScanState(CP0);
          if (Lo=0)and(ConstCnt=Hi+1) then begin
            NT := TList.Create;
            NT.Capacity := ConstCnt;
            LastConstP^ := D;
            DeclP^ := Nil;
            while LastConst<>Nil do begin
              NT.Add(LastConst);
              LastConst := TConstDecl(LastConst.Next);
            end ;
            Enum.NameTbl := NT;
          end ;
        end ;
      end ;
      LastConst := Nil;
      ConstCnt := 0;
    end ;
    DeclP := @(D.Next);
  end ;
end ;

function TUnit.GetExportDecl(Name: String; Stamp: integer): TNameFDecl;
var
  NDX: integer;
begin
  Result := Nil;
  if FExportNames=Nil then
    Exit;
  if not FExportNames.Find(Name,NDX) then
    Exit;
  repeat
    Result := FExportNames.Objects[NDX] as TNameFDecl;
    if Stamp=0 {The don't check Stamp value} then
      Exit;
    if (Result=Nil) then
      Exit;
    if (CompareText(FExportNames[NDX],Name)<>0) then begin
      Result := Nil;
      Exit;
    end ;
    if Result.Inf=Stamp then
      Break;
  until false;
end ;

function TUnit.GetExportType(Name: String; Stamp: integer): TTypeDef;
var
  ND: TNameDecl;
begin
  Result := Nil;
  ND := ExportDecls[Name,Stamp];
  if (ND=Nil)or not(ND is TTypeDecl) then
    Exit;
  Result := GetTypeDef(TTypeDecl(ND).hDef);
end ;

procedure TUnit.LoadFixups;
var
  i: integer;
  CurOfs,PrevDeclOfs,dOfs: Cardinal;
  B1: Byte;
  FP: PFixupRec;
  hPrevDecl: integer;
begin
  if FFixupTbl<>Nil then
    DCUError('2nd fixup');
  FFixupCnt := ReadUIndex;
  FFixupTbl := AllocMem(FFixupCnt*SizeOf(TFixupRec));
  CurOfs := 0;
  FP := Pointer(FFixupTbl);
  for i:=0 to FFixupCnt-1 do begin
    dOfs := ReadUIndex;
    Inc(CurOfs,dOfs);
    if (NDXHi<>0)or(CurOfs>FDataBlSize) then
      DCUErrorFmt('Fixup offset 0x%x>Block size = 0x%x',[CurOfs,FDataBlSize]);
    B1 := ReadByte;
    FP^.OfsF := (CurOfs and FixOfsMask)or(B1 shl 24);
    FP^.NDX := ReadUIndex;
    Inc(FP);
  end ;
  CurOfs := 0;
  FP := Pointer(FFixupTbl);
  hPrevDecl := 0;
  PrevDeclOfs := 0;
  for i:=0 to FFixupCnt-1 do begin
    CurOfs := FP^.OfsF and FixOfsMask;
    B1 := TByte4(FP^.OfsF)[3];
    if (B1=fxStart)or(B1=fxEnd) then begin
      if hPrevDecl>0 then
        CurUnit.SetDeclMem(hPrevDecl,PrevDeclOfs,CurOfs-PrevDeclOfs);
      hPrevDecl := FP^.NDX;
      PrevDeclOfs := CurOfs;
      FDataBlOfs := CurOfs;
    end ;
    Inc(FP);
  end ;
end ;

procedure TUnit.LoadCodeLines;
var
  i,CurL,dL: integer;
  CR: PCodeLineRec;
  CurOfs,dOfs: Cardinal;
begin
  if FCodeLineTbl<>Nil then
    DCUError('2nd Code Lines table');
  FCodeLineCnt := ReadUIndex;
  FCodeLineTbl := AllocMem(FCodeLineCnt*SizeOf(TCodeLineRec));
  CurL := 0;
  CurOfs := 0;
  CR := Pointer(FCodeLineTbl);
  for i:=0 to FCodeLineCnt-1 do begin
    dL := ReadIndex;
    dOfs := ReadUIndex;
    Inc(CurOfs,dOfs);
    Inc(CurL,dL);
    if (NDXHi<>0)or(CurOfs>FDataBlSize) then
      DCUErrorFmt('Code line offset 0x%x>Block size = 0x%x',[CurOfs,FDataBlSize]);
    CR^.Ofs := CurOfs;
    CR^.L := CurL;
    Inc(CR);
  end ;
end ;

function TUnit.GetStartFixup(Ofs: Cardinal): integer;
var
  iMin,iMax: integer;
  d: integer;
begin
  Result := 0;
  if (FFixupTbl=Nil)or(FFixupCnt=0) then
    Exit;
  if Ofs=0 then
    Exit;
  iMin := 0;
  iMax := FFixupCnt;
  while iMin<iMax do begin
    Result := (iMin+iMax)div 2;
    D := FFixupTbl^[Result].OfsF and FixOfsMask-Ofs;
    if D=0 then
      Break;
    if D<0 then
      iMin := Result+1
    else
      iMax := Result;
  end ;
  while (Result>0)and(FFixupTbl^[Result-1].OfsF and FixOfsMask = Ofs) do
    Dec(Result);
end ;

function TUnit.GetNextFixup(iStart: integer; Ofs: Cardinal): integer;
begin
  while iStart<FFixupCnt do begin
    if FFixupTbl^[iStart].OfsF and FixOfsMask >= Ofs then begin
      Result := iStart;
      Exit;
    end ;
    Inc(iStart);
  end ;
  Result := FFixupCnt;
end ;

function TUnit.GetStartCodeLine(Ofs: integer): integer;
var
  d,iMin,iMax: integer;
begin
  Result := 0;
  iMin := 0;
  iMax := FCodeLineCnt;
  while iMin<iMax do begin
    Result := (iMin+iMax) div 2;
    d := FCodeLineTbl^[Result].Ofs-Ofs;
    if D=0 then
      Break;
    if d<0 then
      iMin := Result+1
    else
      iMax := Result;
  end ;
end ;

procedure TUnit.GetCodeLineRec(i: integer; var CL: TCodeLineRec);
begin
  if i>=FCodeLineCnt then begin
    CL.Ofs := MaxInt;
    CL.L := MaxInt;
    Exit;
  end ;
  CL := FCodeLineTbl^[i];
end ;

procedure TUnit.ReadDeclList(LK: TDeclListKind; var Result: TNameDecl);
var
  DeclEnd: ^TNameDecl;
  Decl: TNameDecl;
  Embedded: TNameDecl;
begin
  Result := Nil;
  DeclEnd := @Result;
  while true do begin
    Decl := Nil;
    try
      case Tag of
        drType: Decl := TTypeDecl.Create;
        drTypeP: Decl := TTypePDecl.Create;
        drConst: Decl := TConstDecl.Create;
        drResStr: Decl := TResStrDef.Create;
        drSysProc: Decl := TSysProcDecl.Create;
        drProc: Decl := TProcDecl.Create(Nil);
        drEmbeddedProcStart: begin
            Tag := ReadTag;
            ReadDeclList(dlEmbedded,Embedded);
            if Tag<>drEmbeddedProcEnd then
              TagError('Embedded Stop Tag');
            Tag := ReadTag;
            if Tag<>drProc then
              TagError('Proc Tag');
            Decl := TProcDecl.Create(Embedded);
          end ;
        drVar: case LK of
          dlArgs,dlArgsT: Decl := TLocalDecl.Create(LK);
        else
          Decl := TVarDecl.Create;
        end ;
        drThreadVar: Decl := TThreadVarDecl.Create;
        drExport: Decl := TExportDecl.Create;
        drVarC: Decl := TVarCDecl.Create(false{LK=dlMain});
        arVal, arVar, arResult, arFld, arAbsLocVar:
          Decl := TLocalDecl.Create(LK);
        arLabel: Decl := TLabelDecl.Create;
        arMethod, arConstr, arDestr:
          Decl := TMethodDecl.Create(LK);
        arProperty:
          if LK=dlDispInterface then
            Decl := TDispPropDecl.Create(LK)
          else
            Decl := TPropDecl.Create;
        arCDecl,arPascal,arStdCall,arSafeCall: {Skip it};
        arSetDeft: Decl := TSetDeftInfo.Create;//ReadULong{Skip it};
//        drVoid: Decl := TAtDecl.Create;{May be end of interface}
       {--------- Type definitions ---------}
      drRangeDef,drChRangeDef,drBoolRangeDef,drWCharRangeDef,
      drWideRangeDef: TRangeDef.Create;
      drEnumDef: TEnumDef.Create;
      drFloatDef: TFloatDef.Create;
      drPtrDef: TPtrDef.Create;
      drTextDef: TTextDef.Create;
      drFileDef: TFileDef.Create;
      drSetDef: TSetDef.Create;
      drShortStrDef: TShortStrDef.Create;
      drStringDef,drWideStrDef: TStringDef.Create;
      drArrayDef: TArrayDef.Create;
      drVariantDef: TVariantDef.Create;
      drObjVMTDef: TObjVMTDef.Create;
      drRecDef: TRecDef.Create;
      drProcTypeDef: TProcTypeDef.Create;
      drObjDef: TObjDef.Create;
      drClassDef: TClassDef.Create;
      drInterfaceDef: TInterfaceDef.Create;
      drVoid: TVoidDef.Create;{May be end of interface}
      drCBlock: begin
          if LK<>dlMain then
            Break;
          if FDataBlPtr<>Nil then
            DCUError('2nd Data block');
          FDataBlSize := ReadUIndex;
          FDataBlPtr := ReadMem(FDataBlSize);
        end ;
      drFixUp: LoadFixups;
      drCodeLines: LoadCodeLines;
      drEmbeddedProcEnd:
        if not((LK=dlArgsT)and(Ver>verD3)or(LK=dlArgs)
          and(Ver>verD3{verD5 was observed, but may be in prev ver. too}))
        then
          Break; {Temp. - this tag can mark the const definition used as
          interface arg. default value and also as proc. arg. default value}
      else
        Break;
        //DCUErrorFmt('Unexpected tag: %s(%x)',[Tag,Byte(Tag)]);
      end ;
    finally
      if Decl<>Nil then begin
        DeclEnd^ := Decl;
        DeclEnd := @Decl.Next;
      end ;
    end ;
    Tag := ReadTag;
  end ;
end ;

procedure TUnit.ShowDeclList(LK: TDeclListKind; Decl: TNameDecl; Ofs: Cardinal;
  dScopeOfs: integer; SepF: TDeclSepFlags; ValidKinds: TDeclSecKinds;
  skDefault: TDeclSecKind);
const
  SecNames: array[TDeclSecKind] of String = (
    '','label','const','type','var',
    'threadvar','resourcestring','exports','',
    'private','protected','public','published');

const
  TstDeclCnt: integer=0;
var
  DeclCnt: integer;
  SepS,SecN: String;
  CurSK,SK: TDeclSecKind;
  Ofs0: Cardinal;
  Visible: boolean;
begin
  DeclCnt := 0;
  if dsComma in SepF then
    SepS := ','
  else
    SepS := ';';
  CurSK := skDefault;
  Ofs0 := NLOfs;
  NLOfs := Ofs+dScopeOfs;
  while Decl<>Nil do begin
    Inc(TstDeclCnt);
    Visible := Decl.IsVisible(LK);
    if Visible then begin
      SK := Decl.GetSecKind;
      if (DeclCnt>0) then begin
        PutS(SepS);
        if dsNL in SepF then begin
          if dsSoftNL in SepF then
            SoftNL
          else
            NL;
        end ;
      end ;
      if (SK<>CurSK) then begin
        CurSK := SK;
        NLOfs := Ofs;
        SecN := SecNames[SK];
        if SecN<>'' then begin
          NL;
          PutS(SecN);
        end ;
        if (SK<>skProc)or(dsOfsProc in SepF) then
          Inc(NLOfs,dScopeOfs);
      end ;
      if (DeclCnt>0)or not(dsNoFirst in SepF) then begin
        if dsSoftNL in SepF then
          SoftNL
        else
          NL;
      end ;
      case LK of
        dlMain: Decl.ShowDef(false);
        dlMainImpl: Decl.ShowDef(true)
      else
        Decl.Show;
      end ;
      Inc(DeclCnt);
    end ;
    Decl := Decl.Next as TNameDecl;
  end ;
  if (DeclCnt>0)and(dsLast in SepF) then begin
    PutS(SepS);
    {if dsNL in SepF then
      NL;}
  end ;
  NLOfs := Ofs0;
end ;

procedure ShowDeclTList(Title: String; L: TList);
var
  i: integer;
  D: TDCURec;
begin
  NLOfs := 0;
  NL;
  NL;
  PutS(Title);
  for i:=1 to L.Count do begin
    NLOfs := 2;
    NL;
    PutSFmt('#%x: ',[i]);
    D := L[i-1];
    if D<>Nil then begin
      if D is TNameDecl then begin
        //if not TNameDecl(D).ShowDef(false) then
          TNameDecl(D).ShowName;
       end
      else if D is TBaseDef then
        TBaseDef(D).ShowNamed(Nil)
      else
        D.Show;
     end
    else
      PutS('-');
  end ;
end ;

{ Two methods against circular references }
function TUnit.RegTypeShow(T: TBaseDef): boolean;
begin
  Result := false;
  if FTypeShowStack.IndexOf(T)>=0 then
    Exit;
  FTypeShowStack.Add(T);
  Result := true;
end ;

procedure TUnit.UnRegTypeShow(T: TBaseDef);
var
  C: integer;
begin
  C := FTypeShowStack.Count-1;
  if (C<0)or(FTypeShowStack[C]<>T) then
    DCUError('in UnRegTypeShow');
  FTypeShowStack.Count := C;
end ;
{
function TUnit.RegDataBl(BlSz: Cardinal): Cardinal;
begin
  Result := FDataBlOfs;
  Inc(FDataBlOfs,BlSz);
end ;
}

function TUnit.GetBlockMem(BlOfs,BlSz: Cardinal; var ResSz: Cardinal): Pointer;
var
  EOfs: Cardinal;
begin
  Result := Nil;
  ResSz := BlSz;
  if (FDataBlPtr=Nil)or(integer(BlOfs)<0)or(BlSz=0) then
    Exit;
  EOfs := BlSz+BlOfs;
  if BlSz+BlOfs>FDataBlSize then begin
    BlSz := FDataBlSize-BlOfs;
    if integer(BlSz)<=0 then
      Exit;
  end ;
  Result := FDataBlPtr+BlOfs;
  ResSz := BlSz;
end ;

procedure TUnit.ShowDataBl(Ofs0,BlOfs,BlSz: Cardinal);
var
  Fix0: integer;
  DP: PChar;
begin
  PutSFmt('raw[$%x..$%x]',[Ofs0,BlSz-1]);
  if BlOfs<>Cardinal(-1) then
    PutSFmt('at $%x',[BlOfs]);
  DP := GetBlockMem(BlOfs+Ofs0,BlSz-Ofs0,BlSz);
  if DP=Nil then
    Exit;
//  Inc(NLOfs,2);
  NL;
  Fix0 := GetStartFixup(BlOfs);
  ShowDump(DP,0,BlSz,Ofs0,BlOfs+Ofs0,0,
    FFixupCnt-Fix0,@FFixupTbl^[Fix0],true);
//  Dec(NLOfs,2);
end ;

procedure TUnit.ShowCodeBl(Ofs0,BlOfs,BlSz: Cardinal);
var
  CmdOfs,CmdSz: Cardinal;
  DP: Pointer;
  Fix0,hCL0: integer;
  CL: TCodeLineRec;
  Ok: boolean;
begin
  Inc(AuxLevel);
  if Ofs0=0 then
    PutSFmt('//raw[0x%x]',[BlSz])
  else
    PutSFmt('//raw[0x%x..0x%x]',[Ofs0,Ofs0+BlSz]);
  if BlOfs<>Cardinal(-1) then
    PutSFmt('at 0x%x',[BlOfs]);
  Dec(AuxLevel);
  DP := GetBlockMem(BlOfs,BlSz,BlSz);
  if DP=Nil then
    Exit;
  Inc(AuxLevel);
//  Inc(NLOfs,2);
  NL;
  Dec(AuxLevel);
  CmdOfs := BlOfs;
  Fix0 := GetStartFixup(BlOfs);
  hCL0 := GetStartCodeLine(BlOfs);
  GetCodeLineRec(hCL0,CL);
  SetCodeRange(FDataBlPtr,PChar(DP)-Ofs0,BlSz+Ofs0);
  while true do begin
    while CmdOfs>=CL.Ofs do begin
      Dec(NLOfs,2);
      NL;
      PutSFmt('// -- Line #%d -- ',[CL.L]);
      Inc(NLOfs,2);
      if CmdOfs>CL.Ofs then
        PutSFmt('<<%d',[CmdOfs-CL.Ofs]);
      Inc(hCL0);
      GetCodeLineRec(hCL0,CL);
    end ;
    NL;
    CodePtr := FDataBlPtr+CmdOfs;
    SetFixupInfo(FFixupCnt-Fix0,@FFixupTbl^[Fix0],Self);
    Ok := ReadCommand;
    if Ok then
      CmdSz := CodePtr-PrevCodePtr
    else if FixUpEnd>PrevCodePtr then
      CmdSz := FixUpEnd-PrevCodePtr
    else
      CmdSz := 1;
    ShowDump(FDataBlPtr+CmdOfs,BlSz+Ofs0,CmdSz,CmdOfs-BlOfs+Ofs0,CmdOfs,
      7,FFixupCnt-Fix0,@FFixupTbl^[Fix0],not Ok);
    PutS(' ');
    if not Ok then begin
      PutS('?');
     end
    else begin
      ShowCommand;
    end ;
    Dec(BlSz,CmdSz);
    if BlSz<=0 then
      Break;
    Inc(CmdOfs,CmdSz);
    Fix0 := GetNextFixup(Fix0,CmdOfs);
  end ;
//  Dec(NLOfs,2);
end ;

constructor TUnit.Create(FName: String; VerRq: integer);
var
  F: File;
  Magic: ulong;
  FileSizeH,L: ulong;
  FT: TFileTime;
  B: Byte;
  CP0: TScanState;
begin
  CurUnit := Self;
  if MainUnit=Nil then
    MainUnit := Self;
  FUnitImp := TList.Create;
  FTypes := TList.Create;
  FAddrs := TList.Create;
  FTypeShowStack := TList.Create;
  FDecls := Nil;
  FTypeDefCnt := 0;
//  FDefs := Nil;
  FFName := FName;
  Assign(F,FName);
  Reset(F,1);
  try
    FMemSize := FileSize(F);
    GetMem(FMemPtr,FMemSize);
    BlockRead(F,FMemPtr^,FMemSize);
  finally
    Close(F);
  end ;
  ChangeScanState(CP0,FMemPtr,FMemSize);
  try
    Magic := ReadULong;
    case Magic of
      $50505348: FVer := verD2;
      $44518641: FVer := verD3;
      $4768A6D8: FVer := verD4;
      ulong($F21F148B): FVer := verD5;
      $0E0000DD: FVer := verD6;
      ulong($F21F148C): FVer := verK1; //Kylix 1.0
    else
      DCUErrorFmt('Wrong magic: 0x%x',[Magic]);
    end ;
    if (VerRq>0)and(FVer<>VerRq) then
      Exit;
    if Ver=verD2 then begin
      fxStart := fxStart20;
      fxEnd := fxEnd20;
     end
    else begin
      fxStart := fxStart30;
      fxEnd := fxEnd30;
    end ;
   { Read File Header }
    FileSizeH := ReadULong;
    if FileSizeH<>FMemSize then
      DCUErrorFmt('Wrong size: 0x%x<>0x%x',[FMemSize,FileSizeH]);
    FT := ReadULong;
    if Ver=verD2 then begin
      B := ReadByte;
      Tag := ReadTag;
     end
    else begin
      FStamp := ReadULong;
      B := ReadByte;
      {if Ver>=verK1 then
        L := ReadULong; //$7E64AEE0 expected, it could be a tag $E0}
      {repeat
        Tag := ReadTag;
        case Tag of
         drUnitFlags: begin
           FFlags := ReadUIndex;
           if Ver>verD3 then
             FUnitPrior := ReadUIndex;
         end ;
         drUnit3,drUnit3c: begin
           if Ver<verK1 then
             Break;
           SkipBlock(3);
          end ;
         drUnit4: begin
           if Ver<verK1 then
             Break;
           L := ReadULong;
          end ;
        else
          Break;
        end ;
      until false;}
      Tag := ReadTag;
      if Ver>=verK1 then begin
        if Tag=drUnit4 then begin
          repeat
            L := ReadULong; //$7E64AEE0 expected, it could be a tag $E0}
            Tag := ReadTag;
          until Tag<>drUnit4;
         end
        else begin
          SkipBlock(3);
          Tag := ReadTag;
        end ;
      end ;
      if Tag=drUnitFlags then begin
        FFlags := ReadUIndex;
        if Ver>verD3 then
          FUnitPrior := ReadUIndex;
        Tag := ReadTag;
      end ;
    end ;
    ReadSourceFiles;
  {  PutS('interface');
    NLOfs := 0;
    NL;}
    ReadUses(drUnit);
  {  NLOfs := 0;
    NL;
    PutS('implementation');
    NLOfs := 0;
    NL;}
    ReadUses(drUnit1);
  {  NLOfs := 0;
    NL;
    PutS('imports');
    NLOfs := 0;
    NL;}
    ReadUses(drDLL);
    try
      ReadDeclList(dlMain,FDecls);
  //    if Tag<>drStop then
  //      DCUError({'Unexpected '+}'stop tag');
    finally
      SetExportNames(FDecls);
      SetEnumConsts(FDecls);
  //    Show;
    end ;
  finally
    RestoreScanState(CP0);
  end ;
end ;

destructor TUnit.Destroy;
var
  i: integer;
  U: PUnitImpRec;
  SFR: PSrcFileRec;
begin
  FTypeShowStack.Free;
  if FCodeLineTbl<>Nil then
    FreeMem(FCodeLineTbl,FCodeLineCnt*SizeOf(TCodeLineRec));
  if FFixupTbl<>Nil then
    FReeMem(FFixupTbl,FFixupCnt*SizeOf(TFixupRec));
//  FreeDCURecList(FDecls);
//  FreeDCURecList(FDefs);
  if FUnitImp<>Nil then begin
    for i:=0 to FUnitImp.Count-1 do begin
      U := FUnitImp[i];
      FreeDCURecList(U^.Decls);
      U^.Ref.Free;
//      FreeDCURecList(U^.Addrs);
//      FreeDCURecList(U^.Types);
      Dispose(U);
    end ;
    FUnitImp.Free;
  end ;
  FExportNames.Free;
//  FreeDCURecTList(FTypes);
  FTypes.Free;
//  FreeDCURecTList(FAddrs);
  FAddrs.Free;
  FreeDCURecList(FDecls);
//  FTypes.Free;
//  FAddrs.Free;
  while FSrcFiles<>Nil do begin
    SFR := FSrcFiles;
    FSrcFiles := SFR^.Next;
    Dispose(SFR);
  end ;
  if FMemPtr<>Nil then
    FreeMem(FMemPtr,FMemSize);
  inherited Destroy;
end ;

procedure TUnit.Show;
var
  i: integer;
  FP: PFixupRec;
begin
  if Self=Nil then
    Exit;
  CurUnit := Self;
  InitOut;
  if ShowAuxValues then
    AuxLevel := -MaxInt
  else
    AuxLevel := 0;
  NLOfs := 0;
  ShowSourceFiles;
  PutS('interface');
  NLOfs := 0;
  NL;
  if ShowUses('uses',[]) then begin
    NLOfs := 0;
    NL;
    //NL;
  end ;
  ShowDeclList(dlMain,FDecls,0,2,[dsLast,dsNL],BlockSecKinds,skNone);
  NLOfs := 0;
  NL;
  NL;
  if InterfaceOnly then
    Exit;
  PutS('implementation');
  NLOfs := 0;
  NL;
  if ShowUses('uses',[ufImpl]) then begin
    NLOfs := 0;
    NL;
    //NL;
  end ;
  if ShowUses('imports',[ufDLL]) then begin
    NLOfs := 0;
    //NL;
    NL;
  end ;
  ShowDeclList(dlMainImpl,FDecls,0,2,[dsLast,dsNL],BlockSecKinds,skNone);
  NLOfs := 0;
  NL;
  NL;
  PutS('end.');
  NLOfs := 0;
  NL;
  NL;
  if ShowTypeTbl then begin
    PutSFmt('Types defined: 0x%x of 0x%x',[FTypeDefCnt,FTypes.Count]);
    ShowDeclTList('types',FTypes);
    NLOfs := 0;
    NL;
    NL;
  end ;
  if ShowAddrTbl then begin
    PutSFmt('Addrs defined: 0x%x',[FAddrs.Count]);
    ShowDeclTList('addrs',FAddrs);
    NLOfs := 0;
    NL;
    NL;
  end ;
  if ShowDataBlock then begin
    PutSFmt('Data used: 0x%x of 0x%x ',[FDataBlOfs,FDataBlSize]);
    if (FDataBlPtr<>Nil){and(FDataBlOfs<FDataBlSize)} then
      ShowDataBl(FDataBlOfs,0,FDataBlSize{-FDataBlOfs});
    NLOfs := 0;
    NL;
    NL;
  end ;
  if ShowFixupTbl and(FFixupTbl<>Nil) then begin
    PutSFmt('Fixups: %d',[FFixupCnt]);
    NLOfs := 2;
    FP := Pointer(FFixupTbl);
    for i:=0 to FFixupCnt-1 do begin
      NL;
      PutSFmt('%3d: %6x K%2x %s',[i,FP^.OfsF and FixOfsMask,TByte4(FP^.OfsF)[3],
        GetAddrStr(FP^.NDX,true)]);
      Inc(FP);
    end ;
    NLOfs := 0;
    NL;
    NL;
  end ;
  FlushOut;
end ;

end.
