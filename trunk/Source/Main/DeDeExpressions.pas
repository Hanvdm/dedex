unit DeDeExpressions;

interface

uses HexTools;

///////////////////////////////////////
// Name convention for xpression:
//   00424DF2:[ebp-$06]
//   first 8 chars is the RVA of the procedure or 00000000 if global var
//   9-th char is :
type
   TVar = record
      RVA : DWORD;
      Name : string[40];
      Comment   : string[40];
   end;

type TEmulationRecord = record
       RVA : DWORD;
       Mode : Byte;
       EmulString : String;
     end;

var
   Expressions : array of TVar;
   ExpressionCount : integer = 0;

   Emulations : array of TEmulationRecord;
   EmulationCount : integer =0;

procedure AddExpression(const RVA : longint; const expression, name : String);
procedure AddNewExpression(const RVA : longint; const expression, name : String);
function GetExpression(const RVA : longint; const expression : String) : String;
procedure EditExpression(const RVA : longint; const expression, name : String);


implementation


procedure AddExpression(const RVA : longint; const expression, name : String);
begin
  AddExpression(RVA,expression,name);
end;

procedure AddNewExpression(const RVA : longint; const expression, name : String);
var i : Integer;
begin
  for i:=0 to ExpressionCount-1 do
    if RVA=Expressions[i].RVA then
       if Expressions[i].Name=expression
           then exit;

  Inc(ExpressionCount);
  SetLength(Expressions,ExpressionCount);
  Expressions[ExpressionCount-1].RVA:=RVA;
  Expressions[ExpressionCount-1].Name:=expression;
  Expressions[ExpressionCount-1].Comment:=name;
End;  

function GetExpression(const RVA : longint; const expression : String) : String;
var i : Integer;
begin
  for i:=0 to ExpressionCount-1 do
    if RVA=Expressions[i].RVA then
       if Expressions[i].Name=expression then
          begin
            Result:=Expressions[i].Comment;
            break;
          end;
end;

procedure EditExpression(const RVA : longint; const expression, name : String);
var i : Integer;
begin
  for i:=0 to ExpressionCount-1 do
    if RVA=Expressions[i].RVA then
       if Expressions[i].Name=expression then
          begin
            Expressions[i].Comment:=name;
            exit;
          end;

  Inc(ExpressionCount);
  SetLength(Expressions,ExpressionCount);
  Expressions[ExpressionCount-1].RVA:=RVA;
  Expressions[ExpressionCount-1].Name:=expression;
  Expressions[ExpressionCount-1].Comment:=name;
end;

end.
