unit AdvEmuSetUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TAdvanceEmuSettingsForm = class(TForm)
    Button1: TButton;
    Button2: TButton;
    SetCB: TCheckBox;
    SetGRP: TGroupBox;
    eaxEdit: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    edxEdit: TEdit;
    Label3: TLabel;
    esiEdit: TEdit;
    Label4: TLabel;
    ecxEdit: TEdit;
    Label5: TLabel;
    ebxEdit: TEdit;
    Label6: TLabel;
    ediEdit: TEdit;
    addEdit: TEdit;
    Label7: TLabel;
    procedure SetCBClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    sRegInitStirng : String;
  end;

var
  AdvanceEmuSettingsForm: TAdvanceEmuSettingsForm;

implementation

{$R *.DFM}

procedure TAdvanceEmuSettingsForm.SetCBClick(Sender: TObject);
begin
  SetGRP.Enabled:=SetCB.Checked;
end;

procedure TAdvanceEmuSettingsForm.Button2Click(Sender: TObject);
begin
  sRegInitStirng:=Format('EAX=%s,ECX=%s,EDX=%s,EBX=%s,ESI=%s,EDI=%s',
     [eaxEdit.Text,ecxEdit.Text,edxEdit.Text,ebxEdit.Text,esiEdit.Text,ediEdit.Text]);
  Close;     
end;

procedure TAdvanceEmuSettingsForm.Button1Click(Sender: TObject);
begin
  sRegInitStirng:='';
  Close;
end;

end.
