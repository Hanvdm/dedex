unit DeDePFiles;
//////////////////////////
// Last Change: 02.II.2001
//////////////////////////

interface

uses classes, DeDeConstants;

//Type TPredicate = (pNone, pType, pProp, pMeth, pVar, pConst, pProc, pFunc);

Type TParsedFile = Class (TFileStream)
       Procedure AddDeclaration(sVal : String; iType : Integer);
       Function GetNextDeclaration (Var sVal : String; var iType : Integer) : Boolean;
     End;


Type TClassPredicate = (prNone, prFunc, prProc, prField);

Type TClassParser = Object
       private
         FiCharCount, Delta : Integer;
         fbReadInherits, fbReadIt : Boolean;
         fsInherits : String;
       protected
         FsLowerString, FsString : String;
         FsClassName, sDeclarationType : String;
         GlobChar : Char;
         GlobPos : Integer;
         GlobWord, LastWord : String;
         bStringMode, bProperty, bIndexMode : Boolean;
         iLevel : Integer;
         IdentList, NameList,DefList : TStringList;
         BegPos : Integer;
         Predicate : TClassPredicate;
         Procedure InitParse(s : String; aIdentList, aNameList, aDefList : TStringList);
         Procedure GetNextChar;
         Procedure ReadWord;
         Procedure ParseWord;
       public
         // 0 indent
         // 1 name
         // 2 def
         Function ParseClass(var sClassString : String; Var DefsArray : Array of TStringList; var sClassName : String) : boolean;
     End;


Type TOnNewProcEvent = Procedure (sProcDecl : String; buffer : TSymBuffer; size : Integer; Progress : Byte; bAdd : Boolean) of Object;

Type TImplementationParser = Object
       private
         FiCharCount, Delta : Integer;
         fbReadInherits, fbReadIt : Boolean;
         fsInherits : String;
       protected
         FsLowerString, FsString : String;
         FsClassName, sDeclarationType : String;
         GlobChar : Char;
         GlobPos, GlobSize : Integer;
         GlobWord, LastWord : String;
         bProperty: Boolean;
         iLevel : Integer;
         BegPos : Integer;
         FbFound, FbInProc, FbDontIncreaseParens, FbType : Boolean;
         FOnNewProcedure : TOnNewProcEvent;
         POS0, POS1,POS2,POS3 : Integer;
         Procedure GetNextChar;
         Procedure ReadWord;
         Procedure ParseWord;
       public
         procedure InitParse(sClassString : String; OnNewProcedure : TOnNewProcEvent);
         procedure ParseIt;
     End;

Type TNewDCU2DSFParser = Object
       protected
         List : TStringList;
         FOnNewProcedure : TOnNewProcEvent;
       public
         procedure InitParse(aList : TStringList; OnNewProcedure : TOnNewProcEvent);
         procedure ParseIt;
     End;

var TmpStr, ErrList : TStringList;

implementation

uses SysUtils, Dialogs, Windows;


procedure TruncAll(Var s : String);
begin
  While (Copy(s,1,1)= #32) or (Copy(s,1,1)= #13) or (Copy(s,1,1)= #10) Do s:=Copy(s,2,Length(s)-1);
  While (Copy(s,Length(s),1) = #32) or (Copy(s,Length(s),1) = #13) or (Copy(s,Length(s),1) = #10) Do s:=Copy(s,1,Length(s)-1);
end;

Function MakeBack(s:String) : String;
var  i : Integer;
begin
  Result:='';
  For i:=Length(s) downto 1 do Result:=Result+s[i];
end;

function EncodeString ( const S : string) : string;
var
  I : Integer;
const
  ParsSpecChars : set of char = [#13,#10,'@','#','/','''','"','&'];
begin
  I := 1;
  Result := '';
  while I <= Length(S) do begin
    if s[i] in ParsSpecChars then Result := Result + '/'+IntToStr(Ord(S[i]))
    else Result := Result + s[i];
    Inc(I);
  end;
end;

function DecodeString ( const S : string) : string;
var
  I : Integer;
  tmp : String;
begin
  I := 1;
  Result := '';
  while I <= Length(S) do begin
    if s[i]='/' then  begin
      tmp := '0';
      Inc(I);
      while (I <= Length(S)) and (s[i] in ['0'..'9']) do begin
        tmp := tmp+s[i];
        Inc(I);
      end;
      if tmp<>'0' then Result := Result+Char(StrToInt(tmp))
    end else Result := Result + s[i];
    Inc(I);
  end;
end;

function RemoveComments(s: string): string;
var s2: string;
begin
  while (Pos('(*',s) > 0) and (Pos('*)',s) > Pos('(*',s)) do
    Delete(s,Pos('(*',s),Pos('*)',s)-Pos('(*',s)+2);
  while Pos('//',s) > 0 do begin
    s2 := Copy(s,Pos('//',s),Length(s));
    if Pos(#13+#10,s2) > 0 then
      Delete(s,Pos('//',s),Pos(#13+#10,s2)-1)
    else
      Delete(s,Pos('//',s),Length(s));
  end;
  while (Pos('{',s) > 0) and (Pos('}',s) > Pos('{',s)) do
    Delete(s,Pos('{',s),Pos('}',s)-Pos('{',s)+1);
  Result := s;
end;

function RemoveIntervals(s : String) : String;
var i : Integer;
begin
  Result:='';
  For i:=1 To Length(s)-1 do
      if (s[i] in [' ']) and (s[i+1] in [' '])
          then
          else Result:=Result+s[i];

  s:=Result;
  Result:='';
  i:=0;
  While i<Length(s)-1 do
    begin
      Inc(i);
      Result:=Result+s[i];
      if (s[i] in [',']) and (s[i+1] in [' '])
          then Inc(i);
    end;

end;

procedure TParsedFile.AddDeclaration(sVal: String; iType: Integer);
var w : Word;
begin
  //sVal:=EncodeString(sVal);
  w:=Length(sVal);
  WriteBuffer(w,2);
  WriteBuffer(iType,4);
  Writebuffer(sVal[1],w);
end;

function TParsedFile.GetNextDeclaration(Var sVal : String; var iType : Integer) : Boolean;
var w : Word;
begin
  ReadBuffer(w,2);
  ReadBuffer(iType,4);
  SetLength(sVal,w);
  Readbuffer(sVal[1],w);
 // sVal:=DecodeString(sVal);
  Result:= not (position=size);
end;


{ TClassParser }

procedure TClassParser.GetNextChar;
begin
  Inc(GlobPos);
  If GlobPos>FiCharCount
     Then GlobChar:=#0
     Else GlobChar:=FsLowerString[GlobPos];
end;

procedure TClassParser.InitParse(s : String; aIdentList, aNameList,aDefList : TStringList);
begin
  IdentList:=aIdentList;
  NameList:=aNameList;
  DefList:=aDefList;


  FsString:=RemoveComments(s);
  FsString:=RemoveIntervals(FsString);

  FsLowerString:=AnsiLowerCase(FsString);
  FiCharCount:=Length(s);
  GlobPos:=0;
  BegPos:=0;
  GlobChar:=#0;
  GlobWord:='';
  LastWord:='';
  sDeclarationType:='public';
  bStringMode:=False;
  bIndexMode:=False;
  iLevel:=0;
  Predicate:=prNone;
  bProperty:=False;
  fbReadInherits:=false;
  fbReadIt:=false;
  fsInherits:='';
end;

function TClassParser.ParseClass(var sClassString: String;
  var DefsArray: array of TStringList; var sClassName: String): boolean;
var i,iPos,iPos2 : Integer;
    sLowerString : String;
    sWord : String;
begin
  InitParse(sClassString, DefsArray[0], DefsArray[1], DefsArray[2]);

  FsClassName:='<class parse failed>';
  Repeat
    ReadWord;
    ParseWord;
  Until GlobChar=#0;

  sClassName:=FsClassName;
  fsInherits:=trim(fsInherits);
  if fsInherits='' then fsInherits:='TObject';
  sClassString:=fsInherits;
end;

procedure TClassParser.ParseWord;
var sIdent, sName, sDef  : String;
    iPos : Integer;
begin
  If fsClassName='<class parse failed>' then
    if (GlobWord='object') or (GlobWord='class') or (GlobWord='interface')
       then begin
          iPos:=Pos(LastWord, FsLowerString);
          fsClassName:=Copy(FsString,iPos,Length(LastWord));
          fbReadInherits:=True;
       end;

  if GlobChar='(' then
     begin
      Inc(iLevel);
      if fbReadInherits then fbReadIt:=True;
     end;
  if (iLevel>0) and (GlobChar=')') then begin Dec(iLevel); fbReadInherits:=false; end;

  if (GlobChar='[') and (Predicate=prNone) then
    begin
      Predicate:=prField;
      BegPos:=GlobPos-Length(GlobWord)-1;
      Inc(iLevel);
    end;

  if GlobWord='procedure' then
     begin
       Predicate:=prProc;
       BegPos:=GlobPos;
       fbReadInherits:=false;
     end;

  if GlobWord='function' then
     begin
       Predicate:=prFunc;
       BegPos:=GlobPos;
       fbReadInherits:=false;
     end;

  if GlobWord='property' then bProperty:=True;

  if (GlobChar=':') and (Predicate=prNone) and (iLevel=0)  then
     if (GlobWord<>'private') and (GlobWord<>'public') and (GlobWord<>'published') and (GlobWord<>'protected') then
       begin
         Predicate:=prField;
         If Length(GlobWord)=0 Then GlobWord:=LastWord;
         BegPos:=GlobPos-Length(GlobWord)-1
       end;

  if (GlobWord='private') or (GlobWord='public') or (GlobWord='published') or (GlobWord='protected')
     then sDeclarationType:=GlobWord;

  if (iLevel>0) and (GlobChar=']') then Dec(iLevel);

  if (iLevel=0) and (fbReadIt) then
    begin
      fsInherits:=Copy(FsString,GlobPos-Length(GlobWord),Length(GlobWord));
      fbReadIt:=false;
    end;

  If (iLevel=0) and (GlobChar=';') and (Predicate<>prNone) Then
    Begin
      Case Predicate Of
        prProc : sIdent:='procedure';
        prFunc : sIdent:='function';
        prField: If bProperty Then sIdent:='property'
                              Else sIdent:='';
      End;
      If GlobWord='' Then GlobWord:=LastWord;
      IdentList.Add(sDeclarationType+' '+sIdent);
      sDef:=Copy(FsString,BegPos,GlobPos{-Delta}-BegPos+1);
      TruncAll(sDef);
      iPos:=0;

      If Predicate = prField Then
        begin
         iPos:=Pos(':',MakeBack(sDef));
         iPos:=Length(sDef)-iPos+1;
        end;

      if iPos=0 then iPos:=Pos('(',sDef);
      if iPos=0 Then iPos:=Pos(#32,sDef);
      if (not (Predicate = prField)) and (iPos=0) then iPos:=Length(sDef);
      sName:=Copy(sDef,1,iPos-1);
      sDef:=Copy(sDef,iPos,Length(sDef)-iPos+1);
      TruncAll(sName);
      TruncAll(sDef);
      NameList.Add(sName);
      DefList.Add(sDef);

      Predicate:=prNone;
      bProperty:=False;
    End;


end;

procedure TClassParser.ReadWord;
begin
   If GlobWord<>''
      Then begin
             LastWord:=GlobWord;
             Delta:=0;
           end ;
   GlobWord:='';
   Repeat
     GetNextChar;
     GlobWord:=GlobWord+GlobChar;
     If GlobChar in [''''] then bStringMode:=Not bStringMode;
     If GlobChar in ['[',']'] then bIndexMode:=Not bIndexMode;
   Until (GlobChar in [#0, #10, #13, #32, '(',')', ':', ';', '=','[',']']) and (not bStringMode);
   GlobWord:=Copy(GlobWord,1,Length(GlobWord)-1);
end;

{ TImplementationParser }

procedure TImplementationParser.GetNextChar;
begin
  Inc(GlobPos);
  If GlobPos>FiCharCount
     Then GlobChar:=#0
     Else GlobChar:=FsLowerString[GlobPos];
end;

procedure TImplementationParser.InitParse(sClassString: String;
  OnNewProcedure: TOnNewProcEvent);
begin
  FOnNewProcedure:=OnNewProcedure;

  // DO NOT CALL IT
  // FsString:=RemoveComments(sClassString);
  FsString:=sClassString;
  // FsString:=RemoveIntervals(FsString);

  FsLowerString:=AnsiLowerCase(FsString);
  FiCharCount:=Length(sClassString);
  GlobSize:=Length(FsString);
  GlobPos:=0;
  BegPos:=0;
  GlobChar:=#0;
  GlobWord:='';
  LastWord:='';
  sDeclarationType:='public';
  iLevel:=0;
  bProperty:=False;
  fbReadInherits:=false;
  fbReadIt:=false;
  fsInherits:='';
  FbFound:=False;
  FbInProc:=False;
  FbType:=False;
  FbDontIncreaseParens:=False;
  ErrList.Clear;
end;

procedure TImplementationParser.ParseIt;
begin
  Repeat
    ReadWord;
    ParseWord;
  Until GlobChar=#0;

  if ErrList.Count<>0 then ErrList.SaveToFile(FsTEMPDir+'dcu2dsf_'+IntToStr(GetTickCount)+'.err');
end;

procedure TImplementationParser.ParseWord;
const BytePoses : Array [1..10] of Byte = (12,15,18,21,24,27,30,33,36,39);
var sIdent, sName, sDef   : String;
    iPos, i, j, sz, idx, Offset, iNextOffs, iCurrOffs  : Integer;
    ss : String;
    bt : Byte;
    buffer : TSymBuffer;
    FbFailed : Boolean;

    function Max(x,y : Integer) : Integer;
    begin
      if x>y then result:=x
             else result:=y;
    end;


    procedure FixVal(var ss : String);
    var _s : string;
        i : Integer;
    begin
      _s:='';
      for i:=1 to length(ss) do
        if ss[i] in ['0'..'9','A'..'F'] then _s:=_s+ss[i];

      ss:=_s;
    end;

begin

  if (GlobWord='procedure') or (GlobWord='function')
    then begin
       if FbInProc then Inc(iLevel)
                   else begin
                     //iLevel:=0; {??}
                     POS0:=0;
                     POS1:=GlobPos-Length(GlobWord);
                   end;
       FbInProc:=True;
    end;


  if not FbDontIncreaseParens {POS2=0} then
   // begin is still not found
   // do not parse chars from the code
   begin
     if GlobChar='(' then Inc(iLevel);
     if (iLevel>0) and (GlobChar=')') then Dec(iLevel);
   end;

  if// After the procedure/function is found
    (POS1<>0) and (POS0=0)
    // No parens
    and (iLevel=0)
    //
    and (GlobChar=';')
    then begin
      POS0:=GlobPos;
      FbDontIncreaseParens:=True;
    end;

  if GlobWord='begin'
     then POS2:=GlobPos-5;

  if GlobWord='end' then
     begin
       POS3:=GlobPos-3;
       if iLevel=0 then FbFound:=True;
       if iLevel<>0 then Dec(iLevel);
     end;


  If (FbFound) Then
    try
      sName:=Copy(FsString,POS1,POS0-POS1);
      sDef:=Copy(FsString,POS2+5,POS3-POS2-5);
      TmpStr.Text:=sDef;

      idx:=0; Offset:=0; FbFailed:=False;
      iNextOffs:=0;iCurrOffs:=0;
      //SetLength(buffer,_PatternSize);
      sz:=TmpStr.Count;

      // Skip procs that contains only 1 instruction
      if sz<=2 then
        begin
          FbFound:=False;
          FbFailed:=False;
          POS0:=0;
          POS1:=0;
          POS2:=0;
          exit;
        end;

      For i:=0 to sz-2 Do
        Begin
          sDef:=TmpStr[i];
          if sDef='' then continue;
          if Length(sDef)<3 then continue;
          // 00000000 : 00 00 00 00 00 00 00 00 00 
          // 1234567890123456789012345678901234567890
          // 0        1         2         3         4
          //
          iCurrOffs:=StrToInt('$'+Copy(sDef,1,8));

          // Read the offsets of the current and the next instruction
          // to get instruction length
          if i+1<>sz then ss:='$'+Copy(TmpStr[i+1],1,8);
          Try
           iNextOffs:=StrToInt(ss);
          Except
           On E : EConvertError Do
             Begin
               if i+1<sz then Raise;
             End;
           Else Raise;
          End;


          // Read the bytes
          Try
            // If not last instruction
            if (i+1<>sz) and (iNextOffs<>0) then
              For j:=1 to iNextOffs-iCurrOffs do
               begin
                 ss:=Copy(sDef,
                   // Absolute position of the 0-th byte
                    11
                   // j-th byte position starting from 0 (1,4,7,10,...)
                   //  A1(00 00 00 00 00 00 00 00 00 00
                   //  1234567890123456789012345678901234567890
                   +3*(j-1)+1
                   //Chars to copy
                   ,2);
                 if ss=#32#32 then break;
                 if ss='' then break;
                 bt:=StrToInt('$'+ss);
                 Inc(idx);
                 buffer[idx]:=bt;
                 // PatternSize for DSF version 2.1
                 if idx=_PatternSize then break;
               end

             // If is the last instruction
             else
              For j:=1 to 7 do
               begin
                 ss:=Copy(sDef,BytePoses[j]+Offset,2);
                 if ss=#32#32 then break;
                 if ss='' then break;
                 bt:=StrToInt('$'+ss);
                 Inc(idx);
                 buffer[idx]:=bt;
                 // PatternSize for DSF version 2.1
                 if idx=_PatternSize then break;
               end;
           Except
             FbFailed:=True;
             break;
           End;
         if idx=_PatternSize then break;
        end;

       for i:=idx to _PatternSize-1 do buffer[i]:=0;
       if not FbFailed
          then if Assigned(FOnNewProcedure) then FOnNewProcedure(sName,buffer,_PatternSize, Trunc(100*GlobPos/GlobSize), True)
                                            else
          else ErrList.Add('Cant process: '+sName+' line: "'+sDef+'"');
    Finally
      FbFound:=False;
      FbInProc:=False;
      FbFailed:=False;
      FbDontIncreaseParens:=False;
      POS0:=0;
      POS1:=0;
      POS2:=0;
    End;
end;

procedure TImplementationParser.ReadWord;
begin
   If GlobWord<>''
      Then begin
             LastWord:=GlobWord;
             Delta:=0;
           end ;
   GlobWord:='';
   Repeat
     GetNextChar;
     GlobWord:=GlobWord+GlobChar;
   Until (GlobChar in [#0, #10, #13, #32, '(',')', ':', ';', '=','[',']']);
   GlobWord:=Copy(GlobWord,1,Length(GlobWord)-1);
end;

{ TNewDCU2DSFParser }

procedure TNewDCU2DSFParser.InitParse(aList: TStringList;
  OnNewProcedure: TOnNewProcEvent);
begin
  FOnNewProcedure:=OnNewProcedure;
  List:=aList;
end;

procedure TNewDCU2DSFParser.ParseIt;
const BytePoses : Array [1..10] of Byte = (12,15,18,21,24,27,30,33,36,39);
var i, j, idx : Integer;
    buffer : TSymBuffer;
    sName, s, ss : String;
    bt : Byte;
    bCode : Boolean;
    ProcNameStack : TStringList;

    procedure CheckAndFixRelativeDCUShits(var s : String);
    var k, l : Integer;
    begin
      l:=0;
      for k:=1 to 10 do
       begin
         if Copy(s,BytePoses[k],2)='' then break;
         if Copy(s,BytePoses[k]-1,1)='(' then l:=4;
         if l>0 then
           begin
             s[BytePoses[k]]:='0';
             s[BytePoses[k]+1]:='0';
             Dec(l);
           end;
       end;
    end;
begin
  ProcNameStack:=TStringList.Create;
  Try
    For i:=0 to List.Count-1 Do
     Begin
        s:=Trim(List[i]);

        if   (Copy(s,1,8)='function')
          or (Copy(s,1,9)='procedure')
          then begin
            ProcNameStack.Add(s);
            Continue;
          end;

        if s='begin' then
          begin
            bCode:=True;
            idx:=0;
            Continue;
          end;

        if s='end;' then
          begin
             for j:=idx+1 to _PatternSize-1 do buffer[j]:=0;
             j:=ProcNameStack.Count;
             if j=0 then exit;
             sName:=ProcNameStack[j-1];
             // Add only patterns with more than 6 bytes
             if Assigned(FOnNewProcedure) then FOnNewProcedure(sName,buffer,_PatternSize, Trunc(100*i/List.Count),idx>=6);
             ProcNameStack.Delete(j-1);
             bCode:=False;
             Continue;
          end;


        if bCode then
         begin
          CheckAndFixRelativeDCUShits(s);
          For j:=1 to 10 do
           begin
             ss:=Copy(s,BytePoses[j],2);
             if (ss='') or (ss=' ') then break;
             Try
               bt:=StrToInt('$'+ss);
             Except
               GlobPreParseWarning:=$DEDE;
               Exit;
             End;
             Inc(idx);
             buffer[idx]:=bt;
             // PatternSize for DSF version 2.1
             if idx=_PatternSize then
               begin
                 bCode:=False;
                 break;
               end;
           end;
         end;  
     End;
  Finally
    ProcNameStack.Free;
  End;
end;

initialization
  TmpStr:=TStringList.Create;
  ErrList:=TStringList.Create;

finalization
  TmpStr.Free;
  ErrList.Free;

end.
 