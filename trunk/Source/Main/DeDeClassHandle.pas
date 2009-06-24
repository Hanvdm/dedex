unit DeDeClassHandle;

interface

uses
  Classes, Windows, SysUtils, DeDeClasses, DeDeBSS, Forms, Dialogs, DeDeRes,
  Controls;



Type

  TPackageInfoTable = class (TObject)
  public
    dwUnitCount : DWORD;
    dwPhysOffs  : DWORD;
    UnitsStartPtrs   : Array of DWORD;
    UnitsInitPtrs   : Array of DWORD;
    UnitsFInitPtrs  : Array of DWORD;
    UnitsNames      : TStringList;
    ClassesList : TList;

    constructor Create;
    destructor Destroy; override;
    procedure SetUnitCount(z : DWORD);
    procedure IdentUnitNames(Sender : TObject);
  end;


  TClassDumper = Class
  protected
    IsInDataSection : Boolean;
    Procedure CalculatePositions;
    Procedure DumpFields;
    Function GetDFMOffset(AsClassName : String) : DWORD;
    Function InCodeSection(RVA : DWORD) : Boolean;
    Function InDataSection(RVA : DWORD) : Boolean;
    Function IsInData(RVA : DWORD) : Boolean;
  public
    //PEHeader : TPEHeader;
    DELTA_PHYS : DWORD;
    FdwBSSOffset, FdwHeapPtr, FdwDATAPrt : TList;
    FdwSelfPrt, FdwSelfPrtPos : DWORD;
    FsClassName : String;
    FsUnitName : String;
    FbClassFlag : Byte;
    FdwVMTPtr, FdwVMTPos : DWORD;
    FdwVMTPtr2 : DWORD;
    FdwInterfaceTlbPtr : DWORD;
    FdwAutomationTlbPtr : DWORD;
    FdwInitializationTlbPtr : DWORD;
    FdwInformationTlbPtr : DWORD;
    FdwFieldDefTlbPtr : DWORD;
    FdwMethodDefTlbPtr : DWORD;
    FdwDynMethodsTlbPtr : DWORD;
    FdwInterfaceTlbPos : DWORD;
    FdwAutomationTlbPos : DWORD;
    FdwInitializationTlbPos : DWORD;
    FdwInformationTlbPos : DWORD;
    FdwFieldDefTlbPos : DWORD;
    FdwMethodDefTlbPos : DWORD;
    FdwDynMethodsTlbPos : DWORD;
    FdwClassNamePos : DWORD;
    FdwClassNamePtr : DWORD;
    FdwClassSize : DWORD;
    FdwAncestorPtrPtr : DWORD;
    FdwSafecallExceptionMethodPtr : DWORD;
    FdwDefaultHandlerMethodPtr : DWORD;
    FdwNewInstanceMethodPtr : DWORD;
    FdwFreeInstanceMethodPtr : DWORD;
    FdwDestroyDestructorPtr : DWORD;
    FieldData : TFieldData;
    MethodData : TMethodData;
    FdwDFMOffset : DWORD;
    FdwFirstProcRVA : DWORD;
    Constructor Create;
    Destructor Destroy; override;
    Procedure Dump(dwSelfPtrPos : DWORD);
    Procedure DumpObject(dwSelfPtrPos : DWORD);
    Procedure DumpObjectEx(dwSelfPtrPos: DWORD; btType : Byte);
    Procedure DumpMethods(dwEndRVA : DWORD; bDumpAdditional : Boolean  = False);
    Function GetMethodRVA(sMethName : String) : DWORD;
    Function IsBSSDATAClass(Index : Integer) : Boolean;
  End;

  TClassesDumper = Class
  protected
    DFMTXTDATA_Names : Array of String;
    DFMTXTDATA : TList;
    FiZeroCount : Integer;
    Procedure AddClass(dwSelfPtrPos : DWORD);
    Procedure AddClass_D2(dwSelfPtrPos : DWORD);
    Procedure AddObject(dwSelfPtrPos : DWORD);
    Procedure AddObjectEx(dwSelfPtrPos: DWORD; btType : Byte);
    function ClassExists(sClassName : string) : Boolean;
    function GetClassByName(sClassName : String) : TClassDumper;
    procedure EnumDFMOffsets;
    procedure LoadDFMTXTDATA;
  public
    Classes : TList;
    DFMOffsets : TStringList;
    BSS : TBSS;
    PackageInfoTable : TPackageInfoTable;
    Constructor Create;
    Destructor Destroy; override;
    Procedure ClearClasses;
    Procedure ClearDFMTXTDATA;
    Procedure Dump;
    Procedure FinilizeDump;
    Function GetDFMTXTDATA(sClassName : String) : TStringList;
    Function GetClass(sClassName : String) : TClassDumper;
    Function GetClassWMethods(sClassName : String) : TClassDumper;
    Function GetClassWFields(sClassName: String): TClassDumper;
    Procedure GetBufferForDPJSave(var buff : Array of byte; var size : Integer);
  End;



  

implementation



uses
  MainUnit, DeDeDisAsm, HEXTools, DeDePAS, DeDeConstants, DeDeClassEmulator,
  DeDeOffsInf;



function IsInCodeSection(RVA: DWORD): Boolean;
var idx : Integer;
    DELTA_PHYS : DWORD;
begin
  idx:=PEHeader.GetSectionIndexEx('CODE');
  DELTA_PHYS:=  PEHeader.IMAGE_BASE
               +PEHeader.Objects[idx].RVA
               -PEHeader.Objects[idx].PHYSICAL_OFFSET;
  Result:=((RVA-DELTA_PHYS)>=PEHeader.Objects[idx].PHYSICAL_OFFSET)
      and ((RVA-DELTA_PHYS)<=PEHeader.Objects[idx].PHYSICAL_OFFSET+PEHeader.Objects[idx].PHYSICAL_SIZE)
end;




{ TPackageInfoTable }

constructor TPackageInfoTable.Create;
begin
  Inherited Create;

  UnitsNames:=TStringList.Create;
  ClassesList:=TList.Create;
end;


destructor TPackageInfoTable.Destroy;
var i : Integer;
begin
  For i:=ClassesList.Count-1 downto 0  do TStringList(ClassesList[i]).Free;
  ClassesList.Free;
  UnitsNames.Free;

  Inherited Destroy;
end;

procedure TPackageInfoTable.IdentUnitNames(Sender: TObject);
var Dumper : TClassesDumper;
    ClassDmp,ClassDmp1  : TClassDumper;
    i, j, k : Integer;
    bFound : Boolean;
begin
  Dumper:=TClassesDumper(Sender);

  ////////////////////////////////////////////////
  // Enorder Units Data
  ////////////////////////////////////////////////
  Repeat
    k:=0; j:=0;
    Repeat
      if UnitsFInitPtrs[j]>UnitsFInitPtrs[j+1] then
         begin
           i:=UnitsInitPtrs[j];
           UnitsInitPtrs[j]:=UnitsInitPtrs[j+1];
           UnitsInitPtrs[j+1]:=i;
           i:=UnitsFInitPtrs[j];
           UnitsFInitPtrs[j]:=UnitsFInitPtrs[j+1];
           UnitsFInitPtrs[j+1]:=i;
           Inc(k);
         end;
       Inc(j)
     Until j>dwUnitCount-2;
  Until k=0;

  // The last unit is the project itself. The initialization pointer
  // is the program entry point and finalization is normaly null
  //
  // It is important to have repeat..until loop because the order is mportant
  j:=0;
  Repeat
    UnitsStartPtrs[j+1]:=GetNextProcRVA(UnitsInitPtrs[j],bFound,False);
    UnitsNames[j+1]:='Unit_'+DWORD2HEX(UnitsStartPtrs[j+1]);
    Inc(j);
  Until j>=dwUnitCount-1;

  // The first unit is ALWAYS system.dcu and ALWAYS starts
  // at the beginning of CODE section
  UnitsStartPtrs[0]:=PEHeader.BaseOfCode+PEHeader.IMAGE_BASE;
  UnitsNames[0]:='System';

  // The second unit is ALWAYS sysinit.pas
  UnitsNames[1]:='SysInit';

  // The last unit is ALWAYS the project
  UnitsNames[dwUnitCount-1]:=DeDeMainForm.ProjectNameLbl.Caption;

  ///////////////////////////////////////////////////
  // The same about Classes data
  ///////////////////////////////////////////////////
  Repeat
    k:=0;
    For j:=0 to dwUnitCount-2 do
     begin
      if j+1>=Dumper.Classes.Count then break;
      ClassDmp:=TClassDumper(Dumper.Classes[j]);
      ClassDmp1:=TClassDumper(Dumper.Classes[j+1]);
      if ClassDmp.FdwSelfPrt>ClassDmp1.FdwSelfPrt then
         begin
           Dumper.Classes.Exchange(j,j+1);
         end;
     end;
  Until k=0;


  ///////////////////////////////////////////////////////////////
  // Do the recognition
  ///////////////////////////////////////////////////////////////
  // Loop among all the units
  For i:=0 to Dumper.Classes.Count-1 do
    begin
      ClassDmp:=TClassDumper(Dumper.Classes[i]);

      For j:=0 to dwUnitCount-2 do
        if    (ClassDmp.FdwSelfPrt>UnitsStartPtrs[j])
          and (ClassDmp.FdwSelfPrt<UnitsStartPtrs[j+1])
          then begin
            TStringList(ClassesList[j]).Add(ClassDmp.FsClassName);
            if ClassDmp.FsUnitName<>'' then UnitsNames[j]:=ClassDmp.FsUnitName;
          end;
    end;
end;

procedure TPackageInfoTable.SetUnitCount(z: DWORD);
var i : Integer;
begin
  dwUnitCount:=z;
  SetLength(UnitsInitPtrs,z);
  SetLength(UnitsFInitPtrs,z);
  SetLength(UnitsStartPtrs,z);
  UnitsNames.Clear;
  For i:=1 to dwUnitCount do
    begin
      UnitsNames.Add('');
      ClassesList.Add(TStringList.Create);
    end;
end;

{ TClassDumper }

procedure TClassDumper.CalculatePositions;
begin
   If FdwInterfaceTlbPtr<>0 Then
      FdwInterfaceTlbPos:=FdwInterfaceTlbPtr-DELTA_PHYS;
   If FdwAutomationTlbPtr<>0 Then
    FdwAutomationTlbPos:=FdwAutomationTlbPtr-DELTA_PHYS;
   If FdwInitializationTlbPtr<>0 Then
    FdwInitializationTlbPos:=FdwInitializationTlbPtr-DELTA_PHYS;
   If FdwInformationTlbPtr<>0 Then
    FdwInformationTlbPos:=FdwInformationTlbPtr-DELTA_PHYS;
   If FdwFieldDefTlbPtr<>0 Then
    FdwFieldDefTlbPos:=FdwFieldDefTlbPtr-DELTA_PHYS;
   If FdwMethodDefTlbPtr<>0 Then
    FdwMethodDefTlbPos:=FdwMethodDefTlbPtr-DELTA_PHYS;
   If FdwDynMethodsTlbPtr<>0 Then
    FdwDynMethodsTlbPos:=FdwDynMethodsTlbPtr-DELTA_PHYS;
   If FdwClassNamePtr<>0 Then
    FdwClassNamePos:=FdwClassNamePtr-DELTA_PHYS;
end;

constructor TClassDumper.Create;
begin
  Inherited Create;

  FieldData:=TFieldData.Create;
  MethodData:=TMethodData.Create;

  FdwBSSOffset:=TList.Create;
  FdwBSSOffset.Add(nil);
  FdwHeapPtr:=TList.Create;
  FdwHeapPtr.Add(nil);
  FdwDATAPrt:=TList.Create;
  FdwDATAPrt.Add(nil);
end;

destructor TClassDumper.Destroy;
begin
  FieldData.Free;
  MethodData.Free;
  FdwBSSOffset.Free;
  FdwHeapPtr.Free;
  FdwDATAPrt.Free;

  Inherited Destroy;
end;

procedure TClassDumper.Dump(dwSelfPtrPos: DWORD);
var b  : Byte;
    dw : DWORD;
    w : Word;
    DELTA_TBL : Byte;
begin
  FdwSelfPrtPos:=dwSelfPtrPos;

  {BOZA DeDeClasses.}PEStream.Seek(dwSelfPtrPos,soFromBeginning);

  // Reads SelfPtr
  {BOZA DeDeClasses.}PEStream.ReadBuffer(FdwSelfPrt,4);

  // No selfpointers in Delphi 2
  If GlobDelphi2 then FdwSelfPrt := 0;

  // Reads ClassFlag
  {BOZA DeDeClasses.}PEStream.ReadBuffer(FbClassFlag,1);

  If FbClassFlag<16 Then
  Begin
    // Reads ClassName length
    {BOZA DeDeClasses.}PEStream.ReadBuffer(b,1);
    SetLength(FsClassName,b);

    // Reads ClassName
    {BOZA DeDeClasses.}PEStream.ReadBuffer(FsClassName[1],b);
  End;

  // Reads VMT RVA
  {BOZA DeDeClasses.}PEStream.ReadBuffer(FdwVMTPtr,4);
  IsInDataSection:=IsInData(FdwVMTPtr);

  {BOZA DeDeClasses.}PEStream.ReadBuffer(dw,4);

  // Reads Flag
  {BOZA DeDeClasses.}PEStream.ReadBuffer(w,2);

  ///////////////////////////////////////////
  // Support for other units and classes
  // 7 should be a class that has DFM resources
  if FbClassFlag<>7 Then Exit;
  ///////////////////////////////////////////

  // Reads UnitName length
  {BOZA DeDeClasses.}PEStream.ReadBuffer(b,1);
  SetLength(FsUnitName,b);

  // Reads UnitName
  {BOZA DeDeClasses.}PEStream.ReadBuffer(FsUnitName[1],b);

  // Additive constant to RVA-Phys conversion for CODE section
  if IsInDataSection then
      DELTA_PHYS:=  PEHeader.IMAGE_BASE
                   +PEHeader.Objects[2].RVA
                   -PEHeader.Objects[2].PHYSICAL_OFFSET
  else
      DELTA_PHYS:=  PEHeader.IMAGE_BASE
                   +PEHeader.Objects[1].RVA
                   -PEHeader.Objects[1].PHYSICAL_OFFSET;

  // Gets The First Procedure RVA
  Repeat
    {BOZA DeDeClasses.}PEStream.ReadBuffer(b,1)
  Until not (b in [$00,$90,$8D,$40,$8B,$C0]);
  FdwFirstProcRVA := {BOZA DeDeClasses.}PEStream.Position+DELTA_PHYS;

  // Calculates VMT Position in executable
  FdwVMTPos:=FdwVMTPtr-DELTA_PHYS;

  // Moves to the beginning of the Class VMT
  DELTA_TBL:=76;
  If DelphiVersion='D3' Then DELTA_TBL:=64;
  If DelphiVersion='D2' Then DELTA_TBL:=44; {Offset to FielsDefTblPrtPos-4}
  {BOZA DeDeClasses.}PEStream.Seek(FdwVMTPos-DELTA_TBL,soFromBeginning);

  // Reads ClassInformation Data
  {BOZA DeDeClasses.}PEStream.ReadBuffer(FdwVMTPtr2,4);
  if GlobCBuilder or GlobDelphi2 then FdwVMTPtr2:=FdwVMTPtr;
  If FdwVMTPtr<>FdwVMTPtr2 Then Exit;

  if not GlobDelphi2 then
    begin
      {BOZA DeDeClasses.}PEStream.ReadBuffer(FdwInterfaceTlbPtr,4);
      {BOZA DeDeClasses.}PEStream.ReadBuffer(FdwAutomationTlbPtr,4);
      {BOZA DeDeClasses.}PEStream.ReadBuffer(FdwInitializationTlbPtr,4);
      {BOZA DeDeClasses.}PEStream.ReadBuffer(FdwInformationTlbPtr,4);
    end;

  {BOZA DeDeClasses.}PEStream.ReadBuffer(FdwFieldDefTlbPtr,4);
  {BOZA DeDeClasses.}PEStream.ReadBuffer(FdwMethodDefTlbPtr,4);

  if not GlobDelphi2 then
      {BOZA DeDeClasses.}PEStream.ReadBuffer(FdwDynMethodsTlbPtr,4);

  {BOZA DeDeClasses.}PEStream.ReadBuffer(FdwClassNamePtr,4);
  {BOZA DeDeClasses.}PEStream.ReadBuffer(FdwClassSize,4);
  {BOZA DeDeClasses.}PEStream.ReadBuffer(FdwAncestorPtrPtr,4);
  {BOZA DeDeClasses.}PEStream.ReadBuffer(FdwSafecallExceptionMethodPtr,4);
  {BOZA DeDeClasses.}PEStream.ReadBuffer(FdwDefaultHandlerMethodPtr,4);
  {BOZA DeDeClasses.}PEStream.ReadBuffer(FdwNewInstanceMethodPtr,4);
  {BOZA DeDeClasses.}PEStream.ReadBuffer(FdwFreeInstanceMethodPtr,4);
  {BOZA DeDeClasses.}PEStream.ReadBuffer(FdwDestroyDestructorPtr,4);


  CalculatePositions;
  DumpFields;
  // Get DFM Offsets
  If DeDeMainForm.DFMFormList.IndexOf(FsClassName)<>-1
     Then FdwDFMOffset:=GetDFMOffset(FsClassName);

  // This should be called after all classes has been dumped
  // DumpMethods;
end;


procedure TClassDumper.DumpFields;
var  dw,i : DWORD;
     b : Byte;
     sName : String;
     w : Word;
begin
  If FdwFieldDefTlbPtr=0 Then Exit;
  If Not bELF then
  if Not IsInDataSection
     Then Begin If Not InCodeSection(FdwFieldDefTlbPtr) Then Exit End
     Else If Not InDataSection(FdwFieldDefTlbPtr) Then Exit;
     
  Try
  {BOZA DeDeClasses.}PEStream.Seek(FdwFieldDefTlbPos,soFromBeginning);
  {BOZA DeDeClasses.}PEStream.ReadBuffer(FieldData.Count,2);
  //If FieldData.Count>100 Then Exit;
  {BOZA DeDeClasses.}PEStream.ReadBuffer(FieldData.Ptr,4);

    For i:=0 To FieldData.Count-1 Do
      Begin
       {BOZA DeDeClasses.}PEStream.ReadBuffer(dw,4);
       {BOZA DeDeClasses.}PEStream.ReadBuffer(w,2);
       {BOZA DeDeClasses.}PEStream.ReadBuffer(b,1);
       SetLength(sName,b);
       {BOZA DeDeClasses.}PEStream.ReadBuffer(sName[1],b);
       FieldData.AddField(sName, dw, w);
    End;
  Except
    ShowMessageFmt(err_classdump,[FsClassName,FdwFieldDefTlbPos]);
  End;
end;

procedure TClassDumper.DumpMethods(dwEndRVA : DWORD; bDumpAdditional : Boolean = False);
var  dw,i, MinRVA, MaxRVA, dwLastPublishedMeth : DWORD;
     b : Byte;
     sName : String;
     w : Word;
     idx : Integer;
     bFound : Boolean;
     BegArr, EndArr : Array of DWORD;
begin
  //Get DFM Offset
  //ClassDumper.

  if not bDumpAdditional then
    begin
        If FdwMethodDefTlbPtr=0 Then Exit;
        If Not bELF then
        If Not IsInDataSection
           Then Begin If Not InCodeSection(FdwMethodDefTlbPtr) Then Exit End
           Else If Not InDataSection(FdwMethodDefTlbPtr) Then Exit;

        {BOZA DeDeClasses.}PEStream.Seek(FdwMethodDefTlbPos,soFromBeginning);
        {BOZA DeDeClasses.}PEStream.ReadBuffer(MethodData.Count,2);

        For i:=1 To MethodData.Count Do
         Begin
            {BOZA DeDeClasses.}PEStream.ReadBuffer(w,2);
            {BOZA DeDeClasses.}PEStream.ReadBuffer(dw,4);
            {BOZA DeDeClasses.}PEStream.ReadBuffer(b,1);
            SetLength(sName,b);
            {BOZA DeDeClasses.}PEStream.ReadBuffer(sName[1],b);
            ProcRefOffsets.Add(IntToHex(dw,8));
            ProcRefNames.Add(FsClassName+'.'+sName);
            MethodData.AddMethod(sName, dw, w);
         End;

        {BOZA DeDeClasses.}PEStream.Seek(FdwVMTPos,soFromBeginning);
        Repeat
            {BOZA DeDeClasses.}PEStream.ReadBuffer(dw,4);
            If MethodData.MethodIndexByRVA(dw)=-1
              Then Begin
                ProcRefOffsets.Add(IntToHex(dw,8));
                If not InCodeSection(dw) then break;
                ProcRefNames.Add('virt proc '+FsUnitName+'.VIRT_PROC_'+IntToHex(dw,8));
              End;
        Until {BOZA DeDeClasses.}PEStream.Position>=FdwFieldDefTlbPos;

        // Only The 'Good' Classes should continue down
        If FieldData.Count=0 Then Exit;
        If FdwDFMOffset=0 Then Exit;
        If not bUserProcs Then Exit;
     end
     else begin
        // Gets User Defines Procedures
        DeDeDisASM.PEStream:={BOZA DeDeClasses.}PEStream;
        //DeDeDisASM.PEHeader:=DeDeClasses.PEHEader;
        DeDeDisASM.RVAConverter.ImageBase:=DeDeClasses.PEHEader.IMAGE_BASE;
        DeDeDisASM.RVAConverter.CodeRVA:=DeDeClasses.PEHEader.Objects[1].RVA;
        DeDeDisASM.RVAConverter.PhysOffset:=DeDeClasses.PEHEader.Objects[1].PHYSICAL_OFFSET;

        //Find last published method RVA
        dwLastPublishedMeth:=0;
        for idx:=0 to MethodData.Methods.Count-1 do
          if dwLastPublishedMeth<TMethodRec(MethodData.Methods[idx]).dwRVA
             then dwLastPublishedMeth:=TMethodRec(MethodData.Methods[idx]).dwRVA;

        //Prepare Begin and End rva arrays for knows published methods
        SetLength(BegArr,MethodData.Methods.Count);
        SetLength(EndArr,MethodData.Methods.Count);
        for idx:=0 to MethodData.Methods.Count-1 do
          begin
            dw:=TMethodRec(MethodData.Methods[idx]).dwRVA;
            BegArr[idx]:=dw;
            dw:=DeDeDisASM.GetNextProcRVA(dw, bFound, False);
            EndArr[idx]:=dw;
          end;

        //The real recognition follows here
        dw:=FdwFirstProcRVA;
        Repeat
          MinRVA:=DeDeDisASM.GetNextProcRVA(dw, bFound, False);
          DebugLog(DWORD2HEX(MinRVA));
          dw:=MinRVA;

          if dw>=dwEndRVA then break;

          if (not bFound) then
                if (dw>dwLastPublishedMeth) or (dw=0)
                     then break
                     else continue;
           
           
          if dw=0 then break;

          //Here can check if the found RVA is not in the other method RVA space
          //if so /wrong recognition/ then change next rva to the end of this method rva
          for idx:=Low(BegArr) to High(BegArr) do
            if (dw>BegArr[idx]) and (dw<EndArr[idx]) then
               begin
                 dw:=EndArr[idx];
                 continue;
               end;
          
          //If method is not in the method list then add it
          idx:=MethodData.MethodIndexByRVA(dw);
          If idx=-1 Then
             Begin
               Application.ProcessMessages;
               MethodData.AddMethod('_PROC_'+DWORD2HEX(dw),dw,$FFFF);
               Inc(MethodData.Count);
             End;
        Until False;
     end;
end;

procedure TClassDumper.DumpObject(dwSelfPtrPos: DWORD);
var b  : Byte;
    dw : DWORD;
begin
  FdwSelfPrtPos:=dwSelfPtrPos;

  {BOZA DeDeClasses.}PEStream.Seek(dwSelfPtrPos,soFromBeginning);

  // Reads SelfPtr
  {BOZA DeDeClasses.}PEStream.ReadBuffer(FdwSelfPrt,4);

  // Reads ClassFlag
  {BOZA DeDeClasses.}PEStream.ReadBuffer(FbClassFlag,1);

  If FbClassFlag=$0E Then
   Begin
    // Reads ClassName length
    {BOZA DeDeClasses.}PEStream.ReadBuffer(b,1);
    SetLength(FsClassName,b);

    // Reads ClassName
    {BOZA DeDeClasses.}PEStream.ReadBuffer(FsClassName[1],b);
   End;
end;

procedure TClassDumper.DumpObjectEx(dwSelfPtrPos: DWORD; btType : Byte);
var b  : Byte;
    dw : DWORD;
begin
  if btType<>0 Then
    Begin
      FdwSelfPrtPos:=dwSelfPtrPos;

      {BOZA DeDeClasses.}PEStream.Seek(dwSelfPtrPos,soFromBeginning);

      // Reads SelfPtr
      {BOZA DeDeClasses.}PEStream.ReadBuffer(FdwSelfPrt,4);

      // Reads ClassFlag
      {BOZA DeDeClasses.}PEStream.ReadBuffer(FbClassFlag,1);

      // Reads ClassName length
      {BOZA DeDeClasses.}PEStream.ReadBuffer(b,1);
      SetLength(FsClassName,b);

      // Reads ClassName
      {BOZA DeDeClasses.}PEStream.ReadBuffer(FsClassName[1],b);

      Case btType Of
        $01,$02 :
           begin
             {.. Type: 01 or 02 (Integer, Byte, Char etc.)

              DWORD	SelfPointer
              BYTE	Type = 01 or 02
              STRPAS	ClassName
              BYTE	Size (in bytes)
              DWORD     Min Value
              DWORD	Max Value
             }
           end;

        $03     :
           begin
             { Enumeration Type 03

              DWORD	SelfPointer
              BYTE	Type = 03
              STRPAS	ClassName
              BYTE      ??
              DWORD     ??
              DWORD     Number of elements minus one
              DWORD     with value SelfPointer-4 is reached
              STRPAS	EnumName1
              STRPAS	EnumName2
             }

           end;

        $06     :
           begin
             {Set Type 06 (set of TBlahBlah)

              DWORD	SelfPointer
              BYTE	Type = 06
              BYTE	?? (Count)
              DWORD	Elements type: Pointer to (SelfPointer-4)
              }

           end;

        $08     :
           begin
              {Event Type 08

                DWORD	SelfPointer
                BYTE	Type = 08
                STRPAS	ClassName
                BYTE	Event type /00 = procedure, 01 = function/
                BYTE	Param count

                PARAM_DATA
                        BYTE	Prefix     /00 - normal, 01 - *VAR*, 08 - class instance, 10 - Record/
                        STRPAS	Param Name
                        STRPAS	Param Type

                RESULT_DATA (if function)
                        STRPAS	Result Type
              }
           end;

        $0A     :
           begin
             {String Type 0A}
           end;

        $0E     :
           begin
              {Record - Type 0E

                DWORD	SelfPointer
                BYTE	Type 0E - Record
                STRPAS	ClassName
                DWORD	field_1 type
                DWORD   field_2 type
                ..........
                       / note: If the type is class then the dword is the (SelfPointer-4)
              }
           end;

        $0F     :
           begin
              (*
                Interface (0F)

                DWORD	SelfPointer
                BYTE	Type (0E)
                PASSTR	InterfaceName
                DWORD   ParentPtr
                BYTE    ?? (GUID Count)
                GUID    {00000000-0000-0000-C000-000000000046}
                STRPAS	UnitName

              *)

              
           end;

      End;
    End
    Else Begin
      // Directly Inherited from TObject Class
      FbClassFlag:=btType;


      // Additive constant to RVA-Phys conversion for CODE section
      DELTA_PHYS:=  PEHeader.IMAGE_BASE
                   +PEHeader.Objects[1].RVA
                   -PEHeader.Objects[1].PHYSICAL_OFFSET;

      FdwSelfPrt:=({BOZA DeDeClasses.}PEStream.Position+DELTA_PHYS)-8*4;

      {BOZA DeDeClasses.}PEStream.Seek(dwSelfPtrPos-DELTA_PHYS,soFromBeginning);
      // Reads ClassName length
      Try
       {BOZA DeDeClasses.}PEStream.ReadBuffer(b,1);
      except
       exit;
      end;
      if b=0 then exit;
      SetLength(FsClassName,b);
      {BOZA DeDeClasses.}PEStream.ReadBuffer(FsClassName[1],b);

      {BOZA DeDeClasses.}PEStream.Seek(FdwSelfPrt-DELTA_PHYS,soFromBeginning);
      {BOZA DeDeClasses.}PEStream.ReadBuffer(FdwVMTPtr,4);
    End;
end;

function TClassDumper.GetDFMOffset(AsClassName: String): DWORD;
var i: Integer;
begin
  Result:=0;
  i:=DeDeMainForm.DFMFormList.IndexOf(AsClassName);
  if i=-1 Then Exit;
  Result:=DWORD(DeDeMainForm.DFMFormList.Objects[i]);
end;

function TClassDumper.GetMethodRVA(sMethName: String): DWORD;
var i : Integer;
begin
  Result:=0;
  For i:=0 To MethodData.Methods.Count-1 Do
    If TMethodRec(MethodData.Methods[i]).sName=sMethName Then
       Begin
         Result:=TMethodRec(MethodData.Methods[i]).dwRVA;
         Exit;
       End;
end;

function TClassDumper.InCodeSection(RVA: DWORD): Boolean;
var idx : Integer;
begin
  idx:=PEHeader.GetSectionIndexEx('CODE');
  Result:=((RVA-DELTA_PHYS)>=PEHeader.Objects[idx].PHYSICAL_OFFSET)
      and ((RVA-DELTA_PHYS)<=PEHeader.Objects[idx].PHYSICAL_OFFSET+PEHeader.Objects[idx].PHYSICAL_SIZE)
end;

function TClassDumper.InDataSection(RVA: DWORD): Boolean;
var idx : Integer;
begin
  idx:=PEHeader.GetSectionIndexEx('DATA');
  Result:=((RVA-DELTA_PHYS)>=PEHeader.Objects[idx].PHYSICAL_OFFSET)
      and ((RVA-DELTA_PHYS)<=PEHeader.Objects[idx].PHYSICAL_OFFSET+PEHeader.Objects[idx].PHYSICAL_SIZE)
end;

function TClassDumper.IsBSSDATAClass(Index: Integer): Boolean;
begin
  IF Index>FdwDATAPrt.Count
    then result:=false
    else Result:=
           ((FdwDATAPrt[Index]<>nil) or (FdwDFMOffset<>0))
       and (FdwBSSOffset[Index]<>nil)
       and (FdwHeapPtr[Index]<>nil);
end;

Function TClassDumper.IsInData(RVA : DWORD) : Boolean;
var idx : Integer;
begin
  idx:=PEHeader.GetSectionIndexEx('DATA');
  Result:=((RVA-PEHeader.IMAGE_BASE)>=PEHeader.Objects[idx].RVA)
      and ((RVA-PEHeader.IMAGE_BASE)<=PEHeader.Objects[idx].RVA+PEHeader.Objects[idx].VIRTUAL_SIZE);
End;


{ TClassesDumper }

procedure TClassesDumper.AddClass(dwSelfPtrPos: DWORD);
var inst, inst1 : TClassDumper;
    b : Byte;
    s : String;
begin
  PEFile.PEStream.Seek( dwSelfPtrPos + 5, soFromBeginning);
  PEFile.PEStream.ReadBuffer(b, 1);
  SetLength(s, b);
  PEFile.PEStream.ReadBuffer(s[1], b);
  DeDeMainForm.DumpStatusLbl.Caption := msg_processing + s + '...';
  Application.ProcessMessages;
  inst := TClassDumper.Create;
  //inst.PEHeader:=PEHeader;
  Try
    inst.Dump(dwSelfPtrPos);
  Except
    inst.Free;
    Exit;
  End;

  // Add unit name in Unit list in the case of Delphi2 and CBuilder
  If (GlobCBuilder) or (GlobDelphi2) then
     if DeDeMainForm.UnitList.IndexOf(inst.FsUnitName)=-1 then
       DeDeMainForm.UnitList.Add(inst.FsUnitName);

  If ClassExists(inst.FsClassName) Then
  begin
    inst1:=GetClassByName(inst.FsClassName);
    If (inst1.FdwDFMOffset<>0) and (inst.FdwDFMOffset<>0)
    then
     Case MessageDlg(
         Format(err_classes_same_name
         ,[inst.FsClassName,inst1.FsUnitName,inst.FsUnitName]),
         mtWarning,[mbOK,mbCancel],0) of
       mrOK     : begin
                    inst1.FdwDFMOffset:=0;
                  end;
       mrCancel : begin
                    inst.FdwDFMOffset:=0;
                  end;
     End
    else begin
      inst1.FieldData.Count:=0;
      inst1.MethodData.Count:=0;

      // Remove duplicates
      if inst.FbClassFlag=$07 then
        begin
          Classes.Remove(inst1);
          inst1.Free;
        end;
    end;
  end;
  Classes.Add(inst);
  DeDeMainForm.CustomPB.Position := 300 +
    Trunc(700*(Classes.IndexOf(inst)-FiZeroCount)/GlobClassesCount);
    
  Application.ProcessMessages;
end;

procedure TClassesDumper.AddClass_D2(dwSelfPtrPos: DWORD);
var inst, inst1 : TClassDumper;
    b : Byte;
    s : String;
begin
  PEFile.PEStream.Seek(dwSelfPtrPos+5,soFromBeginning);
  PEFile.PEStream.ReadBuffer(b,1);
  SetLength(s,b);
  PEFile.PEStream.ReadBuffer(s[1],b);
  DeDeMainForm.DumpStatusLbl.Caption:=msg_processing+s+'...';
  Application.ProcessMessages;
  inst:=TClassDumper.Create;
  //inst.PEHeader:=PEHeader;
  Try
    inst.Dump(dwSelfPtrPos);

    // Init FdwBSSOffset for non class objects not in [$07,$0E]
    // with its selfpointer. This trick is neseccary for approprite
    // emulation when custom register value is specified
    inst.FdwBSSOffset.Add(Pointer(dwSelfPtrPos));
    inst.FdwDATAPrt.Add(Pointer(dwSelfPtrPos));
    inst.FdwHeapPtr.Add(Pointer(dwSelfPtrPos));
  Except
    Exit;
  End;

  // Add unit name in Unit list in the case of Delphi2 and CBuilder
  If DeDeMainForm.UnitList.IndexOf(inst.FsUnitName)=-1 then DeDeMainForm.UnitList.Add(inst.FsUnitName);

  Classes.Add(inst);
  DeDeMainForm.CustomPB.Position:=300+Trunc(700*(Classes.IndexOf(inst)-FiZeroCount)/GlobClassesCount);
  Application.ProcessMessages;
end;

procedure TClassesDumper.AddObject(dwSelfPtrPos: DWORD);
var inst : TClassDumper;
    b : Byte;
    s : String;
begin
  PEFile.PEStream.Seek(dwSelfPtrPos+5,soFromBeginning);
  PEFile.PEStream.ReadBuffer(b,1);
  SetLength(s,b);
  PEFile.PEStream.ReadBuffer(s[1],b);
  DeDeMainForm.DumpStatusLbl.Caption:=msg_processing+s+'...';
  Application.ProcessMessages;
  inst:=TClassDumper.Create;
  //inst.PEHeader:=PEHeader;
  inst.DumpObject(dwSelfPtrPos);
  if Not ClassExists(inst.FsClassName) then
    begin
      Classes.Add(inst);
      DeDeMainForm.CustomPB.Position:=300+Trunc(700*(Classes.IndexOf(inst)-FiZeroCount)/GlobClassesCount);
      Application.ProcessMessages;
    end
    else inst.Free;      
end;

procedure TClassesDumper.AddObjectEx(dwSelfPtrPos: DWORD; btType : Byte);
var inst : TClassDumper;
    b : Byte;
    s : String;
begin
  if btType<>0 then
    begin
      PEFile.PEStream.Seek(dwSelfPtrPos+5,soFromBeginning);
      PEFile.PEStream.ReadBuffer(b,1);
      SetLength(s,b);
      PEFile.PEStream.ReadBuffer(s[1],b);
    end
    else s:='unknown type';     
  DeDeMainForm.DumpStatusLbl.Caption:=msg_processing+s+'...';
  Application.ProcessMessages;
  inst:=TClassDumper.Create;
  //inst.PEHeader:=PEHeader;
  try
   inst.DumpObjectEx(dwSelfPtrPos,btType);

   // Init FdwBSSOffset for non class objects not in [$07,$0E]
   // with its selfpointer. This trick is neseccary for approprite
   // emulation when custom register value is specified
   inst.FdwBSSOffset.Add(Pointer(dwSelfPtrPos));
   inst.FdwDATAPrt.Add(Pointer(dwSelfPtrPos));
   inst.FdwHeapPtr.Add(Pointer(dwSelfPtrPos));
  except
   exit;
  end;

  // Must add if class with such name is still
  // not added
  if GetClassByName(inst.FsClassName)=nil then
  //if Not ClassExists(inst.FsClassName) then
    begin
      Classes.Add(inst);
      if btType=0
        then Inc(FiZeroCount)
        else DeDeMainForm.CustomPB.Position:=300+Trunc(700*(Classes.IndexOf(inst)-FiZeroCount)/GlobClassesCount);
      Application.ProcessMessages;
   end
   else inst.Free;
end;

procedure TClassesDumper.LoadDFMTXTDATA;
var i, len : Integer;
    inst : TStringList;
    Input : TMemoryStream;
begin
  ClearDFMTXTDATA;
  len:=DeDeMainForm.DFMList.Items.Count;
  if len=0 then exit;

  SetLength(DFMTXTDATA_Names,len);
  For i:=0 To len-1 Do
    Begin
        DeDeMainForm.FbLoadDFMInMemo:=False;
        Try
          DeDeMainForm.DFMList.Selected:=DeDeMainForm.DFMList.Items[i];
        Finally
          DeDeMainForm.FbLoadDFMInMemo:=True;
        End;

        Input:=DeDeMainForm.PrepareDFM;
        try
          try
           DeDePAS.Convert(Input,'');
          except
            inst:=TStringList.Create;
            DFMTXTDATA_Names[i]:=DeDeMainForm.DFMList.Items[i].Caption;
            DFMTXTDATA.Add(inst);
            Input.SaveToFile(ExtractFileDir(Application.ExeName)+'\debug.dat');
            continue;
          end;
          inst:=TStringList.Create;
          inst.LoadFromFile(FsTEMPDir+'dfm.$$$');
          DeleteFile(FsTEMPDir+'dfm.$$$');
          DFMTXTDATA_Names[i]:=DeDeMainForm.DFMList.Items[i].Caption;
          DFMTXTDATA.Add(inst);
          Application.ProcessMessages;
        finally
         If Input<>nil Then Input.Free;
         DeDeMainForm.FbLoadDFMInMemo:=True;
        end;
    End;

  If FileExists(FsTEMPDir+'dfm.$$$') then DeleteFile(FsTEMPDir+'dfm.$$$');
end;



procedure TClassesDumper.ClearClasses;
var i : Integer;
begin
  For i:=Classes.Count-1 DownTo 0 Do
    TClassDumper(Classes[i]).Free;
end;

procedure TClassesDumper.ClearDFMTXTDATA;
var i : Integer;
begin
  For i:=DFMTXTDATA.Count-1 DownTo 0 Do
    TStringList(DFMTXTDATA[i]).Free;
end;

constructor TClassesDumper.Create;
begin
  Inherited Create;

  Classes:=TList.Create;
  DFMTXTDATA:=TList.Create;
  DFMOffsets:=TStringList.Create;
  BSS:=TBSS.Create;
  PackageInfoTable:=TPackageInfoTable.Create;
end;

destructor TClassesDumper.Destroy;
var i : Integer;
begin
  PackageInfoTable.Free;
  BSS.Free;
  DFMOffsets.Free;

  // Removing custom DOI form data
  For i:=0 To Classes.Count-1 Do
    If (TClassDumper(Classes[i]).FdwDFMOffset<>0)
      Then DeDeClassEmulator.OffsInfArchive.RemoveOffsInfo(TClassDumper(Classes[i]).FsClassName);

  ClearClasses;
  Classes.Free;
  ClearDFMTXTDATA;
  DFMTXTDATA.Free;

  Inherited Destroy;
end;

procedure TClassesDumper.Dump;
var dw, dw1, dw2, code_size,delta,bkup, EndSerchFuncOffs : DWORD;
    b, len : byte;
    i, j, k{, D2_idx} : Integer;
    buff, patt : Array of Byte;
    s : String;
    bFound : Boolean;

  Procedure DumpD2;
  var D2_idx, j : Integer;
      _code_size : dword;
      _bt : Byte;
     TmpArr : Array of String;
  begin
      With DeDeMainForm Do
      begin
        GlobClassesCount:=DFMFormList.Count;
        CustomPB.Position:=300;

        // Copy the class name list because of delphi compiler bug !!!
        SetLength(TmpArr,DFMFormList.Count);
        For D2_idx:=0 to DFMFormList.Count-1 do TmpArr[d2_idx]:=DFMFormList[d2_idx];
      end;

    _code_size:=PEHeader.Objects[1].PHYSICAL_OFFSET+PEHeader.Objects[1].PHYSICAL_SIZE;
    // Search for $07+FormNameAsPascalString got from DFM resource list
    // patt[] is the array containing what is going to be serached
    For D2_idx:=0 to High(TmpArr) do
    Begin
        s:=TmpArr[d2_idx];
        len:=Length(s);
        SetLength(patt,len);
        patt[0]:=$07; patt[1]:=len;
        for j:=1 to len do patt[j+1]:=ORD(s[j]);

        {BOZA DeDeClasses.}PEStream.Seek(PEHeader.Objects[1].PHYSICAL_OFFSET,soFromBeginning);
        bFound:=False;

        // Read byte if it equals $07 then reads buff[] and
        // compares with patt[] else move one byte forward
        Repeat
          bkup:={BOZA DeDeClasses.}PEStream.Position;

          {BOZA DeDeClasses.}PEStream.ReadBuffer(_bt,1);
          if _bt=$07 then
            begin
              SetLength(buff,len);
              {BOZA DeDeClasses.}PEStream.ReadBuffer(buff[0],len);

              // Doesn't compare buff[0] with patt[0] because patt[0]=$07
              if CompareMem(@buff[0],@patt[1],len) then
                begin
                  AddClass_D2(bkup-4);
                  bFound:=True;
                end;

              {BOZA DeDeClasses.}PEStream.Seek(bkup+1,soFromBeginning);
            end;

          If {BOZA DeDeClasses.}PEStream.Position mod 200 = 0 then Application.ProcessMessages;

        Until (bFound) or ({BOZA DeDeClasses.}PEStream.Position>=_code_size);
    End;
  end; {DumpD2}

begin
  // No BSS dump if BCB
  if GlobCBuilder then  bBSS:=False;

  // If BSS option is enabled dump the BSS section
  if bBSS Then
  begin
    DeDeMainForm.DumpStatusLbl.Caption := msg_loadingtarget;
    DeDeMainForm.DumpStatusLbl.Update;

    If FileExists(DeDeMainForm.FsFileName) then
    begin
      BSS.Free;
      BSS := TBSS.Create;
      BSS.Dump(DeDeMainForm.FsFileName);
    end;
  end;

  // Dump DFM Offsets
  DeDeMainForm.DumpStatusLbl.Caption:=msg_dumpingdsfdata;
  DeDeMainForm.DumpStatusLbl.Update;

  Application.ProcessMessages;
  DeDeMainForm.DumpDFMNames;
  //地址计算
  delta := PEHeader.IMAGE_BASE + (PEHeader.Objects[1].RVA) -
    PEHeader.Objects[1].PHYSICAL_OFFSET;
    
  code_size := PEHeader.Objects[1].PHYSICAL_OFFSET + PEHeader.Objects[1].PHYSICAL_SIZE;

  // Dump Classes
  DeDeMainForm.DumpStatusLbl.Caption:=msg_dumpingclasses;
  DeDeMainForm.DumpStatusLbl.Update;

  ///////////////////////////////////////
  // Find and Dump Classes Self Pointers
  // <> Delphi 2 (no self pointers)
  ///////////////////////////////////////
  GlobClassesCount:=0;
  PEStream.Seek(PEHeader.Objects[1].PHYSICAL_OFFSET, soFromBeginning);
  If not GlobDelphi2 then
  Begin
    //计算进度条数据
    Repeat
      PEStream.ReadBuffer(dw,4);
      // If a self-pointer is found
      If dw - delta = PEStream.Position Then
      Begin
        bkup:= PEStream.Position;
        PEStream.ReadBuffer(b,1);
        if b < $11 Then Inc(GlobClassesCount);
        PEStream.Seek(bkup,soFromBeginning);
      End;

      If PEStream.Position mod 200 =0 then
      begin
        DeDeMainForm.CustomPB.Position := 200 + Trunc(100 * (
          PEStream.Position)/code_size);

        Application.ProcessMessages;
      end;
    Until (PEStream.Position >= code_size);

    DeDeMainForm.CustomPB.Position:=300;
    If GlobClassesCount = 0 Then Exit;

    //find class
    FiZeroCount := 0;
    PEStream.Seek(PEHeader.Objects[1].PHYSICAL_OFFSET,soFromBeginning);
    Repeat
      PEStream.ReadBuffer(dw,4);
      bkup := PEStream.Position;

      // If a self-pointer is found
      If dw-delta = PEStream.Position Then
      Begin
        PEStream.ReadBuffer(b,1);
        case b of
           $00 : ;// Nothing
           $07 : AddClass(bkup-4);// Classes with specified UnitName
           else
             If (b<=$11) Then AddObjectEx(bkup-4,b);
        end;

        PEStream.Seek(bkup,soFromBeginning);
      End;
      // Check for Classes directly inherited from TObject
      PEStream.ReadBuffer(dw1,4);
      dw2:=PEStream.Position-10*4;
      PEStream.Seek(dw2,soFromBeginning);
      PEStream.ReadBuffer(dw2,4);
      PEStream.Seek(bkup+4,soFromBeginning);

      if ((dw-dw1*4+12)=(PEStream.Position+delta)) then
        if (IsInCodeSection(dw)) then
          AddObjectEx(dw,0)
        else
      else if
        (IsInCodeSection(dw))
        and (IsInCodeSection(dw2))
        and (dw-dw2>0)
        and (dw-dw2<$100)then
      begin
        PEStream.Seek(dw-delta,soFromBeginning);
        PEStream.Read(b,1);

        if (b>0) then
        begin

          dw1:=b;
          repeat
            PEStream.Read(b,1);
            if not (CHR(b) in ['A'..'Z','a'..'z','0'..'9','_']) then break;
            Dec(dw1);
          until dw1=0;

          PEStream.Seek(bkup+4,soFromBeginning);
          if dw1=0 then
            AddObjectEx(dw,0);
        end;
      end;
      PEStream.Seek(bkup,soFromBeginning);
    Until (PEStream.Position >= code_size);
  End
  Else // Delphi 2 Class Finder
  begin
    DumpD2;
  end;

  ///////////////////////////////////////////////////////////////////////////////////////
  // Dumping classes methods (published)
  //////////////////////////////////////////////////////////////////////////////////////
  DeDeMainForm.CustomPB.Position:=1000;
  DeDeMainForm.CustomPB.Update;
  DeDeMainForm.DumpStatusLbl.Caption:=msg_dumpingprocs;
  DeDeMainForm.DumpStatusLbl.Update;
  Try
    // Dump Methods
    For i:=0 To Classes.Count-2 Do
    begin
      TClassDumper(Classes[i]).DumpMethods(0);
      DeDeMainForm.CustomPB.Position:=1000+Trunc(50*(i)/Classes.Count);
      Application.ProcessMessages;
    end;

    TClassDumper(Classes[Classes.Count-1]).DumpMethods(0);

  Except
    on e:Exception Do
      ShowMessage(e.Message);
  End;


  DeDeDisASM.RVAConverter.ImageBase:=PEHeader.IMAGE_BASE;
  DeDeDisASM.RVAConverter.PhysOffset:=PEHeader.Objects[1].PHYSICAL_OFFSET;
  DeDeDisASM.RVAConverter.CodeRVA:=PEHeader.Objects[1].RVA;
    
  /////////////////////////////////////////////////////////////////////////////////////////
  // Dump units data from  PackageInfoTable and seek/dump additional procedures
  /////////////////////////////////////////////////////////////////////////////////////////
  if bBSS Then
    begin
      DeDeMainForm.DumpStatusLbl.Caption:=msg_read_package_info;
      DeDeMainForm.DumpStatusLbl.Update;
      DeDeMainForm.CustomPB.Position:=1050;
      DeDeMainForm.CustomPB.Update;
      Application.ProcessMessages;

      //Find the physical offset of System..InitUnits() function
      dw:=GetInitUnitsProcRVA;
      if dw<>0 then
        begin
          Case ReducedDelphiVersion of
            dvD2 : j:=InitContextOffset2;
            dvD3, dvBCB3 : j:=InitContextOffset3;
            dvD4, dvBCB4, dvD5, dvBCB5, dvD6 : j:=InitContextOffset4;
            else j:=InitContextOffset4;
          end;
          //Goes there and reads the InitContext.PackageInfo member
          PEFile.PEStream.Seek(dw+j, soFromBeginning);
          PEFile.PEStream.ReadBuffer(dw1,4);

          // Check is it CODE offset
          If OffsetInSegment(dw1,'BSS') then
            begin
              // Gets the real data pointer in the file as physical offset
              dw:=BSS.GetPointer(dw1)-PEHeader.IMAGE_BASE
                                     -PEHeader.Objects[1].RVA
                                     +PEHeader.Objects[1].PHYSICAL_OFFSET;

              //Goes there
              PEFile.PEStream.Seek(dw, soFromBeginning);
              PEFile.PEStream.ReadBuffer(dw1,4);

              if dw1<>0 then
                With PackageInfoTable Do
                  Begin
                    dwPhysOffs:=dw+8;
                    SetUnitCount(dw1);

                    For i:=0 to dw1-1 do
                      begin
                        //Reads Units data
                        PEFile.PEStream.Seek(dwPhysOffs+8*i, soFromBeginning);
                        PEFile.PEStream.ReadBuffer(dw,4);
                        UnitsInitPtrs[i]:=dw;
                        PEFile.PEStream.ReadBuffer(dw,4);
                        UnitsFInitPtrs[i]:=dw;
                      end;

                    IdentUnitNames(Self);
                  End;
            end;
        end;
    end;

  //////////////////////////////////////////////////////////////
  // Dumping additional procs - finding their addresses
  //////////////////////////////////////////////////////////////
  DeDeMainForm.CustomPB.Position:=1050;
  DeDeMainForm.CustomPB.Update;
  DeDeMainForm.DumpStatusLbl.Caption:=msg_dumpingprocs;
  DeDeMainForm.DumpStatusLbl.Update;
  Try
    // Dump Methods
    For i:=0 To Classes.Count-2 Do
      begin
       //Find the end of seek offset
       EndSerchFuncOffs:=TClassDumper(Classes[i+1]).FdwSelfPrt;
       for k:=0 to PackageInfoTable.dwUnitCount-1 do
         if PackageInfoTable.UnitsStartPtrs[k]>TClassDumper(Classes[i]).FdwFirstProcRVA then
           begin
              if  PackageInfoTable.UnitsStartPtrs[k]<EndSerchFuncOffs
                 then EndSerchFuncOffs:=PackageInfoTable.UnitsStartPtrs[k];
              break;
           end;

       //DebugLog(TClassDumper(Classes[i]).FsClassName+' ->'+DWORD2HEX(TClassDumper(Classes[i]).FdwFirstProcRVA)+'  ->'+DWORD2HEX(EndSerchFuncOffs));
       TClassDumper(Classes[i]).DumpMethods(EndSerchFuncOffs,True);
       DeDeMainForm.CustomPB.Position:=1050+Trunc(50*(i)/Classes.Count);
       Application.ProcessMessages;
      end;

     //Find the end of seek offset
     EndSerchFuncOffs:=PEHeader.RVA_ENTRYPOINT;
     for k:=0 to PackageInfoTable.dwUnitCount-1 do
       if PackageInfoTable.UnitsStartPtrs[k]>TClassDumper(Classes[Classes.Count-1]).FdwFirstProcRVA then
         begin
            if  PackageInfoTable.UnitsStartPtrs[k]<EndSerchFuncOffs
               then EndSerchFuncOffs:=PackageInfoTable.UnitsStartPtrs[k];
            break;
         end;
    TClassDumper(Classes[Classes.Count-1]).DumpMethods(EndSerchFuncOffs,True);

  Except
   on e:Exception Do ShowMessage(e.Message);
  End;


  /////////////////////////////////////////////////////////////////////////////////////////
  // Building BSS/DATA pointers list
  /////////////////////////////////////////////////////////////////////////////////////////
  if bBSS Then
   begin
      DeDeMainForm.DumpStatusLbl.Caption:=msg_initpointers;
      DeDeMainForm.DumpStatusLbl.Update;
      DeDeMainForm.CustomPB.Position:=1100;
      DeDeMainForm.CustomPB.Update;
      for j:=0 to self.Classes.Count-1 do
       begin
          DeDeMainForm.CustomPB.Position:=1100+Trunc(200*(j)/self.Classes.Count);
          Application.ProcessMessages;

          // skip the non classes and objects
          if not (TClassDumper(self.Classes[j]).FbClassFlag in [$07,$0E]) then continue;

          // Class Self Pointer
          dw1:=TClassDumper(self.Classes[j]).FdwVMTPtr;
          // Do not process bullshits
          if dw1=0 then continue;

          i:=BSS.dwStartRVA;

          while i<(BSS.dwStartRVA+BSS.dwSize) do
            begin
              if (i mod 160) = 0 then Application.ProcessMessages;
              if BSS.GetValue(i)=dw1 then
                 begin
                   TClassDumper(self.Classes[j]).FdwBSSOffset.Add(Pointer(i));
                   TClassDumper(self.Classes[j]).FdwHeapPtr.Add(Pointer(BSS.GetPointer(i)));
                   TClassDumper(self.Classes[j]).FdwDATAPrt.Add(Pointer(BSS.GetDataPrtOfBSSData(i)));
                 end;
              Inc(i,4);
            end;
       end;
   end;

  DeDeMainForm.CustomPB.Position:=1300;
  DeDeMainForm.CustomPB.Update;
  DeDeMainForm.DumpStatusLbl.Caption:=msg_done;
  DeDeMainForm.DumpStatusLbl.Update;
end;

procedure TClassesDumper.FinilizeDump;
var Cstm, tfrm : TOffsInfStruct;
    i : Integer;
begin
  // Loads DFMTXTData
  LoadDFMTXTDATA;

  // Load DOI definitions for dumped forms
  tfrm:=DeDeClassEmulator.OffsInfArchive.GetOffsInfoByClassName('TForm');
  if tfrm=nil then Exit;

  For i:=0 To Classes.Count-1 Do
    If (TClassDumper(Classes[i]).FdwDFMOffset<>0)
      Then Begin
        Cstm:=TOffsInfStruct.Create;
        Cstm.Assign(tfrm);
        Cstm.FsClassName:=TClassDumper(Classes[i]).FsClassName;
        Cstm.FHierarchyList.Add('TForm');
        DeDeClassEmulator.OffsInfArchive.AddOffsInfo(Cstm);
      End;
end;



function TClassesDumper.GetClass(sClassName: String): TClassDumper;
var i : Integer;
begin
  Result:=nil;
  if sClassName='' then exit;
  For i:=0 To Classes.Count-1 Do
    If (TClassDumper(Classes[i]).FsClassName=sClassName)
       Then Begin
         Result:=TClassDumper(Classes[i]);
         Exit;
       End;
end;

function TClassesDumper.GetClassWMethods(sClassName: String): TClassDumper;
var i : Integer;
begin
  Result:=nil;
  if sClassName='' then exit;
  For i:=0 To Classes.Count-1 Do
    If     (TClassDumper(Classes[i]).FsClassName=sClassName)
       and (TClassDumper(Classes[i]).MethodData.Count<>0)
       Then Begin
         Result:=TClassDumper(Classes[i]);
         Exit;
       End;
end;

function TClassesDumper.GetClassWFields(sClassName: String): TClassDumper;
var i : Integer;
begin
  Result:=nil;
  if sClassName='' then exit;
  For i:=0 To Classes.Count-1 Do
    If     (TClassDumper(Classes[i]).FsClassName=sClassName)
       and (TClassDumper(Classes[i]).FieldData.Count<>0)
       Then Begin
         Result:=TClassDumper(Classes[i]);
         Exit;
       End;
end;

function TClassesDumper.GetDFMTXTDATA(sClassName: String): TStringList;
var i : Integer;
begin
  Result:=nil;
  for i:=0 to High(DFMTXTDATA_Names) do
    if DFMTXTDATA_Names[i]=sClassName then
       begin
         Result:=TStringList(DFMTXTDATA[i]);
         Break;
       end;

end;



function TClassesDumper.ClassExists(sClassName : String): Boolean;
var i : Integer;
begin
  Result:=False;
  For i:=0 To self.Classes.Count-1 Do
    If TClassDumper(self.Classes[i]).FsClassName=sClassName Then
      Begin
        Result:=true;
        Exit;
      End;
end;

function TClassesDumper.GetClassByName(sClassName: String): TClassDumper;
var i : Integer;
begin
  Result:=nil;
  For i:=0 To Classes.Count-1 Do
    If     (TClassDumper(Classes[i]).FsClassName=sClassName)
       Then Begin
         Result:=TClassDumper(Classes[i]);
         Exit;
       End;
end;



procedure TClassesDumper.EnumDFMOffsets;
var i, len : Integer;
    ofs_from, ofs_to : DWORD;
    buffer, classbuffer : Array of byte;
    bFound : Boolean;
    b : Byte;
    s : String;
begin
  //Gets Resource Section Offsetes
  i:=PEHeader.GetSectionIndexEx('.rsrc');
  if i=-1 Then i:=PEHeader.GetSectionIndexByRVA(PEHeader.RESOURCE_TABLE_RVA);

  ofs_from:=PEHeader.Objects[i].PHYSICAL_OFFSET;
  ofs_to:=ofs_from+PEHeader.Objects[i].PHYSICAL_SIZE;

  DFMOffsets.Clear;

  // DFM Magic
  classbuffer[0]:=$54;classbuffer[1]:=$50;classbuffer[2]:=$46;classbuffer[3]:=$30;
  len:=4;

  {BOZA DeDeClasses.}PEStream.Seek(ofs_from,soFromBeginning);
  Repeat
    {BOZA DeDeClasses.}PEStream.Seek(1,soFromCurrent);
    {BOZA DeDeClasses.}PEStream.ReadBuffer(buffer[0],len);
    bFound:=CompareMem(@buffer[0],@classbuffer[0],len);
    if bFound then
      begin
        {BOZA DeDeClasses.}PEStream.ReadBuffer(b,1);
        SetLength(s,b);
        {BOZA DeDeClasses.}PEStream.ReadBuffer(s[1],b);
        DFMOffsets.AddObject(s,Pointer({BOZA DeDeClasses.}PEStream.Position-len));
      end;
    {BOZA DeDeClasses.}PEStream.Seek(-len,soFromCurrent);
    If ({BOZA DeDeClasses.}PEStream.Position mod 1000)=0 Then Application.ProcessMessages;
  Until ({BOZA DeDeClasses.}PEStream.Position>=ofs_to-len);
end;



procedure TClassesDumper.GetBufferForDPJSave(var buff: array of byte;
  var size: Integer);
var OutPut : TMemoryStream;
    dw, clid : DWORD;
    s : String;
    i,j, idx : Integer;
    bf, localbuf : array of byte;
    bfsz : integer;
    bt : Byte;
    cls : TClassDumper;
    fld : TFieldRec;
    mth : TMethodRec;

   procedure WriteBuffer(const Buffer; Count : Integer);
   var len : Integer;
   begin
     len:=Length(localbuf);
     SetLength(localbuf,len+Count);
     Move(Buffer, localbuf[len], Count);
   end;

   procedure StoreStringList(sl : TStringList);
   var idx : Integer;
       ib : Integer;
   begin
     ib:=sl.Count;
     {OutPut.}WriteBuffer(ib,4);
     for idx:=0 to sl.Count-1 do
       begin
         ib:=Length(sl[idx]);
         {OutPut.}WriteBuffer(ib,4);
         {OutPut.}WriteBuffer(sl[idx][1],ib);
         ib:=DWORD(sl.Objects[idx]);
         {OutPut.}WriteBuffer(ib,4);
       end;
   end;



begin
  // DFMTXTDATA_Names
  dw:=Length(DFMTXTDATA_Names);
  {OutPut.}WriteBuffer(dw,4);
  for i:=0 to dw-1 do
    begin
      j:=Length(DFMTXTDATA_Names);
      {OutPut.}WriteBuffer(j,4);
      {OutPut.}WriteBuffer(DFMTXTDATA_Names[i][1],j);
    end;

  // DFMTXTDATA
  dw:=DFMTXTDATA.Count;
  {OutPut.}WriteBuffer(dw,4);
  for i:=0 to dw-1 do StoreStringList(TStringList(DFMTXTDATA[i]));

  // FiZeroCount
  {OutPut.}WriteBuffer(FiZeroCount,4);

  // DFMOffsets StringList
  StoreStringList(DFMOffsets);

  // PackageInfoTable
  {OutPut.}WriteBuffer(PackageInfoTable.dwUnitCount,4);
  {OutPut.}WriteBuffer(PackageInfoTable.dwPhysOffs,4);
  dw:=Length(PackageInfoTable.UnitsStartPtrs);
  {OutPut.}WriteBuffer(dw,4);
  for i:=0 to dw-1 do
    begin
      j:=PackageInfoTable.UnitsStartPtrs[i];
      {OutPut.}WriteBuffer(j,4);
    end;
  dw:=Length(PackageInfoTable.UnitsInitPtrs);
  {OutPut.}WriteBuffer(dw,4);
  for i:=0 to dw-1 do
    begin
      j:=PackageInfoTable.UnitsInitPtrs[i];
      {OutPut.}WriteBuffer(j,4);
    end;
  dw:=Length(PackageInfoTable.UnitsFInitPtrs);
  {OutPut.}WriteBuffer(dw,4);
  for i:=0 to dw-1 do
    begin
      j:=PackageInfoTable.UnitsFInitPtrs[i];
      {OutPut.}WriteBuffer(j,4);
    end;
  StoreStringList(PackageInfoTable.UnitsNames);
  dw:=PackageInfoTable.ClassesList.Count;
  {OutPut.}WriteBuffer(dw,4);
  for i:=0 to dw-1 do StoreStringList(TStringList(PackageInfoTable.ClassesList[i]));

  // BSS with all data
  dw:=BSS.dwStartRVA;{OutPut.}WriteBuffer(dw,4);
  dw:=BSS.dwSize;{OutPut.}WriteBuffer(dw,4);
  dw:=BSS.dwDATAStartRVA;{OutPut.}WriteBuffer(dw,4);
  dw:=BSS.dwDATASize;{OutPut.}WriteBuffer(dw,4);
  BSS.GetProtectedDataForDPJSave(bf,bfsz);
  SetLength(bf,bfsz);
  BSS.GetProtectedDataForDPJSave(bf,bfsz);
  {OutPut.}WriteBuffer(bfsz,4);
  {OutPut.}WriteBuffer(bf[0],bfsz);

  // Classes Data
  dw:=Classes.Count;
  {OutPut.}WriteBuffer(dw,4);
  for clid:=0 to Classes.Count-1 do
    begin
      cls:=TClassDumper(Classes[i]);

      dw:=cls.FdwBSSOffset.Count;
      {OutPut.}WriteBuffer(dw,4);
      for i:=0 to dw-1 do
        begin
          j:=DWORD(cls.FdwBSSOffset[i]);
          {OutPut.}WriteBuffer(j,4);
        end;

      dw:=cls.FdwHeapPtr.Count;
      {OutPut.}WriteBuffer(dw,4);
      for i:=0 to dw-1 do
        begin
          j:=DWORD(cls.FdwHeapPtr[i]);
          {OutPut.}WriteBuffer(j,4);
        end;

      dw:=cls.FdwDATAPrt.Count;
      {OutPut.}WriteBuffer(dw,4);
      for i:=0 to dw-1 do
        begin
          j:=DWORD(cls.FdwDATAPrt[i]);
          {OutPut.}WriteBuffer(j,4);
        end;


      {OutPut.}WriteBuffer(cls.FdwSelfPrt,4);
      {OutPut.}WriteBuffer(cls.FdwSelfPrtPos,4);
      j:=Length(cls.FsClassName);
      {OutPut.}WriteBuffer(j,4);
      {OutPut.}WriteBuffer(cls.FsClassName[1],j);
      j:=Length(cls.FsUnitName);
      {OutPut.}WriteBuffer(j,4);
      {OutPut.}WriteBuffer(cls.FsUnitName[1],j);
      {OutPut.}WriteBuffer(cls.FbClassFlag,1);
      {OutPut.}WriteBuffer(cls.FdwVMTPtr,4);
      {OutPut.}WriteBuffer(cls.FdwVMTPos,4);
      {OutPut.}WriteBuffer(cls.FdwVMTPtr2,4);
      {OutPut.}WriteBuffer(cls.FdwInterfaceTlbPtr,4);
      {OutPut.}WriteBuffer(cls.FdwAutomationTlbPtr,4);
      {OutPut.}WriteBuffer(cls.FdwInitializationTlbPtr,4);
      {OutPut.}WriteBuffer(cls.FdwInformationTlbPtr,4);
      {OutPut.}WriteBuffer(cls.FdwFieldDefTlbPtr,4);
      {OutPut.}WriteBuffer(cls.FdwMethodDefTlbPtr,4);
      {OutPut.}WriteBuffer(cls.FdwDynMethodsTlbPtr,4);
      {OutPut.}WriteBuffer(cls.FdwInterfaceTlbPos,4);
      {OutPut.}WriteBuffer(cls.FdwAutomationTlbPos,4);
      {OutPut.}WriteBuffer(cls.FdwInitializationTlbPos,4);
      {OutPut.}WriteBuffer(cls.FdwInformationTlbPos,4);
      {OutPut.}WriteBuffer(cls.FdwFieldDefTlbPos,4);
      {OutPut.}WriteBuffer(cls.FdwMethodDefTlbPos,4);
      {OutPut.}WriteBuffer(cls.FdwDynMethodsTlbPos,4);
      {OutPut.}WriteBuffer(cls.FdwClassNamePos,4);
      {OutPut.}WriteBuffer(cls.FdwClassNamePtr,4);
      {OutPut.}WriteBuffer(cls.FdwClassSize,4);
      {OutPut.}WriteBuffer(cls.FdwAncestorPtrPtr,4);
      {OutPut.}WriteBuffer(cls.FdwSafecallExceptionMethodPtr,4);
      {OutPut.}WriteBuffer(cls.FdwDefaultHandlerMethodPtr,4);
      {OutPut.}WriteBuffer(cls.FdwNewInstanceMethodPtr,4);
      {OutPut.}WriteBuffer(cls.FdwFreeInstanceMethodPtr,4);
      {OutPut.}WriteBuffer(cls.FdwDestroyDestructorPtr,4);
      {OutPut.}WriteBuffer(cls.FdwDFMOffset,4);
      {OutPut.}WriteBuffer(cls.FdwFirstProcRVA,4);

      dw:=cls.FieldData.Count;
      {OutPut.}WriteBuffer(dw,4);
      dw:=cls.FieldData.Ptr;
      {OutPut.}WriteBuffer(dw,4);
      for idx:=0 to cls.FieldData.Count-1 do
        begin
          fld:=TFieldRec(cls.FieldData.Fields[idx]);
          dw:=Length(fld.sName);
          {OutPut.}WriteBuffer(dw,4);
          {OutPut.}WriteBuffer(fld.sName[1],dw);
          {OutPut.}WriteBuffer(fld.dwID,4);
          {OutPut.}WriteBuffer(fld.wFlag,4);
        end;

      dw:=cls.MethodData.Count;
      {OutPut.}WriteBuffer(dw,4);
      for idx:=0 to cls.MethodData.Count-1 do
        begin
          mth:=TMethodRec(cls.MethodData.Methods[idx]);
          dw:=Length(mth.sName);
          {OutPut.}WriteBuffer(dw,4);
          {OutPut.}WriteBuffer(mth.sName[1],dw);
          {OutPut.}WriteBuffer(mth.dwRVA,4);
          {OutPut.}WriteBuffer(mth.wFlag,4);
        end;
    end;

    size:=Length(localbuf);
    if Length(buff)=size then Move(localbuf,buff,size);
//    FreeMem(localbuf,size);

end;





end.
