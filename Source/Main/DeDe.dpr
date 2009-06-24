{$A+,B-,C+,D+,E-,F-,G+,H+,I+,J+,K-,L+,M-,N+,O-,P+,Q-,R-,S-,T-,U-,V+,W-,X+,Y+,Z1}

{$MINSTACKSIZE $00004000}

{$MAXSTACKSIZE $00100000}

{$IMAGEBASE $00400000}

{$APPTYPE GUI}

program DeDe;

uses
  Forms,
  AboutUnit in 'AboutUnit.pas' {AboutBox},
  ConverterUnit in 'ConverterUnit.pas' {ConverterForm},
  ASMConvertUnit in 'ASMConvertUnit.pas' {ASMForm},
  DeDeDisAsm in 'DeDeDisAsm.pas',
  SectionEditUnit in 'SectionEditUnit.pas' {FlagsEditForm},
  ShowPEUnit in 'ShowPEUnit.pas' {PEIForm},
  AsmTables in 'AsmTables.pas',
  PreferencesUnit in 'PreferencesUnit.pas' {PrefsForm},
  DeDeReg in 'DeDeReg.pas',
  BPLUnit in 'BPLUnit.pas' {BPL},
  DCUUnit in 'DCUUnit.pas' {DCUForm},
  DeDeDCUDumper in 'DeDeDCUDumper.pas',
  DCUOptionUnit in 'DCUOptionUnit.pas' {DCUOptionForm},
  DeDeSym in 'DeDeSym.pas',
  DeDeBPL in 'DeDeBPL.pas',
  SymbolsUnit in 'SymbolsUnit.pas',
  LodoUnit,
  Windows,
  DeDeHidden in 'DeDeHidden.pas',
  ClassInfoUnit in 'ClassInfoUnit.pas' {ClassInfoForm},
  CRC32 in 'CRC32.PAS',
  SelProcessUnit in 'SelProcessUnit.pas' {MemDmpForm},
  DeDeMemDumps in 'DeDeMemDumps.pas',
  MainUnit in 'MainUnit.pas' {DeDeMainForm},
  EPFindUnit in 'EPFindUnit.pas' {EPFindForm},
  DeDeBSS in 'DeDeBSS.pas',
  DeDeClassEmulator in 'DeDeClassEmulator.pas',
  DeDeOffsInf in 'DeDeOffsInf.pas',
  DOIBUnit in 'DOIBUnit.pas' {DOIBForm},
  PlugInInterface in 'PlugInInterface.pas',
  custsetunit in 'custsetunit.pas' {w32CustSetForm},
  SpyDebugUnit in 'SpyDebugUnit.pas' {SpyDebugForm},
  DeDeRes in 'DeDeRes.pas',
  ASMShow in 'ASMShow.pas' {ASMShowForm},
  DOIAddDtaUnit in 'DOIAddDtaUnit.pas' {DOIAddDataForm},
  SysUtils,
  AnalizUnit in 'AnalizUnit.pas' {AnalyzForm},
  DOIParsr in 'DOIParsr.pas' {DOIParsFrm},
  DeDeConstants in 'DeDeConstants.pas',
  DeDe_SDK in 'DeDe_SDK.pas' {Unit1},
  ShowPluginUnit in 'ShowPluginUnit.pas' {ShowPlugInForm},
  StatsUnit in 'StatsUnit.pas' {StatsForm},
  asm2opcode in 'asm2opcode.pas',
  DeDeDPJEng in 'DeDeDPJEng.pas',
  DeDeEditText in 'DeDeEditText.pas' {EditTextForm},
  Emulator in 'Emulator.pas',
  DeDeELFClasses in 'DeDeELFClasses.pas',
  DeDeExpressions in 'DeDeExpressions.pas',
  EditExprUnit in 'EditExprUnit.pas',
  DeDeDUF in 'DeDeDUF.pas',
  DeDeClassHandle in 'DeDeClassHandle.pas',
  DeDePAS in 'DeDePAS.pas',
  DeDeUtils in 'DeDeUtils.pas';

{$R *.RES}


begin


  Application.Initialize;
  Application.CreateForm(TDeDeMainForm, DeDeMainForm);
  Application.CreateForm(TAboutBox, AboutBox);
  Application.CreateForm(TConverterForm, ConverterForm);
  Application.CreateForm(TASMForm, ASMForm);
  Application.CreateForm(TFlagsEditForm, FlagsEditForm);
  Application.CreateForm(TPEIForm, PEIForm);
  Application.CreateForm(TPrefsForm, PrefsForm);
  Application.CreateForm(TBPL, BPL);
  Application.CreateForm(TDCUForm, DCUForm);
  Application.CreateForm(TDCUOptionForm, DCUOptionForm);
  Application.CreateForm(TSymbolsForm, SymbolsForm);
  Application.CreateForm(TClassInfoForm, ClassInfoForm);
  Application.CreateForm(TMemDmpForm, MemDmpForm);
  Application.CreateForm(TEPFindForm, EPFindForm);
  Application.CreateForm(TDOIBForm, DOIBForm);
  Application.CreateForm(Tw32CustSetForm, w32CustSetForm);
  Application.CreateForm(TSpyDebugForm, SpyDebugForm);
  Application.CreateForm(TASMShowForm, ASMShowForm);
  Application.CreateForm(TDOIAddDataForm, DOIAddDataForm);
  Application.CreateForm(TAnalyzForm, AnalyzForm);
  Application.CreateForm(TDOIParsFrm, DOIParsFrm);
  Application.CreateForm(TShowPlugInForm, ShowPlugInForm);
  Application.CreateForm(TStatsForm, StatsForm);
  Application.CreateForm(TEditTextForm, EditTextForm);
  Application.CreateForm(TEditExprForm, EditExprForm);
  Application.Run;


end.


