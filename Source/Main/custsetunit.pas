unit custsetunit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  Tw32CustSetForm = class(TForm)
    FormsGB: TGroupBox;
    SkipLB: TListBox;
    SelectedLB: TListBox;
    Label1: TLabel;
    Label2: TLabel;
    RVAGB: TGroupBox;
    FromRVA: TEdit;
    ToRVA: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    Button1: TButton;
    Button2: TButton;
    DSFCB: TCheckBox;
    FormsCB: TCheckBox;
    GroupBox3: TGroupBox;
    Label5: TLabel;
    SaveRefCB: TCheckBox;
    NoBackupCB: TCheckBox;
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure SelectedLBDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure SelectedLBDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure SkipLBDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure SkipLBDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure SkipLBKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure SelectedLBKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure DSFCBClick(Sender: TObject);
    procedure FormsCBClick(Sender: TObject);
  private
    { Private declarations }
    procedure SelectAll(LB : TListBox);
  public
    { Public declarations }
    bSet : Boolean;
    SelectedForms : TStringList;
    dwRVAFrom, dwRVATo : DWORD;
  end;

var
  w32CustSetForm: Tw32CustSetForm;

implementation

{$R *.DFM}

uses HexTools, DeDeRES;

procedure Tw32CustSetForm.Button2Click(Sender: TObject);
var dwf,dwt : DWORD;
begin
  dwf:=HEX2DWORD(FromRVA.Text);
  dwt:=HEX2DWORD(ToRVA.Text);
  if (DSFCB.Checked)
     and((dwt<=dwf) or (dwf<dwRVAFrom) or (dwt>dwRVATo))
    then Raise Exception.Create(err_invalid_rva_interval);
  bSet:=True;
  Close;
end;

procedure Tw32CustSetForm.Button1Click(Sender: TObject);
begin
  bSet:=False;
  Close;
end;

procedure Tw32CustSetForm.FormShow(Sender: TObject);
begin
  bSet:=False;
  FromRVA.Text:=DWORD2HEX(dwRVAFrom);
  ToRVA.Text:=DWORD2HEX(dwRVATo);
end;

procedure Tw32CustSetForm.FormCreate(Sender: TObject);
begin
  SelectedForms:=TStringList.Create;
end;

procedure Tw32CustSetForm.FormDestroy(Sender: TObject);
begin
  SelectedForms.Free;
end;

procedure Tw32CustSetForm.SelectedLBDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
   Accept:=TListBox(Source).Name='SkipLB';
end;

procedure Tw32CustSetForm.SelectedLBDragDrop(Sender, Source: TObject; X,
  Y: Integer);
var i : Integer;
    lb : TListBox;
begin
  lb:=TListBox(Source);
  For i:=lb.Items.Count-1 downto 0 Do
     if lb.Selected[i] then
        begin
          SelectedLB.Items.Add(lb.Items[i]);
          lb.Items.Delete(i);
        end;
end;

procedure Tw32CustSetForm.SkipLBDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
  Accept:=TListBox(Source).Name='SelectedLB';

end;

procedure Tw32CustSetForm.SkipLBDragDrop(Sender, Source: TObject; X,
  Y: Integer);
var i : Integer;
    lb : TListBox;
begin
  lb:=TListBox(Source);
  For i:=lb.Items.Count-1 downto 0 Do
     if lb.Selected[i] then
        begin
          SkipLB.Items.Add(lb.Items[i]);
          lb.Items.Delete(i);
        end;
end;

procedure Tw32CustSetForm.SelectAll(LB: TListBox);
var i : Integer;
begin
  For i:=0 To Lb.Items.Count-1 do
    LB.Selected[i]:=True;
end;

procedure Tw32CustSetForm.SkipLBKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   If (Key in [$41,$61]) and (ssCtrl in Shift)
     then SelectAll(SkipLB);
end;

procedure Tw32CustSetForm.SelectedLBKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    If (Key in [$41,$61]) and (ssCtrl in Shift)
     then SelectAll(SelectedLB);
end;

procedure Tw32CustSetForm.DSFCBClick(Sender: TObject);
begin
  RVAGB.Enabled:=DSFCB.Checked;
end;

procedure Tw32CustSetForm.FormsCBClick(Sender: TObject);
begin
  FormsGB.Enabled:=FormsCB.Checked;
end;

end.
