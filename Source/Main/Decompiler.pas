unit Decompiler;

interface


const
   vvLocal = 1; vvGlobal = 2; vvParameter = 3;

type TVarList = record
   VarName : string;
   VarType : integer;
   VarSize : integer;
   VarMode : byte;
   VarVision : byte;
end;


type TVariables = class

   private
      { Private declarations }
      VarList : array of TVarList;
      VarCount : integer;
   public
     { Public declarations }
      constructor Create;
      destructor Destroy; override;
      procedure AddVar(Variable : TVarList);
      procedure RenameVar(const OldName : string; const NewName : string);
      procedure DeleteVar(const VarName : string);
      function FindVar(const VarName : string) : TVarList;
   end;

type TExec = class
   private
      
   public

   end;


implementation


constructor TVariables.Create;
begin
  VarCount := 0;
  SetLength(VarList, 0);
end;

destructor TVariables.Destroy;
begin
  SetLength(VarList, 0);
end;


procedure TVariables.AddVar(Variable : TVarList);
begin
//
end;
procedure TVariables.RenameVar(const OldName : string; const NewName : string);
begin
//
end;
procedure TVariables.DeleteVar(const VarName : string);
begin
//
end;
function TVariables.FindVar(const VarName : string) : TVarList;
begin
//
end;


end.
