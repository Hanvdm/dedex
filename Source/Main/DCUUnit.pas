unit DCUUnit;
//////////////////////////
// Last Change: 08.II.2001
//////////////////////////

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Mask, ExtCtrls, rxToolEdit;

type
  TDCUForm = class(TForm)
    dcum: TMemo;
    Panel1: TPanel;
    DCUFile: TFilenameEdit;
    Label1: TLabel;
    Button1: TButton;
    Button2: TButton;
    OutputTypeRG: TRadioGroup;
    SaveDlg: TSaveDialog;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DCUForm: TDCUForm;

implementation

Uses DeDeDCUDumper, DCUOptionUnit, FMXUtils, DeDeRES;

{$R *.DFM}

var bBlahBlah, bBlahApply : Boolean;

procedure TDCUForm.Button1Click(Sender: TObject);
var TmpList : TStringList;
begin
  TmpList:=TStringList.Create;
  Screen.Cursor:=crHourGlass;
  Try
   ProcessFile(DCUFile.FileName,TmpList, bBlahBlah, True);
   dcum.Lines.Clear;

   if OutputTypeRG.ItemIndex=1 then
     begin
       if SaveDlg.Execute Then TmpList.SaveToFile(SaveDlg.FileName);
       Exit;
     end;

   Try
    dcum.Lines.Assign(TmpList);
   Except
     On e : Exception Do
      If e.Message=err_text_exceeds Then
        Begin
          If MessageDlg(msg_notepad_offer,
             mtConfirmation,[mbYes,mbNo],0)=mrNo Then Exit;
          ExecuteFile('wordpad.exe','','',1);
        End
        Else Raise;
   End;
  Finally
   TmpList.Free;
   Screen.Cursor:=crDefault;
  End;
end;

procedure TDCUForm.Button2Click(Sender: TObject);
begin
  DCUOptionForm.ShowModal;

  If DCUOptionForm.ModalResult=mrOK
     Then ProcessParms(DCUOptionForm.sOPTIONS)
end;

procedure TDCUForm.Button1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if (ssShift in Shift) and (ssAlt in Shift) and (ssCtrl in Shift)
    then bBlahBlah:=True
    else bBlahBlah:=False;
end;

procedure TDCUForm.Button1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if (ssCtrl in Shift) and
     (not (ssAlt in Shift)) then bBlahApply:=False
                            else bBlahApply:=True;
end;

end.
