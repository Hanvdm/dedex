unit DeDeDUF;

interface

uses Classes, DeDeExpressions, DeDeEditText;

///////////////////////////////////
// DUF File Format
///////////////////////////////////
// DWORD - Magic (DUF!)
// Byte  - DUF Version
// DWORD - Var table offset
// DWORD - Var table record count
// DWORD - Comments table offset
// DWORD - Comments table record count
// DWORD - Emulation table offset
// DWORD - Emulation table record count
//
// var table contains entries like
// DWORD  - RVA
// PASSTR - VarName
// PASSTR - VarComment
//
// Comment table contins entries like
// DWORD  - RVA
// PASSTR - Comment
//
// Emulation table entries
// DWORD - RVA
// Byte  - Mode (0 - initial proc settings, 1 - inside proc settings)
// PASSTR - Emulation string
//
//////////////////////////////////////

Type DWORD = LongWord;

const CURR_DUFF_VERSION = 1;

Type TDUFFile = class
       protected
         FStream : TMemoryStream;
       public
         Expressions : array of TVar;
         ExpressionCount : Integer;
         Emulations : array of TEmulationRecord;
         EmulationCount : Integer;
         Comments : array of TComment;
         CommentsCount : integer;
         DUFVersion : Byte;
         constructor Create;
         destructor Destroy;
         procedure LoadFromFile(sFileName : String);
         procedure SaveToFile(sFileName : String);
     end;

implementation

{ TDUFFile }

uses VCLUnZip, VCLZip, SysUtils;

constructor TDUFFile.Create;
begin
  Inherited Create;

  FStream:=TMemoryStream.Create;
end;

destructor TDUFFile.Destroy;
begin
  FStream.Free;

  Inherited Destroy;
end;

procedure TDUFFile.LoadFromFile(sFileName: String);
var s : String;
    i : Integer;
    b : Byte;
    dw, VdwPos, VdwCnt, EdwPos, EdwCnt, CdwPos, CdwCnt : DWORD;
    UnZip : TVCLUnZip;
begin
  UnZip:=TVCLUnZip.Create(nil);
  Try
   UnZip.ZipName:=sFileName;
   FStream.Clear;
   UnZip.UnZipToStream(FStream,ExtractFileName(sFileName));
   FStream.Seek(0,soFromBeginning);
  Finally
   UnZip.Free;
  End;

  // Read Magic
  SetLength(s,4);
  FStream.ReadBuffer(s[1],4);
  If s<>'DUF!' Then Exit;
  // Read Version
  FStream.ReadBuffer(b,1);
  DUFVersion:=b;
  // Variable table
  FStream.ReadBuffer(VdwPos,4);
  FStream.ReadBuffer(VdwCnt,4);
  // Comments table
  FStream.ReadBuffer(CdwPos,4);
  FStream.ReadBuffer(CdwCnt,4);
  // Emulation table
  FStream.ReadBuffer(EdwPos,4);
  FStream.ReadBuffer(EdwCnt,4);

  //Read Variable Table
  FStream.Seek(VdwPos,soFromBeginning);
  SetLength(Expressions,VdwCnt);
  for i:=0 to VdwCnt-1 do
    begin
      FStream.ReadBuffer(dw,4);
      Expressions[i].RVA:=dw;
      FStream.ReadBuffer(b,1);
      SetLength(s,b);
      FStream.ReadBuffer(s[1],b);
      Expressions[i].Name:=s;
      FStream.ReadBuffer(b,1);
      SetLength(s,b);
      FStream.ReadBuffer(s[1],b);
      Expressions[i].Comment:=s;
    end;
  ExpressionCount:=VdwCnt;

  //Read Comments Table
  FStream.Seek(CdwPos,soFromBeginning);
  SetLength(Comments,CdwCnt);
  for i:=0 to CdwCnt-1 do
    begin
      FStream.ReadBuffer(dw,4);
      Comments[i].cmtRVA:=dw;
      FStream.ReadBuffer(b,1);
      SetLength(s,b);
      FStream.ReadBuffer(s[1],b);
      Comments[i].Comment:=s;
    end;
  CommentsCount:=CdwCnt;

  //Read Emulation Table
  FStream.Seek(EdwPos,soFromBeginning);
  SetLength(Emulations,EdwCnt);
  for i:=0 to EdwCnt-1 do
    begin
      FStream.ReadBuffer(dw,4);
      Emulations[i].RVA:=dw;
      FStream.ReadBuffer(b,1);
      Emulations[i].Mode:=b;
      FStream.ReadBuffer(b,1);
      SetLength(s,b);
      FStream.ReadBuffer(s[1],b);
      Emulations[i].EmulString:=s;
    end;
  EmulationCount:=EdwCnt;
end;

procedure TDUFFile.SaveToFile(sFileName: String);
var s : String;
    i : Integer;
    b : Byte;
    dw, VdwPos, VdwCnt, EdwPos, EdwCnt, CdwPos, CdwCnt : DWORD;
    Zip : TVCLZip;
begin
  FStream.Clear;

  // Write Magic
  s:='DUF!';
  FStream.WriteBuffer(s[1],4);
  // Write Version
  FStream.WriteBuffer(DUFVersion,1);

  //Will be filled later
  dw:=0;
  FStream.WriteBuffer(dw,4);
  FStream.WriteBuffer(dw,4);
  FStream.WriteBuffer(dw,4);
  FStream.WriteBuffer(dw,4);
  FStream.WriteBuffer(dw,4);
  FStream.WriteBuffer(dw,4);

  //Write Variable Table
  VdwPos:=FStream.Position;
  VdwCnt:=ExpressionCount;
  For i:=0 to ExpressionCount-1 Do
    begin
      dw:=Expressions[i].RVA;
      FStream.WriteBuffer(dw,4);
      s:=Expressions[i].Name;
      b:=Length(s);
      FStream.WriteBuffer(b,1);
      FStream.WriteBuffer(s[1],b);
      s:=Expressions[i].Comment;
      b:=Length(s);
      FStream.WriteBuffer(b,1);
      FStream.WriteBuffer(s[1],b);
    end;

  //Write Comments Table
  CdwPos:=FStream.Position;
  CdwCnt:=CommentsCount;
  For i:=0 to CommentsCount-1 Do
    begin
      dw:=Comments[i].cmtRVA;
      FStream.WriteBuffer(dw,4);
      s:=Comments[i].Comment;
      b:=Length(s);
      FStream.WriteBuffer(b,1);
      FStream.WriteBuffer(s[1],b);
    end;

  //Write Emulation Table
  EdwPos:=FStream.Position;
  EdwCnt:=EmulationCount;
  For i:=0 to EmulationCount-1 Do
    begin
      dw:=Emulations[i].RVA;
      FStream.WriteBuffer(dw,4);
      s:=Emulations[i].EmulString;
      b:=Length(s);
      FStream.WriteBuffer(s[1],b);
    end;

  FStream.Seek(5,soFromBeginning);
  FStream.WriteBuffer(VdwPos,4);
  FStream.WriteBuffer(VdwCnt,4);
  FStream.WriteBuffer(CdwPos,4);
  FStream.WriteBuffer(CdwCnt,4);
  FStream.WriteBuffer(EdwPos,4);
  FStream.WriteBuffer(EdwCnt,4);

  Zip:=TVCLZip.Create(nil);
  Try
   Zip.ZipName:=sFileName;
   Zip.ZipFromStream(FStream,sFileName);
  Finally
   Zip.Free;
  End;
end;

end.
