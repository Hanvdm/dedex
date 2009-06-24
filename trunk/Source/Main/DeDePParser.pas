unit DeDePParser;

interface

uses Classes, SysUtils;

Type TPredicate = (pNone, pType, pProp, pMeth, pVar, pConst, pProc, pFunc, pClass, pRecord, pEvent, pUses);

Type TOnNewBlockEvent = Procedure (iFrom, iTo : Integer; pType : TPredicate; reserved:Integer) of Object;

Var NewBlockProc : TOnNewBlockEvent;



procedure TruncAll(Var s : String);
Procedure ReplaceString(Var s : String; s1,s2 : String);

Procedure InitNewParse(AList : TStringList; ANewBlockProc : TOnNewBlockEvent;  FsFileName : String);
Procedure ParseIT;
Procedure GetChar;
Procedure BackUp;
Procedure Restore;
Procedure Push;
Procedure Pop;
Procedure CorrectEndPos;

Procedure p_Predicate(s : String);

Function ParseClass(s : String) : String;
Procedure PrepareDeclaration(var s : String);
function RemoveComments(s: string): string;


Type TProgresProcedure = Procedure (Max,Pos : Longint) of Object;

Var GlobPos  : Integer;
    GlobChar : Char;
    GlobLevel : Integer;
    GlobPredicate : TPredicate;
    GlobSubPredicate : TPredicate;
    GlobEndParse : Boolean;
    GlobComment : Boolean;
    GlobString : Boolean;
    GlobEvent : Boolean;
    GlobClassDefExpected : Boolean;
    GlobClassStarted : Boolean;
    GlobClassOf : Boolean;
    GlobDeclType : Integer;
    GlobInterface : Boolean;
    GlobName : String;
    EndComment : Char;
    PASFile : TStringList;
    PASMem : TMemoryStream;

    ProgresProc : TProgresProcedure;

const STACK_SIZE = 4096;

var
    StackPos : Array [1..STACK_SIZE] of Integer;
    StackChar : Array [1..STACK_SIZE] of Char;
    StackPointer : Integer;

implementation

Var bkPos : Integer;
    bkChar : Char;
    bInType : Boolean;
    bNL : Boolean;



procedure TruncAll(Var s : String);
begin
  While Copy(s,1,1)=#32 Do s:=Copy(s,2,Length(s)-1);
  While Copy(s,Length(s),1)=#32 Do s:=Copy(s,1,Length(s)-1);
end;

Procedure ReplaceString(Var s : String; s1,s2 : String);
var i : Integer;
Begin
  i:=Pos(s1,s);
  s:=Copy(s,1,i-1)+s2+Copy(s,i+Length(s1),Length(s)-i-Length(s1)+1);
End;

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


Procedure InitNewParse(AList : TStringList;  ANewBlockProc : TOnNewBlockEvent; FsFileName : String);
var s,s1: String;
    sz : Cardinal;
Begin
  NewBlockProc:=ANewBlockProc;
  PASFile.Assign(AList);
  If FsfileName<>'' Then
     PASMem.LoadFromFile(FsFileName);

  PASMem.Seek(0,soFromBeginning);

  GlobPos:=0;
  GlobLevel:=0;
  GlobChar:=#0;
  GlobPredicate:=pNone;
  StackPointer:=0;
  GlobEndParse:=False;
  GlobComment:=False;
  GlobString:=False;
  bInType:=False;
  GlobEvent:=False;
  GlobClassDefExpected:=False;
  GlobClassStarted:=False;
  GlobClassOf:=False;
  ProgresProc(Pos('IMPLEMENTATION',AnsiUpperCase(PasFile.Text)),0);
End;

Procedure GetChar;
var ch : Char;
Begin
  If GlobPos=PASMem.Size Then
    Begin
      GlobEndParse:=True;
      Exit;
    End;

  Repeat
    Inc(GlobPos);
    If GlobPos=PASMem.Size Then
       Begin
         GlobEndParse:=True;
         Exit;
       End;
    PASMem.Seek(GlobPos, soFromBeginning);
    PASMem.ReadBuffer(GlobChar,1);//
    If GlobChar='''' Then GlobString:=not GlobString;
    If (not GlobString) and (GlobComment) and (GlobChar=EndComment) Then
       Begin
         GlobComment:=False;
         EndComment:=#0;
       End;

  Until (GlobChar in [#13,#32..#255]) and (not GlobString);


  If (not GlobString) then
    begin
      If (GlobChar='{')  and (not (GlobComment)) Then
        Begin
          EndComment:='}';
          GlobComment:=True;
        End;

      If (GlobChar='/')
       then begin
        PASMem.ReadBuffer(ch,1);
        if (ch='/') and not (GlobComment) Then
           Begin
             EndComment:=#13;
             GlobComment:=True;
          End
          Else PASMem.Seek(-1,soFromCurrent);
      end;
    end;  
End;


Procedure Backup;
Begin
  bkPos:=GlobPos;
  bkChar:=GlobChar;
End;


Procedure Restore;
Begin
  GlobPos:=bkPos;
  GlobChar:=bkChar;
End;


Procedure Push;
Begin
  If StackPointer=STACK_SIZE Then Raise Exception.Create('Parser stack overflow');
  Inc(StackPointer);
  StackChar[StackPointer]:=GlobChar;
  StackPos[StackPointer]:=GlobPos;
End;

Procedure Pop;
Begin
  If StackPointer=0 Then Raise Exception.Create('Parser stack underflow');
  GlobChar:=StackChar[StackPointer];
  GlobPos:=StackPos[StackPointer];
  Dec(StackPointer);
End;

Function ParseWord(s : String) : Boolean;
Begin
  Result:=   (s='PROCEDURE')
          or (s='FUNCTION')
          or (s='TYPE')
          or (s='VAR');
End;

Procedure ParseIT;
var sWord : String;
    bInterface : Boolean;
Begin
  sWord:='';
  bInterface:=False;
  Repeat
    GetChar;
    If GlobChar='=' Then bInType:=True;
    If GlobChar in [#13,';',#32,'(',')','=','+'] Then
      Begin
        If (Not GlobComment) and (not GlobString) Then
          Begin
            If sWord='' Then sWord:=GlobChar;
            If bInterface Then
               p_Predicate(AnsiUpperCase(sWord));
            If (not bInterface) and (AnsiUpperCase(sWord)='INTERFACE') Then
              begin
                bInterface:=True;
                push;
              end;
            If (ParseWord(AnsiUpperCase(sWord))) and (not bInterface) Then GlobEndParse:=True;
            If AnsiUpperCase(sWord)='IMPLEMENTATION' Then
            begin
              GlobEndParse:=True;
            end;  
          End;
        sWord:='';
        If GlobEndParse Then Break;
        bNL:=False;
        Continue;
      End;
    sWord:=sWord+GlobChar;
  Until GlobEndParse;
  ProgresProc(0,Length(PasFile.Text));
End;


Procedure p_Predicate(s : String);
Var Pred : TPredicate;
    beg: Integer;
Begin
  If s='' Then Exit;

  Pred:=pNone;

  If GlobChar='(' Then
           Inc(GlobLevel);

  If s='IMPLEMENTATION' Then
    Begin
      GlobEndParse:=True;
      Exit;
    End;

  If s='USES' Then
    Begin
      Pred:=pUses;
    End;

  If s='TYPE' Then
    Begin
      Pred:=pType;
      GlobSubPredicate:=pNone;
      bInType:=True;
    End;

  If (s='VAR') and (not GlobEvent) Then
    Begin
      If GlobLevel=0 Then
         Pred:=pVar;
    End;

  If (s='CONST') and (not GlobEvent) Then
    Begin
     If GlobLevel=0 Then
        Pred:=pConst;
    End;

  If s='PROCEDURE' Then
    Begin
      // Procedure in class declaration
      If (GlobLevel=0) then
          if bInType Then GlobEvent:=True
                     else Pred:=pFunc;

      // Event type Procedure (blah) of object;
      If (GlobLevel=1)
          then GlobEvent:=True;

    End;

  If s='FUNCTION' Then
    Begin
      // Procedure in class declaration
      If (GlobLevel=0) then
          if bInType Then GlobEvent:=True
                     else Pred:=pFunc;

      // Event type Procedure (blah) of object;
      If (GlobLevel=1)
          then GlobEvent:=True;
    End;


  If    ((s='CLASS') or (s='OBJECT') or (s='RECORD') or (s='INTERFACE'))
    and (Not GlobEvent) Then
     begin
       If (GlobPredicate=pType) and (GlobLevel in [0,1]) Then Inc(GlobLevel);
       if s='RECORD'
          then GlobSubPredicate:=pRecord
          else begin
             GlobSubPredicate:=pClass;
             GlobDeclType:=0;
             if s<>'INTERFACE' then
              begin
               GlobClassDefExpected:=True;
               GlobClassStarted:=True;
               GlobInterface:=False;
              end
              else GlobInterface:=True;
           end;
     end;

  If (s='END') and (GlobPredicate=pType) Then Dec(GlobLevel);

  if (GlobClassDefExpected) and ( not
       (  (s = #32)
       or (s = #13)
       or (s = ';')
       or (s = 'CLASS')
       or (s = 'OBJECT')
       or (s = 'OF'))
    ) then
       if GlobClassOf then GlobClassOf:=False
                      else GlobClassDefExpected:=False;

  if (GlobClassDefExpected) and (s = 'OF') then GlobClassOf:=True;

  if (GlobClassStarted) and (
         (s='PUBLIC')
      or (s='PRIVATE')
      or (s='PUBLISHED')
      or (s='PROTECTED')
      or (s='AUTOMATED')      
      ) then GlobClassStarted:=False;

  If GlobChar=')' Then
    begin
      Dec(GlobLevel);
      if GlobClassStarted then
        begin
          GlobClassStarted:=False;
          GlobClassDefExpected:=True;
        End;
    end;

  // TMyBlah = class;
  // TBlah = Class(TOtherBlah);
  // TBlah = Class of BlahBlah;
  If (GlobChar=';') and (GlobClassDefExpected)
     then Begin
        Dec(GlobLevel);
        GlobDeclType:=1;
     End;

  If (GlobPredicate<>Pred) and (Pred<>pNone) Then
      Begin
        case GlobPredicate of
        pNone :
          Begin
            Backup;
            Pop;
            Restore;

            // Class Parsing Support
            If GlobSubPredicate in [pClass,pRecord]
               Then NewBlockProc(0, 0, GlobSubPredicate,GlobDeclType)
               Else NewBlockProc(0, 0, Pred,GlobDeclType);
          End;
        Else
         If    (GlobPredicate in [pProc, pFunc]) and (not (Pred in [pProc, pFunc]))
            or (GlobPredicate in [pProp]) and (not (Pred in [pProp]))
            or (GlobPredicate in [pType]) and (not (Pred in [pType]))
          Then
          Begin
            Backup;
            Pop;
            Restore;
            NewBlockProc(0, 0, Pred,GlobDeclType);
          End;

        end; {Case}

        GlobPredicate:=Pred;
        // Pushes New Beggining
        BackUp;
        Dec(GlobPos,Length(s)+1);
        Push;
        Restore;
      End;

   If (Pred=pNone) and (GlobChar=';') and (GlobLevel=0) Then
     Begin
       IF GlobPredicate<>pNone Then
          Begin
            Backup;
            Pop;
            beg:=GlobPos;
            Restore;
            CorrectEndPos;
            If GlobInterface then GlobDeclType:=GlobDeclType OR $80000000;
            // Class Parsing Support
            If GlobSubPredicate in [pClass,pRecord]
               Then NewBlockProc(beg+1, GlobPos+2, GlobSubPredicate,GlobDeclType)
               Else NewBlockProc(beg+1, GlobPos+2, GlobPredicate,GlobDeclType);

            GlobSubPredicate:=pNone;
            GlobInterface:=False;

            //NewBlockProc(beg+1, GlobPos+2, GlobPredicate);
            bInType:=False;
            GlobClassStarted:=False;
          End;
        BackUp;
        Inc(GlobPos,1);
        Push;
        Restore;
        // Event types Blah = procedure (blah) of object;
        if GlobEvent then GlobEvent:=False;
     End;
End;


Procedure CorrectEndPos;
var sWord : String;
    bCont : Boolean;
Begin
  bCont:=True;
  If GlobPredicate in [pProc,pFunc] Then
    Begin
      BackUp;
      sWord:='';
      While bCont Do
       Begin
          GetChar;
          While GlobChar=#32 Do GetChar;
          sWord:=sWord+GlobChar;
          Repeat
            GetChar;
            If GlobChar in [#13,#32,';'] Then
              Begin
                sWord:=AnsiUpperCase(sWord);
                bCont:=   (sWord='STDCALL') or (sWord='EXTERNAL')
                       or (sWord='FAR') or (sWord='PASCAL')
                       or (sWord='FORWARD') or (sWord='OVERLOAD') or (sWord='REINTRODUCE');
                sWord:='';
                If GlobComment Then Continue Else Break;
              End;
            sWord:=sWord+GlobChar;
          Until False;
          If (bCont) and (GlobChar<>';') Then
            Begin
              Repeat GetChar Until GlobChar=';';
            End;
          If bCont Then BackUp;  
         End; {While}
         Restore;
    End; {If}
End;

{ TParsedFile }


Function ParseClass(s : String) : String;
var i,iPos : Integer;
    sWord : String;
begin
  Result:='';
  I:=0;
  Repeat
    iPos:=Pos(#32,s);
    sWord:=Copy(s,1,iPos-1);
    s:=Copy(s,iPos+1,Length(s));
    Inc(i,iPos);
  Until i>=Length(s);
end;

Procedure PrepareDeclaration(var s : String);
var i : Integer;
    ss : String;
    bSkip : Boolean;
    ch, cEnd : Char;
Begin
  ss:='';
  bSkip:=False;
  cEnd:=#0;
  // Remove comments
  For i:=1 To Length(s) Do
    Begin
      ch:=s[i];

      If (bSkip) and (ch=cEnd) Then
        Begin
          bSkip:=False;
          Continue;
        End;

      If (not bSkip) and (ch='{') Then
        Begin
          cEnd:='}';
          bSkip:=True;
        End;

      If (not bSkip) and (ch='/') and (s[i+1]='/') Then
        Begin
          cEnd:=#13;
          bSkip:=True;
        End;

      If not bSkip Then ss:=ss+ch;
    End;
  s:='';
  For i:=1 To Length(ss) Do
    If ss[i]=#10
       Then If (i<>1) and (ss[i-1]=#13)
            Then s:=s+ss[i]
            Else Continue
       Else s:=s+ss[i];
End;


initialization
  PASFile:=TStringList.Create;
  PASMem:=TMemoryStream.Create;
  NewBlockProc:=nil

finalization

PASFile.Free;
PASMem.Free;

end.
