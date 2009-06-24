unit Emulator;

interface

uses FatExpression, Classes;

const
   MaxStack = 10000;

type DWORD = Longword;
type TCPUEmulator = class(TComponent)
   Calc: TFatExpression;
   procedure CalcEvaluate(Sender: TObject; Eval: String;
     Args: array of Double; ArgCount: Integer; var Value: Double;
     var Done: Boolean);
   private
     Regs : array[1..8] of dword;
     Stack : array[0..MaxStack] of dword;
     FPUStack : array[0..10] of Extended;
     OpSize : byte;
     Command : string;
     OpCount : integer;
     Ops : array[1..4] of string;
     function RegNum(const regname : string) : integer;
     function RegSize(const regname : string) : integer;
     function OpType(const s : string) : integer;
     function StripBrackets (const s : string) : string;
     function GetOperand(const expr : string) : dword;
     procedure SetOperand(const expr : string; const Value : dword);
     procedure SetOpSize(const Cmd : string);
     procedure ExpandCommand(const Cmd : string);
     function HexToInt(const s : string) : string;
     procedure SetByte(const b : byte);
     procedure SetWord(const w : word);
     procedure SetDWord(const d: dword);


   public
     constructor Create;
     destructor Destroy; override;
     function GetRegValue(const regname : string) : dword;
     procedure SetRegValue(const regname : string; const value : dword);
     procedure Emulate(const Cmd : string);

end; {TCPUEmulator}

implementation

Uses MainUnit, SysUtils, HexTools;


constructor TCPUEmulator.Create;
begin
   Calc := TFatExpression.Create(Self);
{
   Calc.Functions.Add('eax');
   Calc.Functions.Add('ebx');
   Calc.Functions.Add('ecx');
   Calc.Functions.Add('edx');
   Calc.Functions.Add('edi');
   Calc.Functions.Add('esi');
   Calc.Functions.Add('ebp');
   Calc.Functions.Add('esp');
   Calc.Functions.Add('ax');
   Calc.Functions.Add('bx');
   Calc.Functions.Add('cx');
   Calc.Functions.Add('dx');
   Calc.Functions.Add('ah');
   Calc.Functions.Add('bh');
   Calc.Functions.Add('ch');
   Calc.Functions.Add('dh');
   Calc.Functions.Add('al');
   Calc.Functions.Add('bl');
   Calc.Functions.Add('cl');
   Calc.Functions.Add('dl');
}
   Calc.EvaluateOrder := eoEventFirst;
   Calc.OnEvaluate := CalcEvaluate;

end;

destructor TCPUEmulator.Destroy;
begin
   Calc.Destroy;
end;



procedure TCPUEmulator.SetByte(const b : byte);
begin
end;
procedure TCPUEmulator.SetWord(const w : word);
begin
end;
procedure TCPUEmulator.SetDWord(const d: dword);
begin
end;

function TCPUEmulator.HexToInt(const s : string) : string;
var
   i : integer;
   j : integer;
begin
   i := Pos('$', s);
   if i > 0 then begin
      j := i + 1;
      while Pos(s[j], '0123456789ABCDEF') > 0 do begin
         inc(j);
      end; { while }
      Result := Copy(s, 1, i - 1) + IntToStr(StrToInt64(Copy(s, i, j-i))) + Copy(s, j+1, Length(s) - j);
   end else begin
      Result := s;
   end;
end;

function TCPUEmulator.OpType(const s : string) : integer;
begin
   if Pos('[', s) > 0 then begin
      if Pos('ebp', s) > 0 then begin
         Result := 2;
      end else begin
         Result := 1;
      end; { if }
   end else begin
      Result := 0;
   end; { if }
end;

function TCPUEmulator.StripBrackets (const s : string) : string;
var
   i, j : integer;
begin
   i := Pos('[', s) + 1;
   j := Pos(']', s);
   if (j > 0) then
      Result := Copy(s, i, j - i)
   else
      Result := s;   
end;


function TCPUEmulator.RegSize(const regname : string) : integer;
begin
  if pos('e', regname) > 0 then
     Result := 4
  else if (pos('h', regname) > 0) then
     Result := 3
  else if (pos('l', regname) > 0) then
     Result := 1
  else
     Result := 2;
end;
function TCPUEmulator.RegNum(const regname : string) : integer;
const
   regs4 = '   eaxebxecxedxediesiebpesp';
   regs2 = '    ahalbhblchcldhdl';
var
   i : integer;
begin
   i := Pos(regname, regs2) div 4;
   if i < 1 then begin
      i := Pos(regname, regs4) div 3;
   end; { if }
   Result := i;
end;

function TCPUEmulator.GetRegValue(const regname : string) : dword;
var
   i : integer;
begin
   i := RegNum(regname);
   case RegSize(regname) of
    1 : Result := Regs[i] and $FF;
    2 : Result := Regs[i] and $FFFF;
    3 : Result := (Regs[i] and $FF00) SHR 8;
    4 : Result := Regs[i];
   end; { case }
end;

procedure TCPUEmulator.SetRegValue(const regname : string; const value : dword);
var
   i : integer;
begin
   i := RegNum(regname);
   case RegSize(regname) of
    1 : Regs[i] := (Regs[i] and $FFFFFF00) OR (Value AND $FF);
    2 : Regs[i] := (Regs[i] and $FFFF0000) OR (Value AND $FFFF);
    3 : Regs[i] := (Regs[i] and $FFFF00FF) OR ((Value AND $FF00)SHL 8);
    4 : Regs[i] := Value;
   end; { case }
end;

procedure TCPUEmulator.CalcEvaluate(Sender: TObject; Eval: String;
     Args: array of Double; ArgCount: Integer; var Value: Double;
     var Done: Boolean);
begin
  Value := GetRegValue(Eval);
  Done := true;
end;

function TCPUEmulator.GetOperand(const expr : string) : dword;
var
   i : dword;
begin
   Calc.Text := StripBrackets(expr);
   i := StrToInt64(FloatToStr(Calc.Value));
   case OpType(expr) of
     0 : Result := i;
     1 : begin
            case OpSize of
              1 : Result := GetByte(i);
              2 : Result := GetWord(i);
              4 : Result := GetDWord(i);
             end; { case }
         end;
     2 : begin
         end;
   end; { case }
end;

procedure TCPUEmulator.SetOperand(const expr : string; const Value : dword);
begin
   case OpType(expr) of
     0 : if RegNum(expr) > 0 then begin
            SetRegValue(expr, Value);
         end;
     1 : begin
{            case OpSize of
              1 : Result := SetByte(i);
              2 : Result := SetWord(i);
              4 : Result := SetDWord(i);
             end; { case }
         end;
     2 : begin
         end;
   end; { case }
end;

procedure TCPUEmulator.SetOpSize(const Cmd : string);
begin
   if Pos('dword', cmd) > 0 then OpSize := 4
   else if Pos('word', cmd) > 0 then OpSize := 2
   else if Pos('byte', cmd) > 0 then OpSize := 1
   else OpSize := 4;
end;

procedure TCPUEmulator.ExpandCommand(const Cmd : string);
var
   i, j : integer;
   s : string;
begin
  s := LowerCase(Trim(Cmd));
  i := Pos(' ', s);
  OpCount := 0;
  if i > 0 then begin
     Command := Trim(Copy(s, 1, i));
     Delete(s, 1, i);
     while true do begin
        i := Pos(',', s);
        inc(OpCount);
        if i < 1 then begin
           Ops[OpCount] := HexToInt(Trim(s));
           break;
        end else begin
           Ops[OpCount] := HexToInt(Trim(Copy(s, 1, i - 1)));
           Delete(s, 1, i);
        end; { if }
     end; { while }
  end else begin
     Command := s;
  end; { if }
  for i:= 1 to OpCount do begin
     j := Pos('ptr', Ops[i]);
     if j > 0 then Ops[i] := Trim(Copy(Ops[i], j+3, Length(Ops[i])-(j+2)));
  end; { for }

end;

procedure TCPUEmulator.Emulate(const Cmd : string);
begin
   SetOpSize(Cmd);
   ExpandCommand(Cmd);
   if Command = 'mov' then begin
      SetOperand(Ops[1], GetOperand(Ops[2]));
   end else if Command = 'add' then begin
      SetOperand(Ops[1], GetOperand(Ops[1]) + GetOperand(Ops[2]));
   end else if Command = 'sub' then begin
      SetOperand(Ops[1], GetOperand(Ops[1]) - GetOperand(Ops[2]));
   end else if Command = 'inc' then begin
      SetOperand(Ops[1], GetOperand(Ops[1]) + 1);
   end else if Command = 'dec' then begin
      SetOperand(Ops[1], GetOperand(Ops[1]) - 1);
   end else if Command = 'lea' then begin
      SetOperand(Ops[1], GetOperand(StripBrackets(Ops[2])));
   end else if Command ='and' then begin
      SetOperand(Ops[1], GetOperand(Ops[1]) AND GetOperand(Ops[2]));
   end else if Command ='or' then begin
      SetOperand(Ops[1], GetOperand(Ops[1]) OR GetOperand(Ops[2]));
   end else if Command ='xor' then begin
      SetOperand(Ops[1], GetOperand(Ops[1]) XOR GetOperand(Ops[2]));
   end else if Command ='not' then begin
      SetOperand(Ops[1], NOT GetOperand(Ops[1]));
   end else if Command ='neg' then begin
      SetOperand(Ops[1], - GetOperand(Ops[1]));
   end else if Command ='shl' then begin
      SetOperand(Ops[1], GetOperand(Ops[1]) SHL GetOperand(Ops[2]));
   end else if Command ='shr' then begin
      SetOperand(Ops[1], GetOperand(Ops[1]) SHR GetOperand(Ops[2]));
   end; { if }
end;


end.
