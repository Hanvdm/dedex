unit DOIBUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Mask, ExtCtrls, DeDeOffsInf, ComCtrls, Menus, rxToolEdit;

type
  TDOIBForm = class(TForm)
    Panel1: TPanel;
    GroupBox1: TGroupBox;
    FileEdit: TFilenameEdit;
    Button3: TButton;
    Button5: TButton;
    Panel2: TPanel;
    Button4: TButton;
    Button1: TButton;
    Button2: TButton;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Bevel1: TBevel;
    Panel6: TPanel;
    Label1: TLabel;
    Panel7: TPanel;
    HLB: TListBox;
    Panel8: TPanel;
    Label3: TLabel;
    Panel9: TPanel;
    ClassesLB: TListBox;
    Panel10: TPanel;
    Label2: TLabel;
    StsBar: TStatusBar;
    OffsLV: TListBox;
    PopupMenu1: TPopupMenu;
    Remove1: TMenuItem;
    Button6: TButton;
    Button7: TButton;
    OpenDlg: TOpenDialog;
    SaveDlg: TSaveDialog;
    PopupMenu2: TPopupMenu;
    RemoveRecord1: TMenuItem;
    NewRecord1: TMenuItem;
    AddClass1: TMenuItem;
    p: TPanel;
    procedure Button4Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure ClassesLBClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Remove1Click(Sender: TObject);
    procedure FileEditBeforeDialog(Sender: TObject; var Name: String;
      var Action: Boolean);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure NewRecord1Click(Sender: TObject);
    procedure RemoveRecord1Click(Sender: TObject);
    procedure OffsLVDblClick(Sender: TObject);
    procedure AddClass1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure pMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
    FbModified : Boolean;
    procedure SetModified(bModified : Boolean);
  public
    { Public declarations }
    OffsInfArchive : TOffsInfArchive;
    bParser : Boolean;
    Procedure ShowData;
  end;

var
  DOIBForm: TDOIBForm;

implementation

uses HexTools, DOIAddDtaUnit, Shellapi, DOIParsr;

{$R *.DFM}

procedure TDOIBForm.Button4Click(Sender: TObject);
var Lst : TList;
    i, j : Integer;
    s : String;
    OffsInf : TOffsInfStruct;
    sr : TSearchRec;
begin
  OpenDlg.Title:='Select a set of INI files to add ...';
  If OpenDlg.Execute Then
    Begin
     Lst:=TList.Create;
     Try
       For j:=0 To OpenDlg.Files.Count-1 Do
         begin
           s:=OpenDlg.Files[j];
           FindFirst(s, faAnyFile, sr);
           if (sr.Size>16000) and ((GetVersion and $F0000000)<>0)
              then Raise Exception.Create('File '+s+' is too big for Win9x :))');
           FindClose(sr);
           Lst.Clear;
           OffsInfArchive.LoadOffsInfsFromIniFile(s,Lst);
           For i:=0 to Lst.Count-1 Do
              Begin
                OffsInf:=TOffsInfStruct(Lst[i]);
                If OffsInfArchive.NamesList.IndexOf(OffsInf.FsClassName)<>-1 then
                   begin
                     MessageDlg(Format('Class named %s already exist and will not be added!',[OffsInf.FsClassName]),mtError,[mbOk],0);
                     OffsInf.Free;
                     Continue;
                   end;

                OffsInfArchive.AddOffsInfo(OffsInf);
              End;
          end;
       Finally
         Lst.Free;
       End;


        SetModified(True);
        If MessageDlg('Save changes to .DOI file?',mtConfirmation,[mbYes,mbNo],0)=mrYes
          then begin
            OffsInfArchive.Save(FileEdit.FileName);
            SetModified(False);
          end;
    End;       

end;

procedure TDOIBForm.FormCreate(Sender: TObject);
begin
  OffsInfArchive:=TOffsInfArchive.Create;
end;

procedure TDOIBForm.FormDestroy(Sender: TObject);
begin
  OffsInfArchive.free;
end;

procedure TDOIBForm.Button3Click(Sender: TObject);
begin
  If Not FileExists(FileEdit.FileNAme) Then Exit;

  Screen.Cursor:=crHourGlass;
  Try
    OffsInfArchive.Extract(FileEdit.FileName, False);
  Finally
    Screen.Cursor:=crDefault;
    ShowData;
    SetModified(False);
    ShowMessageFmt('Offset Information for %d classes loaded',[ClassesLB.Items.Count]);
  End;
end;

procedure TDOIBForm.Button5Click(Sender: TObject);
begin
  //If Not FileExists(FileEdit.FileNAme) Then Exit;

  OffsInfArchive.Save(FileEdit.FileName);
  SetModified(False);
end;

procedure TDOIBForm.ShowData;
var i : Integer;
begin
  OffsLV.Clear;
  HLB.Clear;
  
  ClassesLB.Items.BeginUpdate;
  Try
    ClassesLB.Items.Clear;
    for i:=0 to OffsInfArchive.NamesList.Count-1 Do
        ClassesLB.Items.Add(OffsInfArchive.NamesList[i]);
  Finally
    ClassesLB.Items.EndUpdate;
  End;
end;

procedure TDOIBForm.ClassesLBClick(Sender: TObject);
var i, idx, iMaxlen : Integer;
    OffsInf : TOffsInfStruct;
    s : String;
begin
  idx:= ClassesLB.Itemindex;
  if idx=-1 then exit;

  OffsInf:=OffsInfArchive.GetOffsInfoByClassName(ClassesLB.Items[idx]);
  //OffsInf:=TOffsInfStruct(OffsInfArchive.OffsInfList[idx]);
  OffsLV.Items.BeginUpdate;
  Screen.Cursor:=crHourGlass;
  Try
    OffsLV.Items.Clear;
    HLB.Items.Clear;

    for i:=0 to OffsInf.FHierarchyList.Count-1 Do
        HLB.Items.Add(OffsInf.FHierarchyList[i]);

    iMaxlen:=50;
    for i:=0 to OffsInf.FNameList.Count-1 Do
       if iMaxlen<Length(OffsInf.FNameList[i])
          then iMaxlen:=Length(OffsInf.FNameList[i]);
    for i:=0 to OffsInf.FNameList.Count-1 Do
       begin
          s:=OffsInf.FNameList[i];
          While Length(s)<iMaxLen+2 do s:=s+' ';
          s:=s+IntToHex(DWORD(OffsInf.FOffsetList[i]),8);
          If OffsLV.Items.IndexOf(s)=-1 then OffsLV.Items.Add(s);
       end;
  Finally
    OffsLV.Items.EndUpdate;
    Screen.Cursor:=crDefault;
  End;
end;

procedure TDOIBForm.Button1Click(Sender: TObject);
begin
  Close;
end;

procedure TDOIBForm.Button2Click(Sender: TObject);
var Str : TStringList;
    i,j : Integer;
    OffsInf : TOffsInfStruct;
    s : String;
    dw : DWORD;
begin
  Str:=TStringList.Create;
  try
   For i:=0 to OffsInfArchive.classes_count-1 Do
     begin
       OffsInf:=TOffsInfStruct(OffsInfArchive.OffsInfList[i]);
       Str.Add('['+OffsInf.FsClassName+']');
       Str.Add('');
       Str.Add('Inherits='+IntToStr(OffsInf.FHierarchyList.Count));
       For j:=0 to OffsInf.FHierarchyList.Count-1 Do
           Str.Add(Format('Class_%d=%s',[j,OffsInf.FHierarchyList[j]]));
       For j:=0 to OffsInf.FNameList.Count-1 Do
          begin
           s:=Format('%x',[DWORD(OffsInf.FOffsetList[j])]);
           if Length(s)=8 then s:='-'+Format('%x',[(not DWORD(OffsInf.FOffsetList[j]))]);
           Str.Add(Format('%s=%s',[OffsInf.FNameList[j],s]));
          end;
       Str.Add('');
     end;

     s:=ExtractFileDir(Application.ExeName)+'\temp.ini';
     Str.SaveToFile(s);
     ShellExecute(0,PChar('open'),PChar(s),nil,PChar(ExtractFileDir(Application.ExeName)+'\DSF'),1);
     Sleep(1000);
     DeleteFile(s);
  finally
    Str.Free;
  end;
end;

procedure TDOIBForm.Remove1Click(Sender: TObject);
begin
  If MessageDlg('Remove Class?',mtConfirmation,[mbYes,mbNo],0)=mrNo then exit;
  OffsInfArchive.RemoveOffsInfo(ClassesLB.Items[ClassesLB.ItemIndex]);
  SetModified(True);
  ShowData;
end;

procedure TDOIBForm.FileEditBeforeDialog(Sender: TObject; var Name: String;
  var Action: Boolean);
begin
  FileEdit.InitialDir:=ExtractFileDir(Application.ExeName)+'\DSF';
end;

procedure TDOIBForm.Button6Click(Sender: TObject);
var sClass, sDescr, s : String;
    dwOffs : DWORD;
    i,j : Integer;
    OffsInf, inst : TOffsInfStruct;
begin
  DOIAddDataForm.ShowModal;

  if DOIAddDataForm.ModalResult=mrOk then
    begin
      sClass:=DOIAddDataForm.ClassEdit.Text;
      sDescr:=DOIAddDataForm.DescrEdit.Text;
      dwOffs:=HEX2DWORD(DOIAddDataForm.OffsEdit.Text);
      if (sClass='') or (sDescr='') then raise exception.create('Class name or description missing ..');
      OffsInf:=OffsInfArchive.GetOffsInfoByClassName(sClass);
      if OffsInf<>nil then
        begin
        // Existing Class
          i:=OffsInf.FOffsetList.IndexOf(Pointer(dwOffs));
          j:=OffsInf.FNameList.IndexOf(sDescr);
          if (i<>-1) then Raise Exception.Create('Offset already exists!');

          if j<>-1 then
            Case MessageDlg(Format('"%s" is already assigned to offset %x.'#13+
                                   'Do you want to reassign the new offset for the same name?'#13
                                   ,[dwOffs,OffsInf.FNameList[i]]),
               mtWarning,[mbYes,mbNo,mbCancel],0) of
             mrCancel : Exit;
             mrYes    : OffsInf.FOffsetList[j]:=Pointer(dwOffs);
            end {case}
            else begin
              //new name/offset
              OffsInf.FNameList.Add(sDescr);
              OffsInf.FOffsetList.Add(Pointer(dwOffs));
            end;
        end
        else begin
          // NewClass
          If MessageDlg('Add new class "'+sClass+'" ?',mtConfirmation,[mbYes,mbNo],0)=mrNo then Exit;
          OffsInf:=TOffsInfStruct.Create;
          OffsInf.FsClassName:=sClass;
          if not InputQuery('New Class Inherits:','Comma delimited names:',s) then
              begin
                OffsInf.Free;
                exit;
              end;
          if s='' then s:='TObject';    
          OffsInf.FHierarchyList.CommaText:=s;
          OffsInf.FNameList.Add(sDescr);
          OffsInf.FOffsetList.Add(Pointer(dwOffs));
          OffsInfArchive.AddOffsInfo(OffsInf);
        end;
        SetModified(True);
        If MessageDlg('Save changes to .DOI file?',mtConfirmation,[mbYes,mbNo],0)=mrYes
           then begin
             OffsInfArchive.Save(FileEdit.FileName);
             SetModified(False);
           end;
        ShowData;
    end;
end;

procedure TDOIBForm.Button7Click(Sender: TObject);
var i,j  : Integer;
    arch : TOffsInfArchive;
    lst : TList;
    OffsInf : TOffsInfStruct;
    sr : TSearchRec;
begin
  OpenDlg.Title:='Select a set of INI files for the new DOI ...';
  If OpenDlg.Execute Then
   Begin
     If Not SaveDlg.Execute then exit;

     Arch:=TOffsInfArchive.Create;
     lst:=TList.Create;
     Screen.Cursor:=crHourGlass;
     Try
       For i:=0 to OpenDlg.Files.Count-1 Do
          Begin
             FindFirst(OpenDlg.Files[i], faAnyFile, sr);
             // 16K limit
             if (sr.Size>16000) and ((GetVersion and $F0000000)<>0)
                then Raise Exception.Create('File '+OpenDlg.Files[i]+' is too big for Win9x :))');
             FindClose(sr);
             Arch.LoadOffsInfsFromIniFile(OpenDlg.Files[i],lst);
             For j:=0 to Lst.Count-1 Do
               Begin
                OffsInf:=TOffsInfStruct(Lst[i]);

                If OffsInfArchive.NamesList.IndexOf(OffsInf.FsClassName)<>-1 then
                   begin
                     MessageDlg(Format('Class named %s already exist and will not be added!',[OffsInf.FsClassName]),mtError,[mbOk],0);
                     OffsInf.Free;
                     Continue;
                   end;

                Arch.AddOffsInfo(OffsInf);
               End;
         End;


       Arch.Save(SaveDlg.FileName);
     Finally
       Arch.Free;
       lst.Free;
       Screen.Cursor:=crDefault;
     End;

     If MessageDlg('Do you want to load the new .doi file now',
        mtConfirmation,[mbYes,mbNo],0)=mrNo then Exit;

     FileEdit.FileName:=SaveDlg.FileName;
     Button3Click(self);
   End;
end;

procedure TDOIBForm.NewRecord1Click(Sender: TObject);
begin
  DOIAddDataForm.ClassEdit.Text:=ClassesLB.Items[ClassesLB.ItemIndex];
  DOIAddDataForm.DescrEdit.Text:='';
  DOIAddDataForm.OffsEdit.Text:='';
  Button6Click(self);
end;

procedure TDOIBForm.RemoveRecord1Click(Sender: TObject);
var s : String;
begin
  s:=Copy(OffsLv.Items[OffsLV.ItemIndex],1,49);
  s:=Trim(s);
  If MessageDlg('Remove "'+s+'"?',mtConfirmation,[mbYes,mbNo],0)=mrNo then Exit;
  OffsInfArchive.DeleteRecord(ClassesLB.Items[ClassesLB.ItemIndex],s);
  ClassesLBClick(self);
  SetModified(True);
end;

procedure TDOIBForm.SetModified(bModified: Boolean);
var s : String;
begin
  FbModified:=bModified;
  if bModified then s:='Modified'
               else s:='';
  StsBar.Panels[0].Text:=s;
end;

procedure TDOIBForm.OffsLVDblClick(Sender: TObject);
var s, s1 : String;
    OffsInf : TOffsInfStruct;
    i : Integer;
begin
  s:=Copy(OffsLv.Items[OffsLV.ItemIndex],1,49);
  s1:=Copy(OffsLv.Items[OffsLV.ItemIndex],49,10);
  s:=Trim(s);s1:=Trim(s1);
  If not InputQuery('Modify record of class: '+ClassesLB.Items[ClassesLB.ItemIndex],
                    'Enter new offset for: '+s,
                    s1) then exit;

  OffsInf:=OffsInfArchive.GetOffsInfoByClassName(ClassesLB.Items[ClassesLB.ItemIndex]);
  i:=OffsInf.FNameList.IndexOf(s);
  if i=-1 then exit;
  OffsInf.FOffsetList[i]:=Pointer(HEX2DWORD(s1));
  ClassesLBClick(self);
  SetModified(True);
end;

procedure TDOIBForm.AddClass1Click(Sender: TObject);
begin
  DOIAddDataForm.ClassEdit.Text:='';
  DOIAddDataForm.DescrEdit.Text:='';
  DOIAddDataForm.OffsEdit.Text:='';
  Button6Click(self);
end;

procedure TDOIBForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 If FbModified Then
   If MessageDlg('Save changes to '+FileEdit.FileName+' before close?',mtConfirmation,[mbYes,mbNo],0)=mrYes
     then OffsInfArchive.Save(FileEdit.FileName);
end;

procedure TDOIBForm.pMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if ((ssShift in Shift) and (ssAlt in Shift) and (ssCtrl in Shift))
    and (bParser)
    then DOIParsFrm.ShowModal;
end;

end.
