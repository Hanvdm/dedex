unit SectionEditUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TFlagsEditForm = class(TForm)
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    CheckBox6: TCheckBox;
    CheckBox7: TCheckBox;
    CheckBox8: TCheckBox;
    CheckBox9: TCheckBox;
    CheckBox10: TCheckBox;
    CheckBox11: TCheckBox;
    CheckBox12: TCheckBox;
    CheckBox13: TCheckBox;
    CheckBox14: TCheckBox;
    CheckBox15: TCheckBox;
    CheckBox16: TCheckBox;
    Edit1: TEdit;
    Label1: TLabel;
    Button1: TButton;
    Button2: TButton;
    FlagsLbl: TLabel;
    procedure CheckBox1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    FsFlags : String;
    ComboIndexes : Array[1..16] of Boolean;
    Function GetSectionFlags(AiComboIndex : Integer) : String;
    Procedure SetSectionFlags;
  end;

var
  FlagsEditForm: TFlagsEditForm;

implementation

{$R *.DFM}

Uses DeDeClasses, HEXTools;

{ TFlagsEditForm }

function TFlagsEditForm.GetSectionFlags(AiComboIndex: Integer): String;
Var AdwFlags,Flag : DWORD;
    i : Integer;
begin
   AdwFlags:=0;
   For i:=1 To 16 Do
    Begin
       If Not ComboIndexes[i] Then Continue;
       Case i Of
        1 : Flag:=$8;
        2 : Flag:=$20;
        3 : Flag:=$40;
        4 : Flag:=$80;
        5 : Flag:=$200;
        6 : Flag:=$800;
        7 : Flag:=$1000;
        8 : Flag:=0;
        9 : Flag:=$1000000;
        10: Flag:=$2000000;
        11: Flag:=$4000000;
        12: Flag:=$8000000;
        13: Flag:=$10000000;
        14: Flag:=$20000000;
        15: Flag:=$40000000;
        16: Flag:=$80000000
        Else Flag:=$FFFFFFFF;
      End;{Case}
      AdwFlags:=AdwFlags+Flag;
   End;{For}
 Result:=DWORD2Hex(AdwFlags);
end;       

procedure TFlagsEditForm.SetSectionFlags;
Var AdwFlags : DWORD;
    TmpStr : String;
    i : Integer;
begin
   FlagsLbl.Caption:=FsFlags;
   AdwFlags:=HEX2DWORD(FsFlags);
   For i:=1 To 16 Do ComboIndexes[i]:=False;
   If AdwFlags and $8>0 Then ComboIndexes[1]:=True;
   If AdwFlags and $20>0 Then ComboIndexes[2]:=True;
   If AdwFlags and $40>0 Then ComboIndexes[3]:=True;
   If AdwFlags and $80>0 Then ComboIndexes[4]:=True;
   If AdwFlags and $200>0 Then ComboIndexes[5]:=True;
   If AdwFlags and $800>0 Then ComboIndexes[6]:=True;
   If AdwFlags and $1000>0 Then ComboIndexes[7]:=True;
   TmpStr:=DWord2Hex(AdwFlags);
   While Length(TmpStr)<8 Do TmpStr:='0'+TmpStr;
   If TmpStr[3]<>'0' Then ComboIndexes[8]:=True;
   Case TmpStr[3] of
     '1': Edit1.Text:='1';
     '2': Edit1.Text:='2';
     '3': Edit1.Text:='4';
     '4': Edit1.Text:='8';
     '5': Edit1.Text:='16';
     '6': Edit1.Text:='32';
     '7': Edit1.Text:='64';
     '8': Edit1.Text:='128';
     '9': Edit1.Text:='256';
     'A': Edit1.Text:='512';
     'B': Edit1.Text:='1024';
     'C': Edit1.Text:='2048';
     'D': Edit1.Text:='4096';
     'E': Edit1.Text:='8192';
   End;
   If AdwFlags and $1000000>0 Then ComboIndexes[9]:=True;
   If AdwFlags and $2000000>0 Then ComboIndexes[10]:=True;
   If AdwFlags and $4000000>0 Then ComboIndexes[11]:=True;
   If AdwFlags and $8000000>0 Then ComboIndexes[12]:=True;
   If AdwFlags and $10000000>0 Then ComboIndexes[13]:=True;
   If AdwFlags and $20000000>0 Then ComboIndexes[14]:=True;
   If AdwFlags and $40000000>0 Then ComboIndexes[15]:=True;
   If AdwFlags and $80000000>0 Then ComboIndexes[16]:=True;

   CheckBox1.Checked:=ComboIndexes[1];
   CheckBox2.Checked:=ComboIndexes[2];
   CheckBox3.Checked:=ComboIndexes[3];
   CheckBox4.Checked:=ComboIndexes[4];
   CheckBox5.Checked:=ComboIndexes[5];
   CheckBox6.Checked:=ComboIndexes[6];
   CheckBox7.Checked:=ComboIndexes[7];
   CheckBox8.Checked:=ComboIndexes[8];
   CheckBox9.Checked:=ComboIndexes[9];
   CheckBox10.Checked:=ComboIndexes[10];
   CheckBox11.Checked:=ComboIndexes[11];
   CheckBox12.Checked:=ComboIndexes[12];
   CheckBox13.Checked:=ComboIndexes[13];
   CheckBox14.Checked:=ComboIndexes[14];
   CheckBox15.Checked:=ComboIndexes[15];
   CheckBox16.Checked:=ComboIndexes[16];
end;

procedure TFlagsEditForm.CheckBox1Click(Sender: TObject);
Var Combo : TCheckBox;
begin
  Combo:=Sender as TCheckBox;

  ComboIndexes[Combo.Tag]:=Combo.Checked;
  FlagsLbl.Caption:=GetSectionFlags(0);
end;

procedure TFlagsEditForm.Button1Click(Sender: TObject);
begin
  Close;
end;

procedure TFlagsEditForm.Button2Click(Sender: TObject);
begin
  FsFlags:=FlagsLbl.Caption;
  Close;
end;

end.
