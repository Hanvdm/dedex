unit ShowPEUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, StdCtrls, ExtCtrls, Buttons, Grids, DeDeClasses;

type
  TPEIForm = class(TForm)
    PETab: TPageControl;
    PEPage: TTabSheet;
    Label21: TLabel;
    Label23: TLabel;
    Label25: TLabel;
    Label27: TLabel;
    Label29: TLabel;
    Label31: TLabel;
    Label33: TLabel;
    Label35: TLabel;
    Label37: TLabel;
    l1: TLabel;
    l2: TLabel;
    Label22: TLabel;
    Label12: TLabel;
    Label63: TLabel;
    Label65: TLabel;
    Bevel9: TBevel;
    Bevel10: TBevel;
    Label64: TLabel;
    Label66: TLabel;
    Label68: TLabel;
    Bevel11: TBevel;
    Bevel12: TBevel;
    Label67: TLabel;
    Label39: TLabel;
    Label43: TLabel;
    Label47: TLabel;
    Label40: TLabel;
    Bevel13: TBevel;
    Bevel14: TBevel;
    Bevel15: TBevel;
    SMDBtn: TButton;
    ObjectsSheet: TTabSheet;
    Label1: TLabel;
    SectionDataLbl: TLabel;
    Label2: TLabel;
    Label4: TLabel;
    Label13: TLabel;
    Label15: TLabel;
    Label17: TLabel;
    Label19: TLabel;
    SesDescriptionLbl: TLabel;
    Label71: TLabel;
    Label73: TLabel;
    SesIDLbl: TLabel;
    ObjectSGrid: TStringGrid;
    RVAEdit: TEdit;
    SectionNameCombo: TComboBox;
    PhysOffsetEdit: TEdit;
    PhysSizeEdit: TEdit;
    VirtSizeEdit: TEdit;
    FlagsEdit: TEdit;
    Button1: TButton;
    Button9: TButton;
    Button10: TButton;
    TabSheet7: TTabSheet;
    Label24: TLabel;
    ExpTlbRVALbl: TLabel;
    Label28: TLabel;
    TExpSizeLbl: TLabel;
    ExpPhOffsetLbl: TLabel;
    Label11: TLabel;
    Label9: TLabel;
    Exp1Lbl: TLabel;
    Label14: TLabel;
    Exp2Lbl: TLabel;
    Label16: TLabel;
    Exp3Lbl: TLabel;
    Label18: TLabel;
    Exp4Lbl: TLabel;
    Label20: TLabel;
    Exp5Lbl: TLabel;
    Label70: TLabel;
    Exp6Lbl: TLabel;
    Label72: TLabel;
    Exp7Lbl: TLabel;
    Label74: TLabel;
    Exp8Lbl: TLabel;
    Label76: TLabel;
    Exp9Lbl: TLabel;
    Bevel16: TBevel;
    Bevel17: TBevel;
    Bevel18: TBevel;
    Bevel19: TBevel;
    Bevel20: TBevel;
    Button8: TButton;
    ExportLV: TListView;
    TabSheet8: TTabSheet;
    Label26: TLabel;
    Label30: TLabel;
    TImpSizeLbl: TLabel;
    ImpTlbRVALbl: TLabel;
    PhysImLbl: TLabel;
    Label52: TLabel;
    Label51: TLabel;
    Label53: TLabel;
    DLLNumLbl: TLabel;
    ProcNumLbl: TLabel;
    Button6: TButton;
    DLLMemo: TListBox;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    ImportList: TListView;
    TabSheet2: TTabSheet;
    ImportTree: TTreeView;
    TabSheet3: TTabSheet;
    Bevel2: TBevel;
    Bevel3: TBevel;
    Bevel1: TBevel;
    Bevel8: TBevel;
    Bevel5: TBevel;
    Bevel6: TBevel;
    Bevel4: TBevel;
    Bevel7: TBevel;
    Label59: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label10: TLabel;
    Label8: TLabel;
    Label60: TLabel;
    Label62: TLabel;
    PEHdrOffsetLbl: TLabel;
    SignLbl: TLabel;
    CPULbl: TLabel;
    ONumLbl: TLabel;
    NTHDRLbl: TLabel;
    TSLbl: TLabel;
    SymTblOffsetLbl: TLabel;
    SymNumLbl: TLabel;
    O100: TCheckBox;
    O200: TCheckBox;
    O400: TCheckBox;
    O8000: TCheckBox;
    O4000: TCheckBox;
    O2000: TCheckBox;
    O1000: TCheckBox;
    O40: TCheckBox;
    O80: TCheckBox;
    O20: TCheckBox;
    O10: TCheckBox;
    O8: TCheckBox;
    O4: TCheckBox;
    O2: TCheckBox;
    O1: TCheckBox;
    PETypeLbl: TLabel;
    LinkerLbl: TLabel;
    ImBaseLbl: TLabel;
    ImSizeLbl: TLabel;
    OalignLbl: TLabel;
    FAlignLbl: TLabel;
    OSVerLbl: TLabel;
    UserVerLbl: TLabel;
    SubVerLbl: TLabel;
    LFLbl: TLabel;
    SizeOfCodeLbl: TLabel;
    SizeOfIDataLbl: TLabel;
    SizeOfUDataLbl: TLabel;
    StackRSzLbl: TLabel;
    StackCSzLbl: TLabel;
    HeapRSzLbl: TLabel;
    HeapCSzLbl: TLabel;
    VASizeLbl: TLabel;
    FChkLbl: TLabel;
    HeadSizeLbl: TLabel;
    ExcSizeLbl: TLabel;
    ExcRVALbl: TLabel;
    SecSizeLbl: TLabel;
    SecRVALbl: TLabel;
    MachSzLbl: TLabel;
    MachSpLbl: TLabel;
    DescrSizeLbl: TLabel;
    ImDescrLbl: TLabel;
    RVAELbl: TLabel;
    BOCLbl: TLabel;
    BODLbl: TLabel;
    SubsysLbl: TLabel;
    DllFlagsLbl: TLabel;
    Button2: TButton;
    DirectorySheet: TTabSheet;
    Button3: TButton;
    Button4: TButton;
    DirectoryGroup: TGroupBox;
    DirectoryPanel: TPanel;
    Label32: TLabel;
    Label34: TLabel;
    Label3: TLabel;
    Label41: TLabel;
    Label42: TLabel;
    Label44: TLabel;
    Label45: TLabel;
    Label46: TLabel;
    Label48: TLabel;
    Label57: TLabel;
    Label56: TLabel;
    Label55: TLabel;
    Label54: TLabel;
    Label50: TLabel;
    Label49: TLabel;
    Label36: TLabel;
    Label38: TLabel;
    Edit2: TEdit;
    Edit1: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit6: TEdit;
    Edit5: TEdit;
    Edit7: TEdit;
    Edit8: TEdit;
    Edit10: TEdit;
    Edit9: TEdit;
    Edit13: TEdit;
    Edit11: TEdit;
    Edit12: TEdit;
    Edit14: TEdit;
    Edit25: TEdit;
    Edit26: TEdit;
    Edit24: TEdit;
    Edit23: TEdit;
    Edit21: TEdit;
    Edit22: TEdit;
    Edit20: TEdit;
    Edit19: TEdit;
    Edit17: TEdit;
    Edit18: TEdit;
    Edit16: TEdit;
    Edit15: TEdit;
    Label58: TLabel;
    Edit28: TEdit;
    Edit27: TEdit;
    Label61: TLabel;
    Edit30: TEdit;
    Edit29: TEdit;
    SaveDlg: TSaveDialog;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ObjectSGridSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure Button6Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure O1Click(Sender: TObject);
    procedure O2Click(Sender: TObject);
    procedure O4Click(Sender: TObject);
    procedure O8Click(Sender: TObject);
    procedure O10Click(Sender: TObject);
    procedure O20Click(Sender: TObject);
    procedure O80Click(Sender: TObject);
    procedure O40Click(Sender: TObject);
    procedure O1000Click(Sender: TObject);
    procedure O2000Click(Sender: TObject);
    procedure O4000Click(Sender: TObject);
    procedure O8000Click(Sender: TObject);
    procedure O100Click(Sender: TObject);
    procedure O200Click(Sender: TObject);
    procedure O400Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FlagsEditKeyPress(Sender: TObject; var Key: Char);
    procedure Button4Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure ObjectSGridMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
  private
    { Private declarations }
    _bHint : Boolean;
    _shint : String;
    OldRow : Integer;
    procedure InitLabels;
    procedure LoadSectionInformationForEditing(ARow: Integer);
    procedure SetOEnable(Enable : Boolean);
    procedure SaveOldRowChanges;
    procedure LoadDirectoryInfo;
  public
    { Public declarations }
    PEResDir : TPEResDir;
    PEFixupTable : TPEFixupTable;
    PEImportData : TPEImportData;
    PETLSTable : TPETLSTable;
    PEExports : TPEExports;
    PEHeader : TPEHeader;
    PEFile : ThePEFile;
    FsFileName : String;
    function PrepareImports : TStringList;
    Procedure ShowPEData;
  end;

var
  PEIForm: TPEIForm;

implementation

uses MainUnit, HEXTools, Clipbrd, SectionEditUnit, DeDeRES;

{$R *.DFM}

procedure TPEIForm.FormShow(Sender: TObject);
var i : Integer;
    b1,b2 : Byte;
begin
  PEFile.Seek(DATA_FOR_PE_HEADER_OFFSET);
  PEFile.Read(b1,b2);
  PEHdrOffsetLbl.Caption:=WORD2HEX(b1+b2*256);

   With PEHeader Do
    Begin
     {OPTIONAL PE HEADER}
     PETypeLbl.Caption:=OptionalPEType;
     LinkerLbl.Caption:=LMAJOR_MINOR;
     SizeOfCodeLbl.Caption:=IntToHex(SizeOfCode,8);
     SizeOfIDataLbl.Caption:=IntToHex(SizeOfInitializedData,8);
     SizeOfUDataLbl.Caption:=IntToHex(SizeOfUninitializedData,8);
     RVAELbl.Caption:=IntToHex(RVA_ENTRYPOINT,8);
     BODLbl.Caption:=IntToHex(BaseOfData,8);
     BOCLbl.Caption:=IntToHex(BaseOfCode,8);

     ImBaseLbl.Caption:=IntToHex(IMAGE_BASE,8);
     OAlignLbl.Caption:=IntToHex(OBJECT_ALIGN,8);
     FAlignLbl.Caption:=IntToHex(FILE_ALIGN,8);
     OSVerLbl.Caption:=IntToHex(OSMAJOR_MINOR,8);
     UserVerLbl.Caption:=IntToHex(USERMAJOR_MINOR,8);
     SubVerLbl.Caption:=IntToHex(SUBSYSMAJOR_MINOR,8);
     ImSizeLbl.Caption:=IntToHex(IMAGE_SIZE,8);
     HeadSizeLbl.Caption:=IntToHex(HEADER_SIZE,8);
     FChkLbl.Caption:=IntToHex(FILE_CHECKSUM,8);
     SubsysLbl.Caption:=SUBSYSTEM;
     DLLFlagsLbl.Caption:=DLL_FLAGS;
     StackRSzLbl.Caption:=IntToHex(STACK_RESERVE_SIZE,8);
     StackCSzLbl.Caption:=IntToHex(STACK_COMMIT_SIZE,8);
     HeapRSzLbl.Caption:=IntToHex(HEAP_RESERVE_SIZE,8);
     HeapCSzLbl.Caption:=IntToHex(HEAP_COMMIT_SIZE,8);
     LFLbl.Caption:=IntToHex(LoaderFlags,8);
     VASizeLbl.Caption:=IntToHex(VA_ARRAY_SIZE,8);
     ImDescrLbl.Caption:=IntToHex(IMAGE_DESCRIPTION_RVA,8);
     DescrSizeLbl.Caption:=IntToHex(TOTAL_DESCRIPTION_SIZE,8);
     MachSpLbl.Caption:=IntToHex(MACHINE_SPECIFIC_RVA,8);
     MachSzLbl.Caption:=IntToHex(MACHINE_SPECIFIC_SIZE,8);

     ExpTlbRVALbl.Caption:=IntToHex(EXPORT_TABLE_RVA,8);
     TExpSizeLbl.Caption:=IntToHex(TOTAL_EXPORT_DATA_SIZE,8);
     ImpTlbRVALbl.Caption:=IntToHex(IMPORT_TABLE_RVA,8);
     TImpSizeLbl.Caption:=IntToHex(TOTAL_IMPORT_DATA_SIZE,8);
     ExcRVALbl.Caption:=IntToHex(EXCEPTION_TABLE_RVA,8);
     ExcSizeLbl.Caption:=IntToHex(TOTAL_EXCEPTION_DATA_SIZE,8);
     SecRVALbl.Caption:=IntToHex(SECURITY_TABLE_RVA,8);
     SecSizeLbl.Caption:=IntToHex(TOTAL_SECURITY_DATA_SIZE,8);
     If (Load_Config_Table_RVA+Bound_Import_RVA+IAT_RVA
       +Delay_Import_Descriptor_RVA+COM_Runtime_Header_RVA)<>0
       Then SMDBtn.Enabled:=True
       Else SMDBtn.Enabled:=False;

    LoadDirectoryInfo;
   end;

  ObjectSGrid.RowCount:=1+PEHeader.ObjectNum;
  ObjectSGrid.FixedRows:=1;
  {OBJECT TABLE}
  For i:=1 To PEHeader.ObjectNum Do
   With ObjectSGrid Do
     Begin
       Cells[0,i]:='';Cells[1,i]:='';Cells[2,i]:='';Cells[3,i]:='';Cells[4,i]:='';Cells[5,i]:='';
       Cells[6,i]:='';Cells[7,i]:='';Cells[8,i]:='';Cells[9,i]:='';
     End;

  For i:=1 To PEHeader.ObjectNum Do
   With ObjectSGrid Do
     Begin
       {name}Cells[0,i]:=PEHeader.Objects[i].OBJECT_NAME;
       {RVA} Cells[1,i]:=DWord2Hex(PEHeader.Objects[i].RVA);
       {ofs} Cells[2,i]:=DWord2Hex(PEHeader.Objects[i].PHYSICAL_OFFSET);
       {size}Cells[3,i]:=DWord2Hex(PEHeader.Objects[i].PHYSICAL_SIZE);
       {v.sz}Cells[4,i]:=DWord2Hex(PEHeader.Objects[i].VIRTUAL_SIZE);
       {flgs}Cells[5,i]:=DWord2Hex(PEHeader.Objects[i].FLAGS);
       Cells[6,i]:=DWord2Hex(PEHeader.Objects[i].PointerToRelocations);
       Cells[7,i]:=DWord2Hex(PEHeader.Objects[i].PointerToLinenumbers);
       Cells[8,i]:=Word2Hex(PEHeader.Objects[i].NumberOfRelocations);
       Cells[9,i]:=Word2Hex(PEHeader.Objects[i].NumberOfLinenumbers);
     End;

   ShowPEData;
  {#end of visuzlization}

end;

procedure TPEIForm.FormCreate(Sender: TObject);
begin
  With ObjectSGrid Do
    Begin
      Cells[0,0]:='object name';
      Cells[1,0]:='RVA';
      Cells[2,0]:='physical offset';
      Cells[3,0]:='physical size';
      Cells[4,0]:='virtual size';
      Cells[5,0]:='flags';
      Cells[6,0]:='PtrToRelocs';
      Cells[7,0]:='PtrToLinenums';
      Cells[8,0]:='NumOfRelocs';
      Cells[9,0]:='NumOfLinenums';
    End;

   InitLabels;
   OldRow:=-1;
end;

procedure TPEIForm.InitLabels;
begin
  //
  ExpPhOffsetLbl.Caption:='';
  Exp1Lbl.Caption:='';
  Exp2Lbl.Caption:='';
  Exp3Lbl.Caption:='';
  Exp4Lbl.Caption:='';
  Exp5Lbl.Caption:='';
  Exp6Lbl.Caption:='';
  Exp7Lbl.Caption:='';
  Exp8Lbl.Caption:='';
  Exp9Lbl.Caption:='';
  ExportLV.Items.Clear;
  PhysImLbl.Caption:='';
  DLLNumLbl.Caption:='';
  ProcNumLbl.Caption:='';
  DLLMemo.Clear;
  ImportList.Items.Clear;
  ImportTree.Items.Clear;
end;

procedure TPEIForm.ShowPEData;
begin
  With PEHeader Do
   Begin
     {PE HEADER}
     SignLbl.Caption:=Signature;
     CPULbl.Caption:=CPU;
     ONumLbl.Caption:=IntToStr(ObjectNum);
     TSLbl.Caption:=IntToHex(TimeStamp,8);
     SymTblOffsetLbl.Caption:=IntToHex(SymTblOffset,8)+'h';
     SymNumLbl.Caption:=IntToStr(SymNum);
     NTHDRLbl.Caption:=Word2Hex(NT_HDR_SIZE)+'h ('+IntToStr(NT_HDR_SIZE)+')';
     SetOEnable(False);
     Try
       O1.Checked:=FLAGS[1];
       O2.Checked:=FLAGS[2];
       O4.Checked:=FLAGS[3];
       O8.Checked:=FLAGS[4];
       O10.Checked:=FLAGS[5];
       O20.Checked:=FLAGS[6];
       O40.Checked:=FLAGS[7];
       O80.Checked:=FLAGS[8];
       O100.Checked:=FLAGS[9];
       O200.Checked:=FLAGS[10];
       O400.Checked:=FLAGS[11];
       O1000.Checked:=FLAGS[13];
       O2000.Checked:=FLAGS[14];
       O4000.Checked:=FLAGS[15];
       O8000.Checked:=FLAGS[16];
     Finally
      SetOEnable(True);
     End;
   End;
end;

procedure TPEIForm.ObjectSGridSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
begin
  If ARow>PEHeader.ObjectNum Then Exit;
  SaveOldRowChanges;
  SectionDataLbl.Caption:=dword2hex(PEHeader.Objects[ARow].InfoAddress);
  LoadSectionInformationForEditing(ARow);
  If ACol<>5 Then Exit;
  If ObjectSGrid.Cells[0,ARow]='' Then Exit;
end;

procedure TPEIForm.LoadSectionInformationForEditing(ARow: Integer);
var s : String;
begin
   SesIDLbl.Caption:=IntToStr(ARow);
   SectionNameCombo.Text:=ObjectSGrid.Cells[0,ARow];
   RVAEdit.Text:=ObjectSGrid.Cells[1,ARow];
   PhysOffsetEdit.Text:=ObjectSGrid.Cells[2,ARow];
   PhysSizeEdit.Text:=ObjectSGrid.Cells[3,ARow];
   VirtSizeEdit.Text:=ObjectSGrid.Cells[4,ARow];
   FlagsEdit.Text:=ObjectSGrid.Cells[5,ARow];

   s:=ObjectSGrid.Cells[0,ARow];
   If (s='CODE') or (s='.text') then s:='Excutable Code';
   If (s='DATA') or (s='.data') then s:='Data';
   If s='.idata' then s:='Imports';
   If s='.edata' then s:='Exports';
   If (s='.rsrc') or (s='.rdata') then s:='Resources';
   If s='.reloc' then s:='Fix-Up Table';
   If s='.tls' then s:='Thread Local Storage';
   If s='.pdata' then s:='Exceptions table';
   If s='.debug' then s:='Debug Information';

   SesDescriptionLbl.Caption:=s;
   OldRow:=ARow;
end;

procedure TPEIForm.Button6Click(Sender: TObject);

   function CompareDLLNames(s1,s2 : String) : Boolean;
   var i, n : Integer;
   begin
     Result:=False;
     n:=Length(s1);
     i:=Length(s2);
     If i<n Then n:=i;
     i:=0;
     Repeat
       Inc(i);
     Until (i=n) or (s1[i]<>s2[i]);
     If s1[i]=s2[i] Then Result:=True;
   end;

var lImpOffset, lImpSize : LongInt;
    i,j,k : Integer;
    TmpList,TTmpList : TStringList;
    inst : TListItem;
    tinst : TTreeNode;
    CurrDLL : String;
begin
With DeDeMainForm Do
 Begin
  i:=PEHeader.GetSectionIndex('.idata');
  If i=-1 Then i:=PEHeader.GetSectionIndexByRVA(PEHeader.IMPORT_TABLE_RVA);
  If i=-1 Then Raise Exception.Create(err_has_no_import);
  
  lImpOffset:=PEHeader.Objects[i].PHYSICAL_OFFSET;
//  lImpSize:=PEHeader.Objects[i].PHYSICAL_SIZE;



  //lImpOffset:=PEHeader.Objects[PEHeader.GetSectionIndex('.idata')].PHYSICAL_OFFSET;
  PhysImLbl.Caption:=DWord2Hex(lImpOffset);
  PEImportData.FileName:=RecentFileEdit.Text;
  TmpList:=TStringList.Create;
  TTmpList:=TStringList.Create;
  Try
    //This routine does everything
    PEImportData.CollectInfo(lImpOffset, PEHeader.Objects[i].RVA, TmpList);

    DLLNumLbl.Caption:=IntToStr(PEImportData.DLLCount);
    ProcNumLbl.Caption:=IntToStr(PEImportData.ProcCount);

    // Processing Data For ImportListView
    DLLMemo.Clear;
    ImportList.Items.Clear;
    For i:=0 To TmpList.Count-1 Do
      Begin
         If Copy(TmpList[i],1,1)<>' ' Then
           Begin
             If DLLMemo.Items.IndexOf(TmpList[i])=-1
               Then DLLMemo.Items.Add(TmpList[i]);
             CurrDLL:=TmpList[i];
           End
           Else Begin
            TTmpList.Clear;
            TTmpList.CommaText:=Copy(TmpList[i],2,Length(TmpList[i])-1);
            inst:=ImportList.Items.Add;
            inst.Caption:=CurrDLL;
            inst.Subitems.Add(TTmpList[0]);
            inst.Subitems.Add(TTmpList[1]);
            inst.Subitems.Add(TTmpList[2]);
          End;
      End;
      ImportList.Update;

      //Processing Data For ImportTreeView
      ImportTree.Items.Clear;
      ImportTree.Update;
      ImportTree.Items.BeginUpdate;
       For i:=0 To DLLMemo.Items.Count-1 Do
         Begin
           // Adds dll name as root node
           tinst:=ImportTree.Items.AddChild(nil,DLLMemo.Items[i]);

           // For j through all imports
           For j:=0 To ImportList.Items.Count-1 Do
             Begin
              k:=0;
              CurrDLL:='';
              Repeat Inc(k);
              Until   (ImportList.Items[j].Caption[k]=' ')
                   or (k=Length(ImportList.Items[j].Caption[k]));

             CurrDLL:=CurrDLL+Copy(ImportList.Items[j].Caption,1,k-2);

             // If DLLName of Current Item in ImportsList is equal to
             // Current DLLName
             If CompareDLLNames(String(ImportList.Items[j].Caption),DLLMemo.Items[i]) Then
                Begin
                  CurrDLL:=ImportList.Items[j].Subitems[0];
                  ImportTree.Items.AddChild(tinst,CurrDLL);
                End; {If CompareDLLNames}
             End; {For j}
         End; {For i}

   Finally
     ImportTree.Items.EndUpdate;
     TmpList.Free;
     TTmpList.Free;
   End;
 End;
end;

procedure TPEIForm.Button8Click(Sender: TObject);
var lExpOffset, lExpSize : LongInt;
    i : Integer;
    s1,s2,s3 : String;
    inst : TListItem;
begin
With DeDeMainForm Do
Begin
  i:=PEHeader.GetSectionIndex('.edata');
  If i=-1 Then Raise Exception.Create(err_has_no_export);
  lExpOffset:=PEHeader.Objects[i].PHYSICAL_OFFSET;
//  lExpSize:=PEHeader.Objects[i].PHYSICAL_SIZE;

  ExpPhOffsetLbl.Caption:=DWORD2Hex(lExpOffset)+'h';
  ExportLV.Items.Clear;

  PEExports.FileName:= RecentFileEdit.Text;
  Try
    // This routine does everything
    PEExports.Process(lExpOffset,PEHeader.Objects[i].RVA);
  Except
    ShowMessage('Error');
  End;
  Exp1Lbl.Caption:=PEExports.DATE_TIME_STAMP;
  Exp2Lbl.Caption:=PEExports.VERSION;
  Exp3Lbl.Caption:=PEExports.Name_RVA;
  Exp4Lbl.Caption:=IntToStr(PEExports.Ordinal_Base);
  Exp5Lbl.Caption:=IntToStr(PEExports.Address_Table_Entries);
  Exp6Lbl.Caption:=IntToStr(PEExports.Number_of_Name_Pointers);
  Exp7Lbl.Caption:=PEExports.Export_Address_Table_RVA;
  Exp8Lbl.Caption:=PEExports.Name_Pointer_RVA;
  Exp9Lbl.Caption:=PEExports.Ordinal_Table_RVA;

  For i:=1 To PEExports.Address_Table_Entries Do
   Begin
      s1:=IntToStr(PEExports.FUNC_DATA[i].Ordinal);
      s2:=PEExports.FUNC_DATA[i].Offset;
      s3:=PEExports.FUNC_DATA[i].Name;
      While Length(s1)<3 Do s1:=' '+s1;
      While Length(s2)<16 Do s2:=s2+' ';
      While Length(s3)<16 Do s3:=s3+' ';
      inst:=ExportLV.Items.Add;
      inst.Caption:=s3;
      inst.Subitems.Add(s1);
      inst.Subitems.Add(s2);
//      ExportsMemo.Lines.Add(Format('%s  Ord: %s RVA: %s ',[s3,s1,s2]));
   End;
End;
end;

procedure TPEIForm.Button1Click(Sender: TObject);
Var ObjectObj : TPEObject;
    ObjID, i : Integer;
    sNewFile : String;
begin
   SaveDlg.InitialDir:=ExtractFileDir(PEFile.sFileName);
   SaveDlg.FileName:=PEFile.sFileName;

   if not SaveDlg.Execute then exit;
//   IF MessageDlg(wrn_change_file,
//      mtConfirmation,[mbYes,mbNo],0)=mrNo Then Exit;

   ObjectSGrid.Cells[1,OldRow]:=RVAEdit.Text;
   ObjectSGrid.Cells[2,OldRow]:=PhysOffsetEdit.Text;
   ObjectSGrid.Cells[3,OldRow]:=PhysSizeEdit.Text;
   ObjectSGrid.Cells[4,OldRow]:=VirtSizeEdit.Text;
   ObjectSGrid.Cells[5,OldRow]:=FlagsEdit.Text;

   For i:=1 to PEHeader.ObjectNum do
     begin
       ObjID:=i;
       ObjectObj.OBJECT_NAME:=ObjectSGrid.Cells[0,i];
       ObjectObj.VIRTUAL_SIZE:=HEX2DWORD(ObjectSGrid.Cells[4,i]);
       ObjectObj.RVA:=HEX2DWORD(ObjectSGrid.Cells[1,i]);
       ObjectObj.PHYSICAL_OFFSET:=HEX2DWORD(ObjectSGrid.Cells[2,i]);
       ObjectObj.PHYSICAL_SIZE:=HEX2DWORD(ObjectSGrid.Cells[3,i]);
       ObjectObj.FLAGS:=HEX2DWORD(ObjectSGrid.Cells[5,i]);
       ObjectObj.PointerToRelocations:=PEHeader.Objects[ObjID].PointerToRelocations;
       ObjectObj.PointerToLinenumbers:=PEHeader.Objects[ObjID].PointerToLinenumbers;
       ObjectObj.NumberOfRelocations:=PEHeader.Objects[ObjID].NumberOfRelocations;
       ObjectObj.NumberOfLinenumbers:=PEHeader.Objects[ObjID].NumberOfLinenumbers;
       ObjectObj.MakeBuffer;
       PEFile.Seek(PEHeader.Objects[i].InfoAddress);
       For ObjID:=1 To 40 Do PEFile.Write(ObjectObj.DATA[ObjID]);
     end;

   Try
     PEFile.PEStream.SaveToFile(SaveDlg.FileName{FsFileName});
     ShowMessage(msg_save_succ);
   Except
     on e: Exception do
         ShowMessage(msg_save_not_succ+#13#10+e.Message);
   End;

   if Not bELF
     then PEHeader.Dump(Self.PEFile)
     else Raise Exception.Create('This is not PE file !');
   ShowPEData;
   FormShow(self);
end;

procedure TPEIForm.Button10Click(Sender: TObject);
var s, sec : String;
    i : Integer;
begin
  sec:='';

  for i:=1 to PEHeader.ObjectNum do
    begin
      s:=GetDelphiVersion(PEFile)+'  ';
      if copy(s,1,1)='D'
        then Case i Of
                0,1 :   sec:='60000020';
                2,5 :   sec:='C0000040';
                3:      sec:='40000040';
                4,7 :   sec:='C0000000';
                6,8,9,10,11 : sec:='50000040';
              End
        else begin
          s:=ObjectSGrid.Cells[0,i];
          if (Pos('text',s)<>0) or (Pos('CODE',s)<>0) then sec:='E000020';
          if (i=1) and (sec='') then s:='E000020';
        end;

      If sec<>'' Then  ObjectSGrid.Cells[5,i]:=sec;
    end;
end;
    
procedure TPEIForm.Button9Click(Sender: TObject);
begin
  FlagsEditForm.FsFlags:=FlagsEdit.Text;
  FlagsEditForm.SetSectionFlags;
  FlagsEditForm.ShowModal;

  FlagsEdit.Text:=FlagsEditForm.FsFlags;
end;

function TPEIForm.PrepareImports: TStringList;
var i : Integer;
    s,s1 : String;
begin
  FormShow(self);
  Try
    Button6Click(Self);
  Except
  End;

  Result:=TStringList.Create;
  For i:=0 To ImportList.Items.Count-1 Do
    Begin
      s:=ImportList.Items[i].Caption;
      If Copy(s,Length(s),1)=#0 Then s:=Copy(s,1,Length(s)-1);
      s1:=ImportList.Items[i].Subitems[0];
      Result.Add(s+'.'+s1);
    End;
end;


procedure TPEIForm.SetOEnable(Enable: Boolean);
begin
 If Enable Then
  Begin
   O1.OnClick:=O1Click;
   O2.OnClick:=O2Click;
   O4.OnClick:=O4Click;
   O8.OnClick:=O8Click;
   O10.OnClick:=O10Click;
   O20.OnClick:=O20Click;
   O40.OnClick:=O40Click;
   O80.OnClick:=O80Click;
   O100.OnClick:=O100Click;
   O200.OnClick:=O200Click;
   O400.OnClick:=O400Click;
   O1000.OnClick:=O1000Click;
   O2000.OnClick:=O2000Click;
   O4000.OnClick:=O4000Click;
   O8000.OnClick:=O8000Click;
  End
  Else Begin
   O1.OnClick:=nil;
   O2.OnClick:=nil;
   O4.OnClick:=nil;
   O8.OnClick:=nil;
   O10.OnClick:=nil;
   O20.OnClick:=nil;
   O40.OnClick:=nil;
   O80.OnClick:=nil;
   O100.OnClick:=nil;
   O200.OnClick:=nil;
   O400.OnClick:=nil;
   O1000.OnClick:=nil;
   O2000.OnClick:=nil;
   O4000.OnClick:=nil;
   O8000.OnClick:=nil;
  End;
end;

procedure TPEIForm.O1Click(Sender: TObject);
begin
  O1.OnClick:=nil;
  O1.Checked:=not O1.Checked;
  O1.OnClick:=O1Click;
  ShowMessage(dscr_o1);
end;

procedure TPEIForm.O2Click(Sender: TObject);
begin
  O2.OnClick:=nil;
  O2.Checked:=not O2.Checked;
  O2.OnClick:=O2Click;
  ShowMessage(dscr_o2);
end;

procedure TPEIForm.O4Click(Sender: TObject);
begin
  O4.OnClick:=nil;
  O4.Checked:=not O4.Checked;
  O4.OnClick:=O4Click;
  ShowMessage(dscr_o4);
end;

procedure TPEIForm.O8Click(Sender: TObject);
begin
  O8.OnClick:=nil;
  O8.Checked:=not O8.Checked;
  O8.OnClick:=O8Click;
  ShowMessage(dscr_o8);
end;

procedure TPEIForm.O10Click(Sender: TObject);
begin
  O10.OnClick:=nil;
  O10.Checked:=not O10.Checked;
  O10.OnClick:=O10Click;
  ShowMessage(dscr_o10);
end;

procedure TPEIForm.O20Click(Sender: TObject);
begin
  O20.OnClick:=nil;
  O20.Checked:=not O20.Checked;
  O20.OnClick:=O20Click;
  ShowMessage(dscr_o20);
end;

procedure TPEIForm.O80Click(Sender: TObject);
begin
  O80.OnClick:=nil;
  O80.Checked:=not O80.Checked;
  O80.OnClick:=O80Click;
  ShowMessage(dscr_o80);
end;

procedure TPEIForm.O40Click(Sender: TObject);
begin
  O40.OnClick:=nil;
  O40.Checked:=not O40.Checked;
  O40.OnClick:=O40Click;
  ShowMessage(dscr_o40);
end;

procedure TPEIForm.O1000Click(Sender: TObject);
begin
  O1000.OnClick:=nil;
  O1000.Checked:=not O1000.Checked;
  O1000.OnClick:=O1000Click;
  ShowMessage(dscr_o1000);
end;

procedure TPEIForm.O2000Click(Sender: TObject);
begin
  O2000.OnClick:=nil;
  O2000.Checked:=not O2000.Checked;
  O2000.OnClick:=O2000Click;
  ShowMessage(dscr_o2000);
end;

procedure TPEIForm.O4000Click(Sender: TObject);
begin
  O4000.OnClick:=nil;
  O4000.Checked:=not O4000.Checked;
  O4000.OnClick:=O4000Click;
  ShowMessage(dscr_o4000);
end;

procedure TPEIForm.O8000Click(Sender: TObject);
begin
  O8000.OnClick:=nil;
  O8000.Checked:=not O8000.Checked;
  O8000.OnClick:=O8000Click;
  ShowMessage(dscr_o8000);
end;

procedure TPEIForm.O100Click(Sender: TObject);
begin
  O100.OnClick:=nil;
  O100.Checked:=not O100.Checked;
  O100.OnClick:=O100Click;
  ShowMessage(dscr_o100);
end;

procedure TPEIForm.O200Click(Sender: TObject);
begin
  O200.OnClick:=nil;
  O200.Checked:=not O200.Checked;
  O200.OnClick:=O200Click;
  ShowMessage(dscr_o200);
end;

procedure TPEIForm.O400Click(Sender: TObject);
begin
  O400.OnClick:=nil;
  O400.Checked:=not O400.Checked;
  O400.OnClick:=O400Click;
  ShowMessage(dscr_o400);
end;

procedure TPEIForm.SaveOldRowChanges;

  procedure CheckHexValue(s : String);
  begin
    try
      StrToInt('$'+s);
    except
      on e : Exception do
        Raise Exception.Create(s+' is not valid hex value');
    end;
  end;

begin
   if OldRow=-1 then exit;
   CheckHexValue(RVAEdit.Text);
   ObjectSGrid.Cells[1,OldRow]:=RVAEdit.Text;
   CheckHexValue(PhysOffsetEdit.Text);
   ObjectSGrid.Cells[2,OldRow]:=PhysOffsetEdit.Text;
   CheckHexValue(PhysSizeEdit.Text);
   ObjectSGrid.Cells[3,OldRow]:=PhysSizeEdit.Text;
   CheckHexValue(VirtSizeEdit.Text);
   ObjectSGrid.Cells[4,OldRow]:=VirtSizeEdit.Text;
   CheckHexValue(FlagsEdit.Text);
   ObjectSGrid.Cells[5,OldRow]:=FlagsEdit.Text;
end;

procedure TPEIForm.Button2Click(Sender: TObject);
begin
   if Not bELF
     then PEHeader.Dump(Self.PEFile)
     else Raise Exception.Create('This is not PE file !');
   ShowPEData;
   FormShow(self);
end;

procedure TPEIForm.FlagsEditKeyPress(Sender: TObject; var Key: Char);
begin
  Button9Click(self);
end;

procedure TPEIForm.LoadDirectoryInfo;
begin
  With PEHeader Do
   begin
     Edit1.Text:=DWORD2HEX(EXPORT_TABLE_RVA);
     Edit2.Text:=DWORD2HEX(TOTAL_EXPORT_DATA_SIZE);
     Edit3.Text:=DWORD2HEX(IMPORT_TABLE_RVA);
     Edit4.Text:=DWORD2HEX(TOTAL_IMPORT_DATA_SIZE);
     Edit5.Text:=DWORD2HEX(RESOURCE_TABLE_RVA);
     Edit6.Text:=DWORD2HEX(TOTAL_RESOURCE_DATA_SIZE);
     Edit7.Text:=DWORD2HEX(EXCEPTION_TABLE_RVA);
     Edit8.Text:=DWORD2HEX(TOTAL_EXCEPTION_DATA_SIZE);
     Edit9.Text:=DWORD2HEX(SECURITY_TABLE_RVA);
     Edit10.Text:=DWORD2HEX(TOTAL_SECURITY_DATA_SIZE);
     Edit11.Text:=DWORD2HEX(FIXUP_TABLE_RVA);
     Edit12.Text:=DWORD2HEX(TOTAL_FIXUP_DATA_SIZE);
     Edit13.Text:=DWORD2HEX(DEBUG_TABLE_RVA);
     Edit14.Text:=DWORD2HEX(TOTAL_DEBUG_DIRECTORIES);
     Edit15.Text:=DWORD2HEX(IMAGE_DESCRIPTION_RVA);
     Edit16.Text:=DWORD2HEX(TOTAL_DESCRIPTION_SIZE);
     Edit17.Text:=DWORD2HEX(MACHINE_SPECIFIC_RVA);
     Edit18.Text:=DWORD2HEX(MACHINE_SPECIFIC_SIZE);
     Edit19.Text:=DWORD2HEX(THREAD_LOCAL_STORAGE_RVA);
     Edit20.Text:=DWORD2HEX(TOTAL_TLS_SIZE);
     Edit21.Text:=DWORD2HEX(Load_Config_Table_RVA);
     Edit22.Text:=DWORD2HEX(Load_Config_Table_Size);
     Edit23.Text:=DWORD2HEX(Bound_Import_RVA);
     Edit24.Text:=DWORD2HEX(Bound_Import_Size);
     Edit25.Text:=DWORD2HEX(IAT_RVA);
     Edit26.Text:=DWORD2HEX(IAT_Size);
     Edit27.Text:=DWORD2HEX(Delay_Import_Descriptor_RVA);
     Edit28.Text:=DWORD2HEX(Delay_Import_Descriptor_Size);
     Edit29.Text:=DWORD2HEX(COM_Runtime_Header_RVA);
     Edit30.Text:=DWORD2HEX(COM_Runtime_Header_Size);
  end;   
end;

procedure TPEIForm.Button4Click(Sender: TObject);
begin
  LoadDirectoryInfo;
end;

procedure TPEIForm.Button3Click(Sender: TObject);
var i : Integer;
    edt : TEdit;
    lPEHOffset : DWORD;

  function CheckHexValue(s : String) : Boolean;
  begin
    Result:=False;
    try
      StrToInt('$'+s);
      Result:=True;
    except
      on e : Exception do ShowMessage(s+' is not valid hex value');
    end;
  end;
  
var
    sNewFile : String;
begin
   SaveDlg.InitialDir:=ExtractFileDir(PEFile.sFileName);
   SaveDlg.FileName:=PEFile.sFileName;

   if not SaveDlg.Execute then exit;
   //If MessageDlg(wrn_change_file,
   //   mtConfirmation,[mbYes,mbNo],0)=mrNo Then Exit;

  for i:=0 to PEIForm.ComponentCount-1 do
    begin
      if PEIForm.Components[i].Tag<>-784 then continue;
      edt:=TEdit(PEIForm.Components[i]);
      if not CheckHexValue(edt.Text) then begin edt.SetFocus; exit end;
    end;

  With PEHeader Do
   begin
     EXPORT_TABLE_RVA:=HEX2DWORD(Edit1.Text);
     TOTAL_EXPORT_DATA_SIZE:=HEX2DWORD(Edit2.Text);
     IMPORT_TABLE_RVA:=HEX2DWORD(Edit3.Text);
     TOTAL_IMPORT_DATA_SIZE:=HEX2DWORD(Edit4.Text);
     RESOURCE_TABLE_RVA:=HEX2DWORD(Edit5.Text);
     TOTAL_RESOURCE_DATA_SIZE:=HEX2DWORD(Edit6.Text);
     EXCEPTION_TABLE_RVA:=HEX2DWORD(Edit7.Text);
     TOTAL_EXCEPTION_DATA_SIZE:=HEX2DWORD(Edit8.Text);
     SECURITY_TABLE_RVA:=HEX2DWORD(Edit9.Text);
     TOTAL_SECURITY_DATA_SIZE:=HEX2DWORD(Edit10.Text);
     FIXUP_TABLE_RVA:=HEX2DWORD(Edit11.Text);
     TOTAL_FIXUP_DATA_SIZE:=HEX2DWORD(Edit12.Text);
     DEBUG_TABLE_RVA:=HEX2DWORD(Edit13.Text);
     TOTAL_DEBUG_DIRECTORIES:=HEX2DWORD(Edit14.Text);
     IMAGE_DESCRIPTION_RVA:=HEX2DWORD(Edit15.Text);
     TOTAL_DESCRIPTION_SIZE:=HEX2DWORD(Edit16.Text);
     MACHINE_SPECIFIC_RVA:=HEX2DWORD(Edit17.Text);
     MACHINE_SPECIFIC_SIZE:=HEX2DWORD(Edit18.Text);
     THREAD_LOCAL_STORAGE_RVA:=HEX2DWORD(Edit19.Text);
     TOTAL_TLS_SIZE:=HEX2DWORD(Edit20.Text);
     Load_Config_Table_RVA:=HEX2DWORD(Edit21.Text);
     Load_Config_Table_Size:=HEX2DWORD(Edit22.Text);
     Bound_Import_RVA:=HEX2DWORD(Edit23.Text);
     Bound_Import_Size:=HEX2DWORD(Edit24.Text);
     IAT_RVA:=HEX2DWORD(Edit25.Text);
     IAT_Size:=HEX2DWORD(Edit26.Text);
     Delay_Import_Descriptor_RVA:=HEX2DWORD(Edit27.Text);
     Delay_Import_Descriptor_Size:=HEX2DWORD(Edit28.Text);
     COM_Runtime_Header_RVA:=HEX2DWORD(Edit29.Text);
     COM_Runtime_Header_Size:=HEX2DWORD(Edit30.Text);

     PEFile.PEStream.Seek(DATA_FOR_PE_HEADER_OFFSET,soFromBeginning);
     PEFile.PEStream.ReadBuffer(lPEHOffset,2);
     PEFile.PEStream.Seek($78+lPEHOffset,soFromBeginning);

     PEFile.PEStream.WriteBuffer(EXPORT_TABLE_RVA,4);
     PEFile.PEStream.WriteBuffer(TOTAL_EXPORT_DATA_SIZE,4);
     PEFile.PEStream.WriteBuffer(IMPORT_TABLE_RVA,4);
     PEFile.PEStream.WriteBuffer(TOTAL_IMPORT_DATA_SIZE,4);
     PEFile.PEStream.WriteBuffer(RESOURCE_TABLE_RVA,4);
     PEFile.PEStream.WriteBuffer(TOTAL_RESOURCE_DATA_SIZE,4);
     PEFile.PEStream.WriteBuffer(EXCEPTION_TABLE_RVA,4);
     PEFile.PEStream.WriteBuffer(TOTAL_EXCEPTION_DATA_SIZE,4);
     PEFile.PEStream.WriteBuffer(SECURITY_TABLE_RVA,4);
     PEFile.PEStream.WriteBuffer(TOTAL_SECURITY_DATA_SIZE,4);
     PEFile.PEStream.WriteBuffer(FIXUP_TABLE_RVA,4);
     PEFile.PEStream.WriteBuffer(TOTAL_FIXUP_DATA_SIZE,4);
     PEFile.PEStream.WriteBuffer(DEBUG_TABLE_RVA,4);
     PEFile.PEStream.WriteBuffer(TOTAL_DEBUG_DIRECTORIES,4);
     PEFile.PEStream.WriteBuffer(IMAGE_DESCRIPTION_RVA,4);
     PEFile.PEStream.WriteBuffer(TOTAL_DESCRIPTION_SIZE,4);
     PEFile.PEStream.WriteBuffer(MACHINE_SPECIFIC_RVA,4);
     PEFile.PEStream.WriteBuffer(MACHINE_SPECIFIC_SIZE,4);
     PEFile.PEStream.WriteBuffer(Thread_LOCAL_STORAGE_RVA,4);
     PEFile.PEStream.WriteBuffer(TOTAL_TLS_SIZE,4);
     PEFile.PEStream.WriteBuffer(Load_Config_Table_RVA,4);
     PEFile.PEStream.WriteBuffer(Load_Config_Table_Size,4);
     PEFile.PEStream.WriteBuffer(Bound_Import_RVA,4);
     PEFile.PEStream.WriteBuffer(Bound_Import_Size,4);
     PEFile.PEStream.WriteBuffer(IAT_RVA,4);
     PEFile.PEStream.WriteBuffer(IAT_Size,4);
     PEFile.PEStream.WriteBuffer(Delay_Import_Descriptor_RVA,4);
     PEFile.PEStream.WriteBuffer(Delay_Import_Descriptor_Size,4);
     PEFile.PEStream.WriteBuffer(COM_Runtime_Header_RVA,4);
     PEFile.PEStream.WriteBuffer(COM_Runtime_Header_Size,4);
  end;

   Try
     PEFile.PEStream.SaveToFile(SaveDlg.FileName{FsFileName});
     ShowMessage(msg_save_succ);
   Except
     on e: Exception do
         ShowMessage(msg_save_not_succ+#13#10+e.Message);
   End;
     
end;

procedure TPEIForm.ObjectSGridMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var ARow : Integer;
begin
  if (x<429) or (x>515) then
    begin
       Application.HideHint;
       exit;
    end;

  ARow:=((y-15) div 15)+1;
  if ARow>PEHeader.ObjectNum then ARow:=PEHeader.ObjectNum;

  _sHint:=ObjectSGrid.Cells[0,ARow]+'    RVA '+ObjectSGrid.Cells[1,ARow]+#13#13
     +PEHeader.Objects[1].DecodeFlags(Hex2DWORD(ObjectSGrid.Cells[5,ARow]));

 if ObjectSGrid.Hint<>_sHint then
   begin
     Application.HideHint;
     ShowHint := False;
     ObjectSGrid.Hint:=_sHint;
   end
   else if (not ShowHint) then ShowHint := True;
end;

end.
