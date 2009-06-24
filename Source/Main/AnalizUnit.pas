unit AnalizUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, ExtCtrls, StdCtrls;

type
  TAnalyzForm = class(TForm)
    Cancel: TButton;
    Bevel1: TBevel;
    ProgressBar1: TProgressBar;
    AnlzAni: TAnimate;
    StatusMemo: TMemo;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure CancelClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AnalyzForm: TAnalyzForm;

implementation

{$R *.DFM}

procedure TAnalyzForm.FormShow(Sender: TObject);
begin
  AnlzAni.Visible:=True;
  AnlzAni.Active:=True;
end;

procedure TAnalyzForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   AnlzAni.Visible:=False;
   AnlzAni.Active:=False;
end;

procedure TAnalyzForm.CancelClick(Sender: TObject);
begin
  Close;
end;

end.
