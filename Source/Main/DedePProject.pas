unit DeDePProject;

interface

uses Classes, SysUtils;

const IDENT_STRING = 'DeDeDOI';
      PREFIX_EVENTHANDLER = 'Btn_';
      PREFIX_TYPEDECLR    = 'Typ_';
      PREFIX_CUSTTYPE     = 'Cust_';
      PREFIX_ARRAY_OF     = 'ArrOf_';
      NEW_UNIT_STR        = 'Unit _DOI_;'#13#10'interface'#13#10;
      BEG_STR             = 'Type TDOIForm = class(TForm)'#13#10'published'#13#10;

procedure InitNewProject;
procedure EndProject(sFileName : String);
function StartNewClass(sClassName, sInheritsClass  : String) : Boolean;
procedure EndClass;
procedure Add(sIdent, sData : String);
procedure AddMethod(sDeclaration : String);
procedure AddProperty(sDeclaration : String);
procedure PrepareToSave(sINIT_DIR : String);

var VarTypesList : TStringList;
    CodeList : TStringList;
    PublishedMethList : TStringList;
    PublishedFieldList : TStringList;
    ImplementationList : TStringList;
    DFMStream : TMemoryStream;

    USES_LIST  : String          = '';
    INIT_DIR   : String;
    GlobClassName : String;

    GlobTypeFIXList : TStringList;
    GlobTypeFIXEDList : TStringList;
    GlobTypeSKIPList : TStringList;
    GlobClassSKIPList : TStringList;

implementation

var sClassDecl : String;
    sCustomTypes : String;
    SizePos : Integer;

Function GetTypeVarName(sTypeName : String) : String;
var s : String;
    i : Integer;
begin
  For i:=1 to Length(sTypeName) do
    if not (sTypeName[i] in [';',':']) then s:=s+sTypeName[i];
  s:=Trim(s);
  sTypeName:=s;
  Result:='';
  if s='' then Exit;

  s:=LowerCase(s);

  //0..41
  if Pos('..',s)<>0 then
     begin
       i:=Pos('..',s);
       s:=Copy(s,i+2,Length(s)-1);s:=Trim(s);
       i:=Pos(#32,s);
       if i<>0 then s:=copy(s,1,i-1);
       Result:=s;
       Exit;
     end;

  if Copy(s,1,9)='array of '
     then begin
       sTypeName:=Copy(sTypeName,10,Length(sTypeName)-9);
       s:=PREFIX_TYPEDECLR+sTypeName+' : '+sTypeName+';';
       if sTypeName<>'const' then
          begin
           s:=PREFIX_TYPEDECLR+PREFIX_ARRAY_OF+sTypeName+' : array of '+sTypeName+';';
           if VarTypesList.IndexOf(s)=-1 then VarTypesList.Add(s);
           Result:=PREFIX_TYPEDECLR+PREFIX_ARRAY_OF+sTypeName;
          end
          else Result:='[0]'; {Array of const}
     end
     else begin
        i:=GlobTypeFIXList.IndexOf(s);
        if i<>-1 then sTypeName:=GlobTypeFIXEDList[i];

        i:=GlobTypeSKIPList.IndexOf(s);
        if i<>-1 then Exit;

        s:=PREFIX_TYPEDECLR+sTypeName+' : '+sTypeName+';';
        if VarTypesList.IndexOf(s)=-1 then VarTypesList.Add(s);
        Result:=PREFIX_TYPEDECLR+sTypeName;
     end;
end;

procedure InitNewProject;
var b : String;
begin
  VarTypesList.Clear;
  PublishedFieldList.Clear;
  PublishedMethList.Clear;
  DFMStream.Clear;

  b:=#$FF#$0A#$00;
  DFMStream.WriteBuffer(b[1],3);
  b:='TDOIFORM';
  DFMStream.WriteBuffer(b[1],length(b));
  b:=#$00#$30#$10#$00#$00#$00#$00;
  DFMStream.WriteBuffer(b[1],7);
  SizePos:=DFMStream.Position-4;
  b:='TPF0'+Chr(Length('TDOIForm'))+'TDOIForm'+Chr(Length('DOIForm'))+'DOIForm';
  DFMStream.WriteBuffer(b[1],length(b));
  b:=#$04#$4C#$65#$66#$74#$03#$D5#$00#$03#$54+
     #$6F#$70#$02#$6B#$05#$57#$69#$64#$74#$68+
     #$03#$B8#$02#$06#$48#$65#$69#$67#$68#$74+
     #$03#$E0#$01#$07#$43#$61#$70#$74#$69#$6F+
     #$6E#$06#$05#$46#$6F#$72#$6D#$31#$05#$43+
     #$6F#$6C#$6F#$72#$07#$09#$63#$6C#$42#$74+
     #$6E#$46#$61#$63#$65#$0C#$46#$6F#$6E#$74+
     #$2E#$43#$68#$61#$72#$73#$65#$74#$07#$0F+
     #$44#$45#$46#$41#$55#$4C#$54#$5F#$43#$48+
{10} #$41#$52#$53#$45#$54#$0A#$46#$6F#$6E#$74+
     #$2E#$43#$6F#$6C#$6F#$72#$07#$0C#$63#$6C+
     #$57#$69#$6E#$64#$6F#$77#$54#$65#$78#$74+
     #$0B#$46#$6F#$6E#$74#$2E#$48#$65#$69#$67+
     #$68#$74#$02#$F5#$09#$46#$6F#$6E#$74#$2E+
     #$4E#$61#$6D#$65#$06#$0D#$4D#$53#$20#$53+
     #$61#$6E#$73#$20#$53#$65#$72#$69#$66#$0A+
     #$46#$6F#$6E#$74#$2E#$53#$74#$79#$6C#$65+
     #$0B#$00#$0E#$4F#$6C#$64#$43#$72#$65#$61+
     #$74#$65#$4F#$72#$64#$65#$72#$08#$0D#$50+
{20} #$69#$78#$65#$6C#$73#$50#$65#$72#$49#$6E+
     #$63#$68#$02#$60#$0A#$54#$65#$78#$74#$48+
     #$65#$69#$67#$68#$74#$02#$0D;
  DFMStream.WriteBuffer(b[1],217);
  sCustomTypes:='type'#13#10;
end;

procedure EndProject(sFileName : String);
var sz : LongWord;
    b,s : String;
    i,counter : Integer;
begin
  CodeList.Clear;
  CodeList.Add(NEW_UNIT_STR);
  s:='';b:='';
  For i:=1 To Length(USES_LIST) Do
    begin
     if USES_LIST[i]=',' then
       begin
         inc(counter);
         if counter mod 5 = 0 then b:=','#13#10
                              else b:=',';
       end
       else b:=USES_LIST[i];
       s:=s+b;
    end;
  USES_LIST:=s;
  CodeList.Add(USES_LIST);

  CodeList.Add(BEG_STR);
  CodeList.Add(PublishedFieldList.Text);
  CodeList.Add(PublishedMethList.Text);
  CodeList.Add('end;'#13#10'var'#13#10);
  CodeList.Add(VarTypesList.Text);
  CodeList.Add(sCustomTypes);
  CodeList.Add(#13#10'var DOIForm : TDOIForm;');
  CodeList.Add(#13#10'implementation'#13#10'{$R *.DFM}'#13#10);
  CodeList.Add(ImplementationList.Text);
  CodeList.Add(#13#10'end.');

  CodeList.SaveToFile(sFileName);

  // Update Length
  b:=#$00#$00;
  DFMStream.WriteBuffer(b[1],2);
  sz:=DFMStream.Size-SizePos-4;
  DFMStream.Seek(SizePos,soFromBeginning);
  DFMStream.WriteBuffer(sz,4);
  DFMStream.SaveToFile(ChangeFileExt(sFileName,'.dfm'));
end;

function StartNewClass(sClassName, sInheritsClass : String) : Boolean;
var s,b : String;
begin
  Result:=False;
  sClassName:=Trim(sClassName);
  if sClassName='' then Exit;

  Result:=True;
  GlobClassName:=sClassName;

  if GlobClassSKIPList.IndexOf(sClassName)<>-1 then Exit;
  sClassDecl:='';

  s:=PREFIX_EVENTHANDLER+sClassName+' : TButton;';
  PublishedFieldList.Add(s);
  s:='procedure '+PREFIX_EVENTHANDLER+sClassName+'Click(Sender : TObject);';
  PublishedMethList.Add(s);

  sCustomTypes:=sCustomTypes+PREFIX_CUSTTYPE+sClassName+' = Class ('+sClassName+');'#13#10;

  sClassDecl:='procedure TDOIForm.'+PREFIX_EVENTHANDLER+sClassName+'Click(Sender : TObject);'+
     #13#10'var s : String;'#13#10'inst : '+PREFIX_CUSTTYPE+sClassName+';'#13#10'begin'#13#10+
     's:='''+sInheritsClass+''';'+#13#10;



  b:=#$00;
  DFMStream.WriteBuffer(b[1],1);
  b:=#$07'TButton';
  DFMStream.WriteBuffer(b[1],length(b));
  b:=CHR(Length(PREFIX_EVENTHANDLER+sClassName))+PREFIX_EVENTHANDLER+sClassName;
  DFMStream.WriteBuffer(b[1],length(b));
  b:=#$04#$4C#$65#$66#$74#$02#$08#$03#$54#$6F#$70#$02#$10#$05#$57#$69#$64#$74#$68#$02#$71#$06#$48#$65#$69#$67#$68#$74#$02#$19#$08#$54#$61#$62#$4F#$72#$64#$65#$72#$02#$00;
  DFMStream.WriteBuffer(b[1],41);
  b:=#$07'OnClick'#$07;
  DFMStream.WriteBuffer(b[1],length(b));
  b:=PREFIX_EVENTHANDLER+sClassName+'Click';
  b:=CHR(Length(b))+b;
  DFMStream.WriteBuffer(b[1],length(b));
  b:=#$00;
  DFMStream.WriteBuffer(b[1],1);
end;

procedure EndClass;
begin
  sClassDecl:=sClassDecl+'end;'#13#10;
  ImplementationList.Add(sClassDecl);
end;

procedure Add(sIdent, sData : String);
var iPos : Integer;
    Sp, Stp : String;
Begin
  sp:='';
  For iPos:=1 to Length(sData) Do
      if not (sData[iPos] in [#1..#31]) then sp:=sp+sData[iPos];
  sData:=sp;

  iPos:=Pos(#32,sIdent);
  sp:=Copy(sIdent,1,iPos-1);
  stp:=Copy(sIdent,iPos+1,Length(sIdent)-iPos);
  if sp='private' then exit;
  if iPos=0 then stp:='';
  if (stp='') or (stp='property')
     then AddProperty(sData)
     else AddMethod(sData);
End;

procedure AddCode(s,s1 : String; bProp : Boolean = False);
var sProto, st, s_r, s_w : String;
    iPos : Integer;

    procedure ParseReadWrite(var s:String; var Rs,Ws : String);
    var rPos, wPos, iPos, dPos, sPos : Integer;
        s1 : String;
    begin
      s1:=LowerCase(s);

      iPos:=Pos(' index ',s1);
      rPos:=Pos(' read ',s1);
      wPos:=Pos(' write ',s1);
      sPos:=Pos(' stored ',s1);
      dPos:=Pos(' default ',s1);


      if rPos<>0
         then if wPos<>0
           then begin
              Rs:=Copy(s,rPos+6,wPos-rPos-6);
              if sPos=0
                 then Ws:=Copy(s,wPos+7,sPos-wPos-7)
                 else
                 if dPos=0 then Ws:=Copy(s,wPos+7,Length(s)-wPos-7)
                           else Ws:=Copy(s,wPos+7,dPos-wPos-7);
           end
           else begin
              if sPos<>0
                 then Rs:=Copy(s,rPos+7,sPos-rPos-7)
                 else
                 if dPos=0 then Rs:=Copy(s,rPos+6,Length(s)-rPos-6)
                           else Rs:=Copy(s,rPos+6,dPos-rPos-6);
              Ws:='';
           end
         else if wPos<>0
          then begin
              Rs:='';
              if sPos=0
                 then Ws:=Copy(s,wPos+7,sPos-wPos-7)
                 else
                 if dPos=0 then Ws:=Copy(s,wPos+7,Length(s)-wPos-7)
                           else Ws:=Copy(s,wPos+7,dPos-wPos-7);
          end
          else begin
              Rs:='';
              Ws:='';
          end;

      if rPos<>0
        then
          if iPos=0 then s:=Copy(s,1,rPos-1)
                    else s:=Copy(s,1,iPos-1)
        else if wPos<>0
          then
            if iPos=0 then s:=Copy(s,1,wPos-1)
                      else s:=Copy(s,1,iPos-1)
          else
            if iPos=0 then if dPos<>0 then s:=Copy(s,1,dPos-1)
                                      else if sPos<>0 then s:=Copy(s,1,sPos-1)
                      else s:=Copy(s,1,iPos-1);


    end;

    var lp,rp,i : Integer;
        sit,stmp   : String;
begin
   sProto:=s;

   While Pos(PREFIX_TYPEDECLR,sProto)<>0 Do
     Begin
       iPos:=Pos(PREFIX_TYPEDECLR,sProto);
       Delete(sProto,iPos,Length(PREFIX_TYPEDECLR));
     End;

   // 'inst' ....
   sProto:=Copy(sProto,6,Length(s)-5);
   // .... ';'
   While Copy(sProto,Length(sProto),1)=';' do  sProto:=Copy(sProto,1,Length(sProto)-1);
   if not bProp
     then begin
       // Method
       if s1<>'' then sProto:=sProto+' '+Copy(s1,1,Length(s1)-1);
       sProto:=Trim(sProto);
       sClassDecl:=sClassDecl+'s:='''+sProto+''';'#13#10+s+#13#10;
     end
     else begin
       // Property - may have read RBlah write RBlah
        ParseReadWrite(s1,s_r,s_w);
        s1:=Trim(s1); If (Length(s1)>0) and (s1[1]=':') then s1:=Copy(s1,2,Length(s1)-1);s1:=Trim(s1);
        st:=GetTypeVarName(s1);
        if (s1<>'') then  sProto:=sProto+' |'+s1;//Copy(s1,2,Length(s1)-1);

        // Blah[Index : Integer] : TBlah
        if Pos('[',s)<>0 then
          begin
            lp:=Pos('[',s);
            rp:=Pos(']',s);
            sit:=copy(s,lp+1,rp-lp-1);
            sit:=Trim(sit);
            stmp:='';
            for i:=Length(sit) downto 1 do
              if sit[i]<>':' then stmp:=sit[i]+stmp
                             else break;
            stmp:=Trim(stmp);
            stmp:=GetTypeVarName(stmp);
            s1:='';
            repeat
              i:=Pos(',',sit);
              sit:=Copy(sit,i+1,Length(sit)-i);
              s1:=s1+stmp+',';
            until i=0;
            s1:=Copy(s1,1,Length(s1)-1);
            s:=Copy(s,1,lp-1)+'['+s1+']'+Copy(s,rp+1,Length(s)-rp);
          end;

        sProto:=Trim(sProto);
        if s_r<>'' then sClassDecl:=sClassDecl+'s:='''+sProto+'<r_'+s_r+'>'+''';'#13#10+st+':='+s+';'#13#10;
        if s_w<>'' then sClassDecl:=sClassDecl+'s:='''+sProto+'<w_'+s_w+'>'+''';'#13#10+s+':='+st+';'#13#10;
     end;


end;

procedure AddMethod(sDeclaration : String);
var i,iPos : Integer;
    sCode, sParam : String;

    procedure ParseParams(s:String);
    var j, k : Integer;
        tmp : TStringList;
        s1, st : String;
    begin
      tmp:=TStringList.Create;
      try
        // Default values
        j:=Pos('=',s);
        if j<>0 then s:=Copy(s,1,j-1)+';';

        j:=Pos(':',s);
        if j=0 then
           begin
             //(untyped)
             s1:='Pointer';
           end
           else begin
              s1:=Copy(s,j+1,Length(s)-j);
              s:=Copy(s,1,j-1);
           end;
        tmp.CommaText:=s;
        st:=Trim(s1);
        st:=GetTypeVarName(st);
        For j:=0 to tmp.Count-1 Do
          if     (LowerCase(tmp[j])<>'const')
             and (LowerCase(tmp[j])<>'var')
             and (LowerCase(tmp[j])<>'out') then sCode:=sCode+st+',';
      finally
        tmp.free;
      end;
    end;

var bFlag : Boolean;
    sResType : String;

begin
  iPos:=Pos('(',sDeclaration);
  // No parameters
  if iPos=0 then
   begin
    if Pos(':',sDeclaration)<>0 then
     begin
       bFlag:=False;sCode:='';   sResType:='';
       For iPos:=Length(sDeclaration) downto 1 Do
         begin
          if bFlag then sCode:=sDeclaration[iPos]+sCode
                   else sResType:=sDeclaration[iPos]+sResType;
          if sDeclaration[iPos] in [':'] then bFlag:=True;
         end;
      end
      else begin
        sCode:=sDeclaration;
        sResType:='';
      end;
     AddCode('inst.'+sCode+';',sResType);
     Exit;
   end;

  sCode:=Copy(sDeclaration,1,iPos);
  sParam:=Copy(sDeclaration,iPos+1,Length(sDeclaration));

  iPos:=Pos(')',sParam);
  sResType:=Copy(sParam,iPos+1,Length(sParam)-iPos);
  sParam:=Copy(sParam,1,iPos-1);
  // Parsing Parameters
  Repeat
    iPos:=Pos(';',sParam);
    ParseParams(Copy(sParam,1,iPos-1));
    sParam:=Copy(sParam,iPos+1,Length(sParam)-iPos);
  Until iPos=0;
  ParseParams(sParam);
  // Clean last comma !
  sCode:=Copy(sCode,1,Length(sCode)-1);
  sCode:=sCode+');';
  AddCode('inst.'+sCode,sResType);
end;

procedure AddProperty(sDeclaration : String);
var bFlag : Boolean;
    sResType, sCode : String;
    iPos : Integer;
begin
  // Items[Index : Integer] : TBlahItem
  if Pos('[',sDeclaration)<>0 then
   begin
   end;

  if Pos(':',sDeclaration)<>0 then
   begin
     bFlag:=False;sCode:='';sResType:='';
     For iPos:=Length(sDeclaration) downto 1 Do
       begin
        if bFlag then sCode:=sDeclaration[iPos]+sCode
                 else sResType:=sDeclaration[iPos]+sResType;
        if sDeclaration[iPos] in [':'] then bFlag:=True;

       end;

       AddCode('inst.'+sCode,sResType,True);
    end;
end;

procedure PrepareToSave(sINIT_DIR : String);
var sr : TSearchRec;
    b : Boolean;      
begin              
  INIT_DIR:=sINIT_DIR+'\OutPut_DOI_';
  b:=FindFirst(INIT_DIR,faDirectory,sr)=0;
 // sINIT_DIR:=sr.Name;
  FindClose(sr);
  if not b then
    begin
      ChDir(sINIT_DIR);
      MkDir('OutPut_DOI_');
    end;
end;

Procedure InitializeFixups;
Begin
  //GlobTypeFIXList.Add('tbitmap');GlobTypeFIXEDList.Add('tagBITMAP');
end;

Procedure InitializeSkips;
Begin
  GlobTypeSKIPList.Add('TResourceManager');

  GlobClassSKIPList.Add('TConnectionPoint');
end;


initialization
  VarTypesList:=TStringList.Create;
  CodeList:=TStringList.Create;
  PublishedMethList:=TStringList.Create;
  PublishedFieldList:=TStringList.Create;
  ImplementationList:=TStringList.Create;
  DFMStream:=TMemoryStream.Create;
  GlobTypeFIXList:=TStringList.Create;
  GlobTypeFIXEDList:=TStringList.Create;
  InitializeFixups;
  GlobTypeSKIPList:=TStringList.Create;
  GlobClassSKIPList:=TStringList.Create;
  InitializeSkips;

finalization
  VarTypesList.Free;
  PublishedMethList.Free;
  PublishedFieldList.Free;
  ImplementationList.Free;
  CodeList.Free;
  DFMStream.Free;
  GlobTypeFIXList.Free;
  GlobTypeFIXEDList.Free;
  GlobTypeSKIPList.free;
  GlobClassSKIPList.Free;

end.
