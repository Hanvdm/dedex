unit DOIParsr;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, DeDePParser, DeDePFiles, ComCtrls;

type
  TDOIParsFrm = class(TForm)
    Button1: TButton;
    OpenDlg: TOpenDialog;
    PB: TProgressBar;
    ListBox1: TListBox;
    Memo1: TMemo;
    StsLbl: TLabel;
    Button2: TButton;
    OpenDlg1: TOpenDialog;
    Button3: TButton;
    OpenDlg2: TOpenDialog;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
    Procedure OnNewBlockProc(beg, en : Integer; p : TPredicate;  reserved:Integer);
    Procedure OnProgressProc(Max,Pos : Longint);
    Procedure ClearData;
  public
    { Public declarations }
    PASFileList,
    IdentList, NameList, DefinitionList, BlahList, UsesList : TStringList;
    PasFileText, FsUses : String;
    ClassParser : TClassParser;
    DefsArray : Array of TStringList;
    iClassesCount : Integer;
    procedure UpdateUsesList;
  end;

var
  DOIParsFrm: TDOIParsFrm;

implementation

{$R *.DFM}

uses Registry, DedePProject, DeDePAnalizer, inifiles;

Procedure TDOIParsFrm.OnNewBlockProc(beg, en : Integer; p : TPredicate; reserved:Integer);
var s, ss, sClassName : String;
    TmpList : TStringList;
Begin
  If (beg*en=0) Then
    Begin
       // New Header
       Exit;
    End;

  // New Pattern
  s:=PASFileText;
  s:=Copy(s,beg,en-beg+1);
  PrepareDeclaration(s);
  Case p Of
    pNone : ss:='';
    pVar,pConst, pProp,
    pType, pRecord,
    pProc, pFunc, pEvent
        :
            Begin
              BlahList.Add(s+#13#10#13#10);
            End;
    pUses : FsUses:=Copy(s,6,length(s)-7);
    pClass :
            Begin
              if s<>'' then begin
                s:=s+' ';
                While Copy(s,1,1)[1]<#32 do s:=Copy(s,2,Length(s)-1);
                TmpList:=TStringList.Create;
                TmpList.Text:=s;
                BlahList.Add(s+#13#10#13#10);
                
                DefsArray[0].Clear;
                DefsArray[1].Clear;
                DefsArray[2].Clear;
                ClassParser.ParseClass(s,DefsArray,sClassName);
                if (reserved=0) and (sClassName<>'<class parse failed>') then
                  Begin
                    Inc(iClassesCount);
                    ListBox1.Items.AddObject(sClassName, TmpList);
                  End;
              end;
            End;
  End;

End;

procedure TDOIParsFrm.Button1Click(Sender: TObject);
var i, j : Integer;
   s, sClassName, sDOIString : String;
begin
  sDOIString:='';
  If OpenDlg.Execute Then
   Begin
      // Parsing Classes
      StsLbl.Caption:='Parsing Classes ...';
      PB.Max:=OpenDlg.Files.Count-1;
      PB.Position:=0;
      Memo1.Clear;
      ClearData;
      ListBox1.Items.BeginUpdate;
      UsesList.Clear;
      j:=0;
      Try
        For i:=0 to OpenDlg.Files.Count-1 Do
          Begin
            USES_LIST:=USES_LIST+ChangeFileExt(ExtractFileName(OpenDlg.Files[i]),'')+',';
            if j mod 5 = 0 then USES_LIST:=USES_LIST+#13#10;
            Inc(j);
            sDOIString:=sDOIString+Format('"%s" ',[ExtractFileName(OpenDlg.Files[i])]);
            PASFileList.LoadFromFile(OpenDlg.Files[i]);
            PASFileText:=PASFileList.Text;
            iClassesCount:=0;
            DeDePParser.InitNewParse(PASFileList,OnNewBlockProc,OpenDlg.Files[i]);
            DeDePParser.ParseIT;
            UpdateUsesList;
            PB.Position:=i;
            PB.Update;
            Application.ProcessMessages;
          End;
          USES_LIST:=Copy(USES_LIST,1,Length(USES_LIST)-1);
          USES_LIST:=USES_LIST+';';
         BlahList.SaveToFile(ExtractFileDir(Application.ExeName)+'\output.txt');
      Finally
        ListBox1.Items.EndUpdate;
      End;

      //Analizing Classes
      StsLbl.Caption:='Analizing '+IntToStr(ListBox1.Items.Count)+' Classes';
      StsLbl.Update;
      PB.Position:=0;
      PB.Max:=ListBox1.Items.Count;
      DeDePProject.InitNewProject;

      For i:=0 to ListBox1.Items.Count-1 Do
        Begin
          PB.Position:=i;
          s:=TStringList(ListBox1.Items.Objects[i]).Text;
          DefsArray[0].Clear;
          DefsArray[1].Clear;
          DefsArray[2].Clear;
          ClassParser.ParseClass(s,DefsArray,sClassName);
          if not DedePProject.StartNewClass(sClassName,s{Inherits Class}) then continue;
          For j:=0 to NameList.Count-1 Do
            Begin
              s:=IdentList[j]+'|'+NameList[j]+'|'+DefinitionList[j];
              DeDePProject.Add(IdentList[j],NameList[j]+DefinitionList[j]);
            End;
          DeDePProject.EndClass;
        End;

      FsUses:=USES_LIST;
      UpdateUsesList;
      USES_LIST:='uses '+UsesList.CommaText+';';
      PrepareToSave(ExtractFileDir(Application.ExeName));
      DeDePProject.EndProject(INIT_DIR+'\_doi_.pas');
      Memo1.Lines.Assign(DeDePProject.CodeList);
      //InputQuery('DOI.VCL.Builder','Units.String',sDOIString);
      PB.Position:=0;
      StsLbl.Caption:='Done';
    End;
end;

procedure TDOIParsFrm.FormCreate(Sender: TObject);
var s : String;
    reg : Tregistry;
begin
  DeDePParser.ProgresProc:=OnProgressProc;
  PASFileList:=TStringList.Create;
  IdentList:=TStringList.Create;
  NameList:=TStringList.Create;
  DefinitionList:=TStringList.Create;
  BlahList:=TStringList.Create;
  UsesList:=TStringList.Create;

  SetLength(DefsArray,3);
  DefsArray[0]:=IdentList;
  DefsArray[1]:=NameList;
  DefsArray[2]:=DefinitionList;

  reg:=TRegistry.Create;
  Try
    reg.RootKey:=HKEY_LOCAL_MACHINE;
    reg.OpenKey('SOFTWARE\Borland\Delphi\4.0',False);
    s:=reg.ReadString('RootDir');
    OpenDlg.InitialDir:=s+'\Source\VCL';
  Finally
    reg.Free;
  End;
end;

procedure TDOIParsFrm.FormDestroy(Sender: TObject);
begin
  PASFileList.Free;
  IdentList.Free;
  NameList.Free;
  DefinitionList.Free;
  BlahList.Free;
  UsesList.Free;
end;

procedure TDOIParsFrm.OnProgressProc(Max, Pos: Integer);
begin
//  PB.Max:=Max;
//  PB.Position:=Pos;
//  PB.Update;
  Application.ProcessMessages;
end;

procedure TDOIParsFrm.ClearData;
var i : Integer;
    Blah : TStringList;
begin
  For i:=ListBox1.Items.Count-1 DownTo 0 Do
    Begin
      Blah:=TStringList(ListBox1.Items.Objects[i]);
      If Blah<>nil then Blah.Free;
      ListBox1.Items.Delete(i);
    End;
end;

procedure TDOIParsFrm.ListBox1Click(Sender: TObject);
var Blah : TStringList;
begin
  Blah:=TStringList(ListBox1.Items.Objects[ListBox1.ItemIndex]);
  Memo1.Lines.Assign(Blah);
end;


procedure TDOIParsFrm.UpdateUsesList;
var TmpList : TStringList;
    i : Integer;
begin
  TmpList:=TStringList.Create;
  Try
    TmpList.CommaText:=FsUses;
    For i:=0 to TmpList.Count-1 Do
      if UsesList.IndexOf(TmpList[i])=-1 then UsesList.Add(TmpList[i]);
  Finally
    TmpList.Free;
  End;
end;

procedure TDOIParsFrm.Button2Click(Sender: TObject);
begin
  If OpenDlg1.Execute Then
   Begin
      InitNewAnalize(OpenDlg1.FileNAme);
      StsLbl.Caption:='Analizing ....';
      StsLbl.Update;
      Screen.Cursor:=crHourGlass;
      try
        Analize;
      finally
        DaData.SaveToFile(ChangeFileExt(OpenDlg1.FileNAme,'.ini'));
        StsLbl.Caption:='Done';
        Screen.Cursor:=crDefault;
      end;
   End;
end;

procedure TDOIParsFrm.Button3Click(Sender: TObject);
const  sTPERSISTENT = 'TObject';
var inif, inif2 : TIniFile;
    slClassesNames, slTmp : TStringList;
    i, k : Integer;
    ss : String;


    function GetInheritsValue(sClassName : String) : String;
    begin
      Result:=inif.ReadString(sClassName,'Inherits','TObject');
    end;

    function GetInhertanceTree(sInherits : String) : String;
    var j : Integer;
        s : String;
    begin
      Result:='TObject';
      for j:=0 to slClassesNames.Count-1 do
        if slClassesNames[j]=sInherits then
          begin
            s:=GetInheritsValue(slClassesNames[j]);
            if s='TObject' then Result:=s
                           else Result:=s+','+GetInhertanceTree(s);
          end;
    end;

begin

  If OpenDlg2.Execute Then
   Begin
     inif:=TIniFile.Create(OpenDlg2.FileName);
     inif2:=TIniFile.Create(changefileext(OpenDlg2.FileName,'.out'));
     slClassesNames:=TStringList.Create;
     slTmp:=TStringList.Create;
     try
       inif.ReadSections(slClassesNames);
       For i:=0 to slClassesNames.Count-1 do
         begin
           ss:=GetInheritsValue(slClassesNames[i]);
           ss:=ss+','+GetInhertanceTree(ss);
           slTmp.CommaText:=ss;
           inif2.WriteInteger(slClassesNames[i],'Inherits',slTmp.Count);
           For k:=0 to slTmp.Count-1 Do
             begin
              inif2.WriteString(slClassesNames[i],'Class_'+IntToStr(k),slTmp[k]);
             end;
           inif.ReadSection(slClassesNames[i],slTmp);
           For k:=1 to slTmp.Count-1 Do
              inif2.WriteString(slClassesNames[i],slTmp[k],inif.ReadString(slClassesNames[i],slTmp[k],'0'));
         end;
     finally
       inif.Free;
       inif2.Free;
       slClassesNames.Free;
       slTmp.Free;
     end;
   End;
end;

end.


