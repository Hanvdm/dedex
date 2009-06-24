unit MakePEHUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Mask, ExtCtrls, rxToolEdit;

type
  TMakePEHForm = class(TForm)
    Button1: TButton;
    Button2: TButton;
    SrcFileEdit: TFilenameEdit;
    DestFileEdit: TFilenameEdit;
    Label1: TLabel;
    Label2: TLabel;
    EPBC: TCheckBox;
    SecCB: TCheckBox;
    Bevel1: TBevel;
    Bevel2: TBevel;
    procedure SrcFileEditChange(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MakePEHForm: TMakePEHForm;

implementation

{$R *.DFM}

Uses DeDeClasses, DeDeMemDumps, HEXTools, DeDeRES;

procedure TMakePEHForm.SrcFileEditChange(Sender: TObject);
begin
  DestFileEdit.Text:='"'+ChangeFileExt(SrcFileEdit.FileName,'.new')+'"';
end;

procedure TMakePEHForm.Button1Click(Sender: TObject);
begin
  Close;
end;

procedure TMakePEHForm.Button2Click(Sender: TObject);
const sBoolean = '07426F6F6C65616E';
var MemStr : TMemoryStream;
    PEF : ThePEFile;
    PEH : TPEHeader;
    dw, DVer : DWORD;
    s : String;
    b1 : byte;
    i : Integer;
    b : array [0..7] of Byte;
begin
   If Not FileExists(SrcFileEdit.FileName) Then
      Raise Exception.CreateFmt(err_invalid_file,[SrcFileEdit.FileName]);

   PEF:=ThePEFile.Create(SrcFileEdit.FileName);
   Try
     PEH.Dump(PEF);

     PEF.PEStream.Seek(PEH.Objects[1].PHYSICAL_OFFSET+1,soFromBeginning);
     s:='';
     For i:=1 To Length(sBoolean) div 2 Do
      Begin
        PEF.PEStream.ReadBuffer(b1,1);
        s:=s+Byte2HEX(b1);
      End;

     if s=sBoolean
        then DVer:=2
        else s:=GetDelphiVersion(PEF);

     if s='D3' then DVer:=3;
     if s='D4' then DVer:=4;
     if s='D5' then DVer:=5;
     if s='D6' then DVer:=6;

     If DVer=0 then
       begin
         ShowMessage(err_not_delphi_app1);
         exit;
       end;

     PEH.PEHeaderOffset:=256;
       
     If EPBC.Checked Then
       Begin
         //Finding and correcting Entry Point
         dw:=GetRVAEntryPoint(PEF.PEStream, PEH.IMAGE_BASE, 0, 0, DVer);
         PEF.PEStream.Seek($28+PEH.PEHeaderOffset,soFromBeginning);
         dw:=dw+(PEH.Objects[1].RVA-PEH.Objects[1].PHYSICAL_OFFSET);
         PEF.PEStream.WriteBuffer(dw,4);
       End;

     If SecCB.Checked Then
       Begin
          // Setting Flags
          PEH.Objects[1].FLAGS:=$60000020;
          PEH.Objects[2].FLAGS:=$C0000040;
          PEH.Objects[3].FLAGS:=$C0000000;
          PEH.Objects[4].FLAGS:=$C0000040;
          PEH.Objects[5].FLAGS:=$C0000000;
          PEH.Objects[6].FLAGS:=$50000040;
          PEH.Objects[7].FLAGS:=$50000040;
          PEH.Objects[8].FLAGS:=$50000040;

          // Setting objects data

          // Change the CODE section flags
          // to be opened by Win32DASM (if not 60000020 it do not process the file)
          For i:=1 To 1 Do
            Begin
               // Fix the ProcDump bug !!!
               dw:=PEH.Objects[i].PHYSICAL_SIZE;
               if PEH.Objects[i].VIRTUAL_SIZE>dw then
                  begin
                     PEH.Objects[i].PHYSICAL_SIZE:=PEH.Objects[i].VIRTUAL_SIZE;
                     PEH.Objects[i].VIRTUAL_SIZE:=dw;
                  end;

               // Goto to the begining of a section record in PE HEader
               PEF.PEStream.Seek((i-1)*$28+$F8+PEH.PEHeaderOffset,soFromBeginning);

               // Change Section Names
               FillChar(b,8,0);
               Case i of
                 1: begin b[0]:=$43; b[1]:=$4F; b[2]:=$44; b[3]:=$45; end;                       {CODE}
                 2: begin b[0]:=$44; b[1]:=$41; b[2]:=$54; b[3]:=$41; end;                       {DATA}
                 3: begin b[0]:=$42; b[1]:=$53; b[2]:=$53; end;                                  {BSS}
                 4: begin b[0]:=$2E; b[1]:=$69; b[2]:=$64; b[3]:=$61; b[4]:=$74; b[5]:=$61; end; {.idata}
                 5: begin b[0]:=$74; b[1]:=$6C; b[2]:=$73; end;                                  {.tls}
                 6: begin b[0]:=$2E; b[1]:=$72; b[2]:=$64; b[3]:=$61; b[4]:=$74; b[5]:=$61; end; {.rdata}
                 7: begin b[0]:=$2E; b[1]:=$72; b[2]:=$65; b[3]:=$6C; b[4]:=$6F; b[5]:=$63; end; {.reloc}
                 8: begin b[0]:=$2E; b[1]:=$72; b[2]:=$73; b[3]:=$72; b[4]:=$63; end;            {.rsrc}
               End;

               PEF.PEStream.Seek(8,SoFromCurrent);
               dw:=PEH.Objects[i].VIRTUAL_SIZE;
               PEF.PEStream.WriteBuffer(dw,4);
               dw:=PEH.Objects[i].RVA;
               PEF.PEStream.WriteBuffer(dw,4);
               dw:=PEH.Objects[i].PHYSICAL_SIZE;
               PEF.PEStream.WriteBuffer(dw,4);

               PEF.PEStream.Seek(16,soFromCurrent);
               dw:=PEH.Objects[i].FLAGS;
               PEF.PEStream.WriteBuffer(dw,4);
            End;
       end;

       PEF.PEStream.SaveToFile(DestFileEdit.FileName);
       ShowMessage(msg_peh_corrsaved);
   Finally
     PEF.Free;
   End;
end;

end.
