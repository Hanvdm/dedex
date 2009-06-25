unit DeDeDfm;


interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, DBCtrls, Grids, DBGrids, Buttons, StdCtrls, Contnrs,
  ComCtrls, dbcgrids, Tabs;


  procedure RegisterAllClasses();


procedure IniDll(aApp: TApplication); external 'DFMClass11.dll';

function LoadFormFromStrings(aStrs: TStrings): TForm; external 'DFMClass11.dll';

implementation




var
  IsClassReged: Boolean = False;


procedure RegisterAllClasses();
var
  i:Integer;

  AClass: TPersistentClass;
begin
  if IsClassReged then exit;

  IniDll(Application);

  IsClassReged := True;

end;





end.
