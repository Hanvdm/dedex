library DFMClass11;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

uses
  SysUtils,
  Classes,
  Contnrs,
  Forms,
  Windows,
  DeDeComponentForm in 'DeDeComponentForm.pas' {frmDedeComponent},
  DeDeDfm in 'DeDeDfm.pas';

{$R *.res}

var
  DLLApp: TApplication;

procedure MyDLLProc(Reason: Integer);
begin
  if Reason = DLL_PROCESS_DETACH then
  begin
    Application := DLLApp;
  end;
end;




procedure IniDll(aApp: TApplication);
var
  i: Integer;
begin

  Application := aApp;

  if not Assigned(frmDedeComponent) then
  begin
    aApp.CreateForm(TfrmDedeComponent, frmDedeComponent);
  end;

  for i := 0 to frmDedeComponent.ComponentCount - 1 do
  begin
    Classes.RegisterClass(TPersistentClass(frmDedeComponent.Components[i].ClassType));
  end;

end;


exports
  IniDll,
  LoadFormFromStrings;


begin
  DLLApp := Application;
  DLLProc := @MyDLLProc;

end.
