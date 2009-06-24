unit DOIAddDtaUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TDOIAddDataForm = class(TForm)
    ClassEdit: TEdit;
    DescrEdit: TEdit;
    OffsEdit: TEdit;
    Button1: TButton;
    Button2: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DOIAddDataForm: TDOIAddDataForm;

implementation

{$R *.DFM}

end.
