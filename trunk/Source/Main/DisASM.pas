unit DisAsm;

interface

uses
  SysUtils, Classes;

type
  EDisAsmError = class(Exception);
  TRegister = (rEax, rEcx, rEdx, rEbx, rEsp, rEbp, rEsi, rEdi);
  TdaRef = record
    MultiplyReg1: Integer;
    ARegister1: TRegister;
    MultiplyReg2: Integer;
    ARegister2: TRegister;
    Immidiate: PChar;
  end;

  TJumpInstrProc = procedure (Param: Pointer; ValueAddress, JumpAddress: PChar; var Result: string);
  TCallInstrProc = procedure (Param: Pointer; ValueAddress, CallAddress: PChar; var Result: string);
  TAddressRefProc = procedure (Param: Pointer; ValueAddress, RefAddress: PChar; var Result: string);
  TRefProc = procedure (Param: Pointer; Ref: TdaRef; RefSize: Integer; var Result: string);
  TImmidiateDataProc = procedure (Param: Pointer; ValueAddress: PChar; OperandSize: Integer; Sigend: Boolean; var Result: string);

  TDisAsm = class(TObject)
  public
    OnJumpInstr: TJumpInstrProc;
    OnCallInstr: TCallInstrProc;
    OnAddressRef: TAddressRefProc;
    OnRef: TRefProc;
    OnImmidiateData: TImmidiateDataProc;
    Param: Pointer;
    function GetInstruction(Address: PChar; var Size: Integer): string;
  end;

const
  modrmReg = $38;  // Reg part of the ModRM byte, ??XXX???
  modrmMod = $C0;  // Mod part of the ModRM byte, XX??????
  modrmRM =  $07;  // RM part of the ModRM byte,  ?????XXX

function SignedIntToHex(Value: Integer; Digits: Integer): string;
function FindFirstSimpleCallTo(CallAddress, SearchAddress: PChar; SearchSize: Integer): PChar;
function FindLastSimpleCallTo(CallAddress, SearchAddress: PChar; SearchSize: Integer): PChar;

implementation

uses
  Windows, DisAsmTables, DeDeRES;

// Convert an Integer to a string including a + or - and $ character.
function SignedIntToHex(Value: Integer; Digits: Integer): string;
begin
  if Value < 0 then
    Result := '-$' + IntToHex(-Integer(Value), Digits)
  else
    Result := '+$' + IntToHex(Integer(Value), Digits);
end;

// Reads the instruction at Address and return the Size and the assembler string
// representing the instruction.
function TDisAsm.GetInstruction(Address: PChar; var Size: Integer): string;

var
  Ref: TdaRef;

{ Reading is getting the value at Address + Size and then increment Size
  with the size of the read value }

  function ReadDWord: DWord;
  begin
    if IsBadReadPtr(Address, 4) then
      raise EDisAsmError.Create(err_not_enuff_code);
    Result := PDWord(Address + Size)^;
    Inc(Size, 4);
  end;

  function ReadWord: Word;
  begin
    if IsBadReadPtr(Address, 2) then
      raise EDisAsmError.Create(err_not_enuff_code);
    Result := PWord(Address + Size)^;
    Inc(Size, 2);
  end;

  function ReadByte: Byte;
  begin
    if IsBadReadPtr(Address, 1) then
      raise EDisAsmError.Create(err_not_enuff_code);
    Result := PByte(Address + Size)^;
    Inc(Size, 1);
  end;

  function GetRefAddress: string;
  var
    RefAddress: PChar;
  begin
    RefAddress := PChar(ReadDWord);
    Ref.Immidiate := Ref.Immidiate + Integer(RefAddress);
    Result := '$' + IntToHex(DWord(RefAddress), 4);
    if Assigned(OnAddressRef) then
      OnAddressRef(Param, Address + Size - 4, RefAddress, Result);
    Result := '^' + Chr(Length(Result)) + Result;
  end;

// Only read the ModRM byte the first time it is asked.
// After that return the previous read ModRM byte
var
  XHasModRM: Boolean;
  XModRM: Byte;

  function ModRM: Byte;
  begin
    if not XHasModRM then
    begin
      XModRM := ReadByte;
      XHasModRM := True;
    end;
    Result := XModRM;
  end;

// Only read the Sib byte the first time it is asked.
// After that return the previous read Sib byte
var
  XHasSib: Boolean;
  XSib: Byte;

  function Sib: Byte;
  begin
    if not XHasSib then
    begin
      XSib := ReadByte;
      XHasSib := True;
    end;
    Result := XSib;
  end;

var
  DeffOperandSize: Integer;// Default = 4, but may be changed by operand prefix.
  AddressSize: Integer;    // Default = 4, but may be changed by operand prefix.
  OperandSize: Integer;
  SegOverride: Boolean;
  SegName: string;
  MustHaveSize: Boolean;

  // Operand anlayser.
  function Operand(AddrMethod, OperandType, EnhOperandType: char): string;

    // Returns the name of the register specified by Reg using OperandType
    // to determen the size.
    function GetRegName(Reg: Byte): string;
    const
      ByteRegs1: array[0..3] of char = 'acdb';
      ByteRegs2: array[0..1] of char = 'lh';
      WordRegs1: array[0..7] of char = 'acdbsbsd';
      WordRegs2: array[0..4] of char = 'xxpi';
    begin
      if OperandSize = 1 then
        Result := ByteRegs1[Reg mod 4] + ByteRegs2[Reg div 4]
      else
      begin
        if OperandSize = 4 then
          Result := 'e'
        else
          Result := '';
        Result  := Result + WordRegs1[Reg] + WordRegs2[Reg div 2];
      end;
    end;

    // Returns the description of the effective address in the ModRM byte.
    function GetEffectiveAddress(EAMustHaveSize: Boolean): string;
    var
      RM: Byte;
      AMod: Byte;

      function ReadSib: string;
      var
        SI: Byte;
        SS: Byte;
        Base: Byte;
      begin
        Base := Sib and $07;        {?????XXX}
        SI := (Sib shr 3) and $07;  {??XXX???}
        SS := (Sib shr 6) and $03;  {XX??????}

        // Save register used by Base
        case Base of
          0: Result := '[eax';
          1: Result := '[ecx';
          2: Result := '[edx';
          3: Result := '[ebx';
          4: Result := '[esp';
          5: if AMod <> 0 then
               Result := '[ebp'
             else
               Result := '[' + GetRefAddress;
          6: Result := '[esi';
          7: Result := '[edi';
        end;
        if (Base <> 5) or (AMod = 0) then
        begin
          Ref.ARegister2 := TRegister(Base);
          Ref.MultiplyReg2 := 1;
        end;

        // result register Scaled Index
        case SI of
          0: Result := Result + '+eax';
          1: Result := Result + '+ecx';
          2: Result := Result + '+edx';
          3: Result := Result + '+ebx';
          5: Result := Result + '+ebp';
          6: Result := Result + '+esi';
          7: Result := Result + '+edi';
        end;
        if SI <> 4 then
          Ref.ARegister1 := TRegister(SI);

        // No SS when SI = 4
        if SI <> 4 then
          // Save modification made by SS
          case SS of
            0: begin Result := Result + '';   Ref.MultiplyReg1 := 1; end;
            1: begin Result := Result + '*2'; Ref.MultiplyReg1 := 2; end;
            2: begin Result := Result + '*4'; Ref.MultiplyReg1 := 4; end;
            3: begin Result := Result + '*8'; Ref.MultiplyReg1 := 8; end;
          end;
      end;

    var
      I: Integer;
    begin
      RM := ModRM and modrmRM;
      AMod := ModRm and modrmMod shr 6;

      // Effective address is a register;
      if AMod = 3 then
      begin
        Result := GetRegName(RM);
        Exit;
      end;

      Result := '%s' + Chr(OperandSize);

      // override seg name
      if SegOverride then
        Result := Result + SegName + ':';

      // Include the Size if it is other than 4
      if OperandSize <> 4 then
        MustHaveSize := True;

      if AddressSize = 4 then
      begin
        // disp32.
        if (AMod = 0) and (RM = 5) then
        begin
          Result := Result + '[' + GetRefAddress + ']';
          if Assigned(OnRef) then
            OnRef(Param, Ref, OperandSize, Result);
          Exit;
        end;
      end
      else
      begin
        // disp16
        if (AMod = 0) and (RM = 6) then
        begin
          Result := Result + '[' + GetRefAddress + ']';
          if Assigned(OnRef) then
            OnRef(Param, Ref, OperandSize, Result);
          Exit;
        end;
      end;

      // Analyse RM Value.
      if AddressSize = 2 then
        case RM of
          0: Result := Result + '[bx+si';
          1: Result := Result + '[bx+di';
          2: Result := Result + '[bp+si';
          3: Result := Result + '[bp+di';
          4: Result := Result + '[si';
          5: Result := Result + '[di';
          6: Result := Result + '[bp';
          7: Result := Result + '[bx';
        end
      else
      begin
        case RM of
          0: Result := Result + '[eax';
          1: Result := Result + '[ecx';
          2: Result := Result + '[edx';
          3: Result := Result + '[ebx';
          4: Result := Result + ReadSIB;
          5: Result := Result + '[ebp';
          6: Result := Result + '[esi';
          7: Result := Result + '[edi';
        end;
        if RM <> 4 then
        begin
          Ref.ARegister1 := TRegister(RM);
          Ref.MultiplyReg1 := 1;
        end;
      end;

      // possible disp value dependent of Mod.
      case AMod of
        // no disp
        0: Result := Result + ']';
        // disp8
        1: begin
             I := ShortInt(ReadByte);
             Result := Result + SignedIntToHex(I, 2) + ']';
             Inc(Ref.Immidiate, I);
           end;
        // disp32 or disp16
        2: Result := Result + '+' + GetRefAddress + ']';
      end;

      // Call the OnRef proc.
      if Assigned(OnRef) then
        OnRef(Param, Ref, OperandSize, Result);
    end;

  var
   I: Integer;
  begin
    Result := '';
    // Save the operand size using the DeffOperandSize and SubType
    case OperandType of
      // two Word or two DWord, only used by BOUND
      'a': if DeffOperandSize = 2 then
             OperandSize := 4
           else
             OperandSize := 8;
      // Byte.
      'b': OperandSize := 1;
      // Byte or word
      'c': if DeffOperandSize = 2 then
             OperandSize := 1
           else
             OperandSize := 2;
      // DWord
      'd': OperandSize := 4;
      // 32 or 48 bit pointer
      'p': OperandSize := AddressSize + 2;
      // QWord
      'q': OperandSize := 8;
      // 6Byte
      's': OperandSize := 6;
      // Word or DWord
      'v': OperandSize := DeffOperandSize;
      // Word
      'w': OperandSize := 2;
      // Tera byte
      't': OperandSize := 10;
    end;

    case AddrMethod of
      // Direct Address.
      'A': if OperandType = 'p' then
           begin
             // Read address and return it.
             if SegOverride then
               Result := SegName + ':'
             else
               Result := '';
             if AddressSize = 4 then
               Result := Result + GetRefAddress
             else
               Result := Result + '$' + IntToHex(ReadWord, 2);
           end
           else
             // A direct address the isn't a pointer??
             raise EDisAsmError.Create(err_invalid_operand);

      // Reg field in ModRm specifies Control register.
      'C': if OperandType = 'd' then
           begin
             // Read Reg part of the ModRM field.
             Result := Format('C%d', [(ModRM and modrmReg) div 8]);
             MustHaveSize := False;
           end
           else
             // Only support for the complete register.
             raise EDisAsmError.Create(err_invalid_operand);

      // Reg field in ModRm specifies Debug register.
      'D': if OperandType = 'd' then
           begin
             // Read Reg part of the ModRM field.
             Result := Format('D%d', [(ModRM and modrmReg) div 8]);
             MustHaveSize := False;
           end
           else
             // Only support for the complete register.
             raise EDisAsmError.Create(err_invalid_operand);

      // General purpose register or memory address specified in the ModRM byte.
      // There are no check for invalid operands.
      'E', 'M', 'R': Result := GetEffectiveAddress(False);

      // EFlags register
      'F': { Do nothing };

      // Reg field in ModRM specifies a general register
      'G': begin
           Result := GetRegName((ModRM and modrmReg) div 8);
           MustHaveSize := False;
           end;

      // Signed immidate data
      'H': begin
           case OperandSize of
             1: I := ShortInt(ReadByte);
             2: I := Smallint(ReadWord);
             4: I := Integer(ReadDWord);
             else raise EDisAsmError.Create(err_invalid_operand_size);
           end;
           Result := SignedIntToHex(I, OperandSize * 2);
           if Assigned(OnImmidiateData) then
             OnImmidiateData(Param, Address + Size - OperandSize, OperandSize, True, Result);
           Result := '^' + chr(Length(Result)) + Result;
           end;
      // Imidiate data
      'I': begin
           Result := '';
           for I := OperandSize downto 1 do
             Result := IntToHex(ReadByte, 2) + Result;
           Result := '$' + Result;
           if Assigned(OnImmidiateData) then
             OnImmidiateData(Param, Address + Size - OperandSize,
               OperandSize, False, Result);
           Result := '^' + Chr(Length(Result)) + Result;
           end;

      // Relative jump Offset Byte
      'J': begin
             case OperandSize of
               1: I := ShortInt(ReadByte);
               2: I := Smallint(ReadWord);
               4: I := Integer(ReadDWord);
               else raise EDisAsmError.Create(err_invalid_operand_size);
             end;
             // Convert the value to a string.
             Result := SignedIntToHex(I, OperandSize * 2);
             // if its a jump call the JumpInstr proc.
             if (EnhOperandType = 'j') and Assigned(OnJumpInstr) then
             begin
               OnJumpInstr(Param, Address + Size - OperandSize, Address + Size + I, Result);
               Result := '^' + Chr(Length(Result)) + Result;
             end;
             if (EnhOperandType = 'c') and Assigned(OnCallInstr) then
             begin
               OnCallInstr(Param, Address + Size - OperandSize, Address + Size + I, Result);
               Result := '^' + Chr(Length(Result)) + Result;
             end;
           end;

      // Relative Offset Word or DWord
      'O': if AddressSize = 2 then
             Result := '%s' + Chr(OperandSize) + '[$' + IntToHex(ReadWord, 4) + ']'
           else
           begin
             Result := '%s' + Chr(OperandSize) + '[' + GetRefAddress + ']';
             if Assigned(OnRef) then
               OnRef(Param, Ref, OperandSize, Result);
           end;

      // Reg field in ModRM specifies a MMX register
      'P': begin
           Result := Format('MM%d', [(ModRM and modrmReg) div 8]);
           MustHaveSize := False;
           end;

      // MMX register or memory address specified in the ModRM byte.
      'Q': if (ModRM and modrmmod) = $C0 then
           begin
             // MMX register
             Result := Format('MM%d', [(ModRM and modrmReg) div 8]);
             MustHaveSize := False;
           end
           else
             // Effective address
             Result := GetEffectiveAddress(False);

      // Reg field in ModRM specifies a Segment register
      'S': case (ModRM and modrmReg) div 8 of
             0: Result := 'es';
             1: Result := 'cs';
             2: Result := 'ss';
             3: Result := 'ds';
             4: Result := 'fs';
             5: Result := 'gs';
           end;

      // Reg field in ModRM specifies a MMX register
      'T': begin
           Result := Format('T%d', [(ModRM and modrmReg) div 8]);
           MustHaveSize := False;
           end;

    end;
  end;



  function Replacer(FirstChar, SecondChar: char): string;
  const
    modrmReg = $38;  // Reg part of the ModRM byte, ??XXX???
  begin
    case FirstChar of
      // escape character
      'c': if SecondChar = '2' then
             Result := TwoByteOpcodes[char(ReadByte)]
           else
             if ModRm <= $BF then
               Result := FloatingPointOpcodes[SecondChar, (ModRM and modrmReg) div 8 + $B8]
             else
               Result := FloatingPointOpcodes[SecondChar, ModRm];

      // 32 bit register or 16 bit register.
      'e': if DeffOperandSize = 4 then
             Result := 'e' + SecondChar
           else
             Result := SecondChar;

      // Seg prefix override.
      'p': begin
           SegOverride := True;
           SegName := SecondChar + 's';
           Result := OneByteOpcodes[char(ReadByte)];
           end;

      // Size override (address or operand).
      's': begin
           case SecondChar of
             'o': DeffOperandSize := 2;
             'a': AddressSize := 2;
           end;
           Result := OneByteOpcodes[char(ReadByte)];
           end;

      // Operand size
      'o': if DeffOperandSize = 4 then
             case SecondChar of
               '2': Result := 'w';
               '4': Result := 'd';
               '8': Result := 'q';
             end
           else
             case SecondChar of
               '2': Result := 'b';
               '4': Result := 'w';
               '8': Result := 'd';
             end;

      // Must have size.
      'm': begin
           Result := '';
           MustHaveSize := True;
           end;

      // Group, return the group insruction specified by OperandType
      // and the reg field of the ModRM byte.
      'g': Result := GroupsOpcodes[SecondChar, (ModRM and modrmReg) div 8];

      // Operand for group, return operands for the group insruction specified
      // by OperandType and the reg field of the ModRM byte.
      'h': Result := GroupsOperands[SecondChar, (ModRM and modrmReg) div 8];
    end;
  end;
  
var
  I, J, ps1, ps2, k : Integer;
begin
  DeffOperandSize := 4;
  AddressSize := 4;
  SegOverride := False;
  Size := 0;
  XHasSib := False;
  XHasModRM := False;
  MustHaveSize := True;
  Ref.MultiplyReg1 := 0;
  Ref.MultiplyReg2 := 0;
  Ref.Immidiate := nil;
  Result := OneByteOpcodes[char(ReadByte)];
  I := 1;
  while I < Length(Result) -1  do
    case Result[I] of
      '#': begin
           Insert(Operand(Result[I+1], Result[I+2], Result[I+3]), Result, I + 4);
           Delete(Result, I, 4);
           end;
      '@': begin
           Insert(Replacer(Result[I+1], Result[I+2]), Result, I + 3);
           Delete(Result, I, 3);
           end;
      '^': begin
           // Skip the numbers of character indicate in the next char.
           J := I;
           Inc(I, Ord(Result[I+1]));
           Delete(Result, J, 2);
           end;
      else Inc(I);
    end;
  // Replace '%s' with size name if MustHaveSize = true or nothing.
  I := 1;
  while I < Length(Result) -1  do
    case Result[I] of
      '%': begin
             case Result[I+1] of
               's': if MustHaveSize then
                      case Result[I+2] of
                        #1: Insert('byte ptr ', Result, I + 3);
                        #2: Insert('word ptr ', Result, I + 3);
                        #4: Insert('dword ptr ', Result, I + 3);
                        #6: ;
                        #8: Insert('qword ptr ', Result, I + 3);
                        #10: Insert('tbyte ptr ', Result, I + 3);
                      else
                        //raise Exception.CreateFmt('Size out of range. %d', [Ord(Result[I+2])]);
                        //MessageBox(0,PChar('Not fatal error occured. '+#13#10+'Size out of range'+#13#10+'Convertion will continue ...'),PChar('OPCODE Engine Error'),0);
                        Insert('???? ptr ', Result, I + 3);
                      end;

               'c': begin
                      // Include the opcode as DB.
                      Insert('  //', Result, I + 3);
                      for J := Size -1 downto 1 do
                        Insert(', $' + IntToHex(PByte(Address + J)^, 2), Result, I + 3);
                      Insert('DB  $' + IntToHex(PByte(Address)^, 2), Result, I + 3);
                    end;
             end;
             Delete(Result, I, 3);
           end;
      else Inc(I);
    end;


    //////////////////////////////////////////////////////////////////////
    //Added by DaFixer - Fix the addresses to always be 8 chars in lenth
    //
    ps1:=Pos('[$',Result);
    if ps1<>0 then
      begin
        ps2:=Pos(']',Result);
        if ps2-ps1<10 then
          for k:=ps2-ps1 to 9 do Insert('0',Result,ps1+2);
      end;
    //
    ///////////////////////////////////////////////////////////////////////
end;

function FindFirstSimpleCallTo(CallAddress, SearchAddress: PChar; SearchSize: Integer): PChar;
begin
   Result := SearchAddress;
   while Result <= SearchAddress + SearchSize - 5 do
   begin
     if (Result[0] = #$E8) and (Result + PInteger(Result+1)^ + 5 = CallAddress) then
       exit;
     Inc(Result, 1);
   end;
   Result := nil;
end;

function FindLastSimpleCallTo(CallAddress, SearchAddress: PChar; SearchSize: Integer): PChar;
begin
   Result := SearchAddress + SearchSize - 5;
   while Result >= SearchAddress  do
   begin
     if (Result[0] = #$E8) and (Result + PInteger(Result+1)^ + 5 = CallAddress) then
       exit;
     Dec(Result, 1);
   end;
   Result := nil;
end;

end.
