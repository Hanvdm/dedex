unit DeDePAS;

interface

Uses Classes;

Type DWORD = LongWord;

//OLD ROUTINES
function GeneratePASCALFile(Stream : TMemoryStream; Offset,Size : DWORD; sPasFileName, sParentName,sParentUnit : String) : String;
procedure GeneratePas(S: TMemoryStream; PasFName,ParentName,ParentUnit: String);
//////////////////////////


procedure Convert(DFMName,ParentName : String); overload;
procedure Convert(S : TMemoryStream; ParentName : String); overload;

procedure GenerateDPR(AsProject,AsProjectFileName : String;
  UnitList, DFMList: TStringList; ProgramEntryPoint, RVA : DWORD);

// NEW ROUTINE
procedure StartNewPas(var str : TMemoryStream; sUnitName : String);


implementation

Uses MethProp, SysUtils, Dialogs, DeDeDisAsm, DisAsm, HexTools, DeDeRes, DeDeConstants;

const
  B1: array[boolean] of Char = ' {';
  B2: array[boolean] of PChar = ('','}');

var  PropList,MethodList,UsesList: TStringList;
     Reader: TReader;
     NestingLevel: integer;
     MainClassName, MainObjectName: String;
     MainFlags: TFilerFlags;
     PasF: System.Text;
     UnitName: String;


procedure GeneratePas(S: TMemoryStream; PasFName,ParentName,ParentUnit: String);
const
  B1: array[boolean] of Char = ' {';
  B2: array[boolean] of PChar = ('','}');
var
  NestingLevel: integer;
  Reader: TReader;
  PasF: System.Text;
  UnitName: String;
  PropList,MethodList,UsesList: TStringList;

  function WasUsed(S: String): boolean;
  begin
    Result := UsesList.IndexOf(S)>=0;
  end ;

  procedure AddUses(S: String);
  begin
    if WasUsed(S) then
      Exit;
    UsesList.Add(S);
  end ;

  function ConvertHeader: TComponentInfo;
  var
    pfxFlags: TFilerFlags;
    pfxPos: Integer;
    ClassName, ObjectName: String;
  begin
    Result := Nil;
    Reader.ReadPrefix(pfxFlags, pfxPos);
    ClassName := Reader.ReadStr;
    ObjectName := Reader.ReadStr;
    if ObjectName='' then
      Exit;
    if NestingLevel>0 then begin
      PropList.Add(Format(' %s%s: %s;%s',[B1[ffInherited in pfxFlags],
           ObjectName,ClassName,B2[ffInherited in pfxFlags]]));
     end
    else begin
      MainFlags := pfxFlags;
      MainClassName := ClassName;
      MainObjectName := ObjectName;
    end ;
    Result := GetComponentInfo(ClassName);
    if (Result<>Nil)and(Result.UnitName<>'') then
      AddUses(Result.UnitName);
  end ;

  procedure ConvertProperty(CI: TComponentInfo); forward;

  procedure ConvertBinary;
  const
    BytesPerLine = 32;
  var
    I: Integer;
    Count: Longint;
    Buffer: array[0..BytesPerLine - 1] of Char;
  begin
    Reader.ReadValue;
    Inc(NestingLevel);
    Reader.Read(Count, SizeOf(Count));
    while Count > 0 do
    begin
      if Count >= 32 then I := 32 else I := Count;
      Reader.Read(Buffer, I);
      Dec(Count, I);
    end;
    Dec(NestingLevel);
  end;

  function ConvertValue: String;
  var
    S: string;
  begin
    Result := '';
    case Reader.NextValue of
      vaList:
        begin
          Reader.ReadValue;
          Inc(NestingLevel);
          while not Reader.EndOfList do
            ConvertValue;
          Reader.ReadListEnd;
          Dec(NestingLevel);
        end;
      vaInt8, vaInt16, vaInt32:
        Reader.ReadInteger;
      vaExtended:
        Reader.ReadFloat;
      vaString, vaLString:
        Reader.ReadString;
      vaIdent:
        Result := Reader.ReadIdent;
      vaFalse, vaTrue, vaNil:
        Reader.ReadIdent;
      vaBinary:
        ConvertBinary;
      vaSet:
        begin
          Reader.ReadValue;
          while True do
          begin
            S := Reader.ReadStr;
            if S = '' then Break;
          end;
        end;
      vaCollection:
        begin
          Reader.ReadValue;
          Inc(NestingLevel);
          while not Reader.EndOfList do
          begin
            if Reader.NextValue in [vaInt8, vaInt16, vaInt32] then
            begin
              ConvertValue;
            end;
            //Reader.CheckValue(vaList);
            if Reader.ReadValue<>vaList then {Ignore};
            Inc(NestingLevel);
            while not Reader.EndOfList do ConvertProperty(Nil);
            Reader.ReadListEnd;
            Dec(NestingLevel);
          end;
          Reader.ReadListEnd;
          Dec(NestingLevel);
        end;
    end;
  end;

  procedure ConvertProperty(CI: TComponentInfo);
  var
    Name,V,M: String;
  begin
    Name := Reader.ReadStr;
    V := ConvertValue;
    if CI=Nil then
      Exit;
    if (Name='')or(V='') then
      Exit;
    M := CI.GetPropertyMethod(Name,V);
    if M<>'' then
      MethodList.Add(M);
  end;

  procedure ConvertObject;
  var
    CI: TComponentInfo;
  begin
    CI := ConvertHeader;
    Inc(NestingLevel);
    while not Reader.EndOfList do ConvertProperty(CI);
    Reader.ReadListEnd;
    while not Reader.EndOfList do ConvertObject;
    Reader.ReadListEnd;
    Dec(NestingLevel);
  end;

  procedure WriteUsesList;
  const
    Sep: array[boolean] of PChar = (', ',','#13#10'  ');
  var
    i: integer;
  begin
    for i:=0 to UsesList.Count-1 do
      Write(PasF,Sep[(i mod 6)=0],UsesList[i])
  end ;

  procedure WriteHdrList(S0: String; L: TStrings);
  var
    i: integer;
  begin
    for i:=0 to L.Count-1 do
      Writeln(PasF,S0,L[i]);
  end ;

  procedure WriteBodyMethods;
  var
    i: integer;
    S: String;
    CP: PChar;
    NameP: String;
    DasmList : TStringList;
  begin
    NameP := MainClassName+'.';
    for i:=0 to MethodList.Count-1 do begin
      S := MethodList[i];
      CP := StrScan(PChar(S),' ');
      if CP<>Nil then
        Insert(NameP,S,CP-PChar(S)+2);
      DisassembleProc(ExtractFileName(PasFName),S,DasmList);
      Writeln(PasF,S,#13#10'begin'#13#10'{');
      WriteLn(PasF,DasmList.Text);
      // Frees Disssembly Result String List      
      DasmList.Free;
      WriteLn(PasF,'}'#13#10' end ; '#13#10);
    end ;
  end ;
begin
  PasFName := ChangeFileExt(PasFName,'.pas');
  AssignFile(PasF,PasFName);
 {$I-}
  rewrite(PasF);
 {$I+}
  if IOResult<>0 then
    raise Exception.CreateFmt(err_cant_open_file,[PasFName]);
  try
    LoadComponentDescrs;
    try
      MethodList := TStringList.Create;
      PropList := TStringList.Create;
      UsesList := TStringList.Create;
      try
        MethodList.Sorted := true;
        MethodList.Duplicates := DupIgnore;
        {UsesList.Sorted := true;
        UsesList.Duplicates := DupIgnore;}
        AddUses('Controls');
        AddUses('Forms');
        AddUses('Dialogs');
        UnitName := ExtractFileName(PasFName);
        UnitName := ChangeFileExt(UnitName,'');
        Write(PasF,
        'unit ',UnitName,';'#13#10+
        #13#10+
        'interface'#13#10+
        #13#10+
        'uses'#13#10+
        '  Windows, Messages, SysUtils, Classes, Graphics');
        Reader := TReader.Create(S, 4096);
        try
          NestingLevel := 0;
          Reader.ReadSignature;
          ConvertObject;
          if (ffInherited in MainFlags)or(ParentUnit<>'') then
            AddUses(ParentUnit);
          WriteUsesList;
          Writeln(PasF,';'#13#10#13#10'type');
          if not(ffInherited in MainFlags)and(ParentName='') then
            ParentName := 'TForm';
          Writeln(PasF,'  ',MainClassName,'=class(',ParentName,')');
          WriteHdrList('  ',PropList);
          WriteHdrList('    ',MethodList);
          Writeln(PasF,
          '  private'#13#10+
          '    { Private declarations }'#13#10+
          '  public'#13#10+
          '    { Public declarations }'#13#10+
          '  end ;'#13#10);
          if MainObjectName<>'' then begin
            Writeln(PasF,'var'#13#10'  ',MainObjectName,': ',MainClassName,';'#13#10);
          end ;
        finally
          Reader.Free;
        end;
        Writeln(PasF,
        #13#10+'{'+txt_copyright+'}'#13#10#13#10+
        'implementation'#13#10+
        #13#10+
        '{$R *.DFM}'#13#10+
        #13#10);
        WriteBodyMethods;
        Writeln(PasF,'end.');
      finally
        UsesList.Free;
        MethodList.Free;
        PropList.Free;
      end ;
    finally
      FreeComponentDescrs;
    end ;
  finally
    Close(PasF);
  end ;
end ;

procedure GenerateDFM(S: TMemoryStream; FName,MainClassName: String);
type
  TDFMHdr = packed record
    bFF: byte;
    w10: word;
    ResName: array[byte]of Char;
  end ;

  TDFMHdr1 = packed record
    w1030: word;
    ImageSize: LongInt;
  end ;
//ends: assert[@.bFF=0xFF,@.w10=10,@.w1030=0x1030,@.ImageSize=FileSize-@:Size]

var
  ResF: File;
  Sz: LongInt;
  Hdr: TDFMHdr;
  Hdr1: TDFMHdr1;
begin
  Assign(ResF,FName);
 {$I-}
  Rewrite(ResF,1);
 {$I+}
  if IOResult<>0 then
    raise Exception.CreateFmt(err_cant_open_file,[FName]);
  try
    Hdr.bFF := $FF;
    Hdr.w10 := 10;
    StrPCopy(Hdr.ResName,PChar(UpperCase(MainClassName)));
    BlockWrite(ResF,Hdr,SizeOf(Hdr)-SizeOf(Hdr.ResName)+1+Length(MainClassName));
    Hdr1.w1030 := $1030;
    Sz := S.Size;
    Hdr1.ImageSize := Sz;
    BlockWrite(ResF,Hdr1,SizeOf(Hdr1));
    BlockWrite(ResF,S.Memory^,Sz);
    Writeln(Sz,' bytes of form data written.');
  finally
    Close(ResF);
  end ;
end ;

procedure Convert(DFMName,ParentName : String);
var
  Pos0: LongInt;
  S: TMemoryStream;
  STxt: TFileStream;
begin
  S := TMemoryStream.Create;
  try
    S.LoadFromFile(DFMName);
    S.ReadResHeader;
    Pos0 := S.Position;

    STxt := TFileStream.Create(ChangeFileExt(DFMName,'.txt'),fmCreate);
    try
      ObjectBinaryToText(S,STxt);
    finally
      STxt.Free;
    end ;

    S.Position := Pos0;
    GeneratePas(S,DFMName,ParentName,'');
  finally
    S.Free;
  end ;
end ;


function WasUsed(S: String): boolean;
begin
  Result := UsesList.IndexOf(S)>=0;
end ;

procedure AddUses(S: String);
begin
  if WasUsed(S) then
    Exit;
  UsesList.Add(S);
end ;

function ConvertHeader: TComponentInfo;
var
  pfxFlags: TFilerFlags;
  pfxPos: Integer;
  ClassName, ObjectName: String;
begin
  Result := Nil;
  Reader.ReadPrefix(pfxFlags, pfxPos);
  ClassName := Reader.ReadStr;
  ObjectName := Reader.ReadStr;
  if ObjectName='' then
    Exit;
  if NestingLevel>0 then begin
    PropList.Add(Format(' %s%s: %s;%s',[B1[ffInherited in pfxFlags],
         ObjectName,ClassName,B2[ffInherited in pfxFlags]]));
   end
  else begin
    MainFlags := pfxFlags;
    MainClassName := ClassName;
    MainObjectName := ObjectName;
  end ;
  Result := GetComponentInfo(ClassName);
  if (Result<>Nil)and(Result.UnitName<>'') then
    AddUses(Result.UnitName);
end ;

procedure ConvertProperty(CI: TComponentInfo); forward;

procedure ConvertBinary;
const
  BytesPerLine = 32;
var
  I: Integer;
  Count: Longint;
  Buffer: array[0..BytesPerLine - 1] of Char;
begin
  Reader.ReadValue;
  Inc(NestingLevel);
  Reader.Read(Count, SizeOf(Count));
  while Count > 0 do
  begin
    if Count >= 32 then I := 32 else I := Count;
    Reader.Read(Buffer, I);
    Dec(Count, I);
  end;
  Dec(NestingLevel);
end;

function ConvertValue: String;
var
  S: string;
begin
  Result := '';
  case Reader.NextValue of
    vaList:
      begin
        Reader.ReadValue;
        Inc(NestingLevel);
        while not Reader.EndOfList do
          ConvertValue;
        Reader.ReadListEnd;
        Dec(NestingLevel);
      end;
    vaInt8, vaInt16, vaInt32:
      Reader.ReadInteger;
    vaExtended:
      Reader.ReadFloat;
    vaString, vaLString:
      Reader.ReadString;
    vaIdent:
      Result := Reader.ReadIdent;
    vaFalse, vaTrue, vaNil:
      Reader.ReadIdent;
    vaBinary:
      ConvertBinary;
    vaSet:
      begin
        Reader.ReadValue;
        while True do
        begin
          S := Reader.ReadStr;
          if S = '' then Break;
        end;
      end;
    vaCollection:
      begin
        Reader.ReadValue;
        Inc(NestingLevel);
        while not Reader.EndOfList do
        begin
          if Reader.NextValue in [vaInt8, vaInt16, vaInt32] then
          begin
            ConvertValue;
          end;
          //Reader.CheckValue(vaList);
          if Reader.ReadValue<>vaList then {Ignore};
          Inc(NestingLevel);
          while not Reader.EndOfList do ConvertProperty(Nil);
          Reader.ReadListEnd;
          Dec(NestingLevel);
        end;
        Reader.ReadListEnd;
        Dec(NestingLevel);
      end;
  end;
end;

procedure ConvertProperty(CI: TComponentInfo);
var
  Name,V,M: String;
begin
  Name := Reader.ReadStr;
  V := ConvertValue;
  if CI=Nil then
    Exit;
  if (Name='')or(V='') then
    Exit;
  M := CI.GetPropertyMethod(Name,V);
  if M<>'' then
    MethodList.Add(M);
end;

procedure ConvertObject;
var
  CI: TComponentInfo;
begin
  CI := ConvertHeader;
  Inc(NestingLevel);
  while not Reader.EndOfList do ConvertProperty(CI);
  Reader.ReadListEnd;
  while not Reader.EndOfList do ConvertObject;
  Reader.ReadListEnd;
  Dec(NestingLevel);
end;

procedure WriteUsesList;
const
  Sep: array[boolean] of PChar = (', ',','#13#10'  ');
var
  i: integer;
begin
  for i:=0 to UsesList.Count-1 do
    Write(PasF,Sep[(i mod 6)=0],UsesList[i])
end ;

procedure WriteHdrList(S0: String; L: TStrings);
var
  i: integer;
begin
  for i:=0 to L.Count-1 do
    Writeln(PasF,S0,L[i]);
end ;

procedure WriteBodyMethods;
var
  i: integer;
  S: String;
  CP: PChar;
  NameP: String;
begin
  NameP := MainClassName+'.';
  for i:=0 to MethodList.Count-1 do begin
    S := MethodList[i];
    CP := StrScan(PChar(S),' ');
    if CP<>Nil then
      Insert(NameP,S,CP-PChar(S)+2);
    Writeln(PasF,S,#13#10'begin'#13#10'  {Auto}'#13#10'end ;'#13#10);
  end ;
end ; 

function GeneratePASCALFile(Stream : TMemoryStream; Offset,Size : DWORD; sPasFileName, sParentName,sParentUnit : String) : String;
var S: TMemoryStream;
begin
  S:=TMemoryStream.Create;
  PropList.Clear;
  MethodList.Clear;
  UsesList.Clear;
  Try
    S.LoadFromStream(Stream);

    sPasFileName := ChangeFileExt(sPasFileName,'.pas');
    AssignFile(PasF,sPasFileName);
   {$I-}
    rewrite(PasF);
   {$I+}
    if IOResult<>0 then
      raise Exception.CreateFmt(err_cant_open_file,[sPasFileName]);
    try
      LoadComponentDescrs;
      try
        MethodList := TStringList.Create;
        PropList := TStringList.Create;
        UsesList := TStringList.Create;
        try
          MethodList.Sorted := true;
          MethodList.Duplicates := DupIgnore;
          {UsesList.Sorted := true;
          UsesList.Duplicates := DupIgnore;}
          AddUses('Controls');
          AddUses('Forms');
          AddUses('Dialogs');
          UnitName := ExtractFileName(sPasFileName);
          UnitName := ChangeFileExt(UnitName,'');
          Write(PasF,
          'unit ',UnitName,';'#13#10+
          #13#10+
          'interface'#13#10+
          #13#10+
          'uses'#13#10+
          '  Windows, Messages, SysUtils, Classes, Graphics');
          S.Seek(0,soFromBeginning);
          Reader := TReader.Create(S, 4096);
          try
            NestingLevel := 0;
            Reader.ReadSignature;
            ConvertObject;
            if (ffInherited in MainFlags)or(sParentUnit<>'') then
              AddUses(sParentUnit);
            WriteUsesList;
            Writeln(PasF,';'#13#10#13#10'type');
            if not(ffInherited in MainFlags)and(sParentName='') then
              sParentName := 'TForm';
            Writeln(PasF,'  ',MainClassName,'=class(',sParentName,')');
            WriteHdrList('  ',PropList);
            WriteHdrList('    ',MethodList);
            Writeln(PasF,
            '  private'#13#10+
            '    { Private declarations }'#13#10+
            '  public'#13#10+
            '    { Public declarations }'#13#10+
            '  end ;'#13#10);
            if MainObjectName<>'' then begin
              Writeln(PasF,'var'#13#10'  ',MainObjectName,': ',MainClassName,';'#13#10);
            end ;
          finally
            Reader.Free;
          end;
          Writeln(PasF,
          'implementation'#13#10+
          #13#10+
          '{$R *.DFM}'#13#10+
          #13#10);
          WriteBodyMethods;
          Writeln(PasF,'end.');
          ShowMessage(Format('PAS with %s was generated (%d components, %d events).',
            [MainClassName,PropList.Count,MethodList.Count]));
        finally
        end ;
      finally
        FreeComponentDescrs;
      end ;
    finally
      Close(PasF);
    end ;
  Finally
    S.Free;
  End;
end;

procedure Convert(S : TMemoryStream; ParentName : String); overload;
var
  Pos0: LongInt;
  STxt: TFileStream;
begin
    S.ReadResHeader;
    Pos0 := S.Position;

    STxt := TFileStream.Create(FsTEMPDir+'dfm.$$$',fmCreate);
    try
      ObjectBinaryToText(S,STxt);
    finally
      STxt.Free;
    end ;

    S.Position := Pos0;
    //GeneratePas(S,'dfm',ParentName,'');
end ;

procedure GenerateDPR(AsProject,AsProjectFileName : String;
  UnitList, DFMList: TStringList; ProgramEntryPoint, RVA : DWORD);
var s : String;
    i : Integer;
    DPRList, TmpList : TStringList;
begin
  DPRList:=TStringList.Create;
  Try
    DPRList.Add('{'+txt_copyright+'}');
    DPRList.Add('');
    DPRList.Add('Project '+AsProject+';');
    DPRList.Add('');
    DPRList.Add('Uses');
    //DPRList.Add('  Forms,');  {stuppied ~~!!}
    For i:=0 To UnitList.Count-2 Do
      Begin
        s:=Format('  %s in ''%s.pas'' {%s},',[UnitList[i],UnitList[i],DFMList[i]]);
        DPRList.Add(s);
      End;
    i:=UnitList.Count-1;
    if i>=0 then s:=Format('  %s in ''%s.pas'' {%s};',[UnitList[i],UnitList[i],DFMList[i]]);

    DPRList.Add(s);
    DPRList.Add('');
    DPRList.Add('{$R *.RES}');
    DPRList.Add('');
    DPRList.Add('begin');
    DPRList.Add('{');

     // New Version Of DPR Save
     PEStream.Seek(ProgramEntryPoint,soFromBeginning);

     Try
      DisassembleProc('','',TmpList,False,True);
      For i:=0 To TmpList.Count-1 Do DPRList.Add(TmpList[i]);
     Finally
      // Frees Disaasembly Result String List
      TmpList.Free;
     End;

    DPRList.Add('}');
    DPRList.Add('end.');
    DPRList.SaveToFile(AsProjectFileName);
  Finally
    DPRList.Free;
  End;
end;

procedure StartNewPas(var str : TMemoryStream; sUnitName : String);
const q1 = 'unit ';
const q2 = #13#10#13#10'interface'#13#10#13#10'uses'#13#10+
           '  Windows, Messages, SysUtils, Classes, Graphics,'#13#10+
           '  Controls, Forms, Dialogs, StdCtrls'#13#10;
begin
  sUnitName:=sUnitName+';';
  Str:=TMemoryStream.Create;
  Str.WriteBuffer(q1[1],Length(q1));
  Str.WriteBuffer(sUnitName[1],Length(sUnitName));
  Str.WriteBuffer(q2[1],Length(q2));
end;

initialization


finalization


end.
