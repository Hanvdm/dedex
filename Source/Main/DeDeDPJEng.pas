unit DeDeDPJEng;

////////////////////////////////////////////////////////////////////////////////
// The .DPJ Engine functions for saving and loading .DPJ files
//
////////////////////////////////////////////////////////////////////////////////
// .DPJ Format
//
// DWORD      Ident  'DPJ!'
// QWORD      DPJ version  (4 chars - the current .DPJ version '1.01'
// QWORD      DeDe version (4 chars - minimal DeDe version needed to open
//                         (    the file - '2.50'
// STRPAS     Project name
// STRPAS     Full path to target executable
//
// CLASS_DATA_STREAM    - All classes data
// MEM_DUMP_STREAM      - BSS and DATA sections dumped from memory
// USER_SETTINGS_STREAM - User config (DSF and DOI files to load, etc.)
// USER_MACRO_STREAM    - User macros (COMMENT and EMUL)
//
//


interface

uses Classes;

Procedure LoadDPJFile(FsFileName : String);
Procedure SaveDPJFile(FsFileName : String);

implementation

{ TDPJFile }

Uses VCLUnZip, VCLZip, SysUtils, DeDeConstants, MainUnit, Windows, DeDeEditText,
     CRC32, DeDeSym, DeDeReg, DeDeClasses;

var
   Stream : TMemoryStream;

const
   DPJVersion = '1.00';

procedure SaveMagicStringValue(s : String);
var len : Integer;
begin
   len := Length(s);
   Stream.WriteBuffer(s[1], len);
end;


procedure SaveStringValue(s : String);
var len : Integer;
begin
   len := Length(s);
   Stream.WriteBuffer(len, 4);
   Stream.WriteBuffer(s[1], len);
end;

procedure SaveDWORDValue(i : LongWord);
begin
   Stream.WriteBuffer(i, 4);
end;

procedure SaveIntegerValue(i : Integer);
begin
   Stream.WriteBuffer(i, 4);
end;

procedure SaveByteValue(b : Byte);
begin
   Stream.WriteBuffer(b, 1);
end;


procedure SaveBooleanValue(b : Boolean);
var bt : Byte;
begin
   if b then bt:=1 else bt:=0;
   SaveByteValue(bt);
end;


procedure SaveStringListValues(sl : TStringList);
var i : Integer;
begin
  SaveDWORDValue(sl.Count);
  For i:=0 to sl.Count-1 do SaveStringValue(sl[i]);
end;

procedure SaveTStringsValues(sl : TStrings);
var i : Integer;
begin
  SaveDWORDValue(sl.Count);
  For i:=0 to sl.Count-1 do SaveStringValue(sl[i]);
end;

procedure SaveStringListValuesAndPointers(sl : TStringList);
var i : Integer;
begin
  SaveDWORDValue(sl.Count);
  For i:=0 to sl.Count-1 do
    begin
      SaveStringValue(sl[i]);
      SaveDWORDValue(LongWord(sl.Objects[i]));
    end;
end;


procedure CalcCRC32OfFile(sFileName : String);
var MemStr : TMemoryStream;
    bytesRead : cardinal;
    buff : Array of Byte;
begin
  MemStr:=TMemoryStream.Create;
  try
    MemStr.LoadFromFile(sFileName);
    MemStr.Seek(0,soFromBeginning);
    SetLength(buff,400);
    CRC32.crc32val:=0;
    bytesRead:=MemStr.Read(buff[1],400);
    if bytesRead>0 then CRC32.updatecrc(buff,bytesRead);

{    While MemStr.Position<MemStr.Size do
      begin
        bytesRead:=MemStr.Read(buff[1],100);
        if bytesRead>0 then CRC32.updatecrc(buff,bytesRead);
        if bytesRead<>100 then break;
      end
}  finally
    MemStr.Free;
  end;
end;

procedure ProcessStreamForLoadingDPJ;
const
   mDPJError = 'DeDe project loading error.';
var
   FileVer, s : string;
   i, j : integer;
   p : Pointer;
begin
   SetLength(s, 4);
   Stream.ReadBuffer(s[1], 4);
   if s <> 'DPJ!' then begin
//   Invalid DeDe project
      MessageBox(0, PChar('Invalid DeDe project'), mDPJError, MB_OK);
   end; { if }
   Stream.ReadBuffer(s[1], 4);
   if s > DPJVersion then begin
//   Not supported DPJ version
      MessageBox(0, PChar('Unsupported project version ('+s+')'), mDPJError, MB_OK);
   end; { if }
   FileVer := s;
   Stream.ReadBuffer(s[1],4);
   if s > GlobsCurrDeDeVersion then begin
//   Not supported DeDe version
      MessageBox(0, PChar('Unsupported DeDe version ('+s+')'), mDPJError, MB_OK);
   end; { if }
// Read Project Name
   Stream.ReadBuffer(i, SizeOf(i));
   SetLength(DeDeMainForm.FsProjectName, i);
   Stream.ReadBuffer(DeDeMainForm.FsProjectName[1], i);
// Read File Name
   Stream.ReadBuffer(i, SizeOf(i));
   SetLength(DeDeMainForm.FsFileName, i);
   Stream.ReadBuffer(DeDeMainForm.FsFileName[1], i);
// Read comments
   Stream.ReadBuffer(DeDeEditText.CommentsCount, SizeOf(DeDeEditText.CommentsCount));
   SetLength(DeDeEditText.Comments, DeDeEditText.CommentsCount);
   for i:=0 to DeDeEditText.CommentsCount - 1 do begin
      Stream.ReadBuffer(DeDeEditText.Comments[i], SizeOf(TComment));


   end; { for }
end;



procedure ProcessStreamForSavingDPJ;
var
   s : string;
   i, sz : integer;
   p : Pointer;
   buff : Array of Byte;
begin
   Stream.Clear;
   /////////////////////////////////////////////////////////////////////////////
   // Save DPJ and DeDe versions
   /////////////////////////////////////////////////////////////////////////////
   s:='DPJ!' + DPJVersion + GlobsCurrDeDeVersion;
   Stream.WriteBuffer(s[1], 12);

   /////////////////////////////////////////////////////////////////////////////
   // Save pre-dump data
   /////////////////////////////////////////////////////////////////////////////
   // Project name
      SaveStringValue(DeDeMainForm.FsProjectName);
   // Target file name and path
      SaveStringValue(DeDeMainForm.FsFileName);
   // Target file CRC32
      CalcCRC32OfFile(DeDeMainForm.FsFileName);
      SaveDWORDValue(CRC32.crc32val);
   // Symbols to load
      SaveMagicStringValue('SYM');
      SaveDWORDValue(DeDeMainForm.SymbolsList.Count);
      For i:=0 to DeDeMainForm.SymbolsList.Count-1 do
        Begin
          s:=ExtractFileName(TDeDeSymbol(DeDeMainForm.SymbolsList[i]).FileName);
          SaveStringValue(s);
        End;
   // DeDeReg values
      SaveMagicStringValue('DEDEREG');
      SaveBooleanValue(DeDeReg.bWARN_ON_FILE_OVERWRITE);
      SaveBooleanValue(DeDeReg.bNOT_ALLOW_EXISTING_DIR);
      SaveBooleanValue(DeDeReg.bDumpAll);
      SaveBooleanValue(DeDeReg.bObjPropRef);
      SaveIntegerValue(DeDeReg.iSTRING_REF_TYPE);
      SaveBooleanValue(DeDeReg.bSMARTMODE);
      SaveBooleanValue(DeDeReg.bUseDOI);
      SaveBooleanValue(DeDeReg.bDontShowUnkRefs);
      SaveBooleanValue(DeDeReg.bRegisterShellExt);
   // Dump specific values
      SaveBooleanValue(DeDeClasses.bBSS);
      SaveBooleanValue(DeDeClasses.bDebug);
      SaveBooleanValue(DeDeClasses.bUserProcs);
      SaveBooleanValue(DeDeClasses.GlobCBuilder);
      SaveBooleanValue(DeDeClasses.GlobDelphi2);
      SaveStringListValues(DeDeClasses.ProcRefOffsets);
      SaveStringListValues(DeDeClasses.ProcRefNames);
      SaveStringValue(DeDeClasses.DelphiVersion);
   // More delphi version constants
      SaveStringValue(DeDeMainForm.sDelphiVersion);
      SaveIntegerValue(MainUnit.DelphiVestionCompability);
   // DeDeMainForm string lists
      SaveStringListValuesAndPointers(DeDeMainForm.DFMFormList);
      SaveTStringsValues(DeDeMainForm.PIUL.Items);
      SaveStringListValues(DeDeMainForm.PASNameList);
      SaveIntegerValue(MainUnit.GlobClassesCount);
   /////////////////////////////////////////////////////////////////////////////
   // Save ClassesDumper object
   /////////////////////////////////////////////////////////////////////////////
      SaveMagicStringValue('CLASSESDUMPER');
      DeDeMainForm.ClassesDumper.GetBufferForDPJSave(buff,sz);
      SetLength(buff,sz);
      DeDeMainForm.ClassesDumper.GetBufferForDPJSave(buff,sz);
      SaveDWORDValue(sz);
      Stream.WriteBuffer(buff[0], sz);
   /////////////////////////////////////////////////////////////////////////////
   // Save DeDeMainForm additional stuff
   /////////////////////////////////////////////////////////////////////////////
      SaveStringListValues(DeDeMainForm.DFMFormList);
      SaveStringListValues(DeDeMainForm.UnitList);
      SaveStringListValues(DeDeMainForm.DFMNameList);
      SaveStringListValues(DeDeMainForm.PASNameList);
      SaveStringListValues(DeDeMainForm.CurrNames);
      SaveStringListValues(DeDeMainForm.CurrIDs);
      SaveStringListValues(DeDeMainForm.SymbolsPath);
      SaveBooleanValue(DeDeMainForm.FbMemFump);
      SaveBooleanValue(DeDeMainForm.FbProcessed);
      SaveBooleanValue(DeDeMainForm.FbFailed);
      SaveBooleanValue(DeDeMainForm.FbCutSelfPtr);
      SaveDWORDValue(ORD(DeDeMainForm.FFileType));
      SaveStringValue(DeDeMainForm.FsFileName);
      SaveStringValue(DeDeMainForm.FsProjectName);
      SaveStringValue(DeDeMainForm.DeDeProjectFileName);
      SaveStringValue(DeDeMainForm.FsLoadedDOIFile);

   // Write comments
   Stream.WriteBuffer(DeDeEditText.CommentsCount, SizeOf(DeDeEditText.CommentsCount));
   for i:=0 to DeDeEditText.CommentsCount - 1 do begin
      Stream.WriteBuffer(DeDeEditText.Comments[i], SizeOf(TComment));
   end;

   { Phew! :)) }
end;


procedure LoadDPJFile(FsFileName: String);
var UnZip : TVCLUnzip;
begin
  Stream := TMemoryStream.Create;
  UnZip := TVCLUnZip.Create(nil);
  Try
   UnZip.ZipName := FsFileName;
   UnZip.UnZipToStream(Stream,ExtractFileName(FsFileName));
   Stream.Seek(0, soFromBeginning);
  Finally
   UnZip.Free;
  End;
  ProcessStreamForLoadingDPJ;
  MessageBox(0, 'DeDe Project loaded !', '', MB_OK);
  Stream.Free;
end;


procedure SaveDPJFile(FsFileName: String);
var Zip : TVCLZip;
begin
   Stream := TMemoryStream.Create;
   DeleteFile(PChar(FsFileName));
   ProcessStreamForSavingDPJ;
   Zip := TVCLZip.Create(nil);
   Try
      Zip.ZipName := FsFileName;
      Stream.Seek(0, soFromBeginning);
      Zip.ZipFromStream(Stream, FsFileName);
      MessageBox(0, 'DeDe Project saved !', '', MB_OK);
   Finally
      Zip.Free;
   End;
   Stream.Free;
end;



end.
