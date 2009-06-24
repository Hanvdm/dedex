unit DeDeHidden;

interface

uses Windows, Classes, DeDeClasses;

Procedure RunHiddenStuff(PEStream : TPEStream);

implementation

uses HexTools, SysUtils;

const Buffer_Length = 27;
      Patterns_Count = 1;

type TBuffer = Array [0..Buffer_Length-1] of Byte;

const Patterns : Array [0..Patterns_Count-1] of TBuffer =
                (($0D,$80,$00,$00,$00,$8B,$F3,$81,$E6,$FF,$00,$00,$00,$8B,$55,$FC,$0F,$B6,$54,$32,$FF,$33,$C2,$50,$8D,$45,$FC));

const PatternNames : Array [0..Patterns_Count-1] of String =
        ('ADP');

const Sizes : Array [0..Patterns_Count-1] of Byte = (27);

Var BitSet : Array [0..Patterns_Count-1] of Boolean;


Procedure CheckIt(s : TBuffer);
var i : Integer;
begin
  For i:=0 To Patterns_Count-1 Do
   if CompareMem(@s[0],@Patterns[i][0],High(Patterns[i])+1)
           Then BitSet[i]:=True;
end;

Procedure ClearBits;
var i : Integer;
Begin
  For i:=0 To Patterns_Count-1 Do BitSet[i]:=False;
End;

Function CalcBits : Byte;
var i : Integer;
Begin
  Result:=0;
  For i:=0 To Patterns_Count-1 Do Result:=Result+ORD(BitSet[i]);
End;

Function ExpandBits : String;
var i : Integer;
Begin
  Result:='Found Sequences:'#13#10#13#10;
  For i:=0 To Patterns_Count-1 Do
     If BitSet[i] Then Result:=Result+PatternNames[i];
End;

Procedure RunHiddenStuff(PEStream : TPEStream);
var s : TBuffer;
    i : Cardinal;
Begin
  ClearBits;
  PEStream.Seek(0,soFromBeginning);
  Repeat
    PEStream.ReadBuffer(s[0],Buffer_Length);
    CheckIt(s);
    PEStream.Seek(-Buffer_Length+1,soFromCurrent);
    Inc(i);
  Until PEStream.Position>=PEStream.Size-27;
  If CalcBits>0 Then MessageBox(0,PChar(ExpandBits+#13#10#13#10+IntToStr(i)+' bytes checked'),'',MB_OK)
                Else MessageBox(0,PChar('Noting Found!'+#13#10#13#10+IntToStr(i)+' bytes checked'),'',MB_OK)
End;

end.
