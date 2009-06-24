unit EPFindUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TEPFindForm = class(TForm)
    Label4: TLabel;
    Label5: TLabel;
    Button1: TButton;
    RVALbl: TLabel;
    PEHLbl: TLabel;
    Bevel1: TBevel;
    ProcNameLbl: TLabel;
    Label1: TLabel;
    RawLbl: TLabel;
    Label3: TLabel;
    ImBLbl: TLabel;
    Label7: TLabel;
    BoCLbl: TLabel;
    Label9: TLabel;
    PoCLbl: TLabel;
    Label2: TLabel;
    Bevel2: TBevel;
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
    dwCodePhys : DWORD;
  public
    { Public declarations }
    EP : DWORD;
    BoC,PoC,ImB : DWORD;
    sFileName : String;
  end;

var
  EPFindForm: TEPFindForm;

implementation

{$R *.DFM}

Uses HEXTools;

procedure TEPFindForm.FormShow(Sender: TObject);
begin
  dwCodePhys:=PoC;
  RVALbl.Caption:=DWORD2Hex(EP+ImB+BoC-dwCodePhys);
  PEHLbl.Caption:=DWORD2Hex(EP+BoC-dwCodePhys);
  BoCLbl.Caption:=DWORD2Hex(BoC);
  PoCLbl.Caption:=DWORD2Hex(dwCodePhys);
  ImBLbl.Caption:=DWORD2Hex(ImB);
  RawLbl.Caption:=DWORD2Hex(EP);
  ProcNameLbl.Caption:=sFileName;
end;

procedure TEPFindForm.Button1Click(Sender: TObject);
begin
  Close;
end;

end.
