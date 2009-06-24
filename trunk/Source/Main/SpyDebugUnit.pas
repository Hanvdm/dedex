unit SpyDebugUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  RXCtrls, ComCtrls, StdCtrls;

type
  TSpyDebugForm = class(TForm)
    DaList: TRxCheckListBox;
    PB: TProgressBar;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    dwBeg, dwEnd : DWORD;
    procedure GetDSFList;
  end;

var
  SpyDebugForm: TSpyDebugForm;

implementation

uses DeDeDisAsm;

{$R *.DFM}

{ TSpyDebugForm }

procedure TSpyDebugForm.GetDSFList;
var s : String;
    i : Integer;
begin
 PB.Min:=0;
 PB.Max:=dwEnd-dwBeg;
 PB.Position:=0;
 DaList.Items.BeginUpdate;
 DaList.Items.Clear;
 Try
   for i:=dwBeg to dwEND Do
    begin
      s:=GetSymbolReference(i);
      if (s<>'')
        and (s<>'|'#13#10) then
        DaList.Items.Add(s);
      If i mod 100 = 0 then
        begin
          PB.Position:=i-dwBeg;
          PB.Update;
          Application.ProcessMessages;
        end;
    end;
 Finally
  DaList.Items.EndUpdate;
 End;
end;

procedure TSpyDebugForm.Button1Click(Sender: TObject);
begin
  GetDSFList;
end;

end.
