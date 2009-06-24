unit DeDeWpjAlf;

///////////////////////////////////////////////////////
// Win32DASM WPJ and ALF files editing
//
// This unit has been coded to be used with DeDe 2.40
//
// (c) 2000 DaFixer
///////////////////////////////////////////////////////

interface

uses Classes, DeDeConstants;

Type DWORD = LongWord;

const
      sCopyrightString = #13#10'Including DeDe references (c) DaFixer  '#13#10;

      WPJ_MAGIC1 = $00455845;
      WPJ_MAGIC2 = $00657865;
      DATA_MAGIC = 2.51930465558271833E93;
      DATA_MAGIC1 = $35002C2C;
      DATA_MAGIC2 = $53535300;
      DELTA_OFFSET = $63;

      Color_R_BLK    = $01; // normal = Red && selection = Black
      Color_B_BLK    = $02; // normal = Blue && selection = Black
      Color_R_B      = $03; // normal = Red && selection = Blue
      Color_DB_BLK   = $04; // normal = DarkBlue && selection = Black
      Color_R_DB     = $05; // normal = Red && selection = DarkBlue
      Color_G_BLK    = $08; // normal = Green && selection = Black
      Color_R_G      = $09; // normal = Red && selection = Green

Type TWPJColorRec = Packed Record
       LineNum : DWORD;
       Color   : Word;
       Size    : Byte;
     End;

Type TWPJALF = Class (TObject)
      private
      protected
        procedure ReadHeader;
        procedure ReadWPJData;
        procedure LoadALFListing;
      public
        WPJ, ALF : TMemoryStream;
        dwLineNum, dwColorNum, dwPEP, dwNewPEP : DWORD;
        LineDataPos, EndLineDataPos, ColorPos, EndColorPos, SizePos : DWORD;
        LinesData : Array of Byte;
        ColorData : Array of TWPJColorRec;
        sTargetName : String;
        Listing : TStringList;
        ReffStrings : TStringList;
        constructor Create;
        destructor Destroy; override;
        function OpenWPJFile(sWPJFileName : String) : boolean;
        procedure NewReferences;
        procedure AddRefference(dwRVA : String; color : Word; sReference : String = 'Should be passed by increasing order of RVA');
        procedure SaveCopy(sWPJFileName : String);
     End;

implementation

uses SysUtils, HexTools;

{ TWPJALF }

procedure TWPJALF.AddRefference(dwRVA: String; color: Word;
  sReference: String);
var s : String;
begin
   // dont add trash
   if dwRVA='' then Exit;
   if dwRVA='00000000' then Exit;
   
   sReference:=sReference+#13#10;
   while length(dwRVA)<8 do dwRVA:='0'+dwRVA;
   s:=IntToStr(color);
   while length(s)<2 do s:='0'+s;
   s:=Copy(s,1,2);
   s:=dwRVA+s+sReference;
   If ReffStrings.IndexOf(s)=-1 then ReffStrings.Add(s);
end;

constructor TWPJALF.Create;
begin
  Inherited Create;

  WPJ:=TMemoryStream.Create;
  ALF:=TMemoryStream.Create;
  Listing:=TStringList.Create;
  ReffStrings:=TStringList.Create;
end;

destructor TWPJALF.Destroy;
begin
  ReffStrings.Free;
  Listing.Free;
  if ALF<>nil then ALF.Free;
  if WPJ<>nil then WPJ.Free;

  Inherited Destroy;
end;

procedure TWPJALF.LoadALFListing;
var s : String;
    b : Byte;
    cnt : Cardinal;
begin
  Listing.Clear;
  ALF.Seek(0,soFromBeginning);

  cnt:=0;
  b:=LinesData[cnt]+2;
  SetLength(s,b);
  ALF.ReadBuffer(s[1],b);
  Listing.Add(s);
  Inc(cnt);

  b:=LinesData[cnt]+2;
  SetLength(s,b);
  ALF.ReadBuffer(s[1],b);
  Listing.Add(s);
  Inc(cnt);

  Repeat
   b:=LinesData[cnt]+2;
   SetLength(s,b);
   ALF.ReadBuffer(s[1],b);
   Listing.Add(s);
   Inc(cnt);
  Until (ALF.Position>=ALF.Size) or (cnt>dwLineNum);
end;

procedure TWPJALF.NewReferences;
begin
  ReffStrings.Clear;
end;

function TWPJALF.OpenWPJFile(sWPJFileName: String) : Boolean;
var b : Byte;
    s : String;
begin
  if alf=nil then alf:=TMemoryStream.Create;
  
  WPJ.LoadFromFile(sWPJFileName);
  ALF.LoadFromFile(ChangeFileExt(sWPJFileName,'.alf'));

  repeat
    ALF.ReadBuffer(b,1);
  until b=10;

  SetLength(s,14);
  ALF.ReadBuffer(s[1],14);
  if s='Including DeDe' then
    begin
      alf.free;
      alf:=nil;
      result:=False;
      exit;
    end;

  ReadHeader;
  ReadWPJData;
  LoadALFListing;
  Result:=True;
end;

procedure TWPJALF.ReadHeader;
var dw : DWORD;
     w : WORD;
begin
  WPJ.Seek(0,soFromBeginning);
  WPJ.ReadBuffer(dw,4);

  if   (DW<>WPJ_MAGIC1)
   and (DW<>WPJ_MAGIC2) then Raise Exception.Create('Invalid WPJ File');

  WPJ.ReadBuffer(w,2);
  SetLength(sTargetName,w);

  WPJ.Seek(2,soFromCurrent);
  WPJ.ReadBuffer(sTargetName[1],w);

  SizePos:=WPJ.Position;
  WPJ.ReadBuffer(dwLineNum,4);
  SetLength(LinesData,dwLineNum);

  WPJ.Seek(4,soFromCurrent);
  WPJ.ReadBuffer(dwPEP,4);
end;

procedure TWPJALF.ReadWPJData;
var ext : DWORD;
    bt  : Byte;
    i,n   : DWORD;
    ColRec : TWPJColorRec;
    bkupPos : DWORD;
begin
  // Seek the magic
  Repeat
    Repeat
      WPJ.ReadBuffer(ext,4);
      WPJ.Seek(-3,soFromCurrent);
    Until (ext=DATA_MAGIC1) or (WPJ.Position+4>=WPJ.Size);
    WPJ.Seek(3,soFromCurrent);
    WPJ.ReadBuffer(ext,4);
    WPJ.Seek(-4,soFromCurrent);
  Until (ext=DATA_MAGIC2) or (WPJ.Position+4>=WPJ.Size);
  
  WPJ.Seek(-3,soFromCurrent);

  // find the beginning
  WPJ.Seek(-2,soFromCurrent);

  LineDataPos:=WPJ.Position;
  // Read line Info
  For i:=1 To dwLineNum Do
      WPJ.ReadBuffer(LinesData[i-1],1);

  EndLineDataPos:=WPJ.Position;

  // find the beginning
  Repeat
    WPJ.ReadBuffer(bt,1);
  Until bt=0;

  // find the beginning
  Repeat
    WPJ.ReadBuffer(bt,1);
  Until bt<>0;

  WPJ.Seek(-1,soFromCurrent);

  // enum color data
  bkupPos:=WPJ.Position;
  ColorPos:=bkupPos;
  n:=0;
  Repeat
     WPJ.ReadBuffer(ColRec.LineNum,4);
     WPJ.ReadBuffer(ColRec.Color,2);
     WPJ.ReadBuffer(ColRec.Size,1);
     Inc(n);
  Until ColRec.LineNum+ColRec.Color+ColRec.Size=0;

  // Read color data
  Dec(n,2);
  dwColorNum:=n+1;
  SetLength(ColorData,dwColorNum);
  WPJ.Seek(bkupPos,soFromBeginning);
  For i:=0 to n do
   begin
     WPJ.ReadBuffer(ColRec.LineNum,4);
     WPJ.ReadBuffer(ColRec.Color,2);
     WPJ.ReadBuffer(ColRec.Size,1);
     ColorData[i]:=ColRec;
   end;
   EndColorPos:=WPJ.Position;
end;

procedure TWPJALF.SaveCopy(sWPJFileName: String);
var i, iCol : Integer;
    s, rva, rva1, sline : String;
    color : Word;
    delta_lines,cnt, boza, dw : DWORD;
    Colors, LineData : TMemoryStream;
    wpj1, alf1 : TFileStream;
    ColDTA : TWPJColorRec;
    bt : Byte;

    procedure GetRVACol(var s : String);
    begin
        rva:=copy(s,1,8);
        color:=StrToInt(Copy(s,9,2));
        s:=Copy(s,11,Length(s)-10);
    end;

begin
  //Free some memory
  Alf.Free; alf:=nil;

  wpj1:=TFileStream.Create(sWPJFileName,fmCreate);
  alf1:=TFileStream.Create(ChangeFileExt(sWPJFileName,'.alf'),fmCreate);
  Colors:=TMemoryStream.Create;
  LineData:=TMemoryStream.Create;

  // copyright line will be inserted later
  delta_lines:=1;

  cnt:=0;
  i:=-1;
  iCol:=-1;
  Try
    if i<ReffStrings.Count-1 then Inc(i);
    s:=ReffStrings[i];
    GetRVACol(s);

    if iCol<dwColorNum-1 then Inc(iCol);
    ColDTA:=ColorData[iCol];

    // first line
    sline:=Listing[0];
    bt:=LinesData[cnt];
    LineData.WriteBuffer(bt,1);
    alf1.WriteBuffer(sLine[1],bt);

    //copyright string
     ALF1.WriteBuffer(sCopyrightString,Length(sCopyrightString));
     rva:='';

    for cnt:=1 to dwLineNum-1 Do
     begin
      sline:=Listing[cnt];
      if Copy(sLine,1,1)=':' then rva1:=DWORD2HEX(HEX2DWORD(Copy(sline,2,8)))
                             else rva1:='00000000';

      // correcting entry point line num when reached
      if dwPEP=cnt then
         dwNewPEP:=dwPEP+delta_lines;

      if rva=rva1 then
         repeat
           // add comment here
           bt:=Length(s);
           alf1.WriteBuffer(s[1],bt);
           Dec(bt,2);
           LineData.WriteBuffer(bt,1);

           boza:=cnt+delta_lines;
           Colors.WriteBuffer(boza,4);
           Colors.WriteBuffer(Color,2);
           Colors.WriteBuffer(bt,1);
           Inc(delta_lines);

           // getnext line for reference
           if i<ReffStrings.Count-1 then
            begin
              Inc(i);
              s:=ReffStrings[i];
              GetRVACol(s);
            end
            else rva:='FFFFFFFE';
         until rva<>rva1;

       if rva<rva1 then
         begin
           // getnext line for reference
           if i<ReffStrings.Count-1 then
            begin
              Inc(i);
              s:=ReffStrings[i];
              GetRVACol(s);
            end
            else rva:='FFFFFFFE';
         end;

      ALF1.WriteBuffer(sline[1],Length(sline));
      bt:=LinesData[cnt];
      LineData.WriteBuffer(bt,1);

      if ColDta.LineNum<=cnt then
        begin
          if iCol<=dwColorNum-1 then
           begin
            ColDta.LineNum:=ColDta.LineNum+delta_lines;
            Colors.WriteBuffer(ColDta.LineNum,4);
            Colors.WriteBuffer(ColDta.Color,2);
            Colors.WriteBuffer(ColDta.Size,1);
            if iCol=dwColorNum-1 then Inc(iCol);
           end;
          if iCol<dwColorNum-1 then
            begin
              Inc(iCol);
              ColDTA:=ColorData[iCol];
            end;
        end;
     end;

     // Copyright string color data
     ColDta.LineNum:=1;ColDta.Color:=2;ColDta.Size:=Length(sCopyrightString)-2;
     Colors.WriteBuffer(ColDta.LineNum,4);
     Colors.WriteBuffer(ColDta.Color,2);
     Colors.WriteBuffer(ColDta.Size,1);

     // Save WPJ1 File
     LineData.Seek(0,soFromBeginning);
     WPJ.Seek(0,soFrombeginning);

     // move all to sizePos
     Repeat
       WPJ.ReadBuffer(bt,1);
       WPJ1.WriteBuffer(bt,1);
     Until WPJ.Position=SizePos;

     // Update line num
     WPJ.Seek(4,soFromCurrent);
     dwLineNum:=dwLineNum+delta_lines;
     WPJ1.WriteBuffer(dwLineNum,4);

     // Update code start
     WPJ.ReadBuffer(dw,4); Inc(dw);
     WPJ1.WriteBuffer(bt,4);

     // Correction of program entry point line num
     WPJ.Seek(4,soFromCurrent);
     WPJ1.WriteBuffer(dwNewPEP,4);



     // move all to LineDataPos
     Repeat
       WPJ.ReadBuffer(bt,1);
       WPJ1.WriteBuffer(bt,1);
     Until WPJ.Position=LineDataPos;

     // adding line length data
     cnt:=0;
     Repeat
       LineData.ReadBuffer(bt,1);
       if cnt=1 then begin
           bt:=$2C;
           WPJ1.WriteBuffer(bt,1);
         end;
       WPJ1.WriteBuffer(bt,1);
       Inc(cnt);
     Until LineData.Position>=LineData.Size;

     // move all to ColorDataPos
     WPJ.Seek(EndLineDataPos,soFromBeginning);
     Repeat
       WPJ.ReadBuffer(bt,1);
       WPJ1.WriteBuffer(bt,1);
     Until WPJ.Position=ColorPos;

     // Adding ColorData
     Colors.Seek(0,soFromBeginning);
     Repeat
       Colors.ReadBuffer(bt,1);
       WPJ1.WriteBuffer(bt,1);
     Until Colors.Position>=Colors.Size;

     // moving all the rest
     WPJ.Seek(EndColorPos,soFromBeginning);
     Repeat
       WPJ.ReadBuffer(bt,1);
       WPJ1.WriteBuffer(bt,1);
     Until WPJ.Position>=WPJ.Size;

     //WPJ1.SaveToFile(sWPJFileName);
     //ALF1.SaveToFile(ChangeFileExt(sWPJFileName,'.alf'));
  Finally
    ALF1.Free;
    WPJ1.Free;
    Colors.free;
    LineData.free;
  End;
end;

end.
