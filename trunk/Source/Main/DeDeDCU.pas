unit DeDeDCU;

interface

Uses DeDeClasses, Classes;

Type DWORD = LongWord;

Type TDCUDecoder = Class (TObject)
        protected
          DCUOffset : LongInt;
          FdwImageBase, FdwCodeRVA, FdwCodeSize : DWORD;
          Function ReadPascalStringBack : String;
          Function ReadOffsetBack : DWORD;
          Function ReadWordBack : Word;
          Function ReadByteBack : Byte;
          Function OffsetInCodeSegment(Offset : DWORD) : Boolean;
        public
          PEStream : TPEStream;
          Constructor Create;
          Destructor Destroy; override;
          procedure SetPEData(ImageBase,CodeRVA,CodeSize : DWORD);
          function Dump(AsOffset : String; OpCodeList, ControlList : TStringList) : String;
     End;


implementation

Uses HEXTools, DeDeConstants, SysUtils;


{ TDCUDecoder }

constructor TDCUDecoder.Create;
begin
  Inherited Create;

end;

destructor TDCUDecoder.Destroy;
begin

  Inherited Destroy;
end;


// Result if name of the form corresponding to the unit
function TDCUDecoder.Dump(AsOffset: String;
  OpCodeList, ControlList: TStringList): String;
var s : String;
    sFormName : String;
    Pat : TPaternQuery;
    bFound, bMidHeaderFound : Boolean;
    iOffset,i,j : LongInt;
    iEventCount : Integer;
    wReadCount : WORD;
begin
  Result:='';
  If PEStream=nil Then Exit;
  If OpCodeList=nil Then Exit;
  If ControlList=nil Then Exit;

//  ShowMessage('DCUDump Eneter');
  With PEStream Do
    Begin
      BeginSearch;
      //Moves to DCU Offset Footer
      Seek(HEX2DWORD(AsOffset),soFromBeginning);
      Try
        // Finds End of FormClassName
        Seek(-iDCU_CONST1-1,soFromCurrent);
        // Reads ClassName
        s:=ReadPascalStringBack;
        sFormName:=s;

        // Finds Where RVA List Ends. It Ends with ClassName String
        Pat:=TPaternQuery.Create;
        Try
          // Set ClassName String
          Pat.SetString(s);
          // Backuops current offset
          iOffset:=Position;
          i:=iOffset;
          Repeat
            //Moves 1 byte back
            Seek(i-1,soFromBeginning);
            //Looks if there is ClassName string there
            bFound:=PatternMach(Pat);
            //Decreses CurrentPosition
            Dec(i);
          Until (bFound) or (Position-iOffset>iDCU_CONST2);
          If Not bFound Then Raise Exception.Create('DCU Engine Error L20');

          //Pattern does not contain length-byte, so we must sub. it
          Seek(i-1,soFromBeginning);

          //Skips Additional Data If There Are Any
          i:=0;
          bMidHeaderFound:=False;
          j:=ReadOffsetBack;
          While OffsetInCodeSegment(j) Do
            Begin
              bMidHeaderFound:=True;
              Inc(i);
              j:=ReadOffsetBack;
            End;
          Seek(4,soFromCurrent);
          If bMidHeaderFound Then
            Begin
              For j:=1 To i Do ReadWordBack;
              j:=ReadWordBack;
              If j<>i Then
               Begin
                //Raise Exception.Create('DCU Engine Error L21. Class:"'+sFormName+'". Phisical Offset:'+DWORD2HEX(Position));
//              ShowMessage('Mid Header Skipped Succesfully In: '+sFormName+' DCU !');
                OpCodeList.Clear;
                Exit;
               End;
            End;

          //Sets DCU Offset
          DCUOffset:=Position;
        Finally
          Pat.Free;
        End;

        // Puts Header in EventOffsetDump StringList
        OpCodeList.Add('{'+sFormName);
        OpCodeList.Add('');
        // Initialize Event Read (No Events have been read yet)
        iEventCount:=0;
        Repeat
          //Reads Word Back
          wReadCount:=ReadWordBack;
          //Checks to see if this equals the event count read so far
          IF wReadCount=iEventCount
             // If so, then break. All event handlers have been read
             Then Break;
          // Else return forward to prepare for reading
          Seek(2,soFromCurrent);

          // Reads EventName, EventOffset and EventHint
          s:=ReadPascalStringBack;
          i:=ReadOffsetBack;
          j:=ReadWordBack;

          // Check To see if this is a EventHandler Data
          // Of no events present. If last so i must not be
          // an offset in the code segment
          If Not OffsetInCodeSegment(i) Then Break;

          //Puts Dumped Record in the stringlist
          s:=sFormName+'.'+s;
          While Length(s)<40 Do s:=s+' ';
          OpCodeList.Add(s+DWORD2HEX(i)+' hint:'+WORD2HEX(j));

          //Increaces Events Read so far
          Inc(iEventCount);
        Until False;

        ///////////////////////////////////////////////////////
        /// Controls IDs can be readed here
        ///////////////////////////////////////////////////////
        ControlList.Clear;
        // Moves 4 bytes forward
        Seek(4,soFromCurrent);
        // control name is stored in s, so read only IDs
        j:=ReadWordBack;
        i:=ReadOffsetBack;
        ControlList.Add(Format('%s,%s',[s,i]));

        Repeat
        // Reads ControlName, Number and ControlID
        s:=ReadPascalStringBack;
        j:=ReadWordBack;
        i:=ReadOffsetBack;
        ControlList.Add(Format('%s,%s',[s,i]));
        Until j=0;

        ShowMessage(ControlList.Text);
        ///////////////////////////////////////////////////////
        /// End of Control IDs data
        ///////////////////////////////////////////////////////

        //Puts EventOffsetDump StringList Footer
        OpCodeList.Add('}');
        //ShowMessage(OpCodeList.Text);
        //Result is the form name
        Result:=sFormName;
      Finally
        EndSearch;
      End;
    End;
end;

function TDCUDecoder.OffsetInCodeSegment(Offset: DWORD): Boolean;
begin
  Result:=    (Offset>FdwImageBase+FdwCodeRVA)
          and (Offset<FdwImageBase+FdwCodeRVA+FdwCodeSize);
end;

function TDCUDecoder.ReadByteBack: Byte;
Var b : Byte;
begin
  PEStream.Seek(-1,soFromCurrent);
  PEStream.ReadBuffer(b,1);
  PEStream.Seek(-1,soFromCurrent);
  Result:=b;
end;

function TDCUDecoder.ReadOffsetBack: DWORD;
Var b1,b2,b3,b4 : Byte;
begin
  PEStream.Seek(-4,soFromCurrent);
  PEStream.ReadBuffer(b1,1);
  PEStream.ReadBuffer(b2,1);
  PEStream.ReadBuffer(b3,1);
  PEStream.ReadBuffer(b4,1);
  PEStream.Seek(-4,soFromCurrent);
  Result:=b1+b2*256+(b3+b4*256)*256*256;
end;

function TDCUDecoder.ReadPascalStringBack: String;
Var s : String;
    b : Byte;
begin
   s:='';
   b:=ReadByteBack;
   While b>32 Do
     Begin
       s:=CHR(b)+s;
       b:=ReadByteBack;
     End;
   If b<>Length(s) Then
      s:=Copy(s,2,Length(s)-1);
     //Raise Exception.Create('DCU Dump Engine Error L10!');

   Result:=s;  
end;

function TDCUDecoder.ReadWordBack: Word;
Var b1,b2 : Byte;
begin
  PEStream.Seek(-2,soFromCurrent);
  PEStream.ReadBuffer(b1,1);
  PEStream.ReadBuffer(b2,1);
  PEStream.Seek(-2,soFromCurrent);
  Result:=b1+b2*256;
end;

procedure TDCUDecoder.SetPEData(ImageBase,CodeRVA,CodeSize : DWORD);
begin
  FdwImageBase:=ImageBase;
  FdwCodeRVA:=CodeRVA;
  FdwCodeSize:=CodeSize;
end;

end.
