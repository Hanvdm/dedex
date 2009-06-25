
{

  TFatExpression by Gasper Kozak, gasper.kozak@email.si
  component is open-source and is free for any use
  version: 1.01, July 2001

  this is a component used for calculating text-presented expressions
  features
    operations: + - * / ^ !
    parenthesis: ( )
    variables: their values are requested through OnEvaluate event
    user-defined functions in format:
      function_name [ (argument_name [";" argument_name ... ]] "=" expression

  ! parental advisory : bugs included
  if you find any, fix it or let me know

}

unit FatExpression;

interface

uses Classes, Dialogs, Sysutils, Math;

type
  // empty token, numeric, (), +-*/^!, function or variable, ";" character
  TTokenType = (ttNone, ttNumeric, ttParenthesis, ttOperation, ttString, ttParamDelimitor);
  TEvaluateOrder = (eoInternalFirst, eoEventFirst);
  TOnEvaluate = procedure(Sender: TObject; Eval: String; Args: array of Double;
    ArgCount: Integer; var Value: Double; var Done: Boolean) of object;

  // class used by TExpParser and TExpNode for breaking text into 
  // tokens and building a syntax tree
  TExpToken = class
  private
    FText: String;
    FTokenType: TTokenType;
  public
    property Text: String read FText;
    property TokenType: TTokenType read FTokenType;
  end;

  // engine for breaking text into tokens
  TExpParser = class
  protected
    FExpression: String;
    FTokens: TList;
    FPos: Integer;
  private
    procedure Clear;
    function GetToken(Index: Integer): TExpToken;
    procedure SetExpression(const Value: String);
  public
    constructor Create;
    destructor Destroy; override;

    function ReadFirstToken: TExpToken;
    function ReadNextToken: TExpToken;

    function TokenCount: Integer;
    property Tokens[Index: Integer]: TExpToken read GetToken;
    property TokenList: TList read FTokens;
    property Expression: String read FExpression write SetExpression;
  end;

  // syntax-tree node. this engine uses a bit upgraded binary-tree
  TExpNode = class
  protected
    FOwner: TObject;
    FParent: TExpNode;
    FChildren: TList;
    FTokens: TList;
    FLevel: Integer;
    FToken: TExpToken;
    FOnEvaluate: TOnEvaluate;
  private
    function GetToken(Index: Integer): TExpToken;
    function GetChildren(Index: Integer): TExpNode;
    function FindLSOTI: Integer; // LSOTI = least significant operation token index
    function ParseFunction: Boolean;
    procedure RemoveSorroundingParenthesis;
    procedure SplitToChildren(TokenIndex: Integer);
    function Evaluate: Double;
    property Children[Index: Integer]: TExpNode read GetChildren;
  public
    constructor Create(AOwner: TObject; AParent: TExpNode; Tokens: TList);
    destructor Destroy; override;
    procedure Build;

    function TokenCount: Integer;
    function Calculate: Double;
    property Tokens[Index: Integer]: TExpToken read GetToken;
    property Parent: TExpNode read FParent;
    property Level: Integer read FLevel;
    property OnEvaluate: TOnEvaluate read FOnEvaluate write FOnEvaluate;
  end;

  TFunction = class
  protected
    FAsString, FName, FHead, FFunction: String;
    FOwner: TObject;
    FArgCount: Integer;
    FArgs: TStringList;
    FValues: array of Double;
  private
    procedure SetAsString(const Value: String);
    procedure EvalArgs(Sender: TObject; Eval: String; Args: array of Double; ArgCount: Integer; var Value: Double);
  public
    constructor Create(AOwner: TObject);
    destructor Destroy; override;
    function Call(Values: array of Double): Double;
    property AsString: String read FAsString write SetAsString;
    property Name: String read FName;
    property ArgCount: Integer read FArgCount;
    property Args: TStringList read FArgs;
  end;

  // main component, actually only a wrapper for TExpParser, TExpNode and
  // user input via OnEvaluate event
  TFatExpression = class(TComponent)
  protected
    FInfo, FText: String;
    FEvaluateOrder: TEvaluateOrder;
    FOnEvaluate: TOnEvaluate;
    FValue: Double;
    FFunctions: TStringList;
  private
    procedure Compile;
    function GetValue: Double;
    procedure SetInfo(Value: String);
    procedure Evaluate(Eval: String; Args: array of Double; var Value: Double);
    function FindFunction(FuncName: String): TFunction;
    procedure SetFunctions(Value: TStringList);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Value: Double read GetValue;
  published
    property Text: String read FText write FText;
    property Info: String read FInfo write SetInfo;
    property Functions: TStringList read FFunctions write SetFunctions;
    property EvaluateOrder: TEvaluateOrder read FEvaluateOrder write FEvaluateOrder;
    property OnEvaluate: TOnEvaluate read FOnEvaluate write FOnEvaluate;
  end;


procedure Register;

implementation

const
  // supported operations
  STR_OPERATION = '+-*/^!';
  // function parameter delimitor
  STR_PARAMDELIMITOR = ';';
  // legal variable name characters
  STR_STRING    : array[0..1] of string =
    ('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_',
     'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_$#@0123456789');


procedure Register;
begin
  RegisterComponents('Additional', [TFatExpression]);
end;



function OperParamateres(const Oper: String): Integer;
begin
  if Pos(Oper, '+-*/^') > 0 then
    Result := 2 else
  if Oper = '!' then
    Result := 1 else
    Result := 0;
end;

constructor TExpParser.Create;
begin
  inherited Create;
  FTokens := TList.Create;
end;

destructor TExpParser.Destroy;
begin
  Clear;
  FTokens.Free;
  inherited;
end;

procedure TExpParser.Clear;
begin
  while FTokens.Count > 0 do begin
    TExpToken(FTokens[0]).Free;
    FTokens.Delete(0);
  end;
end;

procedure TExpParser.SetExpression(const Value: String);
begin
  FExpression := Trim(Value);
end;

function TExpParser.GetToken(Index: Integer): TExpToken;
begin
  Result := TExpToken(FTokens[Index]);
end;

function TExpParser.ReadFirstToken: TExpToken;
begin
  Clear;
  FPos := 1;
  Result := ReadNextToken;
end;

function GetTokenType(S: String; First: Boolean): TTokenType;
var Value: Double;
  P, Error: Integer;
begin
  if (S = '(') or (S = ')') then Result := ttParenthesis else
  if S = STR_PARAMDELIMITOR then Result := ttParamDelimitor else
  if Pos(S, STR_OPERATION) > 0 then Result := ttOperation else
    begin
      Val(S, Value, Error);
      if Error = 0 then Result := ttNumeric else
        begin
          if First then
            P := Pos(S, STR_STRING[0]) else
            P := Pos(S, STR_STRING[1]);

          if P > 0 then
            Result := ttString else
            Result := ttNone;
        end;
    end;
end;

function TExpParser.ReadNextToken: TExpToken;
var Part, Ch: String;
  FirstType, NextType: TTokenType;
  Sci: Boolean;
begin
  Result := NIL;
  if FPos > Length(FExpression) then Exit;
  Sci := False;

  Part := '';
  repeat
    Ch := FExpression[FPos];
    Inc(FPos);
  until (Ch <> ' ') or (FPos > Length(FExpression));
  if FPos - 1 > Length(FExpression) then Exit;

  FirstType := GetTokenType(Ch, True);
  if FirstType = ttNone then begin
    raise Exception.CreateFmt('Parse error: illegal character "%s" at position %d.', [Ch, FPos - 1]);
    Exit;
  end;

  if FirstType in [ttParenthesis, ttOperation] then begin
    Result := TExpToken.Create;
    with Result do begin
      FText := Ch;
      FTokenType := FirstType;
    end;
    FTokens.Add(Result);
    Exit;
  end;

  Part := Ch;
  repeat
    Ch := FExpression[FPos];
    NextType := GetTokenType(Ch, False);

    if
        (NextType = FirstType) or
       ((FirstType = ttString) and (NextType = ttNumeric)) or
       ((FirstType = ttNumeric) and (NextType = ttString) and (Ch = 'E') and (Sci = False)) or
       ((FirstType = ttNumeric) and (NextType = ttOperation) and (Ch = '-') and (Sci = True))
    then
      begin
        Part := Part + Ch;
        if (FirstType = ttNumeric) and (NextType = ttString) and (Ch = 'E') then
          Sci := True;
      end else
      begin
        Result := TExpToken.Create;
        with Result do begin
          FText := Part;
          FTokenType := FirstType;
        end;
        FTokens.Add(Result);
        Exit;
      end;
    Inc(FPos);
  until FPos > Length(FExpression);

  Result := TExpToken.Create;
  with Result do begin
    FText := Part;
    FTokenType := FirstType;
  end;
  FTokens.Add(Result);
end;

function TExpParser.TokenCount: Integer;
begin
  Result := FTokens.Count;
end;




constructor TExpNode.Create(AOwner: TObject; AParent: TExpNode; Tokens: TList);
var I: Integer;
begin
  inherited Create;

  FOwner := AOwner;
  FParent := AParent;
  if FParent = NIL then
    FLevel := 0 else
    FLevel := FParent.Level + 1;

  FTokens := TList.Create;
  I := 0;
  while I < Tokens.Count do begin
    FTokens.Add(Tokens[I]);
    Inc(I);
  end;

  FChildren := TList.Create;

  if Tokens.Count = 1 then
    FToken := Tokens[0];
end;

destructor TExpNode.Destroy;
var Child: TExpNode;
begin
  if Assigned(FChildren) then begin
    while FChildren.Count > 0 do begin
      Child := Children[FChildren.Count - 1];
      FreeAndNil(Child);
      FChildren.Delete(FChildren.Count - 1);
    end;

    FreeAndNil(FChildren);
  end;

  FTokens.Free;
  inherited;
end;

procedure TExpNode.RemoveSorroundingParenthesis;
var First, Last, Lvl, I: Integer;
  Sorrounding: Boolean;
begin
  First := 0;
  Last := TokenCount - 1;
  while Last > First do begin
    if (Tokens[First].TokenType = ttParenthesis) and (Tokens[Last].TokenType = ttParenthesis) and
       (Tokens[First].Text = '(') and (Tokens[Last].Text = ')') then begin

      Lvl := 0;
      I := 0;
      Sorrounding := True;
      repeat
        if (Tokens[I].TokenType = ttParenthesis) and (Tokens[I].Text = '(') then
          Inc(Lvl) else
        if (Tokens[I].TokenType = ttParenthesis) and (Tokens[I].Text = ')') then
          Dec(Lvl);

        if (Lvl = 0) and (I < TokenCount - 1) then begin
          Sorrounding := False;
          Break;
        end;

        Inc(I);
      until I = TokenCount;

      if Sorrounding then begin
        FTokens.Delete(Last);
        FTokens.Delete(First);
      end else
      Exit;
    end else
      Exit;
    
    First := 0;
    Last := TokenCount - 1;
  end;
end;

procedure TExpNode.Build;
var LSOTI: Integer;
begin
  if TokenCount < 2 then
    Exit;
  RemoveSorroundingParenthesis;
  if TokenCount < 2 then
    Exit;

  LSOTI := FindLSOTI;
  if LSOTI < 0 then begin
    if ParseFunction then Exit;
    raise Exception.Create('Compile error: syntax fault.');
    Exit;
  end;
  SplitToChildren(LSOTI);
end;

function TExpNode.ParseFunction: Boolean;
var Func: Boolean;
  I, Delimitor, DelimitorLevel: Integer;
  FChild: TExpNode;
  FList: TList;
begin
  Result := False;
  if TokenCount < 4 then Exit;

  Func := (Tokens[0].TokenType = ttString) and
    (Tokens[1].TokenType = ttParenthesis) and (Tokens[TokenCount - 1].TokenType = ttParenthesis);

  if not Func then Exit;

  FToken := Tokens[0];
  with FTokens do begin
    Delete(TokenCount - 1);
    Delete(1);
  end;

  FList := TList.Create;
  try
    while TokenCount > 1 do begin
      Delimitor := - 1;
      DelimitorLevel := 0;
      for I := 1 to TokenCount - 1 do begin
        if (Tokens[I].TokenType = ttParenthesis) and (Tokens[I].Text = '(') then
          Inc(DelimitorLevel) else
        if (Tokens[I].TokenType = ttParenthesis) and (Tokens[I].Text = ')') then
          Dec(DelimitorLevel) else
        if (Tokens[I].TokenType = ttParamDelimitor) and (DelimitorLevel = 0) then begin
          Delimitor := I - 1;
          FTokens.Delete(I);
          Break;
        end;

        if DelimitorLevel < 0 then begin
          raise Exception.Create('Function parse error.');
          Exit;
        end;
      end;

      if Delimitor = -1 then Delimitor := TokenCount - 1;
      for I := 1 to Delimitor do begin
        FList.Add(Tokens[1]);
        FTokens.Delete(1);
      end;
      FChild := TExpNode.Create(FOwner, Self, FList);
      FList.Clear;
      FChild.Build;
      FChildren.Add(FChild);
    end;
  finally
    FList.Free;
  end;
  Result := True;
end;

procedure TExpNode.SplitToChildren(TokenIndex: Integer);
var Left, Right: TList;
  I: Integer;
  FChild: TExpNode;
begin
  Left := TList.Create;
  Right := TList.Create;

  try
    if TokenIndex < TokenCount - 1 then
      for I := TokenCount - 1 downto TokenIndex + 1 do begin
        Right.Insert(0, FTokens[I]);
        FTokens.Delete(I);
      end;

    if Right.Count > 0 then
    begin
      FChild := TExpNode.Create(FOwner, Self, Right);
      FChildren.Insert(0, FChild);
      FChild.Build;
    end;

    if TokenIndex > 0 then
      for I := TokenIndex - 1 downto 0 do begin
        Left.Insert(0, FTokens[I]);
        FTokens.Delete(I);
      end;

    FChild := TExpNode.Create(FOwner, Self, Left);
    FChildren.Insert(0, FChild);
    FChild.Build;
  finally
    FToken := Tokens[0];
    Left.Free;
    Right.Free;
  end;
end;

function TExpNode.GetChildren(Index: Integer): TExpNode;
begin
  Result := TExpNode(FChildren[Index]);
end;

function TExpNode.FindLSOTI: Integer;
var Lvl, I, LSOTI, NewOperPriority, OperPriority: Integer;
begin
  Lvl := 0; // Lvl = parenthesis level
  I := 0;
  LSOTI := - 1;
  OperPriority := 9;

  repeat
    if Tokens[I].TokenType = ttParenthesis then begin
      if Tokens[I].Text = '(' then
        Inc(Lvl) else
      if Tokens[I].Text = ')' then
        Dec(Lvl);

      if Lvl < 0 then begin
        //raise Exception.CreateFmt('Parenthesis mismatch at level %d, token %d.', [Level, I]);
        raise Exception.Create('Compile error: parenthesis mismatch.');
        Exit;
      end;
    end;

    if (Tokens[I].TokenType = ttOperation) and (Lvl = 0) then begin
      NewOperPriority := Pos(Tokens[I].Text, STR_OPERATION);
      if NewOperPriority <= OperPriority then begin
        OperPriority := NewOperPriority;
        LSOTI := I;
      end;
    end;

    Inc(I);
  until I >= TokenCount;

  Result := LSOTI;
end;

function Exl(Value: Integer): Double;
begin
  if Value <= 1 then
    Result := Value else
    Result := Value * Exl(Value - 1);
end;

function TExpNode.Evaluate: Double;
var Args: array of Double;
  Count, I: Integer;
  Done: Boolean;
begin
  Result := 0;
  if FToken.TokenType = ttString then begin
    Count := FChildren.Count;
    SetLength(Args, Count);
    for I := 0 to Count - 1 do
      Args[I] := Children[I].Calculate;

    if Assigned(FOnEvaluate) then
      FOnEvaluate(Self, FToken.Text, Args, High(Args) + 1, Result, Done) else
    if FOwner is TFatExpression then
      TFatExpression(FOwner).Evaluate(FToken.Text, Args, Result) else
    if FOwner is TFunction then
      TFunction(FOwner).EvalArgs(Self, FToken.Text, Args, High(Args) + 1, Result);
  end;
end;

function TExpNode.Calculate: Double;
var Error: Integer;
  DivX, DivY: Double;
begin
  Result := 0;
  if (FToken = NIL) or (TokenCount = 0) then
    Exit;

  if TokenCount = 1 then begin
    if FToken.TokenType = ttNumeric then begin
      Val(FToken.Text, Result, Error);
    end else
    if FToken.TokenType = ttString then begin
      Result := Evaluate;
    end else
    if FToken.TokenType = ttOperation then begin
      if FChildren.Count <> OperParamateres(FToken.Text) then begin
        raise Exception.Create('Calculate error: syntax tree fault.');
        Exit;
      end;
      if FToken.Text = '+' then
        Result := Children[0].Calculate + Children[1].Calculate else
      if FToken.Text = '-' then
        Result := Children[0].Calculate - Children[1].Calculate else
      if FToken.Text = '*' then
        Result := Children[0].Calculate * Children[1].Calculate else
      if FToken.Text = '/' then begin
        DivX := Children[0].Calculate;
        DivY := Children[1].Calculate;
        if DivY <> 0 then Result := DivX / DivY else
          begin
            raise Exception.CreateFmt('Calculate error: "%f / %f" divison by zero.', [DivX, DivY]);
            Exit;
          end;
      end else
      if FToken.Text = '^' then
        Result := Power(Children[0].Calculate, Children[1].Calculate) else
      if FToken.Text = '!' then
        Result := Exl(Round(Children[0].Calculate));
    end;
  end;
end;

function TExpNode.GetToken(Index: Integer): TExpToken;
begin
  Result := TExpToken(FTokens[Index]);
end;

function TExpNode.TokenCount: Integer;
begin
  Result := FTokens.Count;
end;








constructor TFunction.Create(AOwner: TObject);
begin
  inherited Create;
  FOwner := AOwner;
  FAsString := '';
  FName := '';
  FArgCount := 0;
  FArgs := TStringList.Create;
end;

destructor TFunction.Destroy;
begin
  FArgs.Free;
  inherited;
end;

function TFunction.Call(Values: array of Double): Double;
var Token: TExpToken;
  Tree: TExpNode;
  Parser: TExpParser;
  I: Integer;
begin
  SetLength(FValues, High(Values) + 1);
  for I := 0 to High(Values) do
    FValues[I] := Values[I];
    
  Parser := TExpParser.Create;
  try
    Parser.Expression := FFunction;
    Token := Parser.ReadFirstToken;
    while Token <> NIL do Token := Parser.ReadNextToken;

    Tree := TExpNode.Create(Self, NIL, Parser.TokenList);
    try
      with Tree do begin
        Build;
        Result := Calculate;
      end;
    finally
      Tree.Free;
    end;
  finally
    Parser.Free;
  end;
end;

procedure TFunction.EvalArgs(Sender: TObject; Eval: String; Args: array of Double; ArgCount: Integer; var Value: Double);
var I: Integer;
begin
  for I := 0 to FArgs.Count - 1 do
     if UpperCase(FArgs[I]) = UpperCase(Eval) then begin
      Value := FValues[I];
      Exit;
    end;

  if FOwner is TFatExpression then
    TFatExpression(FOwner).Evaluate(Eval, Args, Value);
end;

procedure TFunction.SetAsString(const Value: String);
var Head: String;
  HeadPos: Integer;
  Parser: TExpParser;
  Token: TExpToken;
  ExpectParenthesis, ExpectDelimitor: Boolean;
begin
  FArgs.Clear;
  FArgCount := 0;
  FAsString := Value;
  FHead := '';
  FFunction := '';
  FName := '';

  HeadPos := Pos('=', FAsString);
  if HeadPos = 0 then Exit;
  Head := Copy(FAsString, 1, HeadPos - 1);
  FFunction := FAsString;
  Delete(FFunction, 1, HeadPos);
  Parser := TExpParser.Create;
  try
    Parser.Expression := Head;
    Token := Parser.ReadFirstToken;
    if (Token = NIL) or (Token.TokenType <> ttString) then begin
      raise Exception.CreateFmt('Function "%s" is not valid.', [FAsString]);
      Exit;
    end;
    FName := Token.Text;

    Token := Parser.ReadNextToken;
    if Token = NIL then Exit;
    if Token.TokenType = ttParenthesis then begin
      if Token.Text = '(' then ExpectParenthesis := True else
      begin
        raise Exception.CreateFmt('Function header "%s" is not valid.', [Head]);
        Exit;
      end;
    end else
    ExpectParenthesis := False;

    ExpectDelimitor := False;
    while Token <> NIL do begin
      Token := Parser.ReadNextToken;
      if Token <> NIL then begin
        if Token.TokenType = ttParenthesis then begin
          if ExpectParenthesis and (Token.Text = ')') then Exit else
          begin
            raise Exception.CreateFmt('Function header "%s" is not valid.', [Head]);
            Exit;
          end;
        end;

        if ExpectDelimitor then begin
          if (Token.TokenType <> ttParamDelimitor) and (Token.TokenType <> ttParenthesis) then begin
            raise Exception.Create('Function parse error: delimitor ";" expected between arguments.');
            Exit;
          end;
          ExpectDelimitor := False;
          Continue;
        end;

        if Token.TokenType = ttString then begin
          FArgs.Add(Token.Text);
          FArgCount := FArgs.Count;
          ExpectDelimitor := True;
        end;
      end;
    end;
    if ExpectParenthesis then
      raise Exception.CreateFmt('Function header "%s" is not valid.', [Head]);
  finally
    Parser.Free;
  end;
end;





constructor TFatExpression.Create;
begin
  inherited;
  FText := '';
  FInfo := 'TFatExpression v1.0 by gasper.kozak@email.si';
  FFunctions := TStringList.Create;
end;

destructor TFatExpression.Destroy;
begin
  FFunctions.Free;
  inherited;
end;

procedure TFatExpression.Compile;
var Token: TExpToken;
  Tree: TExpNode;
  Parser: TExpParser;
begin
  Parser := TExpParser.Create;
  try
    Parser.Expression := FText;
    Token := Parser.ReadFirstToken;
    while Token <> NIL do
      Token := Parser.ReadNextToken;

    Tree := TExpNode.Create(Self, NIL, Parser.TokenList);
    try
      with Tree do begin
        Build;
        FValue := Calculate;
      end;
    finally
      Tree.Free;
    end;
  finally
    Parser.Free;
  end;
end;

function TFatExpression.FindFunction(FuncName: String): TFunction;
var F: TFunction;
  I: Integer;
begin
  Result := NIL;
  for I := 0 to FFunctions.Count - 1 do
    if Trim(FFunctions[I]) <> '' then begin
      F := TFunction.Create(Self);
      F.AsString := FFunctions[I];
      if UpperCase(F.Name) = UpperCase(FuncName) then begin
        Result := F;
        Exit;
      end;
      F.Free;
    end;
end;

procedure TFatExpression.SetInfo(Value: String);
begin
  //
end;

procedure TFatExpression.Evaluate(Eval: String; Args: array of Double; var Value: Double);
var Func: TFunction;
  Done: Boolean;
begin
  Done := False;
  if (EvaluateOrder = eoEventFirst) and Assigned(FOnEvaluate) then begin
    FOnEvaluate(Self, Eval, Args, High(Args) + 1, Value, Done);
    if Done then Exit;
  end else
  Value := 0;

  Func := FindFunction(Eval);
  if Func <> NIL then begin
    Value := Func.Call(Args);
    Func.Free;
    Exit;
  end;

  if (EvaluateOrder = eoInternalFirst) and Assigned(FOnEvaluate) then
    FOnEvaluate(Self, Eval, Args, High(Args) + 1, Value, Done) else
    Value := 0;
end;

function TFatExpression.GetValue: Double;
begin
  Compile;
  Result := FValue;
end;

procedure TFatExpression.SetFunctions(Value: TStringList);
begin
  FFunctions.Assign(Value);
end;


end.



