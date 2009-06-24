{ Disassembled text editor }
// [ LC ]
unit DeDeEditText;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls{, Qt};

type
  TEditTextForm = class(TForm)
    Edit1: TEdit;
    Label1: TLabel;
    procedure FormHide(Sender: TObject);
    procedure Edit1KeyPress(Sender: TObject; var Key: Char);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

type
   TComment = record
      cmtRVA : longword;
      Comment : string[255];
end; { type }

var
  EditTextForm: TEditTextForm;
   Comments : array of TComment;
   CommentsCount : integer;

procedure AddComment (const RVA : longword; const CommentString : string);
function GetComment(const RVA : longword; var index : integer; var CommentString : string) : boolean;
procedure EditComment(RVA : longint);

implementation

uses ASMShow, DeDeExpressions, HexTools;

{$R *.dfm}

var
   currentRVA : longint;

procedure AddComment (const RVA : longword; const CommentString : string);
var
   prevComment : string;
   i, prevIndex : integer;
begin
   if GetComment(RVA, prevIndex, prevComment) then begin
      if Trim(CommentString) <> '' then begin
         Comments[prevIndex].Comment := CommentString;
      end else begin
         dec(CommentsCount);
         for i:=prevIndex to CommentsCount-1 do
            Comments[i]:=Comments[i+1];
      end; { if }
   end else if Trim(CommentString)<>'' then begin
      inc(CommentsCount);
      SetLength(Comments, CommentsCount);
      Comments[CommentsCount - 1].cmtRVA := RVA;
      Comments[CommentsCount - 1].Comment := CommentString;
   end; { if }
end;

function GetComment(const RVA : longword; var index : integer; var CommentString : string) : boolean;
var
   i : integer;
begin
   Result := false;
   for i := 0 to (CommentsCount-1) do begin
      if Comments[i].cmtRVA = RVA then begin
         CommentString := Comments[i].Comment;
         index := i;
         Result := true;
         break;
      end; { if }
   end; { for }
end;

procedure EditComment(RVA : longint);
begin
   currentRVA := RVA;
   EditTextForm.Edit1.SetFocus;
end;


procedure TEditTextForm.FormHide(Sender: TObject);
var
   s, q, vars : string;
   i, j, l : integer;
begin
   s := Edit1.Text;
   AddComment(currentRVA, s);
   i := ASMShowForm.AsmList.ItemIndex;
   q := ASMShowForm.AsmList.Items[i];
   j := Pos('{ ', q);
   if j > 0 then q := Trim(Copy(q, 1, j - 1));

   // Seek variables
   vars:='';
   for l:=0 to ExpressionCount-1 do
     if (Expressions[l].RVA=Hex2DWORD(ASMShow.GetCurrFirstRVA)) or (Expressions[l].RVA=0) then
        if (Expressions[l].Comment<>'') and (Pos(Expressions[l].Name,q)<>0)
          then vars:=Expressions[l].Comment+'; '+vars;

   if Trim(s)<>'' then
      ASMShowForm.AsmList.Items[i] := q + ' { ' + vars+s + ' }'

end;

procedure TEditTextForm.Edit1KeyPress(Sender: TObject; var Key: Char);
begin
   if Key in  [#13,#27] then begin
      EditTextForm.Hide;
   end; { if }
end;

procedure TEditTextForm.FormDestroy(Sender: TObject);
begin
   SetLength(Comments, 0);
end;

end.
