unit DeDeSym;
//////////////////////////
// Last Change: 21.II.2001
//////////////////////////

interface

Uses Classes, DeDeClasses, DeDeConstants;

// DeDe Symbols ///////////////////////////////////////////////////////
Type

  TDeDeSymbol = Class
  protected
    procedure UpdateFirstByteSet;
  public
    Sym   : TMemoryStream;
    Str   : TMemoryStream;
    Index : TBoundArray;
    Count : Integer;
    Comment : String;
    Mode  : Byte;
    PatternSize : Byte;
    FileName : String;
    Constructor Create; virtual;
    Function LoadSymbol(AsFileName : String) : Boolean;
    Destructor Destroy; override;
  End;


  Function UnlinkCalls(Var buff : TSymBuffer; Level : byte = 0; RVA : DWORD = 0) : Boolean;
  Function GetDSFVersion(Sym : TDeDeSymbol) : String;
  procedure ParseExportName(var sExport : String);
  procedure ParseExportParam(var sParam : String);
  procedure ParseExportParamFlags(sFlags : String; var beg, en : String);
  function DCUFixParams(s : String) : String;
  function DCUExculdeParamNames(s : String) : String;

var BPLPEHeader : TPEHeader;
    Glob_B5, Glob_B6, Glob_B7, Glob_B10 : Cardinal;
    bMakeCRC : Boolean;

    FirstByteSet : Set of Byte;
    FirstCodeRVA : Cardinal;

implementation

Uses
  DeDeDisASM, DisASM, HexTools, DeDeBPL, VCLUnZip, SysUtils, Dialogs,
  crc32, DeDeRES;

var DASM : TDisAsm;

function InCodeSegment(s : String) : Boolean; overload;
var rva,i : dword;
    DELTA_PHYS : DWORD;
begin
  Result:=False;
  If Length(s)<>8 Then Exit;
  For i:=1 to length(s) do if not (s[i] in ['0'..'9', 'A'..'F']) then Exit;
  rva:=Hex2DWORD(s);

  DELTA_PHYS := BPLPEHeader.IMAGE_BASE
    + BPLPEHeader.Objects[1].RVA
    - BPLPEHeader.Objects[1].PHYSICAL_OFFSET;

  Result:=((RVA-DELTA_PHYS)>=BPLPEHeader.Objects[1].PHYSICAL_OFFSET)
      and ((RVA-DELTA_PHYS)<=BPLPEHeader.Objects[1].PHYSICAL_OFFSET+BPLPEHeader.Objects[1].PHYSICAL_SIZE)
end;

function InCodeSegment(rva : dword) : Boolean; overload;
var DELTA_PHYS : DWORD;
begin
  //Result:=False;
  DELTA_PHYS:=  BPLPEHeader.IMAGE_BASE
               +BPLPEHeader.Objects[1].RVA
               -BPLPEHeader.Objects[1].PHYSICAL_OFFSET;
  Result:=((RVA-DELTA_PHYS)>=BPLPEHeader.Objects[1].PHYSICAL_OFFSET)
      and ((RVA-DELTA_PHYS)<=BPLPEHeader.Objects[1].PHYSICAL_OFFSET+BPLPEHeader.Objects[1].PHYSICAL_SIZE)
end;


function Power(x,y : DWORD) : DWORD;
var i : Integer;
begin
  result:=1;
  for i:=1 to y do result:=result*x;
end;

// CRC of bytes aof called procedures
Procedure MakeCallCRC(var CRC : DWORD; buff : TSymBuffer; ipos : Integer; RVA : DWORD);
var dwOffset : DWORD;
    Offs : LongInt;
    i : Integer;
    pbuf : TSymBuffer;
begin
  dwOffset:=0;
  if iPos>_PatternSize-4 then exit;
  for i:=0 to 3 do dwOffset:=dwOffset+buff[iPos+i]*Power(256,i);

 // This offset is relative and should be corrected
  dwOffset:=dwOffset+iPos+5;

  Offs:=PEHeader.Objects[1].PHYSICAL_OFFSET -PEHeader.Objects[1].RVA -PEHeader.IMAGE_BASE+RVA;

  if buff[iPos+3]=$FF  then Offs:=Offs+(dwOffset-$FFFFFFFF)
                       else Offs:=Offs+dwOffset;

  if Offs>DeDeClasses.PEFile.PEStream.Size-_PatternSize then exit;
  if Offs<0 then exit;
  
  DeDeClasses.PEFile.PEStream.BeginSearch;
  FillChar(pbuf,sizeof(pbuf),0);
  Try
    DeDeClasses.PEFile.PEStream.Seek(Offs,soFromBeginning);
    DeDeClasses.PEFile.PEStream.ReadBuffer(pbuf[1],_PatternSize);

    // The function that is called is export;
    if (pbuf[1]=$FF) and (pbuf[2]=$25) then exit;

    UnlinkCalls(pbuf,1);
    crc32.crc32val:=CRC;
    crc32.updatecrc(pbuf,_PatternSize);
    CRC:=crc32.crc32val;
  Finally
    DeDeClasses.PEFile.PEStream.EndSearch;
  End;
End;

Function UnlinkCalls(Var buff : TSymBuffer; Level : byte = 0; RVA : DWORD = 0) : Boolean;
var s{,ins}   : String;
    j,k,i{,ps} : Integer;
//    w  : Word;
    dw : DWORD;
    CRC : DWORD;
Begin
   j:=1;
   if Level=0 then CRC:=0;
   Repeat
     s:=DASM.GetInstruction(@buff[j],k);

     if k=5 then
       begin
         // 5 byte instructions
         // E8XXXXXXXX   - Call address (same segment)
         // 9AXXXXXXXX   - Call address (other segment)
         // 68XXXXXXXX   - Push address (same segment)
         // B8-BF        - Mov reg32, value **! these ones are neseccary !!!
         ///A0-A3        - eax,al moves
         // E9xxxxxxxx   - Long jump

         ////////////////////////////////////////////////////
         //// FOR NEW DSF ENGINE - CRC CHECK INCLUDED
         ////////////////////////////////////////////////////
         if (Level=0) and (bMakeCRC) then
            if (buff[j] in [$E8,$9A])
                 then MakeCallCRC(CRC, buff, j+1, RVA);
         ////////////////////////////////////////////////////

         if buff[j] in [$E8,$E9,$9A,$A0..$A3,$A9]
            then begin
              for i:=1 to 4 do buff[j+i]:=0;
              Inc(Glob_B5);
            end;

         /////////////////////////////////////////////////////////
         // Unlink only if the value is > IMAGE_BASE+BASE_OF_CODE
         // DO IT ALWAYS !!! (Many Idents build from DCU not found)
         /////////////////////////////////////////////////////////
         if buff[j] in [$68,$B8..$BF]
           then begin
             //dw:=buff[j+1]+buff[j+2]*256+buff[j+3]*256*256+buff[j+4]*256*256*256;
             //if dw>=FirstCodeRVA then
             //  begin
                  for i:=1 to 4 do buff[j+i]:=0;
                  Inc(Glob_B5);
             //  end;
           end;
       end;

     if k=6 then
       begin
         // 6 byte instructions
         //
         // FF05xxxxxxxx - Inc dword ptr [offset]
         // FF0Dxxxxxxxx - Dec dword ptr [offset]
         // FF15xxxxxxxx - Call dword ptr [offset]
         // FF1Dxxxxxxxx - Call [offset]
         // FF25xxxxxxxx - Jmp dword ptr [offset]
         // FF2Dxxxxxxxx - Jmp [offset]
         // FF35xxxxxxxx - Push dword ptr [offset]
         //
         // 86 - xchg [offset], reg16
         // 8A - mov reg16, byte ptr [offset]
         // 8B - mov reg32, dword ptr [offset]
         // 8C - mov word ptr [offset], segreg
         // 8D - lea reg32, [offset]
         // 8E - mov segreg, word prt [offset]
         //
         // C5 - lds reg32, [offset]
         //
         // D8..DF, second byte in [05,0D..35,3D] -> FPU instructions
         //     that works with relative offsets

         ////////////////////////////////////////////////////
         //// FOR NEW DSF ENGINE - CRC CHECK INCLUDED
         ////////////////////////////////////////////////////
         //if Level=0 then
         //   if (buff[j]=$FF) and (buff[j+1] in [$15,$1D])
         //        then MakeCallCRC(CRC, buff, j+2);
         ////////////////////////////////////////////////////

         if     ((buff[j] in [$FF])  and (buff[j+1] in [$05,$0D,$15,$1D,$25,$2D,$35]))
         or ((buff[j] in [$84..$8F, $C4..$C5]) and (buff[j+1] in [$05,$0D,$15,$1D,$25,$2D,$35,$3D,$80..$83,$85..$8B,$8D..$93,$95..$9B,$9D..$A3,$A5..$AB,$AD..$B3,$B5..$BB,$BD..$BF]))
         or ((buff[j]=$0F) and (buff[j+1] in [$84,$85])
         or ((buff[j] in [$D8..$DF]) and (buff[j+1] in [$05,$0D,$15,$1D,$25,$2D,$35,$3D]))
         or (buff[j]=$C7))

            then begin
              for i:=2 to 5 do buff[j+i]:=0;
              Inc(Glob_B6);
            end;
       end;

     if k=7 then
       begin
         // 7 byte instructions
         // 80 ..83  - add, or, adc, sbb, and, sub, xor, cmp
         //       ?? ptr [offset], imidiate_??_data
         /// FF0485xxxxxxxx         inc  dword ptr [offset+eax*4]
         /// FF0D85xxxxxxxx         dec  dword ptr [offset+eax*4]
         /// FF1485xxxxxxxx         call dword ptr [offset+eax*4]
         /// FF1C85xxxxxxxx         call [$offset+eax*4]
         /// FF2485xxxxxxxx         jmp  dword ptr [offset+eax*4]
         /// FF2C85xxxxxxxx         jmp  [offset+eax*4]
         /// FF3485xxxxxxxx         push dword ptr [offset+eax*4]
         /// C605xxxxxxxxYY         mov  byte ptr [$48BB0D], $YY
         /// 8B0485xxxxxxxx
         //
         //  FPU Stuff
         //  D8..DF, 0C..3C|04..34, 05..F5|0D..FD
         if (   (buff[j+0] in [$C6, $80..$83]) and  (buff[j+1] in [$05,$0D,$15,$1D,$25,$2D,$35,$3D,$85,$8D,$95,$9D,$A5,$AD,$B5,$BD]))
            or ((buff[j+0] in [$D8..$DF,$8B,$FF]) and (buff[j+1] in [$04,$0C,$14,$1C,$24,$2C,$34]) and (buff[j+2] in [$05,$0D,$15,$1D,$25,$2D,$35,$3D,$85,$8D,$95,$9D,$A5,$AD,$B5,$BD,$C5,$CD,$E5,$ED,$F5,$FD])
            or ((buff[j+0] in [$C7]) and (buff[j+1] in [$40..$7F])))
            then begin
              if (buff[j+0] in [$C7])
                then for i:=3 to 6 do buff[j+i]:=0
                else for i:=2 to 5 do buff[j+i]:=0;
              Inc(Glob_B7);
            end;
       end;

     if k=10 then
       begin
         // 10 byte instructions
         //
         // 81 - add, or, adc, sbb, and, sub, xor, cmp
         //       dword ptr [offset], imidiate_dword_data
         //
         // C705 - mov dword ptr [offset], imidiate_dword_data
         //
         // 69 [05,0D..35,3D] -> imul reg, [offset], imm_data
         if (    (buff[j+0] in [$81])
            and (buff[j+1] in [$05,$0D,$15,$1D,$25,$2D,$35,$3D,
                               $85,$8D,$95,$9D,$A5,$AD,$B5,$BD]))
             or ((buff[j]=$C7) {and (buff[j+1]=$05)})
             or ((buff[j]=$69) and (buff[j+1] in [$05,$0D,$15,$1D,$25,$2D,$35,$3D]))
            then begin
              for i:=2 to 5 do buff[j+i]:=0;
              Inc(Glob_B10);
            end;
       end;
     j:=j+k;
   Until (j>=_PatternSize) or (s='ret');

   Result:=j>=3;

   For i:=j to _PatternSize do
       buff[i]:=0;

////////////////////////////////////////////////////
//// FOR NEW DSF ENGINE - CRC CHECK INCLUDED
////////////////////////////////////////////////////
   if CRC<>0 then
    begin
      buff[_PatternSize-0]:=CRC;
      buff[_PatternSize-1]:=CRC shr 8;
      buff[_PatternSize-2]:=CRC shr 16;
      buff[_PatternSize-3]:=CRC shr 24;
    end;
End;


{ TDeDeSymbol }

constructor TDeDeSymbol.Create;
begin
  Inherited Create;

  Sym:=TMemoryStream.Create;
  Str:=TMemoryStream.Create;
end;

destructor TDeDeSymbol.Destroy;
begin
  Sym.Free;
  Str.Free;

  Inherited Destroy;
end;

function TDeDeSymbol.LoadSymbol(AsFileName: String): Boolean;
var FS : TMemoryStream;
    s : String;
    UnZip : TVCLUnZip;
begin
  Result:=False;
  Sym.Clear;
  Str.Clear;

  Try
// LoadBPLSymbolFile already Do this
//    FS:=TMemoryStream.Create;
//    Try
//      UnZip:=TVCLUnZip.Create(nil);
//      Try
//       UnZip.ZipName:=AsFileName;
//       UnZip.UnZipToStream(FS,ExtractFileName(AsFileName));
//       FS.Seek(0,soFromBeginning);
//      Finally
//       UnZip.Free;
//      End;
//      // Read Magic
//      SetLength(s,4);
//      FS.ReadBuffer(s[1],4);
//      If s<>'DSF!' Then Exit;
//      // Read Flags
//      FS.ReadBuffer(Mode,1);
//      // Read Record Count
//      FS.ReadBuffer(Count,2);
//    Finally
//      FS.Free;
//    End;
//    SetLength(Index,Count);

    FileName:=AsFileName;
    Result := DeDeBPL.LoadBPLSymbolFile(sym, str, AsFileName, mode, PatternSize,
      Count,Comment,Index);

    UpdateFirstByteSet;
  Except
    ShowMessage(err_load_symfile+AsFileName+'"');
    Result:=False;
  End;
end;

Function GetDSFVersion(Sym : TDeDeSymbol) : String;
var ident : Integer;
Begin
  Result:='unknown';

  ident:=Sym.PatternSize;

  If ident=$F Then
    Begin
      Result:='1.0';
      Exit;
    End;

  If ident=32 Then
    Begin
      Result:='1.2';
      Exit;
    End;

  If ident=40 Then
    Begin
      Result:='2.0';
      Exit;
    End;

  If ident=50 Then
    Begin
      Result:='2.1';
      Exit;
    End;
End;


Procedure ParseExportParamFlags(sFlags : String; var beg, en : String);
var i : Integer;
Begin
  en:='';beg:='';
  i:=1;
  While i<=Length(sFlags) Do
     begin
       case sFlags[i] of
         // i = integer
         'i' : en:=en+'; Integer';
         // j = int64
         'j' : en:=en+'; Int64';
         // g = extended
         'g' : en:=en+'; Extended';
         // ui = Cardinal
         'u' : begin
                 Inc(i);
                 //ui = Cardinal
                 If Copy(sFlags,i,1)='i' then en:=en+'; Cardinal';
               end;
          
          // p = Pointer
         'p' : en:=en+'; Pointer';
         'x' : begin
                 Inc(i);
                 //xi = Array of
                 If Copy(sFlags,i,1)='i' then beg:='Array Of ';
                 if Copy(sFlags,i,1)='t' then
                   begin
                      //xt1 = String
                      en:=en+'; String';
                      //inc(i);
                      //If Copy(sFlags,i,1)='1' then en:=en+'; String';
                   end;
               end;
         // vt1 VAR
         'v' : begin
                 Inc(i);
                 if Copy(sFlags,i,1)='t' then
                   begin
                      //xt1 = String
                      en:=en+'; VAR';
                      //inc(i);
                      //If Copy(sFlags,i,1)='1' then en:=en+'; String';
                   end;
               end;

       end;
       inc(i);
     end;

  If copy(en,Length(en)-8,9)='; Pointer' then
    en:=Copy(en,1,Length(en)-9);
End;

procedure ParseExportParam(var sParam : String);
var s, ss, s1, s0, beg, mid, en, sf, sf0, sp, sfx : String;
    i,len : Integer;
    bChanges, bSkip, bFirst, bFlag : Boolean;
begin
    sp:=sParam+' ';
    s:='';
    i:=Pos('$',sp);
    s0:=Copy(sp,1,i-1);
    bFirst:=True;
    repeat
      bChanges:=False;
      i:=Pos('$',sp);
      If i=0 Then
         begin
           s:=s+sp;
           break;
         end;
      repeat inc(i) until Copy(sp,i,1)[1] in ['0'..'9',' '];

      // Here the flags at the beginning of a params are parsed
      sf0:=Copy(sp,1,i-1);
      If bFirst Then
         Begin
           bFirst:=False;
           ParseExportParamFlags(sf0,beg,en);
           If Copy(en,1,2)='; ' then en:=Copy(en,3,Length(en)-2);
           s:=s+beg+en;
         End;
      //

      If Copy(sp,i,1)<>' ' Then
        Begin
          dec(i);ss:='';
          repeat inc(i); ss:=ss+Copy(sp,i,1) until not (Copy(sp,i,1)[1] in ['0'..'9']);
          ss:=Copy(ss,1,Length(ss)-1);
          len:=StrToInt(ss);
          mid:='';
          If not (   (Pos('$',Copy(sp,i,len))<>0)
                 and (Pos('%',Copy(sp,i,len))=0))
                 then if (len>3) then mid:=Copy(sp,i,len);
          inc(i,len);

          // Parsing Flags Meaning
          en:='';beg:='';sf:='';
          while (i<Length(sp)) and (Copy(sp,i,1)[1] in ['a'..'z']) do
             Begin
              sf:=sf+sp[i];
              Inc(i);
             End;

          ParseExportParamFlags(sf,beg,en);

          s:=s+'; '+beg+mid+en;
          If i<>Length(sp) then sp:=Copy(sp,i,Length(sp)-i+1)
                           else sp:='';
          If (sp<>'') and (Copy(sp,1,1)[1] in ['0'..'9']) Then sp:='$'+sp;
          bChanges:=True;
        End;
    until not bChanges;

    ss:=s;s:='';
    bChanges:=True;bSkip:=False;
    For i:=1 To Length(ss) Do
      Case ss[i] of
        '@' : if bSkip then s1:=s1+'.'
                       else s:=s+'.';
        '%' : begin
                if bChanges
                   then begin
                     bSkip:=True;
                     s1:='';
                   end
                   else begin
                     bSkip:=False;
                     If Copy(s1,1,3)='Set' Then s1:=Copy(s1,4,Length(s1)-3);
                     s1:=s1+' ';
                     ParseExportParam(s1);
                     If Copy(s1,1,2)='; ' Then s1:=Copy(s1,3,Length(s1)-2);
                     If Copy(s1,Length(s1)-2,3)=';  ' Then s1:=Copy(s1,1,Length(s1)-3);
                     If Copy(s1,Length(s1)-1,2)='; ' Then s1:=Copy(s1,1,Length(s1)-2);
                     If Copy(s1,Length(s1),1)=' ' Then s1:=Copy(s1,1,Length(s1)-1);

                     s:=s+'['+s1+']';
                   end;
                bChanges:=not bChanges;
              end;
        Else if bSkip then s1:=s1+ss[i]
                      else s:=s+ss[i];
      End;
    s:=s0+s;
    sfx:='';
    bFlag:=False;
    For i:=1 To Length(s) Do
     Begin
       If bFlag then
         if s[i] in [#32,';']
            then begin
               if s[i]=#32 Then if Copy(sfx,Length(sfx),1)<>#32 then sfx:=sfx+' ';
               continue;
            end
            else bFlag:=False;
       If (s[i]=';') and (not bFlag) Then
         begin
           bFlag:=True;
           sfx:=sfx+';';
           continue;
         end;
       sfx:=sfx+s[i];
     End;
   sParam:=sfx;
end;

procedure ParseExportName(var sExport : String);
var s1 : String;
    i : Integer;
begin
  s1:='';
  For i:=1 To Length(sExport) Do
    Case sExport[i] of
      '@' : s1:=s1+'.'
      Else s1:=s1+sExport[i];
    End;
  sExport:=s1;
end;


function DCUFixParams(s : String) : String;
var  iPos, len : Integer;
    i : Integer;

const fixups_count=3;
      fixups : array [1..fixups_count,1..2] of String =
        (
          ('array[$0..-$1]'         ,'array')
         ,('false..true'            ,'boolean')
         ,('$'                      ,'')

        );
begin
  i:=0;
  // Dont use "for-loop" here !!!!
  // The order of appling fixups is important
  //
  // For i:=0 to fixoups_count do
  // Here the compiler can produce code that decrements from max value
  // instead of increment from min that will fuck up the result
  repeat
    iPos:=Pos(fixups[i+1,1],s);
    While iPos<>0 Do
     Begin
       len:=Length(fixups[i+1,1]);
       s:=Copy(s,1,iPos-1)+fixups[i+1,2]+Copy(s,iPos+len,Length(s)-iPos-len+1);
       iPos:=Pos(fixups[i+1,1],s);
     End;
     Inc(i);
  until i>=fixups_count;

  Result:=s;  
end;

// This should replace param names with param type name
//
// (sParam1, sParam2 : Stirng; dwParam3 : DWORD) -> (String; String; DWORD;)
function DCUExculdeParamNames(s : String) : String;
var s0,s1,s2,ss,st : String;
    iPos, iPos2, i : Integer;
    TmpLst : TStringList;
begin
  iPos:=Pos('(',s);
  s1:=Copy(s,1,iPos); s:=Copy(s,iPos+1,Length(s)-iPos);
  iPos:=Pos(')',s);
  s2:=Copy(s,iPos,Length(s)-iPos+1); s:=Copy(s,1,iPos-1);

  // Replacing
  s0:='';
  TmpLst:=TStringList.Create;
  Try
    iPos:=Pos(':',s);
    while iPos<>0 do
      begin
        iPos2:=Pos(';',s);
        if iPos2=0 then
          begin
            iPos2:=Length(s)+1;
            s:=s+';';
          end;
        ss:=Copy(s,1,iPos-1);
        st:=Copy(s,iPos+1,iPos2-iPos-1);
        st:=Trim(st)+';';
        TmpLst.CommaText:=ss;
        s:=Copy(s,iPos2+1,Length(s)-iPos2);
        iPos:=Pos(':',s);

        for iPos2:=1 to TmpLst.Count Do s0:=s0+st;
      end;
  Finally
    TmpLst.Free;
  End;
  Result:=s1+s0+s2;

  i:=Pos(';)',Result);
  if i<>0 then Result:=Copy(Result,1,i-1)+Copy(Result,i+1,Length(Result)-i);
  s:=Result;

  Result:='';
  For i:=1 to Length(s) Do
    if s[i]<>' ' then Result:=Result+s[i];

end;

procedure TDeDeSymbol.UpdateFirstByteSet;
var i : Integer;
    buff : TSymBuffer;
begin
  Sym.Seek(0,soFromBeginning);
  for i:=0 To Count-1 Do
   Begin
     Sym.ReadBuffer(buff[1],_PatternSize);
     FirstByteSet:=FirstByteSet+[buff[1]];
   End;
end;

initialization
  DASM:=TDisAsm.Create;
  FirstByteSet:=[];

finalization
  DASM.Free;

end.
