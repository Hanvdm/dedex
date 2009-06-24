unit DeDeConstants;
//////////////////////////
// Last Change: 28.VIII.2001
//////////////////////////

interface

///////////////////////////////////////////////////////////////////////////////
// CURRENT DeDe VERSION
///////////////////////////////////////////////////////////////////////////////
var
  GlobsCurrDeDeVersion : string = '3.11';
  GlobsCurrDeDeBuild: string = '9.6.19.9';

///////////////////////////////////////////////////////////////////////////////
// THIS IS THE PATTERN SIZE FOR THE CURRENT DSF VERSION FORMAT
// AND THE TSymBuffer DEFINED FOR THAT, CURRENT, VERSION
///////////////////////////////////////////////////////////////////////////////
Const _PatternSize = 50;
Type TSymBuffer = Array [1.._PatternSize] of Byte;

Const
 (*
 ///////////////////////////////////////////////////////////////////////////////
 // Not used anymore
 ///////////////////////////////////////////////////////////////////////////////
 // sPROJECT_HEADER = '263D4F38C28237B8F3244203179B3A83';

 ///////////////////////////////////////////////////////////////////////////////
 //   These constants are not used anymore since DeDe v2.40. They are needed in
 // DeDeClasses.TDelphi4PE.IdentifyCompiler() function that is not used anymore
 ///////////////////////////////////////////////////////////////////////////////
 iCOMPILER_ID_COUNT=3;
 iCOMPILER_IDENT_LENGTH =$F;
 arrCOMPILER_IDS : Array [1..iCOMPILER_ID_COUNT] of String =
                   ((#$26#$3D#$4F#$38#$C2#$82#$37#$B8#$F3#$24#$42#$03#$17#$9B#$3A#$83),
                    (#$23#$78#$5D#$23#$B6#$A5#$F3#$19#$43#$F3#$40#$02#$26#$D1#$11#$C7),
                    (#$A2#$8C#$DF#$98#$7B#$3C#$3A#$79#$26#$71#$3F#$09#$0F#$2A#$25#$17));

  *)
  
 ///////////////////////////////////////////////////////////////////////////////
 //    Idents used to recognize program entry point. These arrays are used by
 // the Program Entry Point Finder Engine in DeDeMemDumps.GetRVAEntryPoint()
 ///////////////////////////////////////////////////////////////////////////////
 D2_Ident : TSymBuffer =
                ($E8,$00,$00,$00,$00,$6A,$00,$E8,$00,$00,
                 $00,$00,$89,$05,$00,$00,$00,$00,$E8,$00,
                 $00,$00,$00,$89,$05,$00,$00,$00,$00,$C7,
                 $05,$00,$00,$00,$00,$0A,$00,$00,$00,$B8,
                 $00,$00,$00,$00,$C3,$00,$00,$00,$00,$00);
 D3_Ident : TSymBuffer =
                ($50,$6A,$00,$E8,$00,$00,$00,$00,$BA,$00,
                 $00,$00,$00,$52,$89,$05,$00,$00,$00,$00,
                 $89,$42,$04,$E8,$00,$00,$00,$00,$5A,$58,
                 $E8,$00,$00,$00,$00,$C3,$00,$00,$00,$00,
                 $00,$00,$00,$00,$00,$00,$00,$00,$00,$00);
                 
 D4_Ident : TSymBuffer =  //For Delphi 4 and Delphi 5
                ($50,$6A,$00,$E8,$00,$00,$00,$00,$BA,$00,
                 $00,$00,$00,$52,$89,$05,$00,$00,$00,$00,
                 $89,$42,$04,$C7,$42,$08,$00,$00,$00,$00,
                 $C7,$42,$0C,$00,$00,$00,$00,$E8,$00,$00,
                 $00,$00,$5A,$58,$E8,$00,$00,$00,$00,$00);

 D6_Ident : TSymBuffer =
                ($53,$8B,$D8,$33,$C0,$A3,$00,$00,$00,$00,
                 $6A,$00,$E8,$00,$00,$00,$00,$A3,$00,$00,
                 $00,$00,$A1,$00,$00,$00,$00,$A3,$00,$00,
                 $00,$00,$33,$C0,$A3,$00,$00,$00,$00,$33,
                 $C0,$A3,$00,$00,$00,$00,$E8,$00,$00,$00);

  // This is for Delphi 3                 
  RVA_Ident1 : Array [0..15] of byte = ($55,$8B,$EC,$83,$C4,$F4,$B8,$00,$00,$00,$00,$E8,$00,$00,$00,$00);
  // This is for Delphi 4 and 5
  RVA_Ident2 : Array [0..16] of byte = ($55,$8B,$EC,$83,$C4,$F4,$53,$B8,$00,$00,$00,$00,$E8,$00,$00,$00,$00);
  // This is for Delphi 2
  RVA_Ident3 : Array [0..10] of byte = ($55,$8B,$EC,$83,$C4,$F4,$53,$E8,$00,$00,$00);
  // This is for Delphi 6
  RVA_Ident4 : Array [0..15] of byte = ($55,$8B,$EC,$83,$C4,$F0,$B8,$00,$00,$00,$00,$E8,$00,$00,$00,$00);


 ///////////////////////////////////////////////////////////////////////////////
 //    Idents used to find the offset of System..InitUnits() routine and to
 // get the PackageInfoTable
 ///////////////////////////////////////////////////////////////////////////////
  D2_InitUnitsIdent : TSymBuffer =
                ($55,$8B,$EC,$53,$56,$57,$A1,$00,$00,$00,
                 $00,$85,$C0,$74,$4B,$8B,$30,$33,$DB,$8B,
                 $78,$04,$33,$D2,$55,$68,$00,$00,$00,$00,
                 $64,$FF,$32,$64,$89,$22,$3B,$F3,$7E,$14,
                 $8B,$04,$DF,$43,$89,$1D,$00,$00,$00,$00);

  D3_InitUnitsIdent : TSymBuffer =
                ($55,$8B,$EC,$53,$56,$57,$A1,$00,$00,$00,
                 $00,$85,$C0,$74,$4B,$8B,$30,$33,$DB,$8B,
                 $78,$04,$33,$D2,$55,$68,$00,$00,$00,$00,
                 $64,$FF,$32,$64,$89,$22,$3B,$F3,$7E,$14,
                 $8B,$04,$DF,$43,$89,$1D,$00,$00,$00,$00);

  D4_InitUnitsIdent : TSymBuffer =
                ($55,$8B,$EC,$53,$56,$57,$A1,$00,$00,$00,
                 $00,$85,$C0,$74,$4B,$8B,$30,$33,$DB,$8B,
                 $78,$04,$33,$D2,$55,$68,$00,$00,$00,$00,
                 $64,$FF,$32,$64,$89,$22,$3B,$F3,$7E,$14,
                 $8B,$04,$DF,$43,$89,$1D,$00,$00,$00,$00);

  D6_InitUnitsIdent : TSymBuffer =
                ($55,$8B,$EC,$53,$56,$57,$A1,$00,$00,$00,
                 $00,$85,$C0,$74,$4B,$8B,$30,$33,$DB,$8B,
                 $78,$04,$33,$D2,$55,$68,$00,$00,$00,$00,
                 $64,$FF,$32,$64,$89,$22,$3B,$F3,$7E,$14,
                 $8B,$04,$DF,$43,$89,$1D,$00,$00,$00,$00);

  InitContextOffset2 = 7;
  InitContextOffset3 = 7;
  InitContextOffset4 = 7;
  InitContextOffset6 = 7;

 ///////////////////////////////////////////////////////////////////////////////
 // Some constants used to dump project information. Since DeDe v2.40 package
 // information from recourses is used to find the project information. Anyway
 // for Delphi2 method that uses the constants bellow is still used
 ///////////////////////////////////////////////////////////////////////////////
 // Not used anymore
 // sTInterfaceObject = '1154496E74657266616365644F626A656374';
 //-----------------------------------------------------------------------------
 // Used in the old project dump (and D2 also) :
 iPROJECT_OFFSET = $14;
 // Used in the new project dump :
 iPACKAGEINFO_APP_OFFSET=$E;


 ///////////////////////////////////////////////////////////////////////////////
 // Some cinstants used when building .pas files (Save project space)
 ///////////////////////////////////////////////////////////////////////////////
 // Not used anymore
 // iMAX_NON_USES_UNITS_COUNT=2;
 // arrPROJECT_NON_USES_UNITS : Array [1..iMAX_NON_USES_UNITS_COUNT] of String =
 //            ('System','SysInit');
 //-----------------------------------------------------------------------------
 // Used in TDFMProjectHeader.Dump() also :
 iMAX_STANDART_UNITS_COUNT=12;
 arrPROJECT_STANDART_UNITS : Array [1..iMAX_STANDART_UNITS_COUNT] of String =
             ('System','SysInit','Forms','Windows','Classes',
              'SysUtils','Dialogs','Messages','Graphics','Controls',
              'StdCtrls','Db');

 ///////////////////////////////////////////////////////////////////////////////
 // DFM RCDATA Headers/Magics
 ///////////////////////////////////////////////////////////////////////////////
 sDFM_ID = '54504630';
 sDFM_Magic_Stirng = 'TPF0';
 sDFM_HEADER   = 'FF0A0054464F524D310030105C010000';
 arrDFM_HEADER : Array [0..15] of Byte =
         (255,10,0,84,70,79,82,77,49,0,48,16,92,1,0,0);


 ///////////////////////////////////////////////////////////////////////////////
 //    In class emulator this value is used while seeking for object/class
 // references. if there is 'MOV register, [offset]' instruction, this offset
 // is in the CODE section and there is no direct access reference then next
 // iCLASS_REF_IN_CODE_SEEK_LENGTH are being searched for class name. If such
 // string is found it is put as the refered class/object name.
 //    This "trick" is probably useless anymore when the classes directly
 // inherited from TObject are being dumped:
 //    For "normal" classes (that has self pointers)
 //  (DWORD(TClassDumper(ClsDmp.Classes[i]).FdwVMTPtr)=Offs+DELTA_VMT-4)
 //    For classes inherited from TObject (that dont have self pointers)
 //  (DWORD(TClassDumper(ClsDmp.Classes[i]).FdwSelfPrt)=Offs+4)
 ///////////////////////////////////////////////////////////////////////////////
 iCLASS_REF_IN_CODE_SEEK_LENGTH = $200;

 ///////////////////////////////////////////////////////////////////////////////
 // Some signs for IDA MAP export that should be displayed y SoftIce also
 ///////////////////////////////////////////////////////////////////////////////
 IDA_LOCAL_SIGN_SHIT     = '* ';
 IDA_SEPARATOR_SIGN_SHIT = '@';
 IDA_EVENT_HANDLER_START = '<-';
 IDA_CALL_TO_FUNCTION    = '->';
 IDA_MORE_DSF_REFERENCES = '<+>';

 ///////////////////////////////////////////////////////////////////////////////
 // IDA MAP file header/format lines
 ///////////////////////////////////////////////////////////////////////////////
 sIDAMAP_LINE1           = ' Start         Length     Name                   Class';
 sIDAMAP_LINE2           = ' 0001:%s %sH  CODE                   CODE';
 sIDAMAP_LINE3           = '  Address         Publics by Value';
 sIDAMAP_ENTRY_LINE      = ' 0001:%s       %s';
 sIDAMAP_PEP_LINE        = 'Program entry point at 0001:%s';

 ///////////////////////////////////////////////////////////////////////////////
 // Finally i decide to FIX all those texts and use them as standart constants
 ///////////////////////////////////////////////////////////////////////////////
 //-----------------------------------------------------------------------------
 //   This is used to build the DOI/Control references
 //-----------------------------------------------------------------------------
 sREF_TEXT_CONTROL    =   '* Reference to control';
 sREF_TEXT_METHOD     =   '* Reference to method';
 sREF_TEXT_PROPERTY   =   '* Reference to property';
 sREF_TEXT_FIELD      =   '* Reference to field';
 sREF_TEXT_DYN_METHOD =   '* Reference to dynamic method';
 //-----------------------------------------------------------------------------
 // And some possible DOI references
 //-----------------------------------------------------------------------------
 sREF_TEXT_POSSIBLE_TO    =   '* Possible reference to';
 sREF_POSSIBLE_FIELD      =   '* Possible reference to field';
 sREF_POSSIBLE_VIRT_METH  =   '* Possible reference to virtual method';
 sREF_POSSIBLE_DYN_METH   =   '* Possible reference to dynamic method';


 //-----------------------------------------------------------------------------
 //   This is used to find all kind of references and also
 // to build import function and published methods references
 //
 //  import references are      '* Reference to: '
 //  published references are   '* Reference to : '
 //-----------------------------------------------------------------------------
 sREF_TEXT_REF_TO     =   '* Reference to';
 sREF_TEXT_IMPORT     =   sREF_TEXT_REF_TO+':';
 sREF_TEXT_PUBLISHED  =   sREF_TEXT_REF_TO+' :';

 //-----------------------------------------------------------------------------
 //  This is used for the DSF references
 //-----------------------------------------------------------------------------
 sREF_TEXT_REF_DSF    =   sREF_TEXT_REF_TO+':';
 sREF_TEXT_REF_DSF_OR =   '|           or'+':';

 //-----------------------------------------------------------------------------
 //  Try-Except-Finally texts used for building references
 //-----------------------------------------------------------------------------
 sREF_TEXT_TRY        = '***** TRY';
 sREF_TEXT_EXCEPT     = '****** EXCEPT';
 sREF_TEXT_FINALLY    = '****** FINALLY';
 sREF_TEXT_END        = '****** END';

 //-----------------------------------------------------------------------------
 //  Additional chars texts used for building references
 //-----------------------------------------------------------------------------
 sREF_TEXT_REF_STRING    = '* Possible String Reference to:';
 sREF_TEXT_REF_STRING_OR = '|                               ';

 ////////////////////////////////////////////////////////////////////////////////

 ///////////////////////////////////////////////////////////////////////////////
 // Some global variables
 ///////////////////////////////////////////////////////////////////////////////
 var FsTEMPDir : String;

 type TRedusedDelphiVersion = (dvD2, dvD3, dvD4, dvD5, dvBCB3, dvBCB4,
   dvBCB5, dvD6, dvConsole, dvKylix, dvNone);


var

  ReducedDelphiVersion : TRedusedDelphiVersion;

 ///////////////////////////////////////////////////////////////////////////////
 // Used from DCU2INT parser and DCU2DSF parser
 ///////////////////////////////////////////////////////////////////////////////
 GlobPreParsOK : Boolean;
 GlobPreParseWarning : Integer;


const
 ///////////////////////////////////////////////////////////////////////////////
 // The FbClassType value for TClassDumper that represents Unit
 ///////////////////////////////////////////////////////////////////////////////
 CLASS_FLAG_UNIT = $DE;

implementation

uses Windows, DeDeUtils, DeDeRes;

// Needed to get temp path
var sz : DWORD;

initialization
  // GET THE TEMP PATH
  SetLength(FsTEMPDir,MAX_PATH);
  sz:=GetTempPath(MAX_PATH,@FsTEMPDir[1]);
  SetLength(FsTEMPDir,sz);

  GetAppVersion(ParamStr(0), GlobsCurrDeDeVersion, GlobsCurrDeDeBuild);

  txt_copyright := 'This file is generated by DeDe V'+
    GlobsCurrDeDeVersion+' Build' + GlobsCurrDeDeBuild;

end.
