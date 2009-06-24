unit ConverterUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, jpeg;

type
  TConverterForm = class(TForm)
    IB: TEdit;
    RVA: TEdit;
    Ph: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    CRVA: TEdit;
    CPh: TEdit;
    Label5: TLabel;
    Bevel1: TBevel;
    SectionCB: TComboBox;
    Bevel2: TBevel;
    Bevel3: TBevel;
    procedure FormCreate(Sender: TObject);
    procedure PhKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure RVAKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure SectionCBChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    dwIB,dwCRVA,dwCPh : DWORD;
    dwRVA,dwPh : DWORD;
    procedure GetData;
    Procedure SetData;
  end;

var
  ConverterForm: TConverterForm;

implementation

{$R *.DFM}

Uses HexTools, DeDeClasses, MainUnit;

procedure TConverterForm.FormCreate(Sender: TObject);
begin
  dwIB:=HEX2DWORD(IB.Text);
  dwCRVA:=HEX2DWORD(CRVA.Text);
  dwCPh:=HEX2DWORD(Ph.Text);
end;

procedure TConverterForm.PhKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  If Key=13 Then
    Begin
      GetData;
      dwPh:=HEX2DWORD(Ph.Text);
      dwRVA:=dwPh+dwIB+dwCRVA-dwCPh;
      SetData;
    end;
end;
 
procedure TConverterForm.RVAKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  If Key=13 Then
    Begin
      GetData;
      dwRVA:=HEX2DWORD(RVA.Text);
      dwPh:=dwRVA-dwIB-dwCRVA+dwCPh;
      SetData;
    End;
end;

procedure TConverterForm.GetData;
begin
   dwCPh:=HEX2DWORD(CPh.Text);
   dwCRVA:=HEX2DWORD(CRVA.Text);
   dwIB:=HEX2DWORD(IB.Text);   
end;

procedure TConverterForm.SetData;
begin
  IB.Text:=DWORD2HEX(dwIB);
  CRVA.Text:=DWORD2HEX(dwCRVA);
  CPh.Text:=DWORD2HEX(dwCPh);
  RVA.Text:=DWORD2HEX(dwRVA);
  PH.Text:=DWORD2HEX(dwPh);
end;

procedure TConverterForm.FormShow(Sender: TObject);
var i : Integer;
begin
  SectionCB.Clear;
  if DeDeClasses.PEHeader=nil then exit;
  For i:=1 To DeDeClasses.PEHeader.ObjectNum Do
      SectionCB.Items.Add(DeDeClasses.PEHeader.Objects[i].OBJECT_NAME);
  If SectionCB.Items.Count<>0 Then SectionCB.ItemIndex:=0;
  IB.Text:=IntToHex(PEHeader.IMAGE_BASE,8);
  CRVA.Text:=DWORD2HEX(PEHeader.Objects[1].RVA);
  CPh.Text:=DWORD2HEX(PEHeader.Objects[1].PHYSICAL_OFFSET);
  RVA.Text:=IB.Text;
end;

procedure TConverterForm.SectionCBChange(Sender: TObject);
var i : Integer;
begin
  i:=SectionCB.ItemIndex+1;
  CRVA.Text:=DWORD2HEX(PEHeader.Objects[i].RVA);
  CPh.Text:=DWORD2HEX(PEHeader.Objects[i].PHYSICAL_OFFSET);
  PH.Text:=CPH.Text;  
end;

end.
