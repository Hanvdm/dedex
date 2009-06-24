unit DeDeDCUDumper;
///////////////////////////////////////////////////////////////
//   This unit implements some routines that uses the DCU2INT
// engine and returns dumped .DCU files in TStringList. They
// are used from both DCU dumper and DCU.2.DSF engine
///////////////////////////////////////////////////////////////
// Last Change: 08.II.2001
///////////////////////////////////////////////////////////////

interface

Uses Classes;

function ProcessParms(sOPTIONS : String): boolean;
procedure ProcessFile(FN: String; SaveOut : TStrings; bRemoveInstructions : Boolean = False; bApplyFixes : Boolean = True);

implementation

Uses DCU32, SysUtils, DCU_Out, DCU_In, DCUTbl, DeDeRES, DeDeConstants;


function ReplaceStar(FNRes,FN: String): String; forward;

function ProcessParms(sOPTIONS : String): boolean;
var
  i,j: integer;
  Ch: Char;
  TmpList : TStringList;
  PS : String;
begin
  Result:=True;
  TmpList:=TStringList.Create;
  TmpList.CommaText:=sOPTIONS;
  Try
    for i:=0 to TmpList.Count-1 do begin
      PS := TmpList[i];
      if (Length(PS)>1)and((PS[1]='/')or(PS[1]='-')) then begin
        Ch := UpCase(PS[2]);
        case Ch of
          'S': begin
            if Length(PS)=2 then
              SetShowAll
            else begin
              for j:=3 to Length(PS) do begin
                Ch := {UpCase(}PS[j]{)};
                case Ch of
                  'I': ShowImpNames := false;
                  'T': ShowTypeTbl := true;
                  'A': ShowAddrTbl := true;
                  'D': ShowDataBlock := true;
                  'F': ShowFixupTbl := true;
                  'V': ShowAuxValues := true;
                  'M': ResolveMethods := false;
                  'C': ResolveConsts := false;
                  'd': ShowDotTypes := true;
                  'v': ShowVMT := true;
                else
                  Result:=false;
                  Raise Exception.CreateFmt(err_unk_dcu_flag,[Ch]);
                  Exit;
                end ;
              end ;
            end ;
          end ;
          'I': InterfaceOnly := true;
          'U': begin
            Delete(PS,1,2);
            DCUPath := PS;
          end ;
          'N': begin
            Delete(PS,1,2);
            NoNamePrefix := PS;
          end ;
          'D': begin
            Delete(PS,1,2);
            DotNamePrefix := PS;
          end;
         End;
      end ;
    end ;
  Finally
    TmpList.Free;
  End;
end;

function ReplaceStar(FNRes,FN: String): String;
var
  CP: PChar;
begin
  CP := StrScan(PChar(FNRes),'*');
  if CP=Nil then begin
    Result := FNRes;
    Exit;
  end ;
  if StrScan(CP+1,'*')<>Nil then
    raise Exception.Create(err_2nd_ast_notallow);
  FN := ExtractFilename(FN);
  if (CP+1)^=#0 then begin
    Result := Copy(FNRes,1,CP-PChar(FNRes))+ChangeFileExt(FN,'.int');
    Exit;
  end;
  Result := Copy(FNRes,1,CP-PChar(FNRes))+ChangeFileExt(FN,'')+Copy(FNRes,CP-PChar(FNRes)+2,MaxInt);
end ;

////////////////////////////////////////////////////////////////////////////
//   Fixes the raw dcu2int output format. Removes the crap opcodes shown as
// their ascii values, fixes offset to be always 8digit hex value, removes
// the '|' before the instructions, enlarge the space for opcodes to be
// capable to 10 opcodes.
//
// change this:
//
// begin
//  00: S      [53                  | PUSH EBX
//  01: V      |56                  | PUSH ESI
//
// to this:
//
// begin
//  00000000 : 53                         PUSH EBX
//  00000001 : 56                         PUSH ESI
//
//   The function can also remove the instructions and left only opcodes and
// offsets. This is done if bRemoveInstructions is set to True and is used
// from DCU.2.DSF engine as preprocessing to DCU2INT output parser
////////////////////////////////////////////////////////////////////////////
procedure FixDCUOutPutFormat(list : TStrings; bRemoveInstructions : Boolean);
var i, iLevel : Integer;
    s : String;
    bBegin, bEnd, bDontProcess, bImplementation, bDontAdd : Boolean;

  // Fixes line
  Procedure FixLine(var s : String);
  var iPos1,iPos2, iPos2a, iPos3, iFix : Integer;
      sOffs, sOpcode, sInstruction : String;

     // Returns the less non zero value from x and y
     function MinNotZ(x,y : Integer) : Integer;
     begin
       if x=0 then begin result:=y; exit; end;
       if y=0 then begin result:=x; exit; end;
       if x<y then result:=x else result:=y;
     end;

  begin
    iPos2:=0;
    iFix:=0;

    // Finds the end possition of the offset string as the
    // possition of the first ':' char
    iPos1:=Pos(':',s);

    // Finds the begin possition of opcode strings as the
    // position of the first '|' or '[' that is greather
    // than iPos1+8 and replaces all sooner met '|' or '['
    // with space
    While iPos2<iPos1+8 do
     begin
       iPos2:=Pos('|',s);
       iPos2a:=Pos('[',s);
       iPos2:=MinNotZ(iPos2,iPos2a);
       if iPos2<>0
          then s[iPos2]:=' '
          else break;
     end;

   // Finds the start possition of the instruction string
   // as the possition of the next '|'
   iPos3:=Pos('|',s);

   // Fixes offset stirng
   sOffs:=Copy(s,1,iPos1-1);
   While Copy(sOffs,1,1)=' ' do
     begin
       sOffs:=Copy(sOffs,2,Length(sOffs)-1);
       Inc(iFix)
     end;
   While Length(sOffs)<8 do sOffs:='0'+sOffs;

   // Fixes opcode string
   sOpcode:=Trim(Copy(s,iPos2+1,iPos3-iPos2-1));
   While Length(sOpcode)<3*10 do sOpcode:=sOpcode+' ';

   // Fixes Instruction and Offset string if bRemoveInstruction is
   // set to True
   if bRemoveInstructions
     then sInstruction:=''
     else begin
       sInstruction:=Trim(Copy(s,iPos3+1,Length(s)-iPos3));
       for iPos2:=0 to iFix Do sOffs:=' '+sOffs;
     end;

   // Makes the resulting fixed line
   s:=Format('%s : %s%s',[sOffs,sOpcode,sInstruction]);
  end;

var iPos1, iPos2, iParensCount : Integer;
    bDeclarationContinue : Boolean;

  procedure CalsParens(s : String);
  var k : Integer;
  begin
    for k:=1 to Length(s) do
     begin
       if s[k]='(' then Inc(iParensCount);
       if s[k]=')' then Dec(iParensCount);
     end;
   if iParensCount<0 then iParensCount:=0;  
  end;

var bClass : Boolean;  

begin
  iLevel:=0;
  iParensCount:=0;
  bDontProcess:=False;
  bDontAdd:=False;
  bEnd:=False;
  bBegin:=False;
  bImplementation:=False;
  bDeclarationContinue:=False;
  bClass:=False;

  // Read all the lines, makes a simple parse and
  // fixes them if needed
  For i:=0 to list.Count-1 do
    begin
      bDontProcess:=False;
      s:=list[i];

      if Pos('implementation'#10#13,s+#10#13)<>0
        then begin
          bImplementation:=True;
          iLevel:=0;
          // 'implementation' is always added
          continue;
        end;


      iPos1:=Pos('begin'#10#13,s+#10#13);
      if (iPos1<>0) and ((iPos1=1) or (s[iPos1-1]=' '))
        then begin
          bDontProcess:=True;
          bBegin:=True;
          bEnd:=False;
          inc(iLevel);
        end;

      iPos1:=Pos('end;'#10#13,s+#10#13);
      if (iPos1<>0) and ((iPos1=1) or (s[iPos1-1]=' ')) and (not bClass)
        then begin
          bDontProcess:=True;
          bEnd:=True;
          bBegin:=False;
          dec(iLevel);
        end;

       if   (Pos('=class',s)<>0)
         or (Pos('=object',s)<>0)
         or (Pos('=record',s)<>0)
         or (Pos('=interface',s)<>0)
         or (Pos(': record',s)<>0)
         or (Pos(': object',s)<>0)
         or (Pos(': interface',s)<>0)
         or (Pos('^record',s)<>0)
         or (Pos(': ^record',s)<>0)
         or (Pos(' of record',s)<>0) {Array [] of record}
        then begin
          // it is class (needs increasing level)
          // if its not 'TBlah = class of Blha;' declaration
          bClass:=Pos('=class of ',s)=0;
          if bClass then Inc(iLevel);
          bDontProcess:=True;
        end;


      if (bClass) and ((Pos('end;',s)<>0) or (Pos('end);',s)<>0)) then
        begin
          bClass:=False;
          dec(iLevel);
          bDontProcess:=True;
        end;

      // If we are in the implementation part and bRemoveInstructions
      // is set to true we should perform some preparation for parsing
      // excluding all lines that could make mess for dcu.2.int parser
      // only code, 'begin', 'end', and function/procedure declarations
      // should left
      if (not bClass) then
        if bRemoveInstructions then
          if bImplementation then
            begin
              s:=Trim(s);
              bDontAdd:=not (bBegin or ((bEnd) and (bDontProcess)));

              if (Pos('procedure ',s)=1) or (Pos('function ',s)=1) or (bDeclarationContinue) then
                begin
                  // If we have procedure declaration let it stay in the output
                  // and try to find where it finishes by the first ';' of
                  bDontAdd:=False;

                  // Changes iParensCount
                  CalsParens(s);

                  iPos1:=Pos(';',s);
                  iPos2:=Pos(')',s);

                  // The declaration do not have parameters so the end of
                  // declaration is on the same line
                  bDeclarationContinue:= not ((iParensCount=0));
                end;
            end
            //Add only the implementation part
            else bDontAdd:=True
        else bDontAdd:=bRemoveInstructions;    

      // Fix the line if neseccary! This must be applied only
      // for the procedures boddy
      if (iLevel>0) and (not bDontProcess) and (bImplementation) and (not bClass)
          // The fix it!
          then FixLine(s);

      // and add it
      if bDontAdd then s:='';

      list[i]:=s;
    end;

   // If preprocessing for dcu.2.int parsing is enabled
   // remove all
   if bRemoveInstructions then
     for i:=list.count-1 downto 0 do
        if list[i]='' then list.Delete(i)
end;

var FNRes : String;

procedure ProcessFile(FN: String; SaveOut : TStrings; bRemoveInstructions : Boolean = False; bApplyFixes : Boolean = True);
var
  U: TUnit;
  ExcS: String;
  OutRedir: boolean;

  function VerifyParse : Boolean;
  var i, j : Integer;
  begin
    Result:=True;
    j:=0;
    For i:=0 To SaveOut.Count-1 Do
     begin
       Result:=Result and ((SaveOut[i]+'0')[1] in ['i','f','p','b','e','0']);
       case (SaveOut[i]+'0')[1] of
        'b': Inc(j);
        'e': Dec(j);
       end;
     end;
    Result:=Result and (j=0);
    if j<>0 then GlobPreParseWarning:=j
            else GlobPreParseWarning:=-1;
  end;


  //  This proc seeks for more than one 'end;' line one
  //after another and remove them. This could happen
  //because of pre-parser bugs
  procedure FixEnds;
  var i{, LevelCntr} : Integer;
      bEnd : Boolean;
  begin
    // Seeks nulls just in case and removes them
    // Also removes all trash lines (this completely fixes all pre-parser problems)
    For i:=SaveOut.Count-1 downto 0 do
      if (SaveOut[i]='') or (not ((SaveOut[i]+'0')[1] in ['i','f','p','b','e','0']))
         then SaveOut.Delete(i);

    For i:=SaveOut.Count-1 downto 0 do
     begin
      if SaveOut[i]='end;'
       then if bEnd
              then SaveOut.Delete(i+1)
              else bEnd:=True

       // This happens in complicated class declrations
       // in procedure body
       else if (Pos('procedure',SaveOut[i])<>0) or (Pos('function',SaveOut[i])<>0) or (Pos('implementation',SaveOut[i])<>0)
            then begin
              if bEnd then SaveOut.Delete(i+1);
              bEnd:=False;
            end
            else bEnd:=False;
     end;

    // This shit is here because im too lazy to
    // imrove the pre-parser. The lines above
    // removes every 'end;' that is before the 'begin'
    // This can happen if there is type definition
    // in procedure/function
    For i:=SaveOut.Count-1 downto 0 do
     begin
      if (SaveOut[i]='end;')
       then if bEnd
                    // check to not fuck up procedures in procedures
                    // Not possible to have null line so [1] always exists 
               then if SaveOut[i-1][1]<>'0'
                       then SaveOut.Delete(i)
                       else
               else bEnd:=True
       else if SaveOut[i]='begin'
               then bEnd:=True
               else bEnd:=False;
    end;
  end;

begin
  // Adjust max width lenth in the case of
  // pre-parsing (255) and (75) in DCU2INT
  if bRemoveInstructions
    then DCU_Out.MaxOutWidth:=255
    else DCU_Out.MaxOutWidth:=75;


  OutRedir := false;
  if FNRes<>'-' then begin
    if FNRes='' then
      FNRes := ChangeFileExt(FN,'.int')
    else
      FNRes := ReplaceStar(FNRes,FN);
    AssignFile(glob_file,FNRes);
    OutRedir := true;
  end ;
  try
    try
      Rewrite(glob_file); //Test whether the FNRes is a correct file name
      try
        InitOut;
        U := GetDCUByName(FN,0,0){TUnit.Create(FN)};
        U.Show;
      finally
        FreeDCU;
      end ;
    except
      on E: Exception do begin
        ExcS := Format('%s: "%s"',[E.ClassName,E.Message]);
        if TTextRec(glob_file).Mode<>fmClosed then begin
        end ;
        if OutRedir then
          Writeln(glob_file,ExcS);
      end ;
    end ;
  finally
    if OutRedir then
      Close(glob_file);
    SaveOut.LoadFromFile(FNRes);

    if bApplyFixes then
      begin
        FixDCUOutPutFormat(SaveOut, bRemoveInstructions);
      end;

    if bRemoveInstructions then
      begin
        FixEnds;
        GlobPreParsOK:=VerifyParse;
      end;

    DeleteFile(FNRes);
  end ;
end ;


end.
