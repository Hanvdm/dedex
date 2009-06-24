unit ASMConvertUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, DisAsm, asm2opcode;

type
  TASMForm = class(TForm)
    SourceEdit: TEdit;
    DestEdit: TEdit;
    Bevel1: TBevel;
    Bevel3: TBevel;
    Label1: TLabel;
    Label2: TLabel;
    o2a: TRadioButton;
    a2o: TRadioButton;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure SourceEditKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure o2aClick(Sender: TObject);
  private
    { Private declarations }
    procedure DoDasm;
  public
    { Public declarations }
    DASM : TDisAsm;
    _ASM : TAsm;
  end;

var
  ASMForm: TASMForm;

implementation

{$R *.DFM}

Uses HEXTools;

procedure TASMForm.FormShow(Sender: TObject);
begin
  SourceEdit.Clear;
  DestEdit.Clear;
end;

procedure TASMForm.FormCreate(Sender: TObject);
begin
  DASM:=TDisAsm.Create;
  _ASM:=TAsm.Create;
end;

procedure TASMForm.FormDestroy(Sender: TObject);
begin
  DASM.Free;
  _ASM.Free;
end;

procedure TASMForm.SourceEditKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  If Key=13 Then DoDasm
end;

procedure TASMForm.DoDasm;
var sz : Integer;
    pc : String;
    b : Byte;
begin
  pc:='';
  SourceEdit.Text:=AnsiUpperCase(SourceEdit.Text);
  if o2a.checked then
    begin
      For sz:=1 To Length(SourceEdit.Text) div 2 Do
        Begin
          b:=HEX2Byte(Copy(SourceEdit.Text,2*sz-1,2));
          pc:=pc+CHR(b);
        End;
      If pc<>'' Then
         Destedit.Text:=DASM.GetInstruction(PChar(pc),sz);
    end
    else Destedit.Text:=_ASM.DoASM(SourceEdit.Text)
end;

procedure TASMForm.o2aClick(Sender: TObject);
begin
  if o2a.checked then
    begin
      Label2.Caption:='OPCODE';
      Label1.Caption:='ASM';
    end
    else begin
      Label1.Caption:='OPCODE';
      Label2.Caption:='ASM';
    end;
end;

end.
