unit MethProp;
(*
The Components Events Information module of the DFM2PAS utility by Alexei Hmelnov.
----------------------------------------------------------------------------
E-Mail: alex@monster.icc.ru
http://monster.icc.ru/~alex/
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
  SysUtils,Classes;

type
  TComponentInfo = class
    Parent: TComponentInfo;
    UnitName: String;
    Methods: TStringList;
    constructor Create;
    destructor Destroy; override;
    function GetPropertyMethod(PropName,MethodName: String): String;
  private
    function IsNew: boolean;
  end ;

procedure LoadComponentDescrs;
procedure FreeComponentDescrs;

function GetComponentInfo(ClassName: String): TComponentInfo;

implementation

type
  PMethodInfo = ^TMethodInfo;
  TMethodInfo = record
    Descr: String;
   {This information could be extended, so I decided to use record here
    instead of direct string to pointer conversion like
    Methods.Objects[i] := Pointer(Descr)}
  end ;

const
  CompTbl: TStringList = Nil;
  EvtTbl: TStringList = Nil;
  NotifyEvt: String = 'procedure(Sender: TObject);{?}';
  FormInfo: TComponentInfo = Nil;

procedure LoadComponentDescrs;

  function GetComponentInfo(Name: String): TComponentInfo;
  var
    i: integer;
  begin
    if CompTbl.Find(Name,i) then
      Result := TComponentInfo(CompTbl.Objects[i])
    else begin
      Result := TComponentInfo.Create;
      CompTbl.AddObject(Name,Result);
    end ;
  end ;

  function GetEvtInfo(Name: String): PMethodInfo;
  var
    i: integer;
  begin
    if EvtTbl.Find(Name,i) then
      Result := PMethodInfo(EvtTbl.Objects[i])
    else begin
      New(Result);
      Pointer(Result.Descr) := Nil;
      EvtTbl.AddObject(Name,Pointer(Result));
    end ;
  end ;

var
  l: integer;
  S: String;

  procedure ScanError(Msg: String);
  begin
    raise Exception.CreateFmt('%s at %d:'#13#10'%s',[Msg,l,S]);
  end ;

var
  F: Text;
  FBuf: array[0..$FFF] of Byte;
  UnitS: String;
  PropS,EvtS: String;
  OnTypes: boolean;
  CI,Parent: TComponentInfo;
  CP: PChar;
  MI: PMethodInfo;
  i: integer;
begin
  if CompTbl=nil then CompTbl := TStringList.Create;
//  CompTbl := TStringList.Create;
//  CompTbl.Create;
  CompTbl.Sorted := true;
  CompTbl.Duplicates := dupError;

  if EvtTbl=nil then EvtTbl := TStringList.Create;
//  EvtTbl := TStringList.Create;;
//  EvtTbl.Create;
  EvtTbl.Sorted := true;
  EvtTbl.Duplicates := dupError;
  AssignFile(F,ExtractFilePath(ParamStr(0))+'classes.lst');
  SetTextBuf(F,FBuf);
 {$I-}
  Reset(F);
 {$I+}
  if IOResult<>0 then
    Exit;
  try
    UnitS := '?';
    OnTypes := false;
    CI := Nil;
    l := 0;
    while not EOF(F) do begin
      Readln(F,S);
      Inc(l);
      S := Trim(S);
      if S='' then begin
        if not OnTypes then
          CI := Nil;
        Continue;
      end ;
      if OnTypes then begin
        CP := StrScan(PChar(S),'=');
        if CP=Nil then
          ScanError('"=" expected');
        EvtS := TrimRight(Copy(S,1,CP-PChar(S)));
        MI := GetEvtInfo(EvtS);
        if MI^.Descr<>'' then
          ScanError('Event redefined');
        MI.Descr := TrimLeft(Copy(S,CP-PChar(S)+2,1000));
       end
      else begin
        if CompareText(S,'type')=0 then begin
          OnTypes := true;
          Continue;
        end ;
        if S[Length(S)]=':' then begin
          SetLength(S,Length(S)-1);
          UnitS := TrimRight(S);
          Continue;
        end ;
        if CI=Nil then begin
          CP := StrScan(PChar(S),'(');
          if CP=Nil then
            Parent := Nil
          else begin
            if S[Length(S)]<>')' then
              ScanError('")" expected');
            Parent := GetComponentInfo(Trim(Copy(S,CP-PChar(S)+2,Length(S)-(CP-PChar(S))-2)));
            SetLength(S,CP-PChar(S));
            S := TrimRight(S);
          end ;
          CI := GetComponentInfo(S);
          if not CI.IsNew then
            ScanError('Component redefined');
          CI.UnitName := UnitS;
          CI.Parent := Parent;
          Continue;
        end ;
        CP := StrScan(PChar(S),':');
        if CP=Nil then
          ScanError('":" expected');
        PropS := TrimRight(Copy(S,1,CP-PChar(S)));
        EvtS := TrimLeft(Copy(S,CP-PChar(S)+2,255));
        MI := GetEvtInfo(EvtS);
        CI.Methods.AddObject(PropS,Pointer(MI));
      end ;
    end ;
    if CompTbl.Find('TForm',i) then
      FormInfo := TComponentInfo(CompTbl.Objects[i])
  finally
    Close(F);
  end ;
end ;

procedure FreeComponentDescrs;
var
  i: integer;
  MI: PMethodInfo;
  CI: TComponentInfo;
begin
  if EvtTbl<>Nil then begin
    for i:=0 to EvtTbl.Count-1 do begin
      MI := PMethodInfo(EvtTbl.Objects[i]);
      if MI=Nil then
        Continue;
      Dispose(MI);
    end ;
    EvtTbl.Free;
//    EvtTbl := Nil;
  end ;
  if CompTbl<>Nil then begin
    for i:=0 to CompTbl.Count-1 do begin
      CI := TComponentInfo(CompTbl.Objects[i]);
      if CI=Nil then
        Continue;
      CI.Free;
    end ;
    CompTbl.Free;
    CompTbl := Nil;
  end ;
end ;

{ TComponentInfo. }
constructor TComponentInfo.Create;
begin
  inherited Create;
  Methods := TStringList.Create;
  Methods.Sorted := true;
  Methods.Duplicates := dupError;
end ;

destructor TComponentInfo.Destroy;
begin
  Methods.Free;
  inherited Destroy;
end ;

function TComponentInfo.GetPropertyMethod(PropName,MethodName: String): String;
{The DFM files contain only <PropName>=<MethodName> information about
 event handlers. This procedure searches for the PropName method of the
 Component and if found uses its Description to generate the result named
 MethodName, else it returns the method header of the TNotifyEvent
 type if the PropName starts with 'On'}
var
  i: integer;
  MI: PMethodInfo;
  CP: PChar;
begin
  Result := '';
  if Methods.Find(PropName,i) then begin
    MI := PMethodInfo(Methods.Objects[i]);
    Result := MI^.Descr;
  end ;
  if Result='' then begin
    if StrLIComp(PChar(PropName),'On',2)<>0 then
      Exit
     {This heuristics is used to skip component references,
      e.g. TDataSource.DataSet};
    Result := NotifyEvt;
  end ;
  CP := StrScan(PChar(Result),'(');
  if CP=Nil then
    CP := StrScan(PChar(Result),';');
  if CP=Nil then
    CP := PChar(Result)+Length(Result);
  Insert(' '+MethodName,Result,CP-PChar(Result)+1);
end ;

function TComponentInfo.IsNew: boolean;
{This function is used on the LoadComponentDescrs stage to detect
 redefinition of components}
begin
  Result := UnitName='';
end ;

function GetComponentInfo(ClassName: String): TComponentInfo;
var
  i: integer;
begin
  if CompTbl.Find(ClassName,i) then
    Result := TComponentInfo(CompTbl.Objects[i])
  else
    Result := FormInfo {Unknown class is processed using the TForm information};
end ;

end.
