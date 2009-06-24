unit HEXTools;

interface

Const HEX_DIGITS : Array[0..15] of Char =
      ('0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F');

type  DWORD = LongWord;
  {$EXTERNALSYM DWORD}

Function Byte2Hex(Ab: Byte): String;
Function Word2Hex(Aw: Word): String;
Function DWord2Hex(Adw: DWORD): String;
Function Hex2Byte(Ahex: String): Byte;
Function Hex2Word(Ahex: String): Word;
Function Hex2DWord(Ahex: String): DWORD;
Function Dec2Hex(l : Longint) : String;

Function BA2Word(buffer : Array of byte) : Word;
Function BA2DWord(buffer : Array of byte) : DWord;
Function BA2WordF(buffer : Array of byte) : Word;
Function BA2DWordF(buffer : Array of byte) : DWord;

Procedure BA(Var buffer :  Array of Byte; AWord : Word); overload;
Procedure BA(Var buffer : Array of Byte; ADWord : DWord); overload;
Procedure BAF(Var buffer :  Array of Byte; AWord : Word); overload;
Procedure BAF(Var buffer : Array of Byte; ADWord : DWord); overload;

function WordBitMask(w : Word) : String;

function HexViewChar(b : Byte; bCyrMode : Boolean) : Char;

implementation

uses SysUtils;

function WordBitMask(w : Word) : String;
var i : Integer;
    bit : Byte;
begin
  Result:='';
  For i:=1 To 16 Do
    Begin
      bit:=w mod 2;
      w:=w div 2;
      If bit=0 Then Result:='0'+Result
               Else Result:='1'+Result;
      If (i mod 4 = 0) and (i<>16) Then Result:='-'+Result;                 
    End;
end;

function HexViewChar(b : Byte;  bCyrMode : Boolean) : Char;
Begin
  If  bCyrMode
     Then If (b<31) Then Result:='.' Else Result:=CHR(b)
     Else If (b<31) or (b>127) Then Result:='.' Else Result:=CHR(b);
End;

Function Dec2Hex(l : Longint) : String;
var md : Longint;
Begin
  Result:='';
  Repeat
    md:=l mod 16;
    l:=l div 16;
    Result:=HEX_DIGITS[md]+Result;
  Until l=0;
  While Length(Result)<2 Do Result:='0'+Result;
End;

Function _HEX(Ac : Char) : Byte;
Begin
  Case Ac Of
    '1' : Result:=1;
    '2' : Result:=2;
    '3' : Result:=3;
    '4' : Result:=4;
    '5' : Result:=5;
    '6' : Result:=6;
    '7' : Result:=7;
    '8' : Result:=8;
    '9' : Result:=9;
    'A' : Result:=10;
    'B' : Result:=11;
    'C' : Result:=12;
    'D' : Result:=13;
    'E' : Result:=14;
    'F' : Result:=15;
    Else Result:=0;
  End;
End;


Function Byte2Hex(Ab: Byte): String;
Begin
  Result:=IntToHex(Ab,2);
End;


Function Word2Hex(Aw: Word): String;
Begin
  Result:=IntToHex(Aw,4);
End;

Function DWord2Hex(Adw: DWORD): String;
Begin
   Result:=IntToHex(adw,8);
End;

Function Hex2Byte(Ahex: String): Byte;
Begin
  While Length(Ahex)<2 Do Ahex:='0'+Ahex;
  Ahex:=Copy(Ahex,1,2);
  Result:=_HEX(Ahex[1])*16+_HEX(Ahex[2]);
End;

Function Hex2Word(Ahex: String): Word;
Var sHI, sLO : String;
Begin
  While Length(Ahex)<4 Do Ahex:='0'+Ahex;
  Ahex:=Copy(Ahex,1,4);
  sHi:=Copy(Ahex,1,2);
  sLo:=Copy(Ahex,3,2);
  Result:=Hex2Byte(sHi)*256+Hex2Byte(sLo);
End;

Function Hex2DWord(Ahex: String): DWORD;
var sHi, sLo : String;
Begin
  While Length(Ahex)<8 Do Ahex:='0'+Ahex;
  Ahex:=Copy(Ahex,1,8);
  sHi:=Copy(Ahex,1,4);
  sLo:=Copy(Ahex,5,4);
  Result:=Hex2Word(sHi)*256*256+Hex2Word(sLo);
End;

Function BA2Word(buffer : Array of byte) : Word;
Begin
  Result:=buffer[0]+buffer[1]*256;
End;


Function BA2DWord(buffer : Array of byte) : DWord;
Begin
  Result:=buffer[0]+buffer[1]*256+256*256*(buffer[2]+buffer[3]*256);
End;

Function BA2WordF(buffer : Array of byte) : Word;
Begin
  Result:=buffer[1]+buffer[0]*256;
End;


Function BA2DWordF(buffer : Array of byte) : DWord;
Begin
  Result:=buffer[3]+buffer[2]*256+256*256*(buffer[1]+buffer[0]*256);
End;

Procedure BA(Var buffer : Array of Byte; AWord : Word); overload;
Begin
  buffer[0]:=AWord div 256;
  buffer[1]:=AWord mod 256;
End;


Procedure BA(Var buffer : Array of Byte; ADWord : DWord); overload;
Var ALWord,AHWord : Word ;
Begin
  ALWord:=ADWord mod 256*256;
  AHWord:=ADWord div 256*256;
  buffer[0]:=AHWord div 256;
  buffer[1]:=AHWord mod 256;
  buffer[2]:=ALWord div 256;
  buffer[3]:=ALWord mod 256;
End;

Procedure BAF(Var buffer : Array of Byte; AWord : Word); overload;
Begin
  buffer[0]:=AWord mod 256;
  buffer[1]:=AWord div 256;
End;


Procedure BAF(Var buffer : Array of Byte; ADWord : DWord); overload;
Var ALWord,AHWord : Word ;
Begin
  ALWord:=ADWord mod 256*256;
  AHWord:=ADWord div 256*256;
  buffer[0]:=ALWord mod 256;
  buffer[1]:=ALWord div 256;
  buffer[2]:=AHWord mod 256;
  buffer[3]:=AHWord div 256;
End;

end.
