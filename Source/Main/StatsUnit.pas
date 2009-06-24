unit StatsUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, VCLZip{, Psock, NMFtp};

type
  TStatsForm = class(TForm)
    Panel1: TPanel;
    DoneBtn: TButton;
    StartTimer: TTimer;
    Memo1: TMemo;
    procedure StartTimerTimer(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure DoneBtnClick(Sender: TObject);
  private
    { Private declarations }
    procedure ProcessIt(sProcess, sFolder : String);
    procedure AddLine(s : String);
  public
    { Public declarations }
    FsSiceDir, FsTarget : String; 
    procedure DoIt;
  end;

var
  StatsForm: TStatsForm;

var hSaveStdout : THandle;
    hChildStdoutRdDup : THandle;
    fSuccess : Boolean;
    hChildStdoutRd, hChildStdoutWr, hChildStdoutRd2, hChildStdoutWr2, hChildStdoutRd3, hChildStdoutWr3 : Cardinal;

const BUFSIZE=1024;

var dwRead, dwWritten : DWORD;
    chBuf : Array [0..BUFSIZE] of Char;
    saAttr : TSecurityAttributes;

implementation

{$R *.DFM}

{ TStatsForm }

procedure TStatsForm.AddLine(s: String);
var s1 : String;
    i  : Integer;
    //sNewLine, sLastLine : String;
    //bNewLine : Boolean;
begin
  s1:='';
//  bNewLine:=True;
  For i:=1 to dwRead do
    case s[i] of
      #0  : ;
      #8  : {begin
              Memo1.Lines.BeginUpdate;
              Try
                if bNewLine then Memo1.Lines.Add(s1)
              Finally
                Memo1.Lines.EndUpdate;
              End;
              s1:=Memo1.Lines[Memo1.Lines.Count-1];
             } s1:=Copy(s1,1,Length(s1)-1);
             { bNewLine:=False;
            end;
      #13 :;
      #10 : begin
              Memo1.Lines.BeginUpdate;
              Try
                if bNewLine then Memo1.Lines.Add(s1)
                            else Memo1.Lines[Memo1.Lines.Count-1]:=s1;
                bNewLine:=True;
                s1:='';
              Finally
                Memo1.Lines.EndUpdate;
              End;
            end;}
      else s1:=s1+s[i];
    end;
  Memo1.Lines.Add(s1);
end;

procedure TStatsForm.ProcessIt(sProcess, sFolder: String);
var sa : _startupinfoa;
    pi : _process_information;
    dw : DWORD;
begin
  saAttr.nLength := sizeof(SECURITY_ATTRIBUTES);
  saAttr.bInheritHandle := TRUE;
  saAttr.lpSecurityDescriptor := nil;

  CreatePipe(hChildStdoutRd, hChildStdoutWr, @saAttr, 0);
  DuplicateHandle(GetCurrentProcess(), hChildStdoutRd, GetCurrentProcess(), @hChildStdoutRdDup , 0, FALSE,       DUPLICATE_SAME_ACCESS);
  CloseHandle(hChildStdoutRd);
  CreatePipe(hChildStdoutRd2, hChildStdoutWr2, @saAttr, 0);
  CreatePipe(hChildStdoutRd3, hChildStdoutWr3, @saAttr, 0);

  GetStartUpInfo(sa);
  sa.dwFlags:=STARTF_USESTDHANDLES OR STARTF_USESHOWWINDOW;
  sa.wShowWindow:=SW_HIDE;
  sa.hStdOutput:=hChildStdoutWr;
  sa.hStdInput:=hChildStdoutRd;
  sa.hStdError:=hChildStdoutWr3;

  sa.cb := sizeof(STARTUPINFO);
  if not CreateProcess(nil,PChar(sProcess),nil,nil,True,
    0,nil,PChar(sFolder),sa,pi) then
      begin
        dw:=GetLastError;
        Memo1.Lines.Add('Error creating process "'+sProcess+'" : '+IntToStr(dw));
      end;
  CloseHandle(hChildStdoutWr);
   repeat
     if not ReadFile(hChildStdoutRdDup, chBuf[1], BUFSIZE, dwRead, nil) then break;
     if (dwRead = 0) then break;
     AddLine(String(PChar(@chBuf[1])));
   until false;

  CloseHandle(hChildStdoutRdDup);
  CloseHandle(hChildStdoutRd2);
  CloseHandle(hChildStdoutWr2);
  CloseHandle(hChildStdoutRd3);
  CloseHandle(hChildStdoutWr3);
end;

procedure TStatsForm.StartTimerTimer(Sender: TObject);
begin
  StartTimer.Enabled:=False;
  DoIt;
end;

procedure TStatsForm.FormShow(Sender: TObject);
begin
   StartTimer.Enabled:=True;
end;

procedure TStatsForm.DoneBtnClick(Sender: TObject);
begin
  Close;
end;

procedure TStatsForm.DoIt;
var sFileName, sCurDir : String;
begin
 sFileName:=ChangeFileExt(ExtractFileName(FsTarget),'');
 CopyFile(PChar(FsTarget),PChar(FsSiceDir+'\Util16\'+sFileName+'.map'),False);
 GetDir(0,sCurDir);
 ChDir(FsSiceDir+'\Util16');
 Screen.Cursor:=crHourGlass;
 DoneBtn.Enabled:=False;
 Try
   WinExec(PChar('msym.exe '+sFileName+'.map'),0);
   Sleep(5000);
   Memo1.Clear;
   CopyFile(PChar(FsSiceDir+'\Util16\'+sFileName+'.sym'),PChar(FsSiceDir+'\'+sFileName+'.sym'),False);
   ChDir(FsSiceDir);
   ProcessIt('nmsym.exe '+sFileName+'.sym',FsSiceDir);
   ProcessIt('nmsym.exe /UNLOAD:'+sFileName+'.nms',FsSiceDir);
   ProcessIt('nmsym.exe /SYM:'+sFileName+'.nms',FsSiceDir);
   CopyFile(PChar(FsSiceDir+'\Util16\'+sFileName+'.sym'),PChar(ExtractFileDir(FsTarget)+'\'+sFileName+'.sym'),False);
   DeleteFile(PChar(FsSiceDir+'\Util16\'+sFileName+'.map'));
   DeleteFile(PChar(FsSiceDir+'\Util16\'+sFileName+'.sym'));
   DeleteFile(PChar(FsSiceDir+'\'+sFileName+'.sym'));
   DeleteFile(PChar(FsSiceDir+'\'+sFileName+'.nsm'));
 Finally
  ChDir(sCurDir);
  Screen.Cursor:=crDefault;
  DoneBtn.Enabled:=True;
 End;
end;

end.
