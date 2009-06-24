unit DeDeELFClasses;

interface

uses Classes, SysUtils;

type

   DWORD       = LongWord;
   Elf32_Addr  = DWORD;
   Elf32_Half  = WORD;
   Elf32_Off   = DWORD;
   Elf32_Sword = Integer;
   Elf32_Word  = DWORD;

const EI_NIDENT = 16;

type Elf32_Ehdr = record
        e_ident : Array [0..EI_NIDENT-1] of byte;
        e_type : Elf32_Half;
        e_machine : Elf32_Half;
        e_version : Elf32_Word;
        e_entry : Elf32_Addr;
        e_phoff : Elf32_Off;
        e_shoff : Elf32_Off;
        e_flags : Elf32_Word;
        e_ehsize : Elf32_Half;
        e_phentsize : Elf32_Half;
        e_phnum : Elf32_Half;
        e_shentsize : Elf32_Half;
        e_shnum : Elf32_Half;
        e_shstrndx : Elf32_Half;
     End;

type Elf32_Shdr = Record
        sh_name : Elf32_Word;
        sh_type : Elf32_Word;
        sh_flags : Elf32_Word;
        sh_addr : Elf32_Addr;
        sh_offset : Elf32_Off;
        sh_size : Elf32_Word;
        sh_link : Elf32_Word;
        sh_info : Elf32_Word;
        sh_addralign : Elf32_Word;
        sh_entsize : Elf32_Word;
     End;

Type TELFSection = Class
      public
        SHDR : Elf32_Shdr;
        SectionName : String;
        SectionType : String;
        Flags : String;
        constructor Create;
        destructor Destroy; override;
        procedure DecodeTypes;
     end;

type TELFHeader = class
       protected
       public
         ELF32HDR : Elf32_Ehdr;
         Sections : Array of TELFSection;
         SectionsCount : Integer;
         SectionNames : TStringList;
         constructor Create;
         destructor Destroy; override;
     end;

type TELFFile = class
       protected
       public
         FStream : TMemoryStream;
         ELFHeader : TELFHeader;
         stblDelphiVersion : String;
         constructor Create(AFileName : String);
         destructor Destroy; override;
         procedure Dump;
         function IsKylixFile : Boolean;
     end;

const ELF_MAGIC = $464C457F;

implementation

{ TELFHeader }

constructor TELFHeader.Create;
begin
  inherited Create;

  SectionNames:=TStringList.Create;
end;

destructor TELFHeader.Destroy;
var i : Integer;
begin
  SectionNames.Free;

  for i:=Length(Sections)-1 downto 0 do
      if Sections[1]<>nil then Sections[i].Free;
      
  SetLength(Sections,0);

  inherited;
end;

{ TELFFile }

constructor TELFFile.Create(AFileName: String);
begin
  inherited Create;

  ELFHEader:=TELFHEader.Create;
  FStream:=TMemoryStream.Create;
  FStream.LoadFromFile(AFileName);
end;

destructor TELFFile.Destroy;
begin
  FStream.Free;
  ELFHEader.Free;

  inherited;
end;

procedure TELFFile.Dump;
var dw : DWORD;
    i : Integer;
    bt : Byte;
begin
  FStream.Seek(0,soFromBeginning);
  //Magic
  FStream.ReadBuffer(dw,4);
  if dw<>ELF_MAGIC then Raise Exception.Create('Not an ELF file!');

  // Read ELF Header
  FStream.Seek(0,soFromBeginning);
  FStream.ReadBuffer(ELFHeader.ELF32HDR,SizeOf(ELFHeader.ELF32HDR));

  //Read Section Info
  FStream.Seek(ELFHeader.ELF32HDR.e_shoff,soFromBeginning);
  ELFHeader.SectionsCount:=ELFHeader.ELF32HDR.e_shnum;
  SetLength(ELFHeader.Sections,ELFHeader.SectionsCount);
  for i:=0 to ELFHeader.SectionsCount-1 do
    begin
      ELFHeader.Sections[i]:=TELFSection.Create;
      FStream.ReadBuffer(ELFHeader.Sections[i].SHDR,SizeOf(ELFHeader.Sections[1].SHDR));
    end;


  //LAst section is sections string table
  ELFHeader.SectionNames.Clear;
  dw:=ELFHeader.Sections[ELFHeader.SectionsCount-1].SHDR.sh_offset;
  For i:=0 to ELFHeader.SectionsCount-1 do
    begin
      FStream.Seek(dw+ELFHeader.Sections[i].SHDR.sh_name,soFromBeginning);
      ELFHeader.Sections[i].SectionName:='';
      FStream.ReadBuffer(bt,1);
      while bt<>0 do
        begin
         ELFHeader.Sections[i].SectionName:=ELFHeader.Sections[i].SectionName+CHR(bt);
         FStream.ReadBuffer(bt,1);
        End;
      ELFHeader.SectionNames.Add(ELFHeader.Sections[i].SectionName);
      ELFHeader.Sections[i].DecodeTypes;
    end;

  FStream.Seek(ELFHeader.Sections[ELFHeader.SectionsCount-2].SHDR.sh_offset,soFromBeginning);
  stblDelphiVersion:='';
  FStream.ReadBuffer(bt,1);
  while bt<>0 do
    begin
     stblDelphiVersion:=stblDelphiVersion+CHR(bt);
     FStream.ReadBuffer(bt,1);
    End;
end;

function TELFFile.IsKylixFile: Boolean;
var i, idx : Integer;
begin
  idx:=0;
  For i:=0 to ELFHeader.SectionNames.Count-1 do
      if Copy(ELFHeader.SectionNames[i],1,8)='borland.' then Inc(idx);
  Result:=idx>0;
end;

{ TELFSection }

constructor TELFSection.Create;
begin
  inherited Create;
end;

procedure TELFSection.DecodeTypes;
begin
  case SHDR.sh_type of
           0  : SectionType:='NULL';
           1  : SectionType:='PROGBITS';
           2  : SectionType:='SYMTAB';
           3  : SectionType:='STRTAB';
           4  : SectionType:='RELA';
           5  : SectionType:='HASH';
           6  : SectionType:='DYNAMIC';
           7  : SectionType:='NOTE';
           8  : SectionType:='NOBITS';
           9  : SectionType:='REL';
          10  : SectionType:='SHLIB';
          11  : SectionType:='DYNSYM';
   $70000000  : SectionType:='LOPROC';
   $7fffffff  : SectionType:='HIPROC';
   $80000000  : SectionType:='LOUSER';
   $ffffffff  : SectionType:='HIUSER';
  end;

  Flags:='';
  if SHDR.sh_flags and 1 <>0 then Flags:='w';
  if SHDR.sh_flags and 2 <>0 then Flags:=Flags+'a';
  if SHDR.sh_flags and 4 <>0 then Flags:=Flags+'e';
  if SHDR.sh_flags and $f0000000 <>0 then Flags:=Flags+'m';
end;

destructor TELFSection.Destroy;
begin

  inherited;
end;

end.

