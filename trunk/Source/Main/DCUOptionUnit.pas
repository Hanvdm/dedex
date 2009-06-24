unit DCUOptionUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TDCUOptionForm = class(TForm)
    GroupBox1: TGroupBox;
    c1: TCheckBox;
    c2: TCheckBox;
    c3: TCheckBox;
    C4: TCheckBox;
    C5: TCheckBox;
    C6: TCheckBox;
    C7: TCheckBox;
    C8: TCheckBox;
    C10: TCheckBox;
    C9: TCheckBox;
    Label1: TLabel;
    Button1: TButton;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    sOPTIONS : String;
  end;

var
  DCUOptionForm: TDCUOptionForm;

implementation

{$R *.DFM}

procedure TDCUOptionForm.Button1Click(Sender: TObject);
begin
  sOPTIONS:='';

  If not c1.Checked Then sOPTIONS:=sOPTIONS+'-I,';
  If c2.Checked Then sOPTIONS:=sOPTIONS+'-T,';
  If c3.Checked Then sOPTIONS:=sOPTIONS+'-A,';
  If c4.Checked Then sOPTIONS:=sOPTIONS+'-D,';
  If c5.Checked Then sOPTIONS:=sOPTIONS+'-F,';
  If c6.Checked Then sOPTIONS:=sOPTIONS+'-V,';
  If c7.Checked Then sOPTIONS:=sOPTIONS+'-M,';
  If c8.Checked Then sOPTIONS:=sOPTIONS+'-C,';
  If c9.Checked Then sOPTIONS:=sOPTIONS+'-d,';
  If c10.Checked Then sOPTIONS:=sOPTIONS+'-v,';
  sOPTIONS:=Copy(sOPTIONS,1,Length(sOPTIONS)-1);

  ModalResult:=mrOK;
end;

procedure TDCUOptionForm.Button2Click(Sender: TObject);
begin
  ModalResult:=mrCancel;
end;

end.
