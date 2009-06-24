Unit DeDe_SDK;
////////////////////////////////////////////////////////////////////////////////////////////////////
//
//                      DeDe PlugIn SDK ver 1.0
//
//  by DaFixer
//  Last Update: 20.Nov.2000
////////////////////////////////////////////////////////////////////////////////////////////////////


Interface

uses Classes;

type DWORD = LongWord;

////////////////////////////////////////////////////////////////////////////////////////////////////
// NUMBER OF DeDe PLUGIN INTERFACE PROCEDURES
////////////////////////////////////////////////////////////////////////////////////////////////////
const
   DEDE_SDK_VERSION = '1.1'; 

////////////////////////////////////////////////////////////////////////////////////////////////////
// NUMBER OF DeDe PLUGIN INTERFACE PROCEDURES
////////////////////////////////////////////////////////////////////////////////////////////////////
const
   MaxDeDeFunctions     = 9;

////////////////////////////////////////////////////////////////////////////////////////////////////
// INDEXES OF DeDe PLUGIN INTERFACE PROCEDURES
////////////////////////////////////////////////////////////////////////////////////////////////////
const
   nDisassemble         = 1;
   nGetByte             = 2;
   nGetWord             = 3;
   nGetDWORD            = 4;
   nGetPascalString     = 5;
   nGetBinaryData       = 6;
   nGetCallReference    = 7;
   nGetObjectName       = 8;
   nGetFieldReference   = 9;

////////////////////////////////////////////////////////////////////////////////////////////////////
// Array TO TRANSFER OF DeDe PLUGIN INTERFACE PROCEDURES
////////////////////////////////////////////////////////////////////////////////////////////////////
type TFunctionPointerListArray = Array [1..MaxDeDeFunctions] of Pointer;

////////////////////////////////////////////////////////////////////////////////////////////////////
// PROTOTYPES OF DeDe PLUGIN INTERFACE PROCEDURES
////////////////////////////////////////////////////////////////////////////////////////////////////
Type TGetByteProc           = function  (dwVirtOffset : DWORD) : Byte;
     TGetWordProc           = function  (dwVirtOffset : DWORD) : Word;
     TGetDWORDProc          = function  (dwVirtOffset : DWORD) : DWORD;
     TGetPascalStringProc   = function  (dwVirtOffset : DWORD) : String;
     TGetBinaryDataProc     = procedure (var buffer : Array of Byte; size : Integer; dwVirtOffset : DWORD);
     TDisassembleProc       = function  (dwVirtOffset : DWORD; var sInstr : String; var size : Integer) : Boolean;
     TGetCallReferenceProc  = function  (dwVirtOffset : DWORD; var sReference : String; var btRefType : Byte; btMode : Byte = 0) : Boolean;
     TGetObjectNameProc     = function  (dwVirtOffset : DWORD; var sObjName : String) : Boolean;
     TGetFieldReferenceProc = function  (dwVirtOffset : DWORD; var sReference : String) : Boolean;

////////////////////////////////////////////////////////////////////////////////////////////////////
// PLUGIN TYPES
////////////////////////////////////////////////////////////////////////////////////////////////////
type TPlugFlags = DWORD;

const
   ptListGen            = $00000001;
   ptEmulator           = $00000002;
   ptDisassembler       = $00000004;
   ptLoader             = $00000008;

   ptOwnerShow          = $00000010; // If this flag is set then DeDe will not show
                                     // the StringList in OutData param of StartPlugIn
                                     // The plugin should show the result by itself 

   ptFixRelativeOffsets = $00000100; // Used in Disassemble() 


////////////////////////////////////////////////////////////////////////////////////////////////////
// REFERENCES TYPES
////////////////////////////////////////////////////////////////////////////////////////////////////
Const

   REF_TYPE_DSF       = 0;// - DSF recognized procedure
                          //Normaly references looks like
                          // "System..LStrCatN()"
   REF_TYPE_PUBLISHED = 1;// - Published procedure from some unit
                          //Normaly references looks like
                          //"TfrmFormula.sbCloseClick"
   REF_TYPE_PROTECTED = 2;// - Public/Private/Protected Method recognized by DOI
                          //Normaly references looks like
                          //"TControl.GetClientOrigin"
   REF_TYPE_IDATA     = 3;// - Imported function
                          //"kernel32.GetSystemDirectoryA"

////////////////////////////////////////////////////////////////////////////////////////////////////
// REFERENCES MODES
////////////////////////////////////////////////////////////////////////////////////////////////////
const
   REF_MODE_INCLUDE_UNIT   = $00000001;
   REF_MODE_INCLUDE_PARENS = $00000002;
   REF_MODE_INCLUDE_PARAMS = $00000004;
   REF_MODE_ALL_REFS       = $00000008;


////////////////////////////////////////////////////////////////////////////////////////////////////
// StartPlugIn() input/output parameters types
////////////////////////////////////////////////////////////////////////////////////////////////////
type TListGenIN = record
       dwStartAddress : dword;
end;

type TListGenOut = record
	Listing          : TStringList;
	iGlobalVarsCount : integer;
	GlobalVars       : TStringList;
end;

////////////////////////////////////////////////////////////////////////////////////////////////////
// GetPlugInfo() record type
////////////////////////////////////////////////////////////////////////////////////////////////////
Type TPlugInfoRec = Record
        PlugName    : string[25];
        PlugVersion : string[5];
        PlugType    : TPlugFlags;
     End;


////////////////////////////////////////////////////////////////////////////////////////////////////
// PROTOTYPES OD EXPORTED PROCEDURES
////////////////////////////////////////////////////////////////////////////////////////////////////
Type TInitPlugInProc   = function  (DeDe_FunctionsList : TFunctionPointerListArray) : Boolean;
     TStartPlugInProc  = procedure (Index : Integer; InData : TListGenIN ; var OutData : TListGenOut);
     TGetPlugInfoProc  = procedure (var PlugInfo : Array of TPlugInfoRec);
     TGetPlugCountProc = function  : Integer;
     TGetPlugVerProc   = function  (Index : Integer): String;


//////////////////////////////////////////////
// EXPORT NAMES
//////////////////////////////////////////////
const GetPlugCountProc_Name  = 'GetPlugCount';
      GetPlugInfoProc_Name   = 'GetPlugInfo';
      StartPlugInProc_Name   = 'StartPlugIn';
      GetPlugVerProc_Name    = 'GetPlugVer';
      InitPlugInProc_Name    = 'InitPlugIn';

implementation

end.