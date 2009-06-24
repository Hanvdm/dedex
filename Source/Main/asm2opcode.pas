unit asm2opcode;

interface

Uses Classes;

Type TASM = Class (TObject)
       private
       protected
         FsInstruction : String;
         function ParseInstruction : String;
       public
         constructor Create; virtual;           
         destructor Destroy; override;
         function DoASM(sInstruction : String) : String;
     End;

implementation

{ TASM }

constructor TASM.Create;
begin
  inherited Create;
  
end;

destructor TASM.Destroy;
begin

  inherited Destroy;
end;

function TASM.DoASM(sInstruction: String): String;
begin
  
end;

function TASM.ParseInstruction: String;
begin

end;

end.
