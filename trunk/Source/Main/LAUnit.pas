unit LAUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TLSForm = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Button1: TButton;
    Button2: TButton;
    Timer1: TTimer;
    Label3: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  LSForm: TLSForm;

implementation

{$R *.dfm}

procedure TLSForm.Button1Click(Sender: TObject);
begin
  ModalResult:=mrOk;
end;

procedure TLSForm.Button2Click(Sender: TObject);
begin
  ModalResult:=mrCancel;
end;

procedure TLSForm.FormShow(Sender: TObject);
begin
  Button1.Enabled:=False;
  Button2.Enabled:=False;
  Timer1.Interval:=2000;
  Timer1.Enabled:=True;
end;

procedure TLSForm.Timer1Timer(Sender: TObject);
begin
  Button1.Enabled:=True;
  Button2.Enabled:=True;
  Button2.SetFocus;
end;

end.
