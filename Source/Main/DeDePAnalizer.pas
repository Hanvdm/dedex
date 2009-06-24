unit DeDePAnalizer;

interface

uses Classes;

procedure InitNewAnalize(sFileName : String);
procedure Analize;

var DaFile, DaData : TStringList;
    FsLine : String;
    FsLastReference, FsName, FsGlobDynStr : String;

    sOPCODE, sInstr : String;
    Opcode : Array of Byte;

    GlobBImplementation : Boolean;
    GlobInProcedure, GlobNeedInherit : Boolean;
    GlobPrevReffCnt : Integer;
    GlobBAexpected, GlobLStrLAsgExpected, GlobOIExpected : Boolean;

implementation

uses SysUtils;

var FiIndex : Integer;

procedure AddRAWLine(s : String);
begin
  DaData.Add(s);
end;

function GetLine : boolean;
begin
  Result:=False;
  Inc(FiIndex);
  if FiIndex>=DaFile.Count then exit;
  result:=True;
  FsLine:=DaFile[FiIndex]+#32;
end;

procedure InitNewAnalize(sFileName : String);
begin
  DaFile.LoadFromFile(sFileName);
  DaData.Clear;
  FiIndex:=-1;
  FsLine:='';
  FsLastReference:='';
  GlobBImplementation:=False;
  GlobInProcedure:=False;
  GlobNeedInherit:=False;
  GlobBAexpected:=False;
  GlobLStrLAsgExpected:=False;
  GlobOIExpected:=False;
  GlobPrevReffCnt:=0;
end;

procedure AnalizeLine; forward;
 
procedure Analize;
begin
  while GetLine do AnalizeLine;

end;

procedure StartNewProcedure;
var i, j : Integer;
begin
  GlobInProcedure:=False;
  GlobNeedInherit:=False;
  GlobBAexpected:=False;
  GlobLStrLAsgExpected:=False;
  GlobOIExpected:=False;
  GlobPrevReffCnt:=0;

  GlobInProcedure:=True;
  GlobNeedInherit:=True;

  //procedure TDOIForm.Btn_TAnimateClick(Sender: TObject);
  i:=Pos('Btn_',FsLine);
  j:=Pos('Click(',FsLine);
  AddRAWLine('['+Copy(FsLine,i+4,j-i-4)+']');
end;

Procedure FinalizeProcedure;
begin
  AddRAWLine('');
  AddRAWLine('');
  GlobInProcedure:=False;
end;

procedure ParseLine;
var s : String;
    i : Integer;
begin
 //1234567890123456789012345678901234567890
 //0        1         2         3         4
 //004708D1   BEC0984700             mov     esi, $004798C0
 s:=FsLine;
 sOPCODE:=Copy(s,12,20); sOPCODE:=Trim(sOPCODE);
 sInstr:=Copy(s,35,Length(s)-35);sInstr:=Trim(sInstr);

 SetLength(Opcode,Length(sOpcode) div 2);
 for i:=1 to Length(sOpcode) div 2 Do
     Opcode[i-1]:=StrToInt('$'+Copy(sOpcode,2*i-1,2));
end;

procedure ParseName;
begin
  FsName:=FsLastReference;
end;

function ParseTheLine(sName, sInstr : String) : String;
var sPrefix, sOffset : String;
    i,iPos : Integer;
begin
  // Getting the type
  sPrefix:='';
  if copy(sInstr,1,4)='call' then sPrefix:='m_';
  if copy(sInstr,1,13)='mov     bx, $' then sPrefix:='d_';
  if (sPrefix='') and (copy(sInstr,1,3)='mov')
    then begin
      if (copy(sName,1,2)='On') and (sName[3] in ['A'..'Z'])
         then sPrefix:='e_'
         else sPrefix:='p_';
    end;

  // Getting the offset
  iPos:=Pos('$',sInstr);
  if iPos=0
    then sOffset:='0'
    else begin
      sInstr:=sInstr+' ';
      sOffset:='';
      inc(iPos);
      While sInstr[iPos] in ['0'..'9','A'..'F']
       do begin
        sOffset:=sOffset+sInstr[iPos];
        Inc(iPos);
       end;
    end;    


  iPos:=Pos('<',sName);
  if iPos<>0 then
    if Copy(sName,iPos+1,1)='r'
      then sName:=Copy(sName,1,iPos-1)//+' <read '+Copy(sName,iPos+3,Length(sName)-iPos-2)
      else sName:=Copy(sName,1,iPos-1);//+' <write '+Copy(sName,iPos+3,Length(sName)-iPos-2);

  Result:=sPrefix+sName+'='+sOffset;
end;

procedure AnalizeLine;
var i : Integer;
begin
  if Copy(FsLine,1,14)='implementation' then
     begin
       GlobBImplementation:=True;
       Exit;
     end;
  if not GlobBImplementation then exit;

  if not (GlobInProcedure)
    and (Copy(FsLine,1,9)='procedure') then StartNewProcedure;

  if  (GlobInProcedure)
    and (Copy(FsLine,1,6)=' end ;')
      then FinalizeProcedure
      else begin
        // Analize
        if FsLine[1]='*' then
          begin
            i:=Pos('''',FsLine);
            FsLastReference:=Copy(FsLine,i+1,Length(FsLine)-i);
            i:=Pos('''',FsLastReference);
            FsLastReference:=Copy(FsLastReference,1,i-1);

            GlobPrevReffCnt:=0;
            Exit;
          end;

        if FsLine[1] in ['0'..'9']
          then Inc(GlobPrevReffCnt)
          else exit;
          
        ParseLine;

        //
        if Opcode[0]=$BA then
            if GlobNeedInherit
              then begin
                AddRAWLine('inherits='+FsLastReference);
                GlobNeedInherit:=False;
                GlobBAexpected:=True;
                exit;
              end
              else
                if GlobBAexpected then begin
                  ParseName;
                  GlobLStrLAsgExpected:=True;
                  GlobBAexpected:=False;
                  exit;
                end;

        if (GlobLStrLAsgExpected) and (Copy(sInstr,1,4)='call') then
           begin
             GlobOIExpected:=True;
             GlobLStrLAsgExpected:=False;
             Exit;
           end;

        if GlobOIExpected then
          begin
            if   (Pos('[eax+$',sInstr)<>0)
              or (Pos('[ebx+$',sInstr)<>0)
              or (Pos('[ecx+$',sInstr)<>0)
              or (Pos('[edx+$',sInstr)<>0)
              or (Pos('[esi+$',sInstr)<>0)
              or (Pos('[edi+$',sInstr)<>0)
              then
               if GlobPrevReffCnt>1 then begin
                     AddRAWLine(ParseTheLine(FsName,sInstr));
                     GlobOIExpected:=False;
                     GlobBAExpected:=True;
                 end;


               if((Pos('[eax]',sInstr)<>0)
               or (Pos('[ebx]',sInstr)<>0)
               or (Pos('[ecx]',sInstr)<>0)
               or (Pos('[edx]',sInstr)<>0)
               or (Pos('[esi]',sInstr)<>0)
               or (Pos('[edi]',sInstr)<>0))
               and (Copy(sInstr,1,4)='call')
                then
                 if GlobPrevReffCnt>1 then begin
                       AddRAWLine(ParseTheLine(FsName,sInstr));
                       GlobOIExpected:=False;
                       GlobBAExpected:=True;
                   end;


             if (Opcode[0]=$66) and (Opcode[1]=$BB) then
               begin
                 FsGlobDynStr:=sInstr;
                 Exit;
               end;

             if Opcode[0]=$E8 then
               begin
                 if DaFile[FiIndex-2]='* Reference to: System..CallDynaInst()'
                    then if FsGlobDynStr<>'' then AddRAWLine(ParseTheLine(FsName,FsGlobDynStr));

                 FsGlobDynStr:='';
                 GlobOIExpected:=False;
                 GlobBAExpected:=True;
               end;
          end;
      end;

end;


initialization
  DaFile:=TStringList.Create;
  DaData:=TStringList.Create;

finalization
  DaFile.Free;
  DaData.Free;
  
end.
