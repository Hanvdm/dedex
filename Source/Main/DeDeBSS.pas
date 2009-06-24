{*******************************************************

 功    能：BSS

 注意事项：
 
                                                       
*******************************************************}
unit DeDeBSS;


interface

uses Classes, Windows;

Type

  TBSS = Class
  protected
    Data : TList;
    DataPtr : TList;
    Pointers : TList;
    Values : TList;
    PrimValues : TList;
  public
    dwStartRVA, dwSize : DWORD;
    dwDATAStartRVA, dwDATASize : DWORD;
    constructor Create;
    destructor Destroy; override;
    procedure Dump(FileName : String);
    function GetPointer(Offset : DWORD) : DWORD;
    function GetValue(Offset : DWORD) : DWORD;
    function GetValuePrim(Offset : DWORD) : DWORD;
    function GetData(Offset : DWORD) : DWORD;
    function GetDataPtr(Offset : DWORD) : DWORD;
    function GetDataPrtOfBSSData(Offset : DWORD) : DWORD;
    procedure GetProtectedDataForDPJSave(var buff : array of byte; var size : integer);
  end;

implementation

{ TBSS }

Uses DeDeClasses, DeDeRES;

constructor TBSS.Create;
begin
  Values:=TList.Create;
  PrimValues:=TList.Create;
  Pointers:=TList.Create;
  Data:=TList.Create;
  DataPtr:=TList.Create;
  dwSize:=0;
end;

destructor TBSS.Destroy;
begin
  Values.Clear;
  Pointers.Clear;

  PrimValues.Free;
  Values.Free;
  Pointers.Free;
  Data.Free;
  DataPtr.Free;
end;

procedure TBSS.Dump(FileName: String);
var pi : PROCESS_INFORMATION;
    si : _STARTUPINFOA;
    bssi, i : Integer;
    dw, dw1 : DWORD;
    sz : Cardinal;
begin
  bssi := PEHeader.GetSectionIndexEx('DATA');

  dwDATAStartRVA := PEHeader.IMAGE_BASE+PEHeader.Objects[bssi].RVA;
  dwDATASize := PEHeader.Objects[bssi].VIRTUAL_SIZE;

  bssi := PEHeader.GetSectionIndexEx('BSS');
  dwStartRVA := PEHeader.IMAGE_BASE+PEHeader.Objects[bssi].RVA;
  dwSize := PEHeader.Objects[bssi].VIRTUAL_SIZE;


  GetStartUpInfo(si);
  si.dwFlags:=STARTF_USESHOWWINDOW;
  si.wShowWindow:=SW_HIDE;

  If CreateProcess(PCHar(FileName), nil, nil, nil, False,
   CREATE_NEW_PROCESS_GROUP OR CREATE_SUSPENDED, nil, nil, si, pi) Then
  Begin
    //
    ResumeThread(pi.hThread);
    WaitForInputIdle(pi.hProcess,10000);

    MessageBox(GetDesktopWindow,PChar(msg_ok_when_loaded),
      PChar(txt_dede_loader),MB_SYSTEMMODAL);

    SuspendThread(pi.hThread);

    dw := dwStartRVA;
    i:=0;
    while dw < (dwStartRVA + dwSize) Do
    begin
      ReadProcessMemory(pi.hProcess,Pointer(dw),@dw1,4,sz);
      Pointers.Add(TObject(dw1));

      ReadProcessMemory(pi.hProcess,Pointer(dw1),@dw1,4,sz);
      Values.Add(TObject(dw1));

      ReadProcessMemory(pi.hProcess,Pointer(dw1),@dw1,4,sz);
      PrimValues.Add(TObject(dw1));

      Inc(dw,4);
      Inc(i);
    end;

    dw := dwDATAStartRVA;
    i:=0;
    while dw < (dwDATAStartRVA + dwDATASize) Do
    begin
      DataPtr.Add(TObject(i));

      ReadProcessMemory(pi.hProcess,Pointer(dw),@dw1,4,sz);

      Data.Add(TObject(dw1));

      Inc(dw,4);
      Inc(i);
    end;

    //ResumeThread(pi.hThread);
    TerminateProcess(pi.hProcess,0);
  End
  Else
  Begin
    MessageBox(0,PChar(err_can_not_create_process+'"'+FileName+'"'),
      PChar('DeDe'),0);
      
    dw:=dwStartRVA;
    while dw < (dwStartRVA + dwSize) Do
    begin
      Pointers.Add(Pointer(dwStartRVA));
      Values.Add(nil);
      PrimValues.Add(Pointer(dwStartRVA));
      Data.Add(nil);
      DataPtr.Add(Pointer(dwStartRVA));
      Inc(dw,4);
    end;
  End;
end;

function TBSS.GetData(Offset: DWORD): DWORD;
begin
  if bBSS then Result:=DWORD(Data[(Offset-dwDATAStartRVA) div 4])
          else Result:=0;
end;

function TBSS.GetDataPrtOfBSSData(Offset: DWORD): DWORD;
var i : Integer;
begin
  Result:=0;
  if not bBSS then exit;
  
  i:=dwDATAStartRVA;
  while i<(dwDATAStartRVA+dwDATASize) do
  begin
    if GetData(i)=Offset then
    begin
      Result:=i;
      break;
    end;
    inc(i,4);
  end;
end;

function TBSS.GetDataPtr(Offset: DWORD): DWORD;
begin
  if bBSS then
    Result:=DWORD(DataPtr[(Offset-dwDATAStartRVA) div 4])
  else
    Result:=0;

end;

function TBSS.GetPointer(Offset: DWORD): DWORD;
begin
   if bBSS then
     Result:=DWORD(Pointers[(Offset-dwStartRVA) div 4])
   else
     Result:=0;
end;

procedure TBSS.GetProtectedDataForDPJSave(var buff: array of byte;
  var size: integer);
var i : Integer;
begin
  size:=Data.Count+DataPtr.Count+Pointers.Count+Values.Count+PrimValues.Count;
  if Length(buff)<>size then exit;

  for i:=0 to Data.Count-1 do buff[i]:=DWORD(Data[i]);
  size:=Data.Count;
  for i:=0 to DataPtr.Count-1 do buff[size+i]:=DWORD(DataPtr[i]);
  size:=size+DataPtr.Count;
  for i:=0 to Pointers.Count-1 do buff[size+i]:=DWORD(Pointers[i]);
  size:=size+Pointers.Count;
  for i:=0 to Values.Count-1 do buff[size+i]:=DWORD(Values[i]);
  size:=size+Values.Count;
  for i:=0 to PrimValues.Count-1 do buff[size+i]:=DWORD(PrimValues[i]);
  size:=size+PrimValues.Count;
end;

function TBSS.GetValue(Offset: DWORD): DWORD;
begin
  if bBSS then
    Result:=DWORD(Values[(Offset-dwStartRVA) div 4])
  else
    Result:=0;
end;

function TBSS.GetValuePrim(Offset: DWORD): DWORD;
begin
  if bBSS then
   Result:=DWORD(PrimValues[(Offset-dwStartRVA) div 4])
  else
   Result:=0;
end;

end.
