unit EditExprUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TEditExprForm = class(TForm)
    Label1: TLabel;
    Edit1: TEdit;
    procedure Edit1KeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  EditExprForm: TEditExprForm;

implementation

{$R *.dfm}

procedure TEditExprForm.Edit1KeyPress(Sender: TObject; var Key: Char);
begin
   if Key in  [#13,#27] then begin
      if Key=#13 then ModalResult:=mrOk;
      if Key=#27 then ModalResult:=mrCancel;
   end; 
end;

end.
