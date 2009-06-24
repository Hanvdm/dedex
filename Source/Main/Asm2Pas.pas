unit Asm2Pas;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, {SynEditHighlighter, SynHighlighterPas,
  SynEdit,} ComCtrls, Grids, ValEdit, RXCtrls;

type
  TAsm2PasForm = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    GroupBox1: TGroupBox;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    RxLabel1: TRxLabel;
    ListView1: TListView;
    Edit1: TEdit;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure Decompiler(const dw : longword);
  end;

var
  Asm2PasForm: TAsm2PasForm;

implementation

uses DeDe_SDK, MainUnit, hextools, Emulator;

{$R *.dfm}

procedure ProcessInstruction(const dw : dword; const cmd : string);
begin

end;

procedure TAsm2PasForm.Decompiler(const dw : longword);
var
   s : String;
   i : Integer;
begin
   RXLabel1.Caption := 'Find vars and build execution tree.';
   while true do begin
      Disassemble(dw,s,i);
      if (s = 'nop') or (s ='push ebp') then break;
      ProcessInstruction(dw, s);
   end; { while }
end;

procedure TAsm2PasForm.Button1Click(Sender: TObject);
var
   Emul : TCPUEmulator;
//   i : dword;
begin
//   Decompiler(Hex2Dword(Edit1.Text));
   Emul := TCPUEmulator.Create;
   Emul.SetRegValue('eax', 6);
   Emul.SetRegValue('ebx', 1);
   Emul.SetRegValue('esi', 2);
   Emul.Emulate('sub eax, -$2');
   Edit1.Text := Dword2Hex(Emul.GetRegValue('eax'));
   Emul.Free;
end;


end.
