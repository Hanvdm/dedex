unit ClassInfoUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, StdCtrls, ExtCtrls, MainUnit, DeDeClasses, Buttons, DeDeClassHandle;

type
  TClassInfoForm = class(TForm)
    Label1: TLabel;
    ClassNameLbl: TLabel;
    FieldsLV: TListView;
    MethodsLV: TListView;
    Bevel1: TBevel;
    SelfLbl: TLabel;
    Label2: TLabel;
    Label5: TLabel;
    VMTLbl: TLabel;
    Label7: TLabel;
    VMTPosLbl: TLabel;
    Label4: TLabel;
    MethLbl: TLabel;
    Label6: TLabel;
    SizeLbl: TLabel;
    FieldPtrLbl: TLabel;
    Label8: TLabel;
    Label3: TLabel;
    InitLbl: TLabel;
    Label9: TLabel;
    IntrfLbl: TLabel;
    Label11: TLabel;
    AutoLbl: TLabel;
    Label13: TLabel;
    InfoLbl: TLabel;
    Label15: TLabel;
    DynLbl: TLabel;
    Label10: TLabel;
    SCELbl: TLabel;
    Label14: TLabel;
    DefHLbl: TLabel;
    Label17: TLabel;
    NewILbl: TLabel;
    Label19: TLabel;
    FreeILbl: TLabel;
    Label21: TLabel;
    DesILbl: TLabel;
    Label23: TLabel;
    AncLbl: TLabel;
    BSSLV: TListView;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    ClassDumper : TClassDumper;
  end;

var
  ClassInfoForm: TClassInfoForm;

implementation

{$R *.DFM}

procedure TClassInfoForm.FormShow(Sender: TObject);
var i : Integer;
    inst : TListItem;
begin
  FieldsLV.Items.Clear;
  MethodsLV.Items.Clear;
  BSSLV.Items.Clear;
  ClassNameLbl.Caption:='';
  If ClassDumper=nil Then Exit;

  ClassNameLbl.Caption:=ClassDumper.FsClassName;
  SizeLbl.Caption:=IntToHex(ClassDumper.FdwClassSize,4);
  SelfLbl.Caption:=IntToHex(ClassDumper.FdwSelfPrt,8);
  VMTLbl.Caption:=IntToHex(ClassDumper.FdwVMTPtr,8);
  VMTposLbl.Caption:=IntToHex(ClassDumper.FdwVMTPos,8);
  MethLbl.Caption:=IntToHex(ClassDumper.FdwMethodDefTlbPtr,8);
  FieldPtrLbl.Caption:=IntToHex(ClassDumper.FdwFieldDefTlbPtr,8);
  InitLbl.Caption:=IntToHex(ClassDumper.FdwInitializationTlbPtr,8);
  IntrfLbl.Caption:=IntToHex(ClassDumper.FdwInterfaceTlbPtr,8);
  AutoLbl.Caption:=IntToHex(ClassDumper.FdwAutomationTlbPtr,8);
  InfoLbl.Caption:=IntToHex(ClassDumper.FdwInformationTlbPtr,8);
  DynLbl.Caption:=IntToHex(ClassDumper.FdwDynMethodsTlbPtr,8);
  AncLbl.Caption:=IntToHex(ClassDumper.FdwAncestorPtrPtr,8);
  SCELbl.Caption:=IntToHex(ClassDumper.FdwSafecallExceptionMethodPtr,8);
  DefHLbl.Caption:=IntToHex(ClassDumper.FdwDefaultHandlerMethodPtr,8);
  NewILbl.Caption:=IntToHex(ClassDumper.FdwNewInstanceMethodPtr,8);
  FreeILbl.Caption:=IntToHex(ClassDumper.FdwFreeInstanceMethodPtr,8);
  DesILbl.Caption:=IntToHex(ClassDumper.FdwDestroyDestructorPtr,8);

  For i:=1 To ClassDumper.FdwBSSOffset.Count-1 Do
    Begin
      inst:=BSSLV.Items.Add;
      inst.Caption:=IntToHex(DWORD(ClassDumper.FdwDATAPrt[i]),8);
      inst.SubItems.Add(IntToHex(DWORD(ClassDumper.FdwBSSOffset[i]),8));
      inst.SubItems.Add(IntToHex(DWORD(ClassDumper.FdwHeapPtr[i]),8));
    End;

  For i:=0 To ClassDumper.FieldData.Count-1 Do
    Begin
      inst:=FieldsLV.Items.Add;
      inst.Caption:=TFieldRec(ClassDumper.FieldData.Fields[i]).sName;
      inst.SubItems.Add(IntToHex(TFieldRec(ClassDumper.FieldData.Fields[i]).dwID,8));
    End;

  For i:=0 To ClassDumper.MethodData.Count-1 Do
    Begin
      inst:=MethodsLV.Items.Add;
      inst.Caption:=IntToHex(TMethodRec(ClassDumper.MethodData.Methods[i]).dwRVA,8);
      inst.SubItems.Add(TMethodRec(ClassDumper.MethodData.Methods[i]).sName);
      inst.SubItems.Add(IntToHex(TMethodRec(ClassDumper.MethodData.Methods[i]).wFlag,4));
    End;
end;

end.
