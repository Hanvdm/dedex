unit DeDeOffsInf;

interface

(*
 DOI!    - Magic
 BYTE    - Flag (bit-mask 0 = Delphi3, 1=Delphi4, 2=Delphi5, 3,4,5,6,7 - Reserved)
 BYTE    - DOI version
 WORD    - Classes Count
 CLASS DATA

   Class Data format:

   ClassName  - Pascal String
   WORD       - Properties Count
   WORD       - Hierarchy inheritance classes num
   Class1Name - Pascal String
   Class2Name - Pascal String
   ....
   ClassNName - Pascal Stirng
   ROW DATA

      Row Data format:

      Name  - Pascal String
      BYTE  - Type (0=property, 1=method, 2=event, 3=dynamic index)
      DWORD - Offset

*)


(*
   INI File Data Format

   [ClassName]
   Inherits=word (number of classes the current class inherits from)
   class_1=ClassName_1
   class_2=ClassName_2
   .....
   class_n=ClassName_n

   PropertyName=Offset

   Property Names prefix:

     m_ -> Method
     p_ -> Property
     e_ -> Event
     d_ -> Dynamic Method (in this case offset is the Dynamic Method index)

   Property class types:

   if in property name there is ':' then all after that is the class name
   for example:

   p_Items:TStringList
*)

uses Classes, iniFiles;

Type DWORD = LongWord;

Type TOffsInfStruct = class (TPersistent)
      protected
      public
        FsClassName : String;
        FHierarchyList : TStringList;
        FNameList : TStringList;
        FOffsetList : TList;
        constructor Create;
        destructor Destroy; override;
        Procedure AddClassData(Source : TOffsInfStruct);
        Procedure CollectGrabbage;
        Procedure Assign(Source : TOffsInfStruct);
     end;


Type TRefOffsInfType = (rtMOV, rtCALL, rtDynCall);

Type TOffsInfArchive = class
      protected
        FStream : TMemoryStream;
        procedure FreeOffsInfData;
      public
        mode, reserved : Byte;
        classes_count : word;
        OffsInfList : TList;
        NamesList : TStringList;
        Constructor Create;
        Destructor Destroy; override;
        Procedure ClearAllData;
        Procedure Extract(AsFileName : String; bLoadParentsData : Boolean = True);
        Procedure Save(AsFileName : String);
        Procedure AddOffsInfo(AOfssInfStruct : TOffsInfStruct);
        Procedure RemoveOffsInfo(sClassName :  String);
        Function GetOffsInfoByClassName(s : String) : TOffsInfStruct;
        Function GetReference(sClassName : String; dwOffset : DWORD; RefType : TRefOffsInfType; var sReference, sNewClass : String) : Boolean;
        Function GetReferenceEx(sClassName : String; dwOffset : DWORD; RefType : TRefOffsInfType; var sReference, sNewClass : String) : Boolean;
        Function DeleteRecord(sClassName, sName : String) : boolean;
        class Procedure LoadOffsInfsFromIniFile(AsFileName : String; List : TList);
     end;

Function GetType(dw : DWORD) : Byte;

implementation

uses VCLUnZip, VCLZip, SysUtils, Dialogs, HEXTools, DeDeConstants;

Function GetType(dw : DWORD) : Byte;
begin
  Result:=dw shr 24;
end;


{ TOffsInfStruct }

procedure TOffsInfStruct.AddClassData(Source: TOffsInfStruct);
var i : Integer;
begin
  if Source=nil then Exit;
  for i:=0 to Source.FNameList.Count-1 Do
    begin
      if FNameList.IndexOf(Source.FNameList[i])=-1
        then begin
          FNameList.Add(Source.FNameList[i]);
          FOffsetList.Add(Source.FOffsetList[i]);
        end;
    end;
end;

procedure TOffsInfStruct.Assign(Source: TOffsInfStruct);
var i : Integer;
begin
  FsClassName:=Source.FsClassName;
  FHierarchyList.Assign(Source.FHierarchyList);
  FNameList.Assign(Source.FNameList);
  For i:=0 To Source.FOffsetList.Count-1
    Do FOffsetList.Add(Source.FOffsetList[i]);

end;

procedure TOffsInfStruct.CollectGrabbage;
var i : Integer;
begin
   For i:=FNameList.Count-1 downto 0 Do
     begin
       
     end;
end;

constructor TOffsInfStruct.Create;
begin
  inherited Create;

  FNameList:=TStringList.Create;
  FHierarchyList:=TStringList.Create;
  FOffsetList:=TList.Create;
end;

destructor TOffsInfStruct.Destroy;
begin
  FNameList.Free;
  FOffsetList.Free;
  FHierarchyList.Free;

  inherited Destroy;
end;

{ TOffsInfArchive }

procedure TOffsInfArchive.AddOffsInfo(AOfssInfStruct: TOffsInfStruct);
var idx, j : Integer;
    OffsInf : TOffsInfStruct;
begin
  idx:=NamesList.IndexOf(AOfssInfStruct.FsClassName);
  If idx=-1 then
    begin
     OffsInfList.Add(AOfssInfStruct);
     NamesList.Add(AOfssInfStruct.FsClassName);
     Inc(classes_count);
    end
    else begin
      OffsInf:=TOffsInfStruct(OffsInfList[idx]);
      For j:=0 to AOfssInfStruct.FNameList.Count-1 Do
        //Add if the name do not exists then add it
        if OffsInf.FNameList.IndexOf(AOfssInfStruct.FNameList[j])=-1
          then begin
            OffsInf.FNameList.Add(AOfssInfStruct.FNameList[j]);
            OffsInf.FOffsetList.Add(AOfssInfStruct.FOffsetList[j]);
          end;
    end;
end;

procedure TOffsInfArchive.ClearAllData;
begin
  FStream.Free;
  FreeOffsInfData;
  OffsInfList.Free;
  NamesList.Free;
end;

constructor TOffsInfArchive.Create;
begin
  inherited Create;

  FStream:=TMemoryStream.Create;
  OffsInfList:=TList.Create;
  NamesList:=TStringList.Create;
end;

function TOffsInfArchive.DeleteRecord(sClassName, sName: String): boolean;
var i : Integer;
    OffsInf : TOffsInfStruct;
begin
   Result:=False;
   OffsInf:=GetOffsInfoByClassName(sClassName);
   If OffsInf=nil then exit;
   i:=OffsInf.FNameList.IndexOf(sName);
   If i=-1 then exit;
   OffsInf.FNameList.Delete(i);
   OffsInf.FOffsetList.Delete(i);
   Result:=True;
end;

destructor TOffsInfArchive.Destroy;
begin
  ClearAllData;

  inherited Destroy;
end;

procedure TOffsInfArchive.Extract(AsFileName: String; bLoadParentsData : Boolean = True);
var s : String;
    TmpStream : TMemoryStream;
    i,j : Integer;
    b : Byte;
    sz,w : Word;
    dw : DWORD;
    OffsInf : TOffsInfStruct;
    UnZip : TVCLUnZip;
begin
  UnZip:=TVCLUnZip.Create(nil);
  Try
   UnZip.ZipName:=AsFileName;
   FStream.Clear;
   UnZip.UnZipToStream(FStream,ExtractFileName(AsFileName));
   FStream.Seek(0,soFromBeginning);
  Finally
   UnZip.Free;
  End;

//  ClearAllData;

  TmpStream:=TMemoryStream.Create;
  Try
    // Read Magic
    SetLength(s,4);
    FStream.ReadBuffer(s[1],4);
    If s<>'DOI!' Then Exit;
    // Read Flags
    FStream.ReadBuffer(mode,1);
    // Read Version
    FStream.ReadBuffer(reserved,1);
    // Read Classes Count
    FStream.ReadBuffer(classes_count,2);

    OffsInfList.Clear;
    NamesList.Clear;

    For i:=0 to classes_count-1 Do
      begin
        // ClassName - Pascal String
        FStream.ReadBuffer(b,1);

        OffsInf:=TOffsInfStruct.Create;

        SetLength(OffsInf.FsClassName,b);
        FStream.ReadBuffer(OffsInf.FsClassName[1],b);

        If NamesList.IndexOf(OffsInf.FsClassName)<>-1 then
           begin
             MessageDlg(Format('Class named %s already exist and will not be added!',[OffsInf.FsClassName]),mtError,[mbOk],0);
             OffsInf.Free;
             Continue;
           end;

        NamesList.Add(OffsInf.FsClassName);

        // WORD - Properties Count
        FStream.ReadBuffer(sz,2);

        // Hierarchy names count
        FStream.ReadBuffer(w,2);

        // Read Hierarchy
        For j:=1 to w Do
          begin
            FStream.ReadBuffer(b,1);
            SetLength(s,b);
            FStream.ReadBuffer(s[1],b);
            OffsInf.FHierarchyList.Add(s);
          end;


        // Read Properties
        For j:=1 to sz Do
          begin
            FStream.ReadBuffer(b,1);
            SetLength(s,b);
            FStream.ReadBuffer(s[1],b);
            OffsInf.FNameList.Add(s);
            FStream.ReadBuffer(b,1);
            FStream.ReadBuffer(dw,4);
            OffsInf.FOffsetList.Add(TObject((b shl 24) or dw));
          end;

        OffsInfList.Add(OffsInf);
      end; {i:=0 to classes_count-1}

    if bLoadParentsData then
      For i:=0 to classes_count-1 Do
        begin
          OffsInf:=TOffsInfStruct(OffsInfList[i]);
          // Adding data from parents
          For j:=0 to OffsInf.FHierarchyList.Count-1 Do
            OffsInf.AddClassData(GetOffsInfoByClassName(OffsInf.FHierarchyList[j]));
        end;
  
  Finally
    TmpStream.Free;
  End;
end;

procedure TOffsInfArchive.FreeOffsInfData;
var i : Integer;
begin
  For i:=OffsInfList.Count-1 downto 0 Do
   TOffsInfStruct(OffsInfList[i]).Free;
end;


(*
   INI File Data Format

   [ClassName]
   Inherits=word (number of classes the current class inherits from)
   class_1=ClassName_1
   class_2=ClassName_2
   .....
   class_n=ClassName_n

   PropertyName=Offset

   Property Names prefix:

     m_ -> Method
     p_ -> Property
     d_ -> Dynamic Method (in this case offset is the Dynamic Method index)
*)
function TOffsInfArchive.GetOffsInfoByClassName(s: String): TOffsInfStruct;
var i : Integer;
begin
   Result:=nil;
   for i:=0 to OffsInfList.Count-1 Do
     if TOffsInfStruct(OffsInfList[i]).FsClassName=s
       then begin
         Result:=TOffsInfStruct(OffsInfList[i]);
         break;
       end;
end;

function TOffsInfArchive.GetReference(sClassName: String; dwOffset: DWORD;
  RefType: TRefOffsInfType; var sReference, sNewClass: String): Boolean;
var i, iPos : Integer;
    OffsInf : TOffsInfStruct;
    sn : String;

    function CheckPrefix(s : String; RefType : TRefOffsInfType) : Boolean;
    begin
      Case RefType Of
        rtMOV     : Result:=(Pos('p_',s)<>0) or (Pos('e_',s)<>0);
        rtCALL    : Result:=Pos('m_',s)<>0;
        rtDynCall : Result:=Pos('d_',s)<>0;
        else Result:=False;
      End;
    end;


    function MakeReference(sClass, sName : String; RefType : TRefOffsInfType) : String;
    var s : String;
    begin
      Case RefType Of
        rtMOV     : s:='property';
        rtCALL    : s:='method';
        rtDynCall : s:='dynamic method';
      end;

      Result:=sREF_TEXT_REF_TO+' '+s+' '+sClass+'.'+Trim(Copy(sName,3,Length(sName)-2));
      if (RefType<>rtMOV) and (Copy(Result,Length(Result),1)<>')') then Result:=Result+'()';
    end;

begin
   Result:=False;
   sReference:='';

   OffsInf:=Self.GetOffsInfoByClassName(sClassName);
   if OffsInf=nil then Exit;

   For i:=0 to OffsInf.FNameList.Count-1 Do
       if ((DWORD(OffsInf.FOffsetList[i]) and $00FFFFFF)=dwOffset)
          and CheckPrefix(OffsInf.FNameList[i],RefType) then
            begin
              sn:=OffsInf.FNameList[i];
              iPos:=Pos(':',sn);
              if iPos<>0
                 then begin
                   sNewClass:=Copy(sn,iPos+1,Length(sn)-iPos);
                   sn:=Copy(sn,1,iPos-1);
                   sn:=Trim(sn);
                 end
                 else sNewClass:='';

              sReference:=MakeReference(sClassName,sn,RefType);
              Result:=True;
              Exit;
            end;
end;

function TOffsInfArchive.GetReferenceEx(sClassName: String; dwOffset: DWORD;
  RefType: TRefOffsInfType; var sReference, sNewClass: String): Boolean;
var i, iPos : Integer;
    OffsInf : TOffsInfStruct;
    sn : String;

    function CheckPrefix(s : String; RefType : TRefOffsInfType) : Boolean;
    begin
      Case RefType Of
        rtMOV     : Result:=(Pos('p_',s)<>0) or (Pos('e_',s)<>0);
        rtCALL    : Result:=Pos('m_',s)<>0;
        rtDynCall : Result:=Pos('d_',s)<>0;
        else Result:=False;
      End;
    end;
begin
   Result:=False;
   sReference:='';

   OffsInf:=Self.GetOffsInfoByClassName(sClassName);
   if OffsInf=nil then Exit;

   For i:=0 to OffsInf.FNameList.Count-1 Do
       if ((DWORD(OffsInf.FOffsetList[i]) and $00FFFFFF)=dwOffset)
          and CheckPrefix(OffsInf.FNameList[i],RefType) then
            begin
              sn:=OffsInf.FNameList[i];
              iPos:=Pos(':',sn);
              if iPos<>0
                 then begin
                   sNewClass:=Copy(sn,iPos+1,Length(sn)-iPos);
                   sNewClass:=Trim(sNewClass);
                   sn:=Copy(sn,1,iPos-1);
                   sn:=Trim(sn);
                 end
                 else sNewClass:='';

              sReference:=Copy(sn,3,Length(sn)-2);
              Result:=True;
              Exit;
            end;
end;

class procedure TOffsInfArchive.LoadOffsInfsFromIniFile(AsFileName: String;
  List: TList);
var IniFile : TIniFile;
    Sects, Sect : TStringList;
    OffsInf : TOffsInfStruct;
    i, j : Integer;
    s : String;
    dw, dw1 : DWORD;
//    b : Byte;

    Procedure DecodeName(var s : String; var b : Byte);
    var pref : String;
    begin
      b:=$FF;
      pref:=copy(s,1,2);
      //0=property, 1=method, 2=event, 3=dynamic
      if pref='p_' then b:=0;
      if pref='m_' then b:=1;
      if pref='e_' then b:=2;
      if pref='d_' then b:=3;
      s:=Copy(s,3,Length(s)-2);
    end;

begin
  IniFile:=TIniFile.Create(AsFileName);
  Sect:=TStringList.Create;
  Sects:=TStringList.Create;
  Try
    // Read all sections
    IniFile.ReadSections(Sects);

    // Loops the sections
    For i:=0 to Sects.Count-1 Do
      begin
        // Read Section Data
        IniFile.ReadSection(Sects[i],Sect);
        OffsInf:=TOffsInfStruct.Create;
        OffsInf.FsClassName:=Sects[i];

        // Reads Inheritance Data
        dw:=IniFile.ReadInteger(Sects[i],'Inherits',0);
        for j:=1 to dw do
          begin
            s:=IniFile.ReadString(Sects[i],Sect[j],'');
            OffsInf.FHierarchyList.Add(s);
          end;

        // Read Properties
        For j:=dw+1 to Sect.Count-1 do
          begin
            s:=Sect[j];
            //DecodeName(s,b);
            if OffsInf.FNameList.IndexOf(s)=-1 then
              begin
                OffsInf.FNameList.Add(s);
                s:=IniFile.ReadString(Sects[i],s,'');
                dw1:={(b shl 24) or }HEX2DWORD(UpperCase(s));
                if Pos('-',s)<>0 then dw1:=not dw1;
                OffsInf.FOffsetList.Add(TObject(dw1));
              end;  
          end;

        List.Add(OffsInf);
      end;
  Finally
    IniFile.Free;
    Sect.Free;
    Sects.Free;
  End;
end;

procedure TOffsInfArchive.RemoveOffsInfo(sClassName: String);
var i : Integer;
begin
 for i:=0 to OffsInfList.Count-1 Do
   if TOffsInfStruct(OffsInfList[i]).FsClassName=sClassName
     then begin
       TOffsInfStruct(OffsInfList[i]).Free;
       OffsInfList.Delete(i);
       NamesList.Delete(i);
       Dec(classes_count);
       break;
     end;
end;

procedure TOffsInfArchive.Save(AsFileName: String);
var s : String;
    TmpStream : TMemoryStream;
    i,j : Integer;
    b : Byte;
    sz : Word;
    dw : DWORD;
    OffsInf : TOffsInfStruct;
    Zip : TVCLZip;
begin
  TmpStream:=TMemoryStream.Create;
  FStream.Clear;
  Try
    // Write Magic
    s:='DOI!';
    FStream.WriteBuffer(s[1],4);
    // Write Flags
    FStream.WriteBuffer(mode,1);
    FStream.WriteBuffer(reserved,1);
    // Write Classes Count
    FStream.WriteBuffer(classes_count,2);

    For i:=0 to classes_count-1 Do
      begin
        // ClassName - Pascal String
        OffsInf:=TOffsInfStruct(OffsInfList[i]);
        b:=Length(OffsInf.FsClassName);
        FStream.WriteBuffer(b,1);
        FStream.WriteBuffer(OffsInf.FsClassName[1],b);

        // WORD - RawDataSize
        sz:=OffsInf.FNameList.Count;
        FStream.WriteBuffer(sz,2);

        // Hierarchy Count
        sz:=OffsInf.FHierarchyList.Count;
        FStream.WriteBuffer(sz,2);

        // Inherit Classes
        For j:=0 to sz-1 Do
          begin
            s:=OffsInf.FHierarchyList[j];
            b:=Length(s);
            FStream.WriteBuffer(b,1);
            FStream.WriteBuffer(s[1],b);
          end;

        For j:=0 to OffsInf.FNameList.Count-1 Do
          begin
            b:=Length(OffsInf.FNameList[j]);
            FStream.WriteBuffer(b,1);
            FStream.WriteBuffer(OffsInf.FNameList[j][1],b);

            dw:=DWORD(OffsInf.FOffsetList[j]);
            b:=dw shr 24;
            FStream.WriteBuffer(b,1);
            dw:=(dw and $00FFFFFF);
            FStream.WriteBuffer(dw,4);
         end;
      end;

  Finally
    TmpStream.Free;
  End;

  Zip:=TVCLZip.Create(nil);
  Try
   Zip.ZipName:=AsFileName;
   Zip.ZipFromStream(FStream,AsFileName);
  Finally
   Zip.Free;
  End;
end;

end.
