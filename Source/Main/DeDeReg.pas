unit DeDeReg;
// DeDe Registry Related Routines
//////////////////////////
// Last Change: 03.X.2001
//////////////////////////


interface

Uses Classes;


const

  // The DeDe key in HKLM
  APP_KEY = 'Software\DaFixer\DeDe';

Var

  // This variables are directy used from other units in project
  // to retreive the neseccary registry information

  bWARN_ON_FILE_OVERWRITE : Boolean;
  bNOT_ALLOW_EXISTING_DIR : Boolean;
  bDumpAll : Boolean;
  bObjPropRef : Boolean;
  STRING_REF_CHARSET : Set of Byte;
  iSTRING_REF_TYPE : Integer;
  //bAllDSF : Boolean;
  bSMARTMODE : Boolean;
  bUseDOI : Boolean;
  bDontShowUnkRefs : Boolean;
  bRegisterShellExt : Boolean;
  sLanguageFile : String;
  bImportReferences : Boolean;
  MAX_DSF_REFERENCES_COUNT : Integer;
  bModalAsmShow : Boolean;
  bUnitReferences : Boolean;

  sVersionHash : String;

  Procedure LoadRegistryData(var Sym : TStringList; bINIFILE : Boolean = False);
  Procedure SaveRegistryData(Sym : TStrings; bINIFILE : Boolean = False);
  Procedure SetDefaultsRegs;

  Procedure RegisterShellExt;
  Procedure UnregisterShellExt;

var GlobDeDeINIFileName : String;
    GlobalDeDeFileName : String;

implementation

Uses Registry, IniFiles, SysUtils;

type DWORD = LongWord;

const
  {$EXTERNALSYM HKEY_LOCAL_MACHINE}
  HKEY_LOCAL_MACHINE    = DWORD($80000002);
  {$EXTERNALSYM HKEY_CLASSES_ROOT}
  HKEY_CLASSES_ROOT     = DWORD($80000000);


Function ShellExtRegistered : Boolean;
var reg : TRegistry;
begin
  reg:=TRegistry.Create;
  Try
    reg.RootKey:=HKEY_CLASSES_ROOT;
    Result:=reg.KeyExists('exefile\shell\Open with DeDe\Command');
  Finally
    reg.Free;
  End;
end;

Procedure RegisterShellExt;
var reg : TRegistry;
begin
  reg:=TRegistry.Create;
  Try
    reg.RootKey:=HKEY_CLASSES_ROOT;
    reg.OpenKey('exefile\shell\Open with DeDe\Command',True);
    reg.WriteString('',GlobalDeDeFileName+'" "%1"');
  Finally
    reg.Free;
  End;
end;

Procedure UnregisterShellExt;
var reg : TRegistry;
begin
  reg:=TRegistry.Create;
  Try
    reg.RootKey:=HKEY_CLASSES_ROOT;
    reg.DeleteKey('exefile\shell\Open with DeDe');
  Finally
    reg.Free;
  End;
end;

Procedure HandleShellExt;
begin
  if ShellExtRegistered
    then if bRegisterShellExt then
                              else UnregisterShellExt
    else if bRegisterShellExt then RegisterShellExt
                              else  ;
end;


Procedure SetStringCharSet;
Begin
  Case iSTRING_REF_TYPE Of
    1:   STRING_REF_CHARSET:=[10,13,32..128];
    2:   STRING_REF_CHARSET:=[10,13,32..192];
    Else STRING_REF_CHARSET:=[10,13,32..255];
  End;
End;

Procedure SetDefaultsRegs;
Begin
  bWARN_ON_FILE_OVERWRITE:=True;
  bNOT_ALLOW_EXISTING_DIR:=True;
  iSTRING_REF_TYPE:=0;
//  bAllDSF:=False;
  SetStringCharSet;
  bObjPropRef:=True;
  bDumpAll:=False;
  bSmartMode:=True;
  bUseDOI:=True;
  bDontShowUnkRefs:=True;
  bUnitReferences:=True;
  bImportReferences:=True;
  sLanguageFile:='english.ini';
End;


Procedure SaveIniData(Sym : TStrings);
var IniFile : TIniFile;
//    bExists : Boolean;
    i : Integer;
begin
//  bExists:=False;
//  if FileExists(GlobDeDeINIFileName) then bExists:=True;
  IniFile:=TIniFile.Create(GlobDeDeINIFileName);
  Try
    IniFile.WriteInteger('Common','WarnOnFileOverwrite',ORD(bWARN_ON_FILE_OVERWRITE));
    IniFile.WriteInteger('Common','NotAllowExistingDir',ORD(bNOT_ALLOW_EXISTING_DIR));
    SetStringCharSet;
    IniFile.WriteInteger('Common','StringRefType',iSTRING_REF_TYPE);
//    IniFile.WriteInteger('Common','ShowAllDSFRefs',ORD(bAllDSF));
    IniFile.WriteInteger('Common','ObjPropRef',ORD(bObjPropRef));
    IniFile.WriteInteger('Common','DumpAll',ORD(bDumpAll));
    IniFile.WriteInteger('Common','SmartMode',ORD(bSmartMode));
    IniFile.WriteInteger('Common','UseDOI',ORD(bUseDOI));
    IniFile.WriteInteger('Common','DontShowUnk',ORD(bDontShowUnkRefs));
    IniFile.WriteString('Common','LanguageFile',sLanguageFile);
    IniFile.WriteInteger('Common','ResolveImports',ORD(bImportReferences));
    IniFile.WriteInteger('Common','MaxDSFRefCnt',MAX_DSF_REFERENCES_COUNT);

    IniFile.WriteString('Common','Version',sVersionHash);
    IniFile.WriteInteger('Common','UnitProcReferences',ORD(bUnitReferences));
    HandleShellExt;

    IniFile.EraseSection('Symbols');
    If Sym<>nil Then
       For i:=0 To Sym.Count-1 Do IniFile.WriteString('Symbols',Sym[i],IntToStr(i));

  Finally
    IniFile.Free;
  End;
end;

Procedure LoadIniData(var Sym : TStringList);
var IniFile : TIniFile;
    bExists : Boolean;
begin
  bExists:=False;
  if FileExists(GlobDeDeINIFileName) then bExists:=True;
  IniFile:=TIniFile.Create(GlobDeDeINIFileName);
  Try
    if Not bExists then begin
         SetDefaultsRegs;
         Exit;
    end;

    bWARN_ON_FILE_OVERWRITE:=Not (IniFile.ReadInteger('Common','WarnOnFileOverwrite',1)=0);
    bNOT_ALLOW_EXISTING_DIR:=Not (IniFile.ReadInteger('Common','NotAllowExistingDir',1)=0);
    iSTRING_REF_TYPE:=IniFile.ReadInteger('Common','StringRefType',0);
    If Not IniFile.ValueExists('Common','ShowAllDSFRefs')
       Then IniFile.WriteInteger('Common','ShowAllDSFRefs',0);
//    bAllDSF:=Not (IniFile.ReadInteger('Common','ShowAllDSFRefs',1)=0);

    // New Values
    If Not IniFile.ValueExists('Common','ObjPropRef')
       Then IniFile.WriteInteger('Common','ObjPropRef',0);
    If Not IniFile.ValueExists('Common','DumpAll')
       Then IniFile.WriteInteger('Common','DumpAll',1);

    bObjPropRef:=Not (IniFile.ReadInteger('Common','ObjPropRef',1)=0);
    bDumpAll:=Not (IniFile.ReadInteger('Common','DumpAll',1)=0);
    If Not IniFile.ValueExists('Common','SmartMode')
       Then IniFile.WriteInteger('Common','SmartMode',0);
    bSmartMode:=Not (IniFile.ReadInteger('Common','SmartMode',1)=0);
    bUseDOI:=Not (IniFile.ReadInteger('Common','UseDOI',1)=0);
    bDontShowUnkRefs:= Not (IniFile.ReadInteger('Common','DontShowUnk',1)=0);
    bImportReferences:=not (IniFile.ReadInteger('Common','ResolveImports',1)=0);
    MAX_DSF_REFERENCES_COUNT:=IniFile.ReadInteger('Common','MaxDSFRefCnt',6);
    if MAX_DSF_REFERENCES_COUNT<1 then MAX_DSF_REFERENCES_COUNT:=1;

    bModalAsmShow:=IniFile.ValueExists('Common','ModalASMShowForm');

    sVersionHash:=IniFile.ReadString('Common','Version','');
    bUnitReferences:=Not (IniFile.ReadInteger('Common','UnitProcReferences',1)=0);

    bRegisterShellExt := ShellExtRegistered;
    SetStringCharSet;

    sLanguageFile:=IniFile.ReadString('Common','LanguageFile','English.ini');
    if Sym<>nil then IniFile.ReadSection('Symbols',Sym);
  Finally
    IniFile.Free;
  End;

  if Not bExists then SaveIniData(nil);
end;

Procedure LoadRegistryData(var Sym : TStringList; bINIFILE : Boolean = False);
var Reg : TRegistry;
Begin
  if bINIFILE Then
    Begin
      LoadIniData(Sym);
      Exit;
    End;

  Reg:=TRegistry.Create;
  Try
    Reg.RootKey:=HKEY_LOCAL_MACHINE;
    If Not Reg.OpenKey(APP_KEY,False)
      Then Begin
         Reg.OpenKey(APP_KEY,True);
         SetDefaultsRegs;
         SaveRegistryData(nil, True);
         Exit;
      End;
    bWARN_ON_FILE_OVERWRITE:=Not (Reg.ReadInteger('WarnOnFileOverwrite')=0);
    bNOT_ALLOW_EXISTING_DIR:=Not (Reg.ReadInteger('NotAllowExistingDir')=0);
    iSTRING_REF_TYPE:=Reg.ReadInteger('StringRefType');
    If Not Reg.ValueExists('ShowAllDSFRefs')
       Then Reg.WriteInteger('ShowAllDSFRefs',0);
//    bAllDSF:=Not (Reg.ReadInteger('ShowAllDSFRefs')=0);

    // New Values
    If Not Reg.ValueExists('ObjPropRef')
       Then Reg.WriteInteger('ObjPropRef',0);
    If Not Reg.ValueExists('DumpAll')
       Then Reg.WriteInteger('DumpAll',0);
    bObjPropRef:=Not (Reg.ReadInteger('ObjPropRef')=0);
    bDumpAll:=Not (Reg.ReadInteger('DumpAll')=0);
    If Not Reg.ValueExists('SmartMode')
       Then Reg.WriteInteger('SmartMode',0);
    bSmartMode:=Not (Reg.ReadInteger('SmartMode')=0);
    If Not Reg.ValueExists('UseDOI')
       Then Reg.WriteInteger('UseDOI',0);
    bUseDOI:=Not (Reg.ReadInteger('UseDOI')=0);
    bDontShowUnkRefs:= Not (Reg.ReadInteger('DontShowUnk')=0);
    bRegisterShellExt := ShellExtRegistered;
    SetStringCharSet;

    Reg.OpenKey('Symbols',True);
    Reg.GetValueNames(Sym);
  Finally
    Reg.Free;
  End;
End;

Procedure SaveRegistryData(Sym : TStrings; bINIFILE : Boolean = False);
var Reg : TRegistry;
    dta : TStringList;
    i   : Integer;
Begin
  if bINIFILE Then
    Begin
      SaveIniData(Sym);
      Exit;
    End;

  Reg:=TRegistry.Create;
  Try
    Reg.RootKey:=HKEY_LOCAL_MACHINE;
    Reg.OpenKey(APP_KEY,True);
    Reg.WriteInteger('WarnOnFileOverwrite',ORD(bWARN_ON_FILE_OVERWRITE));
    Reg.WriteInteger('NotAllowExistingDir',ORD(bNOT_ALLOW_EXISTING_DIR));
    SetStringCharSet;
    Reg.WriteInteger('StringRefType',iSTRING_REF_TYPE);
//    Reg.WriteInteger('ShowAllDSFRefs',ORD(bAllDSF));
    Reg.WriteInteger('ObjPropRef',ORD(bObjPropRef));
    Reg.WriteInteger('DumpAll',ORD(bDumpAll));
    Reg.WriteInteger('SmartMode',ORD(bSmartMode));
    Reg.WriteInteger('UseDOI',ORD(bUseDOI));
    Reg.WriteInteger('DontShowUnk',ORD(bDontShowUnkRefs));
    HandleShellExt;

    Reg.OpenKey('Symbols',True);
    dta:=TStringList.Create;
    Try
     Reg.GetValueNames(dta);
     For i:=0 To dta.Count-1 Do Reg.DeleteValue(dta[i]);
     If Sym<>nil Then
       For i:=0 To Sym.Count-1 Do Reg.WriteString(Sym[i],IntToStr(i));
    Finally
      dta.Free;
    End;
  Finally
    Reg.Free;
  End;
End;

end.
