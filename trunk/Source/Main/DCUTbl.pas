unit DCUTbl;
(*
The table of used units module of the DCU32INT utility by Alexei Hmelnov.
It is used to obtain the necessary imported declarations. If the imported unit
was not found, the program will still work, but, for example, will show
the corresponding constant value as a HEX dump.
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
  SysUtils,Classes,DCU32;

const
  DCUPath: String='';

//procedure RegisterUnit(U: TUnit);

function GetDCUByName(FName: String; VerRq: integer; StampRq: integer): TUnit;

procedure FreeDCU;

implementation

function FindDCU(FName: String): String;
var
  S: String;
begin
  S := ExtractFilePath(FName);
  if S<>'' then begin
    if not FileExists(FName) then
      FName := '';
    Result := FName;
    Exit;
  end ;
  S := ExtractFileExt(FName);
  if S='' then
    FName := FName+'.dcu';
  Result := FileSearch(FName,DCUPath);
end ;

const
  UnitList: TStringList = Nil;

function GetUnitList: TStringList;
begin
  if UnitList=Nil then begin
    UnitList := TStringList.Create;
    UnitList.Sorted := true;
    UnitList.Duplicates := dupError;
  end ;
  Result := UnitList;
end ;

procedure RegisterUnit(U: TUnit);
var
  UL: TStringList;
begin
  UL := GetUnitList;
  if {(DCUPath='')and}(UL.Count=0) then begin
    if (DCUPath='') then
      DCUPath := ExtractFileDir(U.FileName)
    else
      DCUPath := ExtractFileDir(U.FileName)+
        {$IFNDEF LINUX}';'{$ELSE}':'{$ENDIF}+DCUPath;
  end ;
  UL.AddObject(U.UnitName,U);
end ;

function GetDCUByName(FName: String; VerRq: integer; StampRq: integer): TUnit;
var
  UL: TStringList;
  NDX: integer;
  U0: TUnit;
begin
  UL := GetUnitList;
  if UnitList.Find(FName,NDX) then
    Result := TUnit(UnitList.Objects[NDX])
  else begin
    FName := FindDCU(FName);
    if FName='' then begin
      Result := Nil;
      Exit;
    end ;
    U0 := CurUnit;
    Result := TUnit.Create(FName,VerRq);
    RegisterUnit(Result);
    CurUnit := U0;
  end ;
  if Result=Nil then
    Exit;
  if (VerRq>0)and(Result.Ver<>VerRq) then begin
    Result := Nil;
    Exit;
  end ;
  if (VerRq>2){In Delphi 2.0 Stamp is not used}and(StampRq<>0)
    and(StampRq<>Result.Stamp)
  then
    Result := Nil;
end ;

procedure FreeDCU;
var
  i: integer;
  U: TUnit;
begin
  if UnitList=Nil then
    Exit;
  for i:=0 to UnitList.Count-1 do begin
    U := TUnit(UnitList.Objects[i]);
    U.Free;
  end ;
  UnitList.Free;
  UnitList := Nil;
end ;

end.
