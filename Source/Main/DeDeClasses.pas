unit DeDeClasses;
//////////////////////////
// Last Change: 03.X.2001
//////////////////////////

interface

uses Classes, Windows, DeDeConstants;

const
      DATA_FOR_PE_HEADER_OFFSET = $3C;
      PE_HEADER_SIZE = $F8;
      MAX_PE_PLUS_DELTA = $F;

Type TPEObjectBuffer = array [1..40] of Byte;


Type TPaternQuery = Class(TObject)
       public
         buffer : Array of Byte;
         mask   : Array of Boolean;
         size   : LongInt;
         procedure SetPattern(AsPattern : String);
         procedure SetString(AsString : String);
         function GetPattern : String;
         function GetByte(Index : LongInt) : Integer;
     End;

Type THeaderType = (htNone,htDFM);     

Type TPEStream = Class (TMemoryStream)
       protected
         FlBackupPos : Longint;
       public
         procedure ReadBufferA(var buffer : array of byte; size : Dword);
         procedure WriteBufferA(var buffer : array of byte; size : Dword);
         function ReadByte : Byte;
         function ReadWord : Word;
         function ReadDWord : DWord;
         function ReadByteA : Byte;
         function ReadWordA : Word;
         function ReadDWordA : DWord;
         function ReadWordF : Word;
         function ReadDWordF : DWord;
         function ReadWordFA : Word;
         function ReadDWordFA : DWord;
         function PatternMach(APattern : TPaternQuery) : Boolean;
         procedure DumpCodeToFile(FromO,ToO : DWORD; sFileName : String; HT : THeaderType);
         procedure BeginSearch;
         procedure EndSearch;
     End;

Type ThePEFile = Class(TObject)
       protected
          Stream : TPEStream;
       public
          sFileName : String;
          constructor Create(AsFileName : String);
          destructor Destroy; override;
          procedure Seek(Offset : DWord);
          procedure Read(var b1,b2,b3,b4 : Byte); overload;
          procedure Read(var b1,b2 : Byte); overload;
          procedure Read(var b1 : Byte); overload;
          procedure Write(b : Byte);
          function FilePos : Integer;
          function FileSize : Integer;
          property PEStream : TPEStream read Stream;
     End;

Type TPEObject = object
       DATA: TPEObjectBuffer;
       OBJECT_NAME : String;
       VIRTUAL_SIZE, RVA, PHYSICAL_OFFSET,
       PHYSICAL_SIZE, FLAGS : DWORD;
       PointerToRelocations,PointerToLinenumbers,
       NumberOfRelocations,NumberOfLinenumbers : DWORD;
       InfoAddress : DWORD;
       Procedure Process;
       Function DecodeFlags(AdwFlags : DWORD) : String;
       Procedure MakeBuffer;
     End;

Type TPEHeaderBuffer = array [1..PE_HEADER_SIZE+MAX_PE_PLUS_DELTA] of Byte;


  TPEHeader = class (TObject)
  protected
    Procedure Process;
    Procedure ProcessObjects;
  public
    ELFDumped : Boolean;
    //DATA : TPEHeaderBuffer;
    PEPlusDelta : DWORD;
    PEHeaderOffset : DWORD;

    Signature : String;
    CPU : String;
    ObjectNum : Word;
    TimeStamp : DWORD;
    SymTblOffset : DWORD;
    SymNum : Word;
    OptionalPEType : String;
    NT_HDR_SIZE : Word;
    FLAGS : Array [1..16] of Boolean;
    wFlags : DWORD;
    LMAJOR_MINOR : String;
    SizeOfCode : DWORD;
    SizeOfInitializedData : DWORD;
    SizeOfUninitializedData : DWORD;
    RVA_ENTRYPOINT : DWORD;
    BaseOfCode,BaseOfData : DWORD;
    IMAGE_BASE: DWORD;
    OBJECT_ALIGN, FILE_ALIGN : DWORD;
    OSMAJOR_MINOR : DWORD;
    USERMAJOR_MINOR : DWORD;
    SUBSYSMAJOR_MINOR : DWORD;
    IMAGE_SIZE, HEADER_SIZE, FILE_CHECKSUM  : DWORD;
    SUBSYSTEM : String;
    DLL_FLAGS : String;
    STACK_RESERVE_SIZE, STACK_COMMIT_SIZE : DWORD;
    HEAP_RESERVE_SIZE, HEAP_COMMIT_SIZE : DWORD;
    LoaderFlags : DWORD;
    VA_ARRAY_SIZE : DWORD;

    EXPORT_TABLE_RVA, TOTAL_EXPORT_DATA_SIZE,
    IMPORT_TABLE_RVA, TOTAL_IMPORT_DATA_SIZE,
    RESOURCE_TABLE_RVA, TOTAL_RESOURCE_DATA_SIZE,
    EXCEPTION_TABLE_RVA, TOTAL_EXCEPTION_DATA_SIZE,
    SECURITY_TABLE_RVA, TOTAL_SECURITY_DATA_SIZE : DWORD;
    FIXUP_TABLE_RVA, TOTAL_FIXUP_DATA_SIZE,
    DEBUG_TABLE_RVA, TOTAL_DEBUG_DIRECTORIES,
    IMAGE_DESCRIPTION_RVA, TOTAL_DESCRIPTION_SIZE,
    MACHINE_SPECIFIC_RVA, MACHINE_SPECIFIC_SIZE,
    THREAD_LOCAL_STORAGE_RVA, TOTAL_TLS_SIZE : DWORD;
    Load_Config_Table_RVA, Load_Config_Table_Size : DWORD;
    Bound_Import_RVA, Bound_Import_Size : DWORD;
    IAT_RVA, IAT_Size : DWORD;
    Delay_Import_Descriptor_RVA, Delay_Import_Descriptor_Size : DWORD;
    COM_Runtime_Header_RVA, COM_Runtime_Header_Size : DWORD;
    Objects : Array [1..50] of TPEObject;

    Procedure Dump(PFile : ThePEFile);
    Procedure DumpELFFile(PFile : ThePEFile);
    Function GetPEObjectData(AsRVA : String; Var AiOffset, AiSize : LongInt) : Boolean;
    Function GetSectionIndex(AsSect : String) : Integer;
    Function GetSectionIndexByRVA(RVA: DWORD): Integer;
    Function GetSectionIndexEx(AsSect : String) : Integer;
    Destructor Destroy; override;
  End;

Type TResDirEntry = Record
       NAME_RVA, INTEGER_ID,
       DATA_ENTRY_RVA, SUBDIR_RVA : Word;
     End;


Type TPEResDirEntry = Object
       FLAGS, NameEntry, IDEntry : LongInt;
       DateTimeStamp : String;
       Version : String;
       Count : Integer;
       Entries : Array of TResDirEntry;
     End;

Type TPEResDir = Object
        DATA : Array of Byte;
        DirEntry : Array of TPEResDirEntry;
        Procedure Process;
     End;

Type TFixupBlockData = Record
        Offset, Size : DWORD;
     End;

Type TPEFixupTable = Object
       FileName : String;
       BlocksCount : Word;
       DATA : Array of TFixupBlockData;
       Procedure CollectInfo(ABaseOffset,ASize : DWord);
       Procedure GetData(AiBlock : Word; AList : TStrings);
     End;

Type TPEImportData = Object
       FileName : String;
       DLLCount, ProcCount : Integer;
       Procedure CollectInfo(APhysOffset,RVA : DWord; AList : TStrings);
     End;


Type TPETLSTable = Object
       FileName : String;
       START_DATA_BLOCK_VA,
       END_DATA_BLOCK_VA,
       INDEX_VA, CALLBACK_TABLE_VA : String;
       Procedure Process(PhysOffset : DWORD);
     End;

Type TExportFuncData = Record
       Name : String;
       Offset : String;
       Ordinal : LongInt;
       NameAddress : DWORD;
     End;

Type TPEExports = Object
        FileName : String;
        DATE_TIME_STAMP : String;
        VERSION : String;
        Name_RVA : String;
        Ordinal_Base : LongInt;
        Address_Table_Entries, Number_of_Name_Pointers : LongInt;
        Export_Address_Table_RVA,
        Name_Pointer_RVA,
        Ordinal_Table_RVA : String;
        FUNC_DATA : Array of TExportFuncData;
        Procedure Process(AdwAddress,ARVA : DWORD);
     End;


Function HexChar(Ab : Byte) : Char;
Function _Chr(Ab : Byte) : Char;
Function Chr1(Ab : Byte) : String;

// This var must not be created or freed !!!!
// If must be assigned from Application witch
// uses this unit. This application have to
// create and destroy PEFile !!!
Var PEFile : ThePEFile;


Type TOnSeek = Procedure(dw : DWORD) of Object;


Type TRVAConverter = Object
         ImageBase : DWORD;
         PhysOffset : DWORD;
         CodeRVA : DWORD;
         function GetRVA(AsPhys : DWORD) : DWORD; overload;
         function GetPhys(AsRVA : DWORD) : DWORD; overload;
         function GetRVA(AsPhys : String) : String; overload;
         function GetPhys(AsRVA : String) : String; overload;
     End;

Type TDFMProjectUnitEntrie = record
        Characteristic : Word;
        Name : String;
     end;


Type TDFMProjectHeader = Class(TObject)
        protected
        public
          FPASList : TStringList;
          FDFMList : TStringList;
          Characteristic1,Characteristic2 : DWORD;
          ProjectName : String;
          ProjectChar : WORD;
          UnitEntriesCount : WORD;
          UnitEntries : Array  of TDFMProjectUnitEntrie;
          Procedure Dump(PEStream : TPEStream; Offset : LongInt);
          Constructor Create;
          Destructor Destroy; override;
     end;


Type DWORD = LongWord;

Type TFieldRec = Class
        sName  : String;
        dwID   : DWORD;
        wFlag  : WORD;
     End;


Type TFieldData = Class
       protected
        Procedure ClearFields;
       public
        Count : Integer;
        Ptr   : DWORD;
        Fields : TList;
        Constructor Create;
        Destructor Destroy; override;
        Procedure AddField(Name : String; ID : DWORD; Flag : Word);
        Function GetFieldName(ID : DWORD) : String;
        Function GetFieldIdx(ID : DWORD) : Integer;
     End;

Type TMethodRec = Class
        sName  : String;
        dwRVA   : DWORD;
        wFlag  : WORD;
     End;


Type TMethodData = Class
       protected
        Procedure ClearMethods;
       public
        Count : Integer;
        Methods : TList;
        Constructor Create;
        Destructor Destroy;  override;
        Procedure AddMethod(Name : String; RVA : DWORD; Flag : Word);
        Function MethodIndexByRVA(RVA : DWORD) : Integer;
        Function ProcEntryPossible(RVA : DWORD) : Boolean;
     End;

Function GetDelphiVersion(PEFile : ThePEFile) : String;
Function GetDelphiVersionFromImports(sFileName : String; lImpOffset,lImpRVA : DWORD) : String;

var    GlobAbort : Boolean;
       GlobError : String;

//BOZA       PEStream : TPEStream;
       PEHeader : TPEHeader;
       ProcRefOffsets : TStringList;
       ProcRefNames : TStringList;
       DelphiVersion : String;
       GlobCBuilder : Boolean;
       GlobDelphi2  : Boolean;

       // moved here from MainUnit
       bDebug, bUserProcs, bBSS, bELF : Boolean;

////////////////////////////////////////////////////
//    Some functions needed for IDA MAP file export
// and loading .sym file into SoftIce
////////////////////////////////////////////////////
Function DeDeStrToIDAStr(sDeDeStr : String) : String;
function GetSoftIceDir : String;
function SoftIceIsActive : Boolean;


implementation

Uses
  SysUtils, Dialogs, Controls, HEXTools, IniFiles, DeDeRES, Registry,
  DeDeELFClasses;



{ TPEStream }

procedure TPEStream.BeginSearch;
begin
  FlBackupPos:=Position;
end;

procedure TPEStream.DumpCodeToFile(FromO, ToO: DWORD; sFileName: String; HT : THeaderType);
Var TmpStream : TMemoryStream;
    b : Byte;
    i : DWORD;
begin
  TmpStream:=TMemoryStream.Create;
  Try
   //Puts DFM Header
   If HT=htDFM Then For i:=0 To 15 Do TmpStream.WriteBuffer(arrDFM_HEADER[i],1);

   Try
    Seek(FromO,soFromBeginning);
    For i:=0 To ToO-FromO Do
      Begin
        b:=ReadByte;
        TmpStream.WriteBuffer(b,1);
      End;
    TmpStream.SaveToFile(sFileName);
   Except
   End;
  Finally
    TmpStream.Free;
  End;
end;

procedure TPEStream.EndSearch;
begin
   Position:=FlBackupPos;
end;

function TPEStream.PatternMach(APattern: TPaternQuery): Boolean;
var b  : Byte;
    bi : Integer;
    bMatch : Boolean;
    i : LongInt;
begin
   i:=0;
   bMatch:=True;
   While (bMatch) and (i<APattern.size) Do
    begin
     try
       ReadBuffer(b,1);
     except
       If MessageDlg(err_read_beyond+IntToStr(position),
               mtError,[mbIgnore,mbAbort],0)=mrAbort Then Begin
                    Result:=False;
                    GlobAbort:=True;
                    Exit;
                 End;
     end;
     bi:=APattern.GetByte(i);
     bMatch:=(b=bi) or (bi=-10);
     Inc(i);
    end;

   Result:=bMatch;
end;

procedure TPEStream.ReadBufferA(var buffer: array of byte; size: Dword);
begin
   ReadBuffer(buffer,size);
   Seek(-size,soFromCurrent)
end;

function TPEStream.ReadByte: Byte;
var b : Byte;
begin
  ReadBuffer(b,1);
  Result:=b;
end;

function TPEStream.ReadByteA: Byte;
var b : Byte;
begin
  ReadBuffer(b,1);
  Seek(-1,soFromCurrent);
  Result:=b;
end;

function TPEStream.ReadDWord: DWord;
Var dw : DWORD;
    //b1,b2,b3,b4 : Byte;
begin
  ReadBuffer(dw,4);
  Result:=dw;
end;

function TPEStream.ReadDWordA: DWord;
var buffer : Array of Byte;
begin
  SetLength(buffer,4);
  Read(buffer,4);
  Seek(-4,soFromCurrent);
  Result:=BA2DWORD(buffer);
end;

function TPEStream.ReadDWordF: DWord;
var d : DWORD;
begin
  ReadBuffer(d,4);
  Result:=d;
end;

function TPEStream.ReadDWordFA: DWord;
var d : DWORD;
begin
  ReadBuffer(d,4);
  Seek(-4,soFromCurrent);
  Result:=d;
end;

function TPEStream.ReadWord: Word;
var buffer : Array of Byte;
begin
  SetLength(buffer,2);
  Read(buffer,2);
  Result:=BA2WORD(buffer);
end;

function TPEStream.ReadWordA: Word;
var buffer : Array of Byte;
begin
  SetLength(buffer,2);
  Read(buffer,2);
  Seek(-2,soFromCurrent);
  Result:=BA2WORD(buffer);end;

function TPEStream.ReadWordF: Word;
var w : Word;
begin
  ReadBuffer(w,2);
  Result:=w;
end;

function TPEStream.ReadWordFA: Word;
var w : Word;
begin
  ReadBuffer(w,2);
  Seek(-2,soFromCurrent);
  Result:=w;
end;

procedure TPEStream.WriteBufferA(var buffer: array of byte; size: Dword);
begin
   WriteBuffer(buffer,size);
   Seek(-size,soFromCurrent)
end;

{ TPaternQuery }

function TPaternQuery.GetByte(Index: LongInt): Integer;
begin
  If index>size then
     Result:=-1
     Else If not mask[index]
        then Result:=-10
        else Result:=buffer[index];
end;

function TPaternQuery.GetPattern: String;
var i : Integer;
begin
  Result:='';
  For i:=0 To Size-1 Do
    If mask[i] then Result:=Result+Byte2HEX(buffer[i])
               else Result:=Result+'xx';
End;

procedure TPaternQuery.SetPattern(AsPattern: String);
Var sHex : String;
    i  : Integer;
begin
  Size:=Length(AsPattern) div 2;
  SetLength(buffer,Size);
  SetLength(mask,Size);
  For i:=0 to (Length(AsPattern) div 2)-1 Do
    Begin
      sHex:=Copy(AsPattern,(i*2)+1,2);
      If AnsiUpperCase(sHex)='XX' Then
        Begin
          buffer[i]:=0;
          mask[i]:=false;
        End
        Else Begin
          buffer[i]:=HEX2Byte(sHex);
          mask[i]:=true;
        End;
    End;
end;

procedure TPaternQuery.SetString(AsString: String);
Var i  : Integer;
begin
  Size:=Length(AsString);
  SetLength(buffer,Size);
  SetLength(mask,Size);
  For i:=0 to Length(AsString)-1 Do
    Begin
      buffer[i]:=ORD(AsString[i+1]);
      mask[i]:=true;
    End;
end;

{ TRVAConverter }

function TRVAConverter.GetPhys(AsRVA: DWORD): DWORD;
begin
  Result:=AsRVA-ImageBase-CodeRVA+PhysOffset;
end;

function TRVAConverter.GetRVA(AsPhys: DWORD): DWORD;
begin
  Result:=AsPhys+ImageBase+CodeRVA-PhysOffset;
end;

function TRVAConverter.GetPhys(AsRVA: String): String;
begin
  Result:=DWORD2HEX(HEX2DWORD(AsRVA)-ImageBase-CodeRVA+PhysOffset);
end;

function TRVAConverter.GetRVA(AsPhys: String): String;
begin
  Result:=DWORD2HEX(HEX2DWORD(AsPhys)+ImageBase+CodeRVA-PhysOffset);
end;


{ TDFMProjectHeader }


constructor TDFMProjectHeader.Create;
begin
   Inherited Create;

   FPASList:=TStringList.Create;
   FDFMList:=TStringList.Create;
end;

destructor TDFMProjectHeader.Destroy;
begin
   FPASList.Free;
   FDFMList.Free;

   Inherited Destroy;
end;

procedure TDFMProjectHeader.Dump(PEStream: TPEStream; Offset: Integer);
var b1,b2,b3,b4 : Byte;
    s : String;
    c : Word;
    i,j : LongInt;
    bAddUnit : Boolean;
begin
  // Should be improved to search for system and sysconst units, and from there to
  // to get the project header, not from the compiler ident !!!!
  // Rerteive Information
  With PEStream Do
  Begin
     BeginSearch;
     Seek(Offset+iPROJECT_OFFSET-$10,soFromBeginning);
     GlobError:=err_proj_header_incorrect;
     Try
       ReadBuffer(b1,1);ReadBuffer(b2,1);ReadBuffer(b3,1);ReadBuffer(b4,1);
       Characteristic1:=b1+b2*256+(b3+b4*256)*256*256;
       ReadBuffer(b1,1);ReadBuffer(b2,1);ReadBuffer(b3,1);ReadBuffer(b4,1);
       Characteristic2:=b1+b2*256+(b3+b4*256)*256*256;
       SetLength(UnitEntries,Characteristic2);
       UnitEntriesCount:=Characteristic2-1;
       For i:=0 To UnitEntriesCount Do
        Begin
         ReadBuffer(b1,1);ReadBuffer(b2,1);
         c:=b1+b2*256;
         ReadBuffer(b1,1);
         s:='';
         While b1<>0 Do
          Begin
           s:=s+CHR(b1);
           ReadBuffer(b1,1);
          End;
         If i=0 Then
           Begin
             // Application Data
             ProjectName:=s;
             ProjectChar:=c;
           End
           Else Begin
             // Unit Data
             UnitEntries[i].Name:=s;
             UnitEntries[i].Characteristic:=c;
           End;
       End;
     Finally
       EndSearch;
     End;
  End;

   // Processing Files

   // Adding PAS files to create
   FPASList.Clear;
   FDFMList.Clear;
   GlobError:=err_invalid_unit_flag;
   For i:=1 To UnitEntriesCount Do
   If UnitEntries[i].Characteristic AND $10 = 0
   Then
   Begin
    bAddUnit:=True;
    For j:=1 To iMAX_STANDART_UNITS_COUNT Do
    If arrPROJECT_STANDART_UNITS[j]=UnitEntries[i].Name
    Then begin
    bAddUnit:=False;
    Break;
    End;
    If bAddUnit
    Then FPASList.Add(UnitEntries[i].Name+'.PAS');
   End;
end;

Function GetDelphiVersion(PEFile : ThePEFile) : String;
const
  IDS = 'TControl';
  VER_ARR : Array [0..1,0..2] of String =
       (('0','114','120'),('D3','D4','D5'));
var
  delta, dw, dw1, bkup : DWord;
  b1,b2 : Byte;
  s : String;

  function InCODE(DW : DWORD) : boolean;
  begin
    result:=(dw > PEHeader.IMAGE_BASE + (PEHeader.Objects[1].RVA)) and
      (dw<PEHeader.IMAGE_BASE + (PEHeader.Objects[1].RVA) +
        PEHeader.Objects[1].PHYSICAL_SIZE)
  end;

Begin
  Result:='<check failed>';

  delta:=PEHeader.IMAGE_BASE + (PEHeader.Objects[1].RVA) -
    PEHeader.Objects[1].PHYSICAL_OFFSET;

  PEFile.PEStream.Seek(PEHeader.Objects[1].PHYSICAL_OFFSET,soFromBeginning);

  Repeat
    PEFile.PEStream.ReadBuffer(dw,4);
    bkup:=PEFile.PEStream.Position;
    If dw - delta = PEFile.PEStream.Position Then
    Begin
      PEFile.PEStream.ReadBuffer(b1,1);
      if b1<=16 Then
      begin
        PEFile.PEStream.ReadBuffer(b2,1);
        SetLength(s,b2);
        PEFile.PEStream.ReadBuffer(s[1],b2);
        PEFile.PEStream.ReadBuffer(dw,4);
        If InCODE(dw) then
        begin
          dw1:= dw - PEHeader.IMAGE_BASE - (PEHeader.Objects[1].RVA) +
           PEHeader.Objects[1].PHYSICAL_OFFSET;

          PEFile.PEStream.Seek(dw1-40,soFromBeginning);
          PEFile.PEStream.ReadBuffer(dw,4);
          If s=IDS then
          begin
            case dw of
              $0:
              begin
                Result:='D3';
              end;
              $B4,$114:   {cbuilder}
              begin
                if GlobCBuilder then
                  Result:='BCB4'
                else
                  Result:='D4';
              end;
              $120:
              begin
                if GlobCBuilder then
                 Result:='BCB5'
                else
                 Result:='D5';
              end;
              $138:
              begin
                if bELF then
                 Result:='Kylix';
              end;
              $128:
              begin
                if GlobCBuilder then
                  Result:='BCB6?'
                else
                  Result:='D6 CLX';
              end;

              $15C, $160:
              begin
                if GlobCBuilder then
                  Result:='BCB6?'
                else
                  Result:='D6';
              end;
              else
                Result:='<unknown version>';
            end;
            Exit;
          end;
        end;
      end;
    end;
    PEFile.PEStream.seek(bkup,soFromBeginning);
  Until
    (PEFile.PEStream.Position >=
      PEHeader.Objects[1].PHYSICAL_OFFSET+PEHeader.Objects[1].PHYSICAL_SIZE);

  If GlobDelphi2 Then Result:='D2';

End;

Function GetDelphiVersionFromImports(sFileName : String; lImpOffset,lImpRVA : DWORD) : String;
var PEImportData : TPEImportData;
    TmpList : TStringList;
    idx : Integer;
    s : String;
Begin
  Result:='<unknown>';
  if PEHeader.GetSectionIndexEx('BSS')=-1 then Exit;

  Result:='Console';
  PEImportData.FileName:=sFileName;

  TmpList:=TStringList.Create;
  Try
    Try
      PEImportData.CollectInfo(lImpOffset, lImpRVA, TmpList);
    Except
    End;

    If TmpList.IndexOf('VCL30.bpl')<>-1 Then Result:='3';
    If TmpList.IndexOf('VCL30.dpl')<>-1 Then Result:='3';

    If TmpList.IndexOf('VCL40.bpl')<>-1 Then Result:='4';
    If TmpList.IndexOf('VCL40.dpl')<>-1 Then Result:='4';

    If TmpList.IndexOf('VCL50.bpl')<>-1 Then Result:='5';
    If TmpList.IndexOf('VCL50.dpl')<>-1 Then Result:='5';

    If TmpList.IndexOf('VCL60.bpl')<>-1 Then Result:='6';
    If TmpList.IndexOf('VCL60.dpl')<>-1 Then Result:='6';

    If TmpList.IndexOf('VCL70.bpl')<>-1 Then Result:='7';
    If TmpList.IndexOf('VCL70.dpl')<>-1 Then Result:='7';

    If TmpList.IndexOf('VCL80.bpl')<>-1 Then Result:='8';
    If TmpList.IndexOf('VCL80.dpl')<>-1 Then Result:='8';

    If TmpList.IndexOf('VCL90.bpl')<>-1 Then Result:='2005';
    If TmpList.IndexOf('VCL90.dpl')<>-1 Then Result:='2005';

    If TmpList.IndexOf('VCL100.bpl')<>-1 Then Result:='2006';
    If TmpList.IndexOf('VCL100.dpl')<>-1 Then Result:='2006';

    If TmpList.IndexOf('VCL110.bpl')<>-1 Then Result:='2007';
    If TmpList.IndexOf('VCL110.dpl')<>-1 Then Result:='2007';

    If TmpList.IndexOf('VCL120.bpl')<>-1 Then Result:='2009';
    If TmpList.IndexOf('VCL120.dpl')<>-1 Then Result:='2009';


    idx:=PEHeader.GetSectionIndexEx('CODE');
    PEFile.PEStream.BeginSearch;
    Try
      PEFile.PEStream.Seek(PEHeader.Objects[idx].PHYSICAL_OFFSET+5,soFromBeginning);
      SetLength(s,3);
      PEFile.PEStream.ReadBuffer(s[1],3);
    Finally
      PEFile.PEStream.EndSearch;
    End;

    if s='C++' then
      Result:='BCB'+Result
    else
      Result:='D'  +Result;
      
  Finally
    TmpList.Free;
  End;
End;


{ TFieldData }

procedure TFieldData.AddField(Name : String; ID : DWORD; Flag : Word);
var Field : TFieldRec;
begin
  Field:=TFieldRec.Create;
  Field.sName:=Name;
  Field.dwID:=ID;
  Field.wFlag:=Flag;
  Fields.Add(Field);
end;

Function TFieldData.GetFieldName(ID : DWORD) : String;
var Field : TFieldRec;
    i : Integer;
begin
  Result:='';
  For i:=0 to Fields.Count-1 Do
    begin
      Field:=TFieldRec(Fields[i]);
      if Field.dwID=ID then
        begin
          Result:=Field.sName;
          Break;
        end;
    end;
end;

Function TFieldData.GetFieldIdx(ID : DWORD) : Integer;
var Field : TFieldRec;
    i : Integer;
begin
  Result:=-1;
  For i:=0 to Fields.Count-1 Do
    begin
      Field:=TFieldRec(Fields[i]);
      if Field.dwID=ID then
        begin
          Result:=i;
          Break;
        end;
    end;
end;


procedure TFieldData.ClearFields;
var i : Integer;
begin
  For i:=Fields.Count-1 downto 0 Do
     TFieldRec(Fields[i]).Free;
end;

constructor TFieldData.Create;
begin
  Inherited Create;

  Fields:=TList.Create;
end;

destructor TFieldData.Destroy;
begin
  ClearFields;
  Fields.Free;

  Inherited Destroy;
end;


{ TMethodData }

procedure TMethodData.AddMethod(Name: String; RVA: DWORD; Flag: Word);
var Field : TMethodRec;
begin
  Field:=TMethodRec.Create;
  Field.sName:=Name;
  Field.dwRVA:=RVA;
  Field.wFlag:=Flag;
  Methods.Add(Field);
end;

procedure TMethodData.ClearMethods;
var i : Integer;
begin
  For i:=Methods.Count-1 downto 0 Do
     TMethodRec(Methods[i]).Free;
end;

constructor TMethodData.Create;
begin
  Inherited Create;

  Methods:=TList.Create;
end;

destructor TMethodData.Destroy;
begin
  ClearMethods;
  Methods.Free;

  Inherited Destroy;
end;

function TMethodData.MethodIndexByRVA(RVA: DWORD): Integer;
var i : Integer;
begin
  For i:=0 To Methods.Count-1 Do
    If TMethodRec(Methods[i]).dwRVA=RVA Then
       Begin
         Result:=i;
         Exit;
       End;
  Result:=-1;     
end;


Function _Chr(Ab : Byte) : Char;
Begin
  If Ab=0 Then Result:='.'
     Else Result:=Chr(Ab);
End;

Function Chr1(Ab : Byte) : String;
Begin
  If Ab=0 Then Result:=''
     Else Result:=Chr(Ab);
End;

Function HexChar(Ab : Byte) : Char;
Begin
  If Ab in [32..ORD('z')]
     Then Result:=Chr(Ab)
     Else Result:='.';
End;


function TMethodData.ProcEntryPossible(RVA: DWORD): Boolean;
var i : Integer;
    dw : DWORD;
begin
  Result:=False;
  For i:=0 To Methods.Count-1 Do
    Begin
      dw:=TMethodRec(Methods[i]).dwRVA;
      If dw=RVA then
         begin
           Result:=True;
           Exit;
         end;
    End;
end;

{ TPEObject }

function TPEObject.DecodeFlags(AdwFlags: DWORD): String;
var TmpStr : String;
begin
   Result:='';
   If AdwFlags and $8>0 Then Result:=Result+txt_sect8;
   If AdwFlags and $20>0 Then Result:=Result+txt_sect20;
   If AdwFlags and $40>0 Then Result:=Result+txt_sect40;
   If AdwFlags and $80>0 Then Result:=Result+txt_sect80;
   If AdwFlags and $200>0 Then Result:=Result+txt_sect200;
   If AdwFlags and $800>0 Then Result:=Result+txt_sect800;
   If AdwFlags and $1000>0 Then Result:=Result+txt_sect1000;
   TmpStr:=DWord2Hex(AdwFlags);
   While Length(TmpStr)<8 Do TmpStr:='0'+TmpStr;
   Case TmpStr[3] of
     '1': Result:=Result+txt_align_on_a+'1-byte'+txt_boundary;
     '2': Result:=Result+txt_align_on_a+'2-byte'+txt_boundary;
     '3': Result:=Result+txt_align_on_a+'4-byte'+txt_boundary;
     '4': Result:=Result+txt_align_on_a+'8-byte'+txt_boundary;
     '5': Result:=Result+txt_align_on_a+'16-byte'+txt_boundary;
     '6': Result:=Result+txt_align_on_a+'32-byte'+txt_boundary;
     '7': Result:=Result+txt_align_on_a+'64-byte'+txt_boundary;
     '8': Result:=Result+txt_align_on_a+'128-byte'+txt_boundary;
     '9': Result:=Result+txt_align_on_a+'256-byte'+txt_boundary;
     'A': Result:=Result+txt_align_on_a+'512-byte'+txt_boundary;
     'B': Result:=Result+txt_align_on_a+'1024-byte'+txt_boundary;
     'C': Result:=Result+txt_align_on_a+'2048-byte'+txt_boundary;
     'D': Result:=Result+txt_align_on_a+'4096-byte'+txt_boundary;
     'E': Result:=Result+txt_align_on_a+'8192-byte'+txt_boundary;
   End;
   If AdwFlags and $1000000>0 Then Result:=Result+txt_sect1000000;
   If AdwFlags and $2000000>0 Then Result:=Result+txt_sect2000000;
   If AdwFlags and $4000000>0 Then Result:=Result+txt_sect4000000;
   If AdwFlags and $8000000>0 Then Result:=Result+txt_sect8000000;
   If AdwFlags and $10000000>0 Then Result:=Result+txt_sect10000000;
   If AdwFlags and $20000000>0 Then Result:=Result+txt_sect20000000;
   If AdwFlags and $40000000>0 Then Result:=Result+txt_sect40000000;
   If AdwFlags and $80000000>0 Then Result:=Result+txt_sect80000000;
end;

procedure TPEObject.MakeBuffer;
Var i : Integer;
    val : DWORD;
begin
  // adding object name
  For i:=1 To Length(OBJECT_NAME) Do
     DATA[i]:=ORD(OBJECT_NAME[i]);
  For i:=Length(OBJECT_NAME)+1 To 8 Do
     DATA[i]:=0;
  Val:=VIRTUAL_SIZE;
  DATA[9]:=Val mod 256;Val:=Val div 256;
  DATA[10]:=Val mod 256;Val:=Val div 256;
  DATA[11]:=Val mod 256;Val:=Val div 256;
  DATA[12]:=Val mod 256;
  Val:=RVA;
  DATA[13]:=Val mod 256;Val:=Val div 256;
  DATA[14]:=Val mod 256;Val:=Val div 256;
  DATA[15]:=Val mod 256;Val:=Val div 256;
  DATA[16]:=Val mod 256;
  Val:=PHYSICAL_SIZE;
  DATA[17]:=Val mod 256;Val:=Val div 256;
  DATA[18]:=Val mod 256;Val:=Val div 256;
  DATA[19]:=Val mod 256;Val:=Val div 256;
  DATA[20]:=Val mod 256;
  Val:=PHYSICAL_OFFSET;
  DATA[21]:=Val mod 256;Val:=Val div 256;
  DATA[22]:=Val mod 256;Val:=Val div 256;
  DATA[23]:=Val mod 256;Val:=Val div 256;
  DATA[24]:=Val mod 256;
  Val:=PointerToRelocations;
  DATA[25]:=Val mod 256;Val:=Val div 256;
  DATA[26]:=Val mod 256;Val:=Val div 256;
  DATA[27]:=Val mod 256;Val:=Val div 256;
  DATA[28]:=Val mod 256;
  Val:=PointerToLinenumbers;
  DATA[29]:=Val mod 256;Val:=Val div 256;
  DATA[30]:=Val mod 256;Val:=Val div 256;
  DATA[31]:=Val mod 256;Val:=Val div 256;
  DATA[32]:=Val mod 256;
  Val:= NumberOfRelocations;
  DATA[33]:=Val mod 256;Val:=Val div 256;
  DATA[34]:=Val mod 256;
  Val:=NumberOfLinenumbers;
  DATA[35]:=Val mod 256;Val:=Val div 256;
  DATA[36]:=Val mod 256;
  Val:=FLAGS;
  DATA[37]:=Val mod 256;Val:=Val div 256;
  DATA[38]:=Val mod 256;Val:=Val div 256;
  DATA[39]:=Val mod 256;Val:=Val div 256;
  DATA[40]:=Val mod 256;
end;

procedure TPEObject.Process;
begin
 // Object Table: begins from 1F8h, 40 bytes as follows:
 //*1..8   - object name
 //*12..9  - virtual size (when loaded into memory)
 //*16..13 - RVA (virtual address);
 //*20..17 - size (of raw data);
 //*24..21 - offset (pointer to raw data);
 // 28..25 - PointerToRelocations
 // 32..29 - PointerToLinenumbers
 // 34..33 - NumberOfRelocations
 // 36..35 - NumberOfLinenumbers
 //*40..37 - flags (Characteristics);
 //                                       [ name              ]
 // [virtual size ]  [RVA           ]     [ Size   ]  [ Offset]
 // [ PtrToRelocs.]  [ PtrToLinNum. ]     [NOR][NOL]  [ Flags ]
   OBJECT_NAME:=Chr1(DATA[1])+Chr1(DATA[2])+Chr1(DATA[3])+Chr1(DATA[4])
         +Chr1(DATA[5])+Chr1(DATA[6])+Chr1(DATA[7])+Chr1(DATA[8]);
   RVA:=(DATA[16]*256+DATA[15])*256*256+DATA[14]*256+DATA[13];
   PHYSICAL_OFFSET:=(DATA[24]*256+DATA[23])*256*256+DATA[22]*256+DATA[21];
   PHYSICAL_SIZE:=(DATA[20]*256+DATA[19])*256*256+DATA[18]*256+DATA[17];
   VIRTUAL_SIZE:=(DATA[12]*256+DATA[11])*256*256+DATA[10]*256+DATA[9];
   FLAGS:=(DATA[40]*256+DATA[39])*256*256+DATA[38]*256+DATA[37];

   PointerToRelocations:=(DATA[28]*256+DATA[27])*256*256+DATA[26]*256+DATA[25];
   PointerToLinenumbers:=(DATA[32]*256+DATA[31])*256*256+DATA[30]*256+DATA[29];
   NumberOfRelocations:=DATA[34]*256+DATA[33];
   NumberOfLinenumbers:=DATA[36]*256+DATA[35];
end;

{ TPEHeader }

destructor TPEHeader.Destroy;
begin

  inherited;
end;

procedure TPEHeader.Dump(PFile : ThePEFile);
var lPEHOffset : DWORD;
    b1,b2 : Byte;
    j,k : Integer;
begin
  if bELF then
  begin
    DumpElfFile(PFile);
    ELFDumped:=True;
    Exit;
  end;

  ELFDumped := False;

  PEFile := PFile;
  PEFile.PEStream.Seek(0, SoFromBeginning);
  PEFile.Seek(DATA_FOR_PE_HEADER_OFFSET);
  PEFile.Read(b1, b2);
  lPEHOffset := b1 + b2*256;

  PEHeaderOffset := lPEHOffset;

  Process;
  PEFile.Seek(PE_HEADER_SIZE + lPEHOffset + PEPlusDelta);
  For j:=1 To ObjectNum Do
  Begin
    //Objects[j]:=TPEObject.Create;
    Objects[j].InfoAddress:=PEFile.FilePos;

    SetLength(Objects[j].OBJECT_NAME,8);
    PEFile.Stream.ReadBuffer(Objects[j].OBJECT_NAME[1],8);
    For k:=1 to 8 do
    if Objects[j].OBJECT_NAME[k] = #0 then
    begin
      Objects[j].OBJECT_NAME := Copy(Objects[j].OBJECT_NAME,1,k-1);
      Break;
    end;

    PEFile.Stream.ReadBuffer(Objects[j].VIRTUAL_SIZE,4);
    PEFile.Stream.ReadBuffer(Objects[j].RVA,4);
    PEFile.Stream.ReadBuffer(Objects[j].PHYSICAL_SIZE,4);
    PEFile.Stream.ReadBuffer(Objects[j].PHYSICAL_OFFSET,4);
    PEFile.Stream.ReadBuffer(Objects[j].PointerToRelocations,4);
    PEFile.Stream.ReadBuffer(Objects[j].PointerToLinenumbers,4);
    PEFile.Stream.ReadBuffer(Objects[j].NumberOfRelocations,2);
    PEFile.Stream.ReadBuffer(Objects[j].NumberOfLinenumbers,2);
    PEFile.Stream.ReadBuffer(Objects[j].FLAGS,4);
  End;

  //ProcessObjects;
end;

procedure TPEHeader.DumpELFFile(PFile : ThePEFile);
var  ElfFile : TELFFile;
     i,idx : Integer;
     tmp : TPEObject;
begin
  ElfFile:=TELFFile.Create(PFile.sFileName);
  try
    ElfFile.Dump;

    PEHeader.ELFDumped:=True;
    PEHeader.Signature:='ELF';
    PEHeader.ObjectNum:=ElfFile.ELFHeader.SectionsCount;
    if PEHeader.ObjectNum>High(PEHeader.Objects) then Raise Exception.Create('Too many ELF sections!');
    //First Section is NULL
    for i:=1 to PEHeader.ObjectNum-1 do
      begin
        PEHeader.Objects[i].OBJECT_NAME:=ElfFile.ELFHeader.Sections[i].SectionName;
        PEHeader.Objects[i].VIRTUAL_SIZE:=ElfFile.ELFHeader.Sections[i].SHDR.sh_size;
        PEHeader.Objects[i].RVA:=ElfFile.ELFHeader.Sections[i].SHDR.sh_addr;
        PEHeader.Objects[i].PHYSICAL_OFFSET:=ElfFile.ELFHeader.Sections[i].SHDR.sh_offset;
        PEHeader.Objects[i].PHYSICAL_SIZE:=ElfFile.ELFHeader.Sections[i].SHDR.sh_size;;
        PEHeader.Objects[i].FLAGS:=ElfFile.ELFHeader.Sections[i].SHDR.sh_flags;
      end;
    PEHeader.RVA_ENTRYPOINT:=ElfFile.ELFHeader.ELF32HDR.e_entry;
    PEHeader.BaseOfCode:=PEHeader.GetSectionIndex('.text');
    idx:=PEHeader.GetSectionIndex('.rodata');

    //Move the class data section first
    if idx>1 then begin
      tmp:=PEHeader.Objects[idx];
      PEHeader.Objects[idx]:=PEHeader.Objects[1];
      PEHeader.Objects[1]:=tmp;
    end;

    PEHeader.IMAGE_BASE:=0;
  finally
    ElfFile.Free;
  end;
end;

function TPEHeader.GetPEObjectData(AsRVA: String; Var AiOffset,
  AiSize: Integer): Boolean;
Var i : Integer;
begin
  For i:=1 To ObjectNum Do
   Begin
     If Objects[i].RVA=Hex2DWord(AsRVA) Then Break;
   End;
 If Objects[i].RVA=Hex2DWord(AsRVA)
  Then Begin
    Result:=True;
    AiOffset:=Objects[i].PHYSICAL_OFFSET;
    AiSize:=Objects[i].PHYSICAL_SIZE;
  End
  Else Begin
    For i:=1 To ObjectNum Do
     Begin
       If Objects[i].RVA>Hex2DWord(AsRVA) Then Break;
     End;
     AiOffset:=Objects[i-1].PHYSICAL_OFFSET+(Hex2DWord(AsRVA)-Objects[i-1].RVA);
     AiSize:=-1;
     If Hex2DWORD(AsRVA)=0
      Then Result:=False
      Else Result:=True; 
  End;
end;

function TPEHeader.GetSectionIndex(AsSect: String): Integer;
Var i : Integer;
begin
//  Result:=GetSectionIndexEx(AsSect);
  Result:=-1;
  If ObjectNum=0 Then Exit;
  For i:=1 To ObjectNum Do
    If Objects[i].OBJECT_NAME=AsSect Then Break;
  If Objects[i].OBJECT_NAME=AsSect Then Result:=i;
end;

function TPEHeader.GetSectionIndexByRVA(RVA: DWORD): Integer;
Var i : Integer;
begin
  Result:=-1;
  If ObjectNum=0 Then Exit;
{  for i:=1 to PEHeader.ObjectNum Do
    If ABS(PEHeader.Objects[i].RVA-RVA)<$10 then break;

  If ABS(PEHeader.Objects[i].RVA-RVA)<$10 then Result:=i;}
  for i:=1 to PEHeader.ObjectNum Do
    If PEHeader.Objects[i].RVA=RVA then break;

  If PEHeader.Objects[i].RVA=RVA then Result:=i;

end;

function TPEHeader.GetSectionIndexEx(AsSect: String): Integer;
var i : Integer;
    RVA : DWORD;
begin
  Result:=-1;
  //Elf file support. The mapping is not exactly 100% :(
  if  bELF then begin
    if AsSect='CODE' then AsSect:='.text';
    if AsSect='DATA' then AsSect:='.data';
    if AsSect='.idata' then AsSect:='.dynsym';
    if AsSect='.rsrc' then AsSect:='borland.resdata';
    if AsSect='BSS' then AsSect:='.bss';
    Result:=GetSectionIndex(AsSect);
  end
  else begin
    if AsSect='CODE' then Result:=GetSectionIndexByRVA(self.BaseOfCode);
    if AsSect='DATA' then Result:=GetSectionIndexByRVA(self.BaseOfData);
    if AsSect='.idata' then Result:=GetSectionIndexByRVA(self.IMPORT_TABLE_RVA);
    if AsSect='.rsrc' then Result:=GetSectionIndexByRVA(self.RESOURCE_TABLE_RVA);
    if AsSect='BSS' then
      begin
        Result:=-1;
        RVA:=self.BaseOfData;
        If ObjectNum=0 Then Exit;
        // Try to find the BSS section as the first section after the data section
        // that has zero phisical length. This will not be 0 length if the file is
        // memory mirror
        for i:=1 to PEHeader.ObjectNum Do
          If (PEHeader.Objects[i].RVA>RVA) and (PEHeader.Objects[i].PHYSICAL_SIZE=0) then break;

        If (PEHeader.Objects[i].RVA>RVA) and (PEHeader.Objects[i].PHYSICAL_SIZE=0) then Result:=i;
        if Result<>-1 then exit;

        //now return it as the 3-th section
        Result:=3;
      end;
   end;
end;


procedure TPEHeader.Process;
var
  wCPU,wSubSys, wDLL, wOptionalPEType : Word;
  lPEHOffset : Word;
  b1,b2 : Byte;
begin
  // PE Header:

  PEFile.PEStream.Seek(DATA_FOR_PE_HEADER_OFFSET,soFromBeginning);
  PEFile.PEStream.ReadBuffer(lPEHOffset,2);
  PEFile.PEStream.Seek(lPEHOffset,soFromBeginning);

  {REAL PE HEADER}
  SetLength(Signature,4);
  PEFile.PEStream.ReadBuffer(Signature[1],4);
  If Copy(Signature,1,2)<>'PE' Then
    Raise Exception.Create(err_bad_signature+Copy(Signature,1,2)+#13#10+err_d1_not_supported);

  PEFile.PEStream.ReadBuffer(wCPU,2);
  Case wCPU of
       0: CPU:='unknown';
    $184: CPU:='Alpha AXP';
    $1c0: CPU:='ARM';
    $284: CPU:='Alpha AXP?64-bit';
    $14c: CPU:='386 and later';
     333: CPU:='486';
     334: CPU:='586';
    $200: CPU:='Intel IA64';
    $268: CPU:='Motorola 68000 series';
    $266: CPU:='MIPS16';
    $366: CPU:='MIPS with FPU';
    $466: CPU:='MIPS16 with FPU';
    $1f0: CPU:='Power PC, little endian';
    $162: CPU:='R3000';
    $166: CPU:='MIPS?little endian';
    $168: CPU:='R10000';
    $1a2: CPU:='Hitachi SH3';
    $1a6: CPU:='Hitachi SH4';
    $1c2: CPU:='MACHINE_THUMB';
    Else CPU:=IntToHex(wCPU,2);
  End;

  PEFile.PEStream.ReadBuffer(ObjectNum,2);
  PEFile.PEStream.ReadBuffer(TimeStamp,4);
  PEFile.PEStream.ReadBuffer(SymTblOffset,4);
  PEFile.PEStream.ReadBuffer(SymNum,4);
  PEFile.PEStream.ReadBuffer(NT_HDR_SIZE,2);

  //Note: wFlag is a bit mask and must be OR-ed
  PEFile.PEStream.ReadBuffer(wFlags,2);
  FLAGS[1]:=wFlags and $1 > 0;
  FLAGS[2]:=wFlags and $2 > 0;
  FLAGS[3]:=wFlags and $4 > 0;
  FLAGS[4]:=wFlags and $8 > 0;
  FLAGS[5]:=wFlags and $10 > 0;
  FLAGS[6]:=wFlags and $20 > 0;
  FLAGS[7]:=wFlags and $40 > 0;
  FLAGS[8]:=wFlags and $80 > 0;
  FLAGS[9]:=wFlags and $100 > 0;
  FLAGS[10]:=wFlags and $200 > 0;
  FLAGS[11]:=wFlags and $400 > 0;
  FLAGS[13]:=wFlags and $1000 > 0;
  FLAGS[14]:=wFlags and $2000 > 0;
  FLAGS[15]:=wFlags and $4000 > 0;
  FLAGS[16]:=wFlags and $8000 > 0;

  PEFile.PEStream.ReadBuffer(wOptionalPEType,2);
  {OPTIONAL PE HEADER}
  PEFile.Read(b1,b2);
  LMAJOR_MINOR:=IntToStr(b1)+'.'+IntToStr(b2);
  PEFile.PEStream.ReadBuffer(SizeOfCode,4);
  PEFile.PEStream.ReadBuffer(SizeOfInitializedData,4);
  PEFile.PEStream.ReadBuffer(SizeOfUninitializedData,4);
  PEFile.PEStream.ReadBuffer(RVA_ENTRYPOINT,4);
  PEFile.PEStream.ReadBuffer(BaseOfCode,4);
  PEFile.PEStream.ReadBuffer(BaseOfData,4);

  PEFile.PEStream.ReadBuffer(IMAGE_BASE,4);
  PEFile.PEStream.ReadBuffer(OBJECT_ALIGN,4);
  PEFile.PEStream.ReadBuffer(FILE_ALIGN,4);
  PEFile.PEStream.ReadBuffer(OSMAJOR_MINOR,4);
  PEFile.PEStream.ReadBuffer(USERMAJOR_MINOR,4);
  PEFile.PEStream.ReadBuffer(SUBSYSMAJOR_MINOR,4);

  // Reading Reserved Flag
  PEFile.PEStream.ReadBuffer(IMAGE_SIZE,4);

  PEFile.PEStream.ReadBuffer(IMAGE_SIZE,4);
  PEFile.PEStream.ReadBuffer(HEADER_SIZE,4);
  PEFile.PEStream.ReadBuffer(FILE_CHECKSUM,4);
  PEFile.PEStream.ReadBuffer(wSubSys,2);
  Case wSubSys Of
    0: SUBSYSTEM:='Unknown';
    1: SUBSYSTEM:='Device Driver Or Native';
    2: SUBSYSTEM:='Windows?GUI';
    3: SUBSYSTEM:='Windows?CUI';
    5: SUBSYSTEM:='OS/2 CUI';
    7: SUBSYSTEM:='Posix CUI';
    9: SUBSYSTEM:='Windows CE';
    10: SUBSYSTEM:='EFI application';
    11: SUBSYSTEM:='EFI Boot Service';
    12: SUBSYSTEM:='EFI Runtime Service'
    Else SUBSYSTEM:=IntToHex(wSubSys,2);
  End;
  PEFile.PEStream.ReadBuffer(wDLL,2);
  Case wDLL Of
    $1    : DLL_FLAGS:='Per-Process Library Initialization';
    $2    : DLL_FLAGS:='Per-Process Library Termination';
    $4    : DLL_FLAGS:='Per-Thread Library Initialization';
    $8    : DLL_FLAGS:='Per-Thread Library Termination';
    $800  : DLL_FLAGS:='Do not bind image';
    $2000 : DLL_FLAGS:='Driver is a WDM Driver';
    $8000 : DLL_FLAGS:='Image is Terminal Server aware'
    Else DLL_FLAGS:=IntToHex(wDLL,2);
  End;

  PEFile.PEStream.ReadBuffer(STACK_RESERVE_SIZE,4);
  PEFile.PEStream.ReadBuffer(STACK_COMMIT_SIZE,4);
  PEFile.PEStream.ReadBuffer(HEAP_RESERVE_SIZE,4);
  PEFile.PEStream.ReadBuffer(HEAP_COMMIT_SIZE,4);
  PEFile.PEStream.ReadBuffer(LoaderFlags,4);
  PEFile.PEStream.ReadBuffer(VA_ARRAY_SIZE,4);

  PEFile.PEStream.ReadBuffer(EXPORT_TABLE_RVA,4);
  PEFile.PEStream.ReadBuffer(TOTAL_EXPORT_DATA_SIZE,4);
  PEFile.PEStream.ReadBuffer(IMPORT_TABLE_RVA,4);
  PEFile.PEStream.ReadBuffer(TOTAL_IMPORT_DATA_SIZE,4);
  PEFile.PEStream.ReadBuffer(RESOURCE_TABLE_RVA,4);
  PEFile.PEStream.ReadBuffer(TOTAL_RESOURCE_DATA_SIZE,4);
  PEFile.PEStream.ReadBuffer(EXCEPTION_TABLE_RVA,4);
  PEFile.PEStream.ReadBuffer(TOTAL_EXCEPTION_DATA_SIZE,4);
  PEFile.PEStream.ReadBuffer(SECURITY_TABLE_RVA,4);
  PEFile.PEStream.ReadBuffer(TOTAL_SECURITY_DATA_SIZE,4);
  PEFile.PEStream.ReadBuffer(FIXUP_TABLE_RVA,4);
  PEFile.PEStream.ReadBuffer(TOTAL_FIXUP_DATA_SIZE,4);
  PEFile.PEStream.ReadBuffer(DEBUG_TABLE_RVA,4);
  PEFile.PEStream.ReadBuffer(TOTAL_DEBUG_DIRECTORIES,4);
  PEFile.PEStream.ReadBuffer(IMAGE_DESCRIPTION_RVA,4);
  PEFile.PEStream.ReadBuffer(TOTAL_DESCRIPTION_SIZE,4);
  PEFile.PEStream.ReadBuffer(MACHINE_SPECIFIC_RVA,4);
  PEFile.PEStream.ReadBuffer(MACHINE_SPECIFIC_SIZE,4);
  PEFile.PEStream.ReadBuffer(THREAD_LOCAL_STORAGE_RVA,4);
  PEFile.PEStream.ReadBuffer(TOTAL_TLS_SIZE,4);


  PEFile.PEStream.ReadBuffer(Load_Config_Table_RVA,4);
  PEFile.PEStream.ReadBuffer(Load_Config_Table_Size,4);
  PEFile.PEStream.ReadBuffer(Bound_Import_RVA,4);
  PEFile.PEStream.ReadBuffer(Bound_Import_Size,4);
  PEFile.PEStream.ReadBuffer(IAT_RVA,4);
  PEFile.PEStream.ReadBuffer(IAT_Size,4);
  PEFile.PEStream.ReadBuffer(Delay_Import_Descriptor_RVA,4);
  PEFile.PEStream.ReadBuffer(Delay_Import_Descriptor_Size,4);
  PEFile.PEStream.ReadBuffer(COM_Runtime_Header_RVA,4);
  PEFile.PEStream.ReadBuffer(COM_Runtime_Header_Size,4);

  PEPlusDelta:=0;
end;

procedure TPEHeader.ProcessObjects;
var i : Integer;
begin
  For i:=1 To ObjectNum Do
     Objects[i].Process;
end;

{ TPEResDir }

procedure TPEResDir.Process;
var i,j,SubNameCount, SubIDCount : Word;
    ResDirCount : Word;
    Flag : Word;
begin
  i:=1;
  ResDirCount:=0;
  Repeat
     Flag:=DATA[i+1]*256+DATA[i];
     If Flag<>0 Then Break;
     SubNameCount:=DATA[13+i]*256+DATA[12+i];
     SubIDCount:=DATA[15+i]*256+DATA[14+i];
     i:=i+16+(SubIDCount+SubNameCount)*8;
     Inc(ResDirCount);
  Until False;

  SetLength(DirEntry,ResDirCount+1);
  i:=0;
  ResDirCount:=0;
 Try
  Repeat
     Flag:=DATA[i+2]*256+DATA[i+1];
     If Flag<>0 Then Break;
     SubNameCount:=DATA[i+14]*256+DATA[i+13];
     SubIDCount:=DATA[i+16]*256+DATA[i+15];
     DirEntry[ResDirCount].FLAGS:=Flag;
     DirEntry[ResDirCount].Version:=IntToStr(DATA[i+10]*256+DATA[i+9])+'.'+IntToStr(DATA[i+12]*256+DATA[i+11]);
     DirEntry[ResDirCount].NameEntry:=DATA[i+14]*256+DATA[i+13];
     DirEntry[ResDirCount].IDEntry:=DATA[i+16]*256+DATA[i+15];
     DirEntry[ResDirCount].DateTimeStamp:=Byte2Hex(DATA[i+8])
      +Byte2Hex(DATA[i+7])+Byte2Hex(DATA[i+6])+Byte2Hex(DATA[i+5]);
     SetLength(DirEntry[ResDirCount].Entries,SubIDCount+SubNameCount);
     For j:=1 To SubIDCount+SubNameCount Do
      With DirEntry[ResDirCount].Entries[j] Do
        Begin
          NAME_RVA:=DATA[i+(j-1)*8+2]*256+DATA[i+(j-1)*8+1];
          INTEGER_ID:=DATA[i+(j-1)*8+4]*256+DATA[i+(j-1)*8+3];
          DATA_ENTRY_RVA:=DATA[i+(j-1)*8+6]*256+DATA[i+(j-1)*8+5];
          SUBDIR_RVA:=DATA[i+(j-1)*8+8]*256+DATA[i+(j-1)*8+7];
        End;
     i:=16+(SubIDCount+SubNameCount)*8;
     Inc(ResDirCount);
  Until ResDirCount=50;
 Except
   ShowMessage(IntToStr(ResDirCount));
 End;

end;

{ TPEFixupTable }

procedure TPEFixupTable.CollectInfo;
var i, Count : DWORD;
    f : File of Byte;
    b1,b2,b3,b4 : Byte;
begin
  BlocksCount:=0;
  System.Assign(f,FileName);
  System.Reset(f);
  i:=ABaseOffset;
  Repeat
     System.Seek(f,i+4);
     System.Read(f,b1,b2,b3,b4);
     Count:=b1+b2*256+(b3+b4*256)*256*256;
     i:=i+Count;
     Inc(BlocksCount);
  Until (i>=ABaseOffset+ASize) or (Count=0);

  SetLength(DATA,BlocksCount);
  BlocksCount:=0;
  i:=ABaseOffset;
  Repeat
     System.Seek(f,i+4);
     System.Read(f,b1,b2,b3,b4);
     Count:=b1+b2*256+(b3+b4*256)*256*256;
     Inc(BlocksCount);
     DATA[BlocksCount-1].Offset:=i;
     DATA[BlocksCount-1].Size:=Count;
     i:=i+Count;
  Until(i>=ABaseOffset+ASize) or (Count=0);
  System.Close(f);
end;

procedure TPEFixupTable.GetData(AiBlock: Word; AList: TStrings);
var f : File of Byte;
    b1,b2,b3,b4 : Byte;
    blocksize,i : Word;
begin
  AList.Clear;
  System.Assign(f,FileName);
  System.Reset(f);
  System.Seek(f,DATA[AiBlock-1].Offset);
  System.Read(f,b1,b2,b3,b4);
  AList.Add(Format('Fixup Block N%d  Page RVA:%d',[AiBlock,b1+b2*256+(b3+b4*256)*256*256]));
  System.Read(f,b1,b2,b3,b4);
  AList.Add('');
  blocksize:=b1+b2*256+(b3+b4*256)*256*256;
  For i:=5 To blocksize div 2 Do
   Begin
    System.Read(f,b1,b2);
    AList.Add(Byte2Hex(b1)+Byte2Hex(b2));
   End;
  System.Close(f);
end;

{ TPEImportData }

procedure TPEImportData.CollectInfo(APhysOffset, RVA: DWord; AList : TStrings);
var b1,b2,b3,b4 : Byte;
    Delta : DWORD;
    CurrDirPos : DWORD;
    LookOffset : DWORD;
    HintOffset : DWORD;
    ProcOffset : DWord;
    DLLName, ProcName, ProcAddress, ProcHint : String;
begin
  If PEFile=nil Then
     Raise Exception.Create(err_no_pefile_assigned);
  DLLCount:=0;
  ProcCount:=0;
  DELTA:=APhysOffset-RVA;
  AList.Clear;
  CurrDirPos:=APhysOffset;
  Repeat
    PEFile.Seek(CurrDirPos+12);
    PEFile.Read(b1,b2,b3,b4);
    HintOffset:=(b1+256*b2)+(b3+256*b4)*65536;
    HintOffset:=HintOffset+Delta;
    PEFile.Read(b1,b2,b3,b4);
    LookOffset:=(b1+256*b2)+(b3+256*b4)*65536+Delta;
    If (HintOffset=LookOffset) and (HintOffset=Delta) Then Break;
    PEFile.Seek(HintOffset);
    DLLName:='';
    Repeat
      PEFile.Read(b1);
      DLLName:=DLLName+Chr(b1);
    Until b1=0;
    AList.Add(DLLName);
    Inc(DLLCount);
    ProcName:='';
     Repeat
       PEFile.Seek(LookOffset);
       PEFile.Read(b1,b2,b3,b4);
       ProcOffset:=(b1+256*b2)+(b3+256*b4)*65536;
       If ProcOffset=0 Then Break;
       ProcHint:=DWord2Hex(ProcOffset and $80000000);
       ProcAddress:=DWord2Hex(ProcOffset and $7fffffff);
       If ProcHint<>'80000000' Then
        Begin
          // Import is by name, so read the name !!!
          ProcOffset:={ProcOffset}HEX2DWord(ProcAddress)+Delta;
          PEFile.Seek(ProcOffset+2);
          ProcName:='';
          Repeat
            PEFile.Read(b1);
            ProcName:=ProcName+Chr(b1);
          Until b1=0;
         End
         Else Begin
           //Import is by ordinal.
           ProcName:='Ordinal:'+ProcAddress;
           ProcAddress:='00000000';
         End;
       ProcName:=Copy(ProcName,1,Length(ProcName)-1);
       AList.Add(' '+ProcName+Format(',%sh,%s',[ProcAddress,ProcHint]));
       Inc(ProcCount);
       LookOffset:=LookOffset+4;
     Until False;
    CurrDirPos:=CurrDirPos+20;
  Until False;
end;

{ TPETLSTable }

procedure TPETLSTable.Process;
var f : File of Byte;
    b1,b2,b3,b4 : Byte;
begin
  System.Assign(f,FileName);
  System.ReSet(f);
  System.Seek(f,PhysOffset);
  System.Read(f,b1,b2,b3,b4);
  START_DATA_BLOCK_VA:=Byte2Hex(b4)+Byte2Hex(b3)+Byte2Hex(b2)+Byte2Hex(b1);
  System.Read(f,b1,b2,b3,b4);
  END_DATA_BLOCK_VA:=Byte2Hex(b4)+Byte2Hex(b3)+Byte2Hex(b2)+Byte2Hex(b1);
  System.Read(f,b1,b2,b3,b4);
  INDEX_VA:=Byte2Hex(b4)+Byte2Hex(b3)+Byte2Hex(b2)+Byte2Hex(b1);
  System.Read(f,b1,b2,b3,b4);
  CALLBACK_TABLE_VA:=Byte2Hex(b4)+Byte2Hex(b3)+Byte2Hex(b2)+Byte2Hex(b1);
  System.Close(f);
end;

{ TPEExports }

procedure TPEExports.Process(AdwAddress,ARVA: DWORD);
var b1,b2,b3,b4 : Byte;
    i : LongInt;
    TmpStr : String;
begin
   If PEFile=nil Then
      Raise Exception.Create(err_no_pefile_assigned);
   {Reading Export Directory Table}
   PEFile.Seek(AdwAddress+4);
   PEFile.Read(b1,b2,b3,b4);
   DATE_TIME_STAMP:=Byte2Hex(b4)+Byte2Hex(b3)+Byte2Hex(b2)+Byte2Hex(b1);
   PEFile.Read(b1,b2,b3,b4);
   VERSION:=Format('%d.%d',[b1+256*b2,b3+256*b4]);
   PEFile.Read(b1,b2,b3,b4);
   Name_RVA:=Byte2Hex(b4)+Byte2Hex(b3)+Byte2Hex(b2)+Byte2Hex(b1)+'h';
   PEFile.Read(b1,b2,b3,b4);
   Ordinal_Base:=(b1+b2*256)+(b3+b4*256)*256*256;
   PEFile.Read(b1,b2,b3,b4);
   Address_Table_Entries:=(b1+b2*256)+(b3+b4*256)*256*256;
   PEFile.Read(b1,b2,b3,b4);
   Number_of_Name_Pointers:=(b1+b2*256)+(b3+b4*256)*256*256;
   PEFile.Read(b1,b2,b3,b4);
   Export_Address_Table_RVA:=Byte2Hex(b4)+Byte2Hex(b3)+Byte2Hex(b2)+Byte2Hex(b1)+'h';
   PEFile.Read(b1,b2,b3,b4);
   Name_Pointer_RVA:=Byte2Hex(b4)+Byte2Hex(b3)+Byte2Hex(b2)+Byte2Hex(b1)+'h';
   PEFile.Read(b1,b2,b3,b4);
   Ordinal_Table_RVA:=Byte2Hex(b4)+Byte2Hex(b3)+Byte2Hex(b2)+Byte2Hex(b1)+'h';

   SetLength(FUNC_DATA,Address_Table_Entries+1);

   {Reading Export Address Table}
   PEFile.Seek(Hex2DWORD(Export_Address_Table_RVA)-ARVA+AdwAddress);
   For i:=1 To Address_Table_Entries Do
    Begin
      PEFile.Read(b1,b2,b3,b4);
      FUNC_DATA[i].Offset:=Byte2Hex(b4)+Byte2Hex(b3)+Byte2Hex(b2)+Byte2Hex(b1)+'h';
    End;

   {Reading Export Name Pointer Table}
   PEFile.Seek(Hex2DWORD(Name_Pointer_RVA)-ARVA+AdwAddress);
   For i:=1 To Address_Table_Entries Do
    Begin
      PEFile.Read(b1,b2,b3,b4);
      FUNC_DATA[i].NameAddress:=(b1+b2*256)+(b3+b4*256)*256*256;
    End;

   {Reading Export Ordinal Table}
   PEFile.Seek(Hex2DWORD(Ordinal_Table_RVA)-ARVA+AdwAddress);
   For i:=1 To Address_Table_Entries Do
    Begin
      PEFile.Read(b1,b2);
      FUNC_DATA[i].Ordinal:=(b1+b2*256);
    End;

   {Reading Export Name Table}
   For i:=1 To Address_Table_Entries Do
    Begin
      PEFile.Seek(FUNC_DATA[i].NameAddress-ARVA+AdwAddress);
      TmpStr:='';
      Repeat
        PEFile.Read(b1);
        TmpStr:=TmpStr+Chr(b1);
      Until b1=0;
      TmpStr:=Copy(TmpStr,1,Length(TmpStr)-1);
      FUNC_DATA[i].Name:=TmpStr;
    End;
end;

{ ThePEFile }

constructor ThePEFile.Create(AsFileName: String);
begin
   Inherited Create;

   sFileName:=AsFileName;
   Stream:=TPEStream.Create;
   If AsFileName<>'' Then
      Stream.LoadFromFile(AsFileName);
end;

destructor ThePEFile.Destroy;
begin
   If Stream<>nil Then
     Begin
       Stream.Free;
       Stream:=nil;
     End;

   Inherited Destroy;
end;

procedure ThePEFile.Read(var b1, b2, b3, b4: Byte);
begin
  b1:=Stream.ReadByte;
  b2:=Stream.ReadByte;
  b3:=Stream.ReadByte;
  b4:=Stream.ReadByte;
end;

procedure ThePEFile.Read(var b1, b2: Byte);
begin
  b1:=Stream.ReadByte;
  b2:=Stream.ReadByte;
end;

function ThePEFile.FilePos: Integer;
begin
  Result:=Stream.Position;
end;

procedure ThePEFile.Read(var b1: Byte);
begin
  b1:=Stream.ReadByte;
end;

procedure ThePEFile.Seek(Offset: DWord);
begin
   Stream.Seek(Offset,soFromBeginning);
end;

function ThePEFile.FileSize: Integer;
begin
  Result:=Stream.Size;
end;

procedure ThePEFile.Write(b: Byte);
begin
  Stream.WriteBuffer(b,1);
end;

////////////////////////////////////////////////////
//    This removes chars that has special meaning
// in IDA and SoftIce
////////////////////////////////////////////////////
Function DeDeStrToIDAStr(sDeDeStr : String) : String;
var i : Integer;
begin
  Result:='';
  For i:=1 to Length(sDeDeStr) Do
    case sDeDeStr[i] of
      #32: //Result:=Result+sDeDeStr[i] Explicitly remove intervals
      else Result:=Result+sDeDeStr[i];
    end;
end;

/////////////////////////////////////
// Returns SoftIce install directory
// if SoftIce is installed
/////////////////////////////////////
function GetSoftIceDir : String;
const SICE_KEY = 'SOFTWARE\NuMega\SoftICE';
      INSTALL_DIR  = 'InstallDir';
var reg : TRegistry;
begin
  Result:='';
  reg:=TRegistry.Create;
  Try
    reg.RootKey:=HKEY_LOCAL_MACHINE;
    if not reg.KeyExists(SICE_KEY) then Exit;
    reg.OpenKey(SICE_KEY,False);
    Result:=reg.ReadString(INSTALL_DIR);
  Finally
    reg.Free;
  End;
end;

/////////////////////////////////////
// Returns true if SoftIce is active
/////////////////////////////////////
function SoftIceIsActive : Boolean;
const SICE_FILES : Array [1..3] of String = ('SICE','SIWVID','NTICE');
var hFile : Cardinal;
    i : Integer;
begin
  Result:=False;
  For i:=1 To 3 Do
    Begin
      hFile:=CreateFile(PChar('\\.\'+SICE_FILES[i]), GENERIC_READ or GENERIC_WRITE,
                        FILE_SHARE_READ or FILE_SHARE_WRITE,
                        nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);

      if hFile<>INVALID_HANDLE_VALUE
        then begin
          Result:=True;
          CloseHandle(hFile);
          exit;
        end;
    End;   
end;


initialization
  GlobAbort:=False;
  ProcRefOffsets:=TStringList.Create;
  ProcRefNames:=TStringList.Create;
  PEFile:=nil;
  
finalization
  ProcRefOffsets.Clear;
  ProcRefNames.Clear;    
end.
