unit SymbolsUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons, ComCtrls;

type
  TSymbolsForm = class(TForm)
    OpenDlg: TOpenDialog;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    Panel1: TPanel;
    Notebook1: TNotebook;
    Panel5: TPanel;
    ListBox: TListBox;
    Panel7: TPanel;
    ViewBtn: TButton;
    RABtn: TButton;
    Button3: TButton;
    UBtn: TButton;
    Panel4: TPanel;
    Det: TListBox;
    Panel2: TPanel;
    Panel8: TPanel;
    Button4: TButton;
    Panel3: TPanel;
    Label4: TLabel;
    TotSymLbl: TLabel;
    Button1: TButton;
    Panel6: TPanel;
    gb: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    SymCountLbl: TLabel;
    Label3: TLabel;
    DSFVerLbl: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    d3: TCheckBox;
    d4: TCheckBox;
    d5: TCheckBox;
    d2: TCheckBox;
    d6: TCheckBox;
    Panel9: TPanel;
    Label11: TLabel;
    Button2: TButton;
    Panel10: TPanel;
    Panel11: TPanel;
    Notebook2: TNotebook;
    Panel12: TPanel;
    DOIList: TListBox;
    Panel13: TPanel;
    Panel14: TPanel;
    ListBox2: TListBox;
    Panel15: TPanel;
    Panel16: TPanel;
    Button9: TButton;
    OpenDOIDlg: TOpenDialog;
    procedure FormShow(Sender: TObject);
    procedure ListBoxClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure ListBoxDblClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure DetDblClick(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure UBtnClick(Sender: TObject);
    procedure RABtnClick(Sender: TObject);
    procedure Panel1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
    Procedure UpdateStatuses;
  public
    { Public declarations }
    SymbolsList : TList;
  end;

var
  SymbolsForm: TSymbolsForm;

implementation

{$R *.DFM}

Uses DeDeSym, HEXTools, MainUnit, DeDeConstants, DeDeRES;

procedure TSymbolsForm.FormShow(Sender: TObject);
var i : Integer;
    Sym : TDeDeSymbol;
    s : String;
    count : Integer;
begin
  ListBox.Items.Clear;
  If SymbolsList=nil Then Exit;
  count:=0;
  For i:=0 To SymbolsList.Count-1 Do
    Begin
      Sym:=TDeDeSymbol(SymbolsList[i]);
      s:=ExtractFileName(Sym.FileName);
      While Length(s)<25 Do s:=s+' ';
      s:=s+Sym.Comment;
      inc(count,Sym.Count);
      ListBox.Items.Add(s);
    End;
  TotSymLbl.Caption:=IntToStr(count);
   Notebook1.ActivePage:='Default';
  If ListBox.Items.Count<>0 Then
    Begin
      ListBox.ItemIndex:=0;
      ListBoxClick(self);
    End;

  For i:=0 To DeDeMainForm.LoadedDOIList.Count-1 Do
    Begin
      s:=ExtractFileName(DeDeMainForm.LoadedDOIList[i]);
      DOIList.Items.Add(s);
    End;

  UpdateStatuses;
end;

procedure TSymbolsForm.ListBoxClick(Sender: TObject);
var i, idx : Integer;
    Sym : TDeDeSymbol;
begin
  d2.Checked:=False;
  d3.Checked:=False;
  d4.Checked:=False;
  d5.Checked:=False;
  d6.Checked:=False;
  SymCountLbl.Caption:='';
  DSFVerLbl.Caption:='';

  If ListBox.Items.Count=0 Then Exit;

  idx:=0;
  For i:=0 To ListBox.Items.Count-1 Do
    If ListBox.Selected[i] Then
      Begin
        idx:=i;
        break;
      End;
  If Not ListBox.Selected[idx] Then Exit;

  Sym:=TDeDeSymbol(SymbolsList[idx]);
  d3.Checked:=(Sym.Mode AND 1)<>0;
  d4.Checked:=(Sym.Mode AND 2)<>0;
  d5.Checked:=(Sym.Mode AND 4)<>0;
  d2.Checked:=(Sym.Mode AND 8)<>0;
  d6.Checked:=(Sym.Mode AND 16)<>0;
  SymCountLbl.Caption:=IntToStr(Sym.Count);
  DSFVerLbl.Caption:=GetDSFVersion(Sym);
end;

procedure TSymbolsForm.Button1Click(Sender: TObject);
begin
  Close;
end;

procedure TSymbolsForm.ListBoxDblClick(Sender: TObject);
var i, idx : Integer;
    Sym : TDeDeSymbol;
    b : Byte;
    s : String;
begin
  Screen.Cursor:=crHourGlass;
  Try
    idx:=0;
    For i:=0 To ListBox.Items.Count-1 Do
      If ListBox.Selected[i] Then
        Begin
          idx:=i;
          break;
        End;
    If Not ListBox.Selected[idx] Then Exit;

    Sym:=TDeDeSymbol(SymbolsList[idx]);
    Sym.Str.Seek(0,soFromBeginning);
    Det.Items.Clear;
    For i:=0 To Sym.Count-1 Do
      Begin
        Sym.Str.ReadBuffer(b,1);
        SetLength(s,b);
        Sym.Str.ReadBuffer(s[1],b);
        Det.Items.Add(s);
      End;
    Notebook1.ActivePage:='Boza';
  Finally
    Screen.Cursor:=crDefault;
  End;
end;

procedure TSymbolsForm.SpeedButton1Click(Sender: TObject);
begin
  NoteBook1.ActivePage:='Default';
end;

procedure TSymbolsForm.DetDblClick(Sender: TObject);
var i, idx : Integer;
    Sym : TDeDeSymbol;
    b : Byte;
    s : String;
begin
  idx:=0;
  For i:=0 To ListBox.Items.Count-1 Do
    If ListBox.Selected[i] Then
      Begin
        idx:=i;
        break;
      End;
  If Not ListBox.Selected[idx] Then Exit;

  Sym:=TDeDeSymbol(SymbolsList[idx]);

  For i:=0 To Det.Items.Count-1 Do
    If Det.Selected[i] Then
      Begin
        idx:=i;
        break;
      End;
  If Not Det.Selected[idx] Then Exit;

  Sym.Sym.Seek(idx*_PatternSize,soFromBeginning);
  s:='';
  For i:=1 To _PatternSize Do
   Begin
    Sym.Sym.ReadBuffer(b,1);
    s:=s+Byte2Hex(b);
   End;

  InputBox(Det.Items[idx],'DSF_ID',s);
  //ShowMessage(s);
end;

procedure TSymbolsForm.Button3Click(Sender: TObject);
var DeDeSym : TDeDeSymbol;
    i : Integer;
    s : String;
begin
  OpenDlg.InitialDir:=ExtractFileDir(Application.ExeName)+'\DSF';
  If Not OpenDlg.Execute Then Exit;
  
  Screen.Cursor:=crHourGlass;
  Try
    For i:=0 To OpenDlg.Files.Count-1 Do
      Begin
        s:=OpenDlg.Files[i];
        If DeDeMainForm.SymbolsPath.IndexOf(s)<>-1 Then ShowMessage(err_symbol_loaded);
        DeDeSym:=TDeDeSymbol.Create;
        If DeDeSym.LoadSymbol(s)
           Then Begin
            If DeDeSym.PatternSize=_PatternSize Then
               Begin
                 DeDeMainForm.SymbolsList.Add(DeDeSym);
                 DeDeMainForm.SymbolsPath.Add(s);
               End
               Else Begin
                 ShowMessage(ExtractFileName(s)+' - '+err_dsf_ver_not_supp);
                 DeDeSym.Free;
               End;
           End
           Else begin
             ShowMessage(ExtractFileName(s)+' - Not a valid symbol file');
             DeDeSym.Free;
           End;
      End;
  Finally
    Screen.Cursor:=crDefault;
  End;
  
  SymbolsList:=DeDeMainForm.SymbolsList;
  OnShow(Self);
  UpdateStatuses;
end;

procedure TSymbolsForm.UBtnClick(Sender: TObject);
var i : Integer;
begin
  For i:=0 To ListBox.Items.Count-1 Do
    If ListBox.Selected[i] Then Break;
  If Not ListBox.Selected[i] Then Exit;
  DeDeMainForm.UnloadDSFSymbol(i);
  DeDeMainForm.SymbolsPath.Delete(i);
  SymbolsList:=DeDeMainForm.SymbolsList;
  OnShow(Self);
  ListBoxClick(Self);
  UpdateStatuses;
end;

procedure TSymbolsForm.RABtnClick(Sender: TObject);
var i : Integer;
    DeDeSym : TDeDeSymbol;
begin
  If MessageDlg(msg_reload_symbols_ask,mtConfirmation,[mbYES,mbNo],0)=mrNo Then Exit;

  For i:=ListBox.Items.Count-1 DownTo 0 Do
       DeDeMainForm.UnloadDSFSymbol(i);

  FirstByteSet:=[];
  
  Screen.Cursor:=crHourGlass;
  Try
    For i:=0 To DeDeMainForm.SymbolsPath.Count-1 Do
      begin
        DeDeSym:=TDeDeSymbol.Create;

        If DeDeSym.LoadSymbol(DeDeMainForm.SymbolsPath[i])
           Then Begin
             If DeDeSym.PatternSize=_PatternSize Then
               Begin
                 SymbolsList.Add(DeDeSym);
               End
               Else Begin
                 ShowMessage(err_dsf_ver_not_supp);
                 DeDeSym.Free;
               End;
              // Do not add symbol when reloading all
              // DeDeMainForm.SymbolsList.Add(DeDeSym);
           End
           Else DeDeSym.Free;
      end;
  Finally
    Screen.Cursor:=crDefault;
    FormShow(self);
    ShowMessage(IntToStr(DeDeMainForm.SymbolsPath.Count)+msg_symbols_reloaded);
  end;
end;

procedure TSymbolsForm.UpdateStatuses;
begin
 ViewBtn.Enabled:=ListBox.Items.Count<>0;
 RABtn.Enabled:=ListBox.Items.Count<>0;
 UBtn.Enabled:=ListBox.Items.Count<>0;
end;

procedure TSymbolsForm.Panel1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var s : String;
    i,j,k,sidx,idx : Integer;
    Sym : TDeDeSymbol;
    b : Byte;
begin
  If True
    Then If InputQuery('Search Export','Export Name:',s) Then
        For j:=Det.ItemIndex+1 To Det.Items.Count-1 Do
          If Pos(s,Det.Items[j])<>0 Then
            Begin
              sidx:=j;
              ShowMessage(Det.Items[sidx]);
              Det.ItemIndex:=sidx;
{              For k:=0 To ListBox.Items.Count-1 Do
              If ListBox.Selected[k] Then
                Begin
                  idx:=k;
                  break;
                End;

              If Not ListBox.Selected[idx] Then Exit;
              Sym:=TDeDeSymbol(SymbolsList[idx]);

              Sym.Sym.Seek(sidx*_PatternSize,soFromBeginning);
              s:='';
              For i:=1 To _PatternSize Do
               Begin
                Sym.Sym.ReadBuffer(b,1);
                s:=s+Byte2Hex(b);
               End;
               ShowMessage(s); }
              Break;
            End;
end;

end.
