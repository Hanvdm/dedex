unit DeDeDfm;


interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, DBCtrls, Grids, DBGrids, Buttons, StdCtrls, Contnrs,
  ComCtrls, dbcgrids, Tabs, ADODB;


  function ComponentToString(Component: TComponent): string;
  function StringToComponent(Value: string; Instance:TComponent): TComponent;


  function GetObjectString(list:TStrings;BegLine:Integer=0;TypeString:string=''):string;

  function LoadTextForm(FileName:String): TForm;
  function LoadFormFromStrings(aStrs: TStrings): TForm;


  function LoadTextForm2(FileName:String;out ErrMsg:string):TForm;
  procedure DeleteErrorLines(list:TStrings);

  procedure ReadForm(aFrom : TComponent;aFileName :string='');

  procedure ReadFormFromStrings(aFrom: TComponent;aStrs: TStrings);



implementation



var
  IsClassReged: Boolean = False;




function ComponentToString(Component: TComponent): string;
var
  BinStream:TMemoryStream;
  StrStream: TStringStream;
  s: string;
begin
  BinStream := TMemoryStream.Create;
  try
    StrStream := TStringStream.Create(s);
    try
      BinStream.WriteComponent(Component);
      BinStream.Seek(0, soFromBeginning);
      ObjectBinaryToText(BinStream, StrStream);
      StrStream.Seek(0, soFromBeginning);
      Result:= StrStream.DataString;
    finally
      StrStream.Free;
    end;
  finally
    BinStream.Free
  end;
end;

function StringToComponent(Value: string; Instance:TComponent): TComponent;
var
  StrStream:TStringStream;
  BinStream: TMemoryStream;
begin
  StrStream := TStringStream.Create(Value);
  try
    BinStream := TMemoryStream.Create;
    try
      ObjectTextToBinary(StrStream, BinStream);
      BinStream.Seek(0, soFromBeginning);
      Result := BinStream.ReadComponent(Instance);

    finally
      BinStream.Free;
    end;
  finally
    StrStream.Free;
  end;
end;

function GetObjectString(list:TStrings;BegLine:Integer=0;TypeString:string=''):string;
var
  i,iBegCount,iEndCount:Integer;
  ObjString,Line,ClassStr:String;
begin
  iBegCount:=0;
  iEndCount:=0;
  ClassStr := Trim(UpperCase(TypeString));
  for i:=BegLine to list.Count-1 do
  begin
    line := UpperCase(list[i]);
    if Pos('OBJECT',line)>0 then
    begin
      if (TypeString='') or (Pos(': '+ClassStr,line)>0) then
        Inc(iBegCount);
    end
    else if (iBegCount>iEndCount) and (trim(line)='END') then
      Inc(iEndCount);

    if iBegCount>0 then
      Result := Result + list[i] + #13#10;

    if (iBegCount>0) and (iBegCount=iEndCount) then
      Exit;
  end;
end;

procedure DeleteErrorLines(list:TStrings);
var
  i:Integer;
  line:String;
begin
  if list.Count=0 then
    Exit;

  i:=0;
  while i<list.Count do
  begin
    line := Trim(list[i]);
    if Copy(line,1,2)='On' then
      list.Delete(i)
    else
      Inc(i);
  end;
end;
procedure ReadForm(aFrom : TComponent;aFileName :string='');
var
  FrmStrings : TStrings;
begin
  RegisterClass(TPersistentClass(aFrom.ClassType));
  FrmStrings:=TStringlist.Create ;
  try
    if trim(aFileName)='' then
      exit
    else
      FrmStrings.LoadFromFile(aFileName);

    while aFrom.ComponentCount>0 do
      aFrom.Components[0].Destroy ;

    aFrom:=StringToComponent(FrmStrings.Text,aFrom);
  finally
    FrmStrings.Free;
  end;
  UnRegisterClass(TPersistentClass(aFrom.ClassType));
end;



function LoadTextForm(FileName:String):TForm;
var
  list:TStrings;
  FirstLine:String;
  iPos : Integer;
  Form : TForm;
begin
  Result := nil;

  if FileExists(FileName)=False then
    Exit;

  Form := TForm.Create(Application);
  list := TStringList.Create;
  try
    list.LoadFromFile(FileName);
    if list.Count=0 then
      Exit;

    FirstLine := list[0];
    iPos := Pos(': ',FirstLine);
    if iPos = 0 then //找不到': '，格式不对
      Exit;

    list[0]:=Copy(FirstLine,1,iPos)+' TForm';

    DeleteErrorLines(list);

    StringToComponent(list.Text,Form);
    Result := Form;
  except
    Form.Free;
    Result := nil;
  end;
  list.Free;
end;


function LoadFormFromStrings(aStrs: TStrings): TForm;
var
  FirstLine:String;
  iPos : Integer;
  Form : TForm;
begin
  Result := nil;
  Form := TForm.Create(Application);
  try
    FirstLine := aStrs[0];
    iPos := Pos(': ',FirstLine);
    if iPos = 0 then //找不到': '，格式不对
      Exit;

    aStrs[0]:=Copy(FirstLine,1,iPos)+' TForm';

    DeleteErrorLines(aStrs);

    StringToComponent(aStrs.Text,Form);
    Result := Form;
  except
    Form.Free;
    Result := nil;
    raise;
  end;

end;



function LoadTextForm2(FileName:String;out ErrMsg:string):TForm;
var
  list:TStrings;
  FirstLine:String;
  iPos : Integer;
  Form : TForm;
begin
  Result := nil;

  if FileExists(FileName)=False then
  begin
    ErrMsg := '无效的文件名！';
    Exit;
  end;

  Form := TForm.Create(Application);
  list := TStringList.Create;
  try
    list.LoadFromFile(FileName);
    if list.Count=0 then
      Exit;

    FirstLine := list[0];
    iPos := Pos(': ',FirstLine);
    if iPos = 0 then //找不到': '，格式不对
    begin
      ErrMsg := '找不到'': ''，文件格式不对';
      Exit;
    end;

    list[0]:=Copy(FirstLine,1,iPos)+' TForm';

    DeleteErrorLines(list);

    StringToComponent(list.Text,Form);
    Result := Form;
  except
    on e:exception do
    begin
      Form.Free;
      Result := nil;
      ErrMsg := '读入文件错误:'+e.Message;
    end;
  end;
  list.Free;
end;


procedure ReadFormFromStrings(aFrom: TComponent;aStrs: TStrings);
begin
  RegisterClass(TPersistentClass(aFrom.ClassType));

  while aFrom.ComponentCount>0 do
    aFrom.Components[0].Destroy ;

  aFrom:=StringToComponent(aStrs.Text,aFrom);
  UnRegisterClass(TPersistentClass(aFrom.ClassType));

end;


end.
