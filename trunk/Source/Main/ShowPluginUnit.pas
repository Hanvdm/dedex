unit ShowPluginUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TShowPlugInForm = class(TForm)
    Memo: TMemo;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ShowPlugInForm: TShowPlugInForm;

implementation

{$R *.DFM}

end.
