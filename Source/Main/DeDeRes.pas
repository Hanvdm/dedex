unit DeDeRes;


interface

uses Classes, DeDeConstants, INIFiles, SysUtils, CRC32, Dialogs;

procedure LoadResourcesFromIniFile(sFileName : String);
function GetCRC32OfValueNames(sFileName : String) : LongWord;

const CURRENT_CRC32_VAL = $DF6B82D4;

var

  {MAIN MENU ITEMS}
  mm_file : String = '&File';
  mm_file_process : String = '&Process';
  mm_file_open_project : String = '&Open Project';
  mm_file_save_project : String = '&Save Project';
  mm_file_save_project_as : String = 'Save Project &As ...';
  mm_file_loadsym : String = '&Load symbol file';
  mm_file_loaddoi : String = 'Load &DOI File';
  mm_file_exit : String = 'E&xit';
  mm_dumpers : String = '&Dumpers';
  mm_dumpers_bpl : String = '&DSF builder';
  mm_dumpers_dcu : String = '&DCU dumper';
  mm_tools : String = '&Tools';
  mm_tools_peedit : String = 'PE &Editor';
  mm_tools_peheadcon : String = 'PE &Header Converter';
  mm_tools_dump_active : String = '&Dump Active Process';
  mm_tools_doibuild : String = 'DOI &Builder';
  mm_tools_rvaconv : String = '&RVA Converter';
  mm_tools_opcodeasm : String = '&Opcode to asm';
  mm_options : String = '&Options';
  mm_options_symbols : String = '&Symbols';
  mm_options_config : String = '&Configuration';
  mm_options_languages : String = '&Languages';
  mm_about : String = '&About';

  {POPUP MENU ITEMS}
  pm_svrvspu_1 : String = 'Save events RVA''s as text';
  pm_rvapu_copy_rva : String = 'Copy current RVA to clipboard';
  pm_rvapu_showadddata : String = 'Show additional data';
  pm_rvapu_disassemble : String = 'Disassemble';
  pm_DFMListPopUp_0 : String = 'Open with Notepad';
  pm_DFMListPopUp_2 : String = 'Save as TXT';
  pm_DFMListPopUp_3 : String = 'Save as DFM';
  pm_DFMListPopUp_4 : String = 'Save as RES';
  pm_DFMListPopUp_6 : String = 'Show Form';



  {TAB CONTROLS}
  tab_mpc_uts : String = 'Classes Info';
  tab_mps_fmts : String = 'Forms';
  tab_mps_dts : String = 'Procedures';
  tab_mps_fts : String = 'Project';
  tab_mps_xp : String = 'Exports';
  tab_2_ev : String = 'Events';
  tab_2_ctrl : String = 'Controls';

  {LISTVIEW CONTROLS}
  lv_ClassesLV_col0 : String = 'Class Name';
  lv_ClassesLV_col1 : String = 'Unit Name';
  lv_ClassesLV_col2 : String = 'SelfPrt';
  lv_ClassesLV_col3 : String = 'DFM Offset';
  lv_DFMList_col0 : String = 'Class Name';
  lv_DFMList_col1 : String = 'Offset';
  lv_DCULV_col0 : String = 'Unit Name';
  lv_DCULV_col1 : String = 'Class Name';
  lv_EventLV_col0 : String = 'Event';
  lv_EventLV_col1 : String = 'RVA';
  lv_EventLV_col2 : String = 'Hint';
  lv_ControlsLV_col0 : String = 'Control';
  lv_ControlsLV_col1 : String = 'ID';

  {LABELS}
  lbl_MainForm_Label2 : String = 'Save Delphi Project Space';
  lbl_MainForm_cbDFM : String = 'Include DFM files for all forms';
  lbl_MainForm_cbPAS : String = 'Include PAS files';
  lbl_MainForm_cbDPR : String = 'Include DPR project file';
  lbl_MainForm_cbTXT : String = 'Include TXT event handler RVA description';
  lbl_MainForm_Label1 : String = 'Project directory:';
  lbl_MainForm_PrcsBtn : String = 'Process';
  lbl_MainForm_ctrBtn : String = 'Create files';
  //sandy add
  lbl_MainForm_btnOpenDir: string = 'Open Directory';

  lbl_MainForm_Label3 : String = 'Export DeDe References in ...';
  lbl_MainForm_REF : String = 'W32DASM WPJ/ALF File';
  lbl_MainForm_IDAMAP : String = 'MAP/SYM File for IDA/SoftIce';
  lbl_MainForm_AllStrCB : String = 'Add non English string references';
  lbl_MainForm_AllCallsCB : String = 'Seek DSF references for *all* CALLs in ALF file (need lots of time)';
  lbl_MainForm_CustomCB : String = 'Custom settings (recommended)';
  lbl_MainForm_RVACB : String = 'Include event handlers';
  lbl_MainForm_ControlCB : String = 'Include control references';
  lbl_MainForm_Label4 : String = 'Export File:';
  lbl_MainForm_Button1 : String = 'Create Export File';
  lbl_MainForm_Label5 : String = 'Unit List (from PACKAGEINFO)';

  {LISTVIEW CONTROLS}
  lv_PLV_col0 : String = 'PID';
  lv_PLV_col1 : String = 'Name';
  lv_PLV_col2 : String = 'Image Size';
  lv_PLV_col3 : String = 'EP';
  lv_PLV_col4 : String = 'Base';

  {LABELS}
  lbl_MemDmpForm_Label1 : String = 'Processes';
  lbl_MemDmpForm_Label2 : String = 'Description:';
  lbl_MemDmpForm_ProcDescrLbl : String = '<no process selected>';
  lbl_MemDmpForm_Label3 : String = 'NOTE: DeDe will not seek for import references in a dumped processes !';
  lbl_MemDmpForm_DumpBtn : String = '&Dump';
  lbl_MemDmpForm_RVABtn : String = '&Get RVA Entry Point';
  lbl_MemDmpForm_CancelBtn : String = '&Close';
  lbl_MemDmpForm_Button1 : String = '&Refresh';

  {TAB CONTROLS}
  tab_pc_tsh1 : String = 'General';
  tab_pc_tsh2 : String = 'References';
  tab_pc_tsh3 : String = 'Symbols';
  grp_SRTypeRG : String = 'String References';

  {LABELS}
  lbl_PrefsForm_o1 : String = 'Do not allow report to be saved in existing folder';
  lbl_PrefsForm_o2 : String = 'Warn before overwriting files';
  lbl_PrefsForm_DumpALLCB : String = 'Dump additional non event handler procedures';
  lbl_PrefsForm_ObjPropCB : String = 'Dump extra data and search for obj/prop references';
  lbl_PrefsForm_Label1 : String = 'At startup load these symbol files:';
  lbl_PrefsForm_AllDSFCb : String = 'Show all found DSF references';
  lbl_SmartEmulation : String = 'Smart emulation';
  lbl_PrefsForm_okBtn : String = '&OK';
  lbl_PrefsForm_cancelBtn : String = '&Cancel';
  lbl_PrefsForm_Button3 : String = '&Add';
  lbl_PrefsForm_rmvBtn : String = '&Remove';


  {MESSAGES}
  msg_processing : String = 'Processing ';
  msg_loadingtarget : String = 'Loading Target...';
  msg_dumpingdsfdata : String = 'Dumping DFM data...';
  msg_dumpingprocs : String = 'Dumping procs...';
  msg_initpointers : String = 'Initializing pointers...';
  msg_done : String = 'Done.';
  msg_done1 : String = ' done.';
  msg_analizefile : String = 'Analizing file ...';
  msg_dumping_unit_data : String = 'Dumping units data ...';
  msg_dump_success : String = 'Dump successfull ! :)';
  msg_ready_secs : String = 'Ready %s sec.';
  msg_filesaved : String = ' saved.';
  msg_notepad_offer : String = 'Text is too large to be displayed.'#13#10' Do you want to open it with notepad ?';
  msg_novice_delphi_programmer : String = '  Published method %s does not handle any event. It is'#13#10+
                           'possible this method to be windows message handler. ';
  msg_saving_project : String = 'Saving project ...';
  msg_save_complete : String = 'Save completed!';
  msg_peedit_offer : String = 'Do you want to open in PE editor the current project ?';
  msg_thinking : String = 'Thinking ...';
  msg_loading_idata : String = 'Loading idata ...';
  msg_dsf_loaded : String = 'Symbol File %s "%s" Loaded !';
  msg_exit_dede_confirm : String = 'Exit DeDe ?';
  msg_creating_exports : String = 'Creating export ...';
  msg_file_created : String = '"%s" created!';
  msg_open_files : String = 'Opening files ...';
  msg_dis_bepatient : String = 'Disassembling ... be patient';
  msg_process_calls : String = 'Processing calls ... ';
  msg_save_alfwpj : String = 'Proceeding ... be patient';
  msg_wpjalf_ready : String = '%s'#13'%s'#13'Created!'#13#13'%d lines added';
  msg_reload_symbols_ask : String = 'Reload all symbols?';
  msg_symbols_reloaded : String = ' Symbols Reloaded!';
  msg_load_exp_names : String = 'Loading Export Names ...';
  msg_load_package : String = 'Loading Package ...';
  msg_load_exp_sym : String = 'Loading Export Symbols ...';
  msg_unload_package : String = 'Unloading Package ...';
  msg_dasm_exp : String = 'Disassembling %s Exports ...';
  msg_saveing_file : String = 'Saving File ...';
  msg_dsf_success : String = 'DSF Created Successfully.';
  msg_peh_corrsaved : String = 'PE Header corrected and file saved !';
  msg_save_succ : String = 'Save successfull !';
  msg_save_not_succ : String = 'Save not successfull !';
  msg_load_dsf_now : String = 'Do you want to load selected DSF files now ?';
  msg_load_status : String = '%d Symbol Files Loaded '#13'%d Symbol Files Loading Failed!';
  msg_load_status1 : String = '%d Symbol Files Loaded '#13;
  msg_ok_when_loaded : String = 'Press OK when target is fully loaded';

  {TEXTS}
  txt_copyright : String = 'This file is generated by DeDe';

  txt_delphi_version : String = 'Version: ';
  txt_disassemble_proc : String = 'Disassemble Procedure';
  txt_begin_rva : String = 'Enter begin RVA:';
  txt_rightclick4more : String = 'Right-click for more functions';
  txt_sect8 : String = 'Section should not be padded to next boundary.'#13;
  txt_sect20 : String = 'Section contains executable code.'#13;
  txt_sect40 : String = 'Section contains initialized data.'#13;
  txt_sect80 : String = 'Section contains uninitialized data.'#13;
  txt_sect200 : String = 'Section contains comments or ther information.'#13;
  txt_sect800 : String = 'Section will not become part of the image.'#13;
  txt_sect1000 : String = 'Section contains COMDAT data.'#13;
  txt_sect1000000 : String = 'Section contains extended relocations.'#13;
  txt_sect2000000 : String = 'Section can be discarded as needed.'#13;
  txt_sect4000000 : String = 'Section cannot be cached.'#13;
  txt_sect8000000 : String = 'Section is not pageable.'#13;
  txt_sect10000000 : String = 'Section can be shared in memory.'#13;
  txt_sect20000000 : String = 'Section can be executed as code.'#13;
  txt_sect40000000 : String = 'Section can be read.'#13;
  txt_sect80000000 : String = 'Section can be written to.'#13;
  txt_align_on_a : String = 'Align data on a ';
  txt_boundary : String = ' boundary.';
  txt_program : String = 'program';
  txt_program_sup_soon : String = 'program (will be supported soon)';
  txt_not_available : String = 'Not available';
  txt_old_version : String = 'Old Delphi version or runtime packages';
  txt_unk_ver : String = 'Unknown version';
  txt_epf_version : String = 'DeDe EP-Finder v0.2';
  txt_Remove : String = 'Remove ';
  txt_from_list : String = ' from list?';
  txt_files_from_list : String = ' files from list?';
  txt_dede_loader : String = 'DeDe Target Loader';


  {WANINGS}
  wrn_fileexists : String = 'File %s already exists. Overwrite it?';
  wrn_not_using_vcl : String = 'This application do not use VCL and no events will be assigned. Use "Show DPR" to see the code!';
  wrn_runtime_pkcg : String = ' application compiled with runtime packages found !';
  wrn_w32dasm_active : String = 'W32DASM is active! '#13'Make sure the project is not open in W32DASM. Press OK when you are ready!';
  wrn_upx : String = 'This process appears to be packed with UPX. Continue?';
  wrn_neolit : String = 'This process appears to be packed with Neolit. Continue?';
  wrn_change_file : String = 'This will change original file. Continue?';

  {ERRORS}
  err_classdump : String = 'Class Dump Engine Error! ClassName: %s  FieldTblPos: %x';
  err_classes_same_name : String = 'Two classes with the same name found - %s'#13#10+
                        'Press OK to unassign DFM resources from the class from unit %s'#13#10+
                        'or Calnel to unassign DFM resources from the class from unit %s'#13#10;
  err_specifyfilename : String = 'Specify a file name!';
  err_filenotfound : String = 'File Not Found';
  err_d2_app : String = 'This appears to be a D2 application.'#13#10+
             'DeDe can process only D3, D4 and D5 applications!';
  err_might_not_delphi_app : String = '  This not appears to be a Delphi application or CODE section might be crypted!'#13#10+
                           'This also can be Delphi application compiled with run-time packages. Continue '#13#10+
                           'analizing of this file may result DeDe to stop responding !';
  err_not_delphi_app : String = 'This is not a Delphi application or executable file might be cripted/packed !!!';
  err_cantload : String = 'Can not load %s';
  err_text_exceeds : String = 'Text exceeds memo capacity';
  err_invalid_dfm_index : String = 'Invalid DFM index';
  err_unabletogenproj : String = '  Unable to generate project space from loaded project.'#13#10+
                      'Please process the target firts !';
  err_dir_not_found : String = 'Directory "%s" Not Found';
  err_dir_not_exist : String = 'Directory "%s" Exists. Please specify different directory!';
  err_class_not_found : String = 'Class not found!';
  err_nothing_processed : String = 'There is no processed project';
  err_rva_not_in_CODE : String = 'RVA not in CODE section';
  err_nothing_to_save : String = 'No project to save';
  err_dsf_ver_not_supp : String = 'DSF Version Not Supported';
  err_dsf_ver_not_supp_1 : String = '  (DSF version not supported)';
  err_dsf_unabletoload : String = 'Unable To Load Symol File';
  err_dsf_failedtoload : String = 'Failed To Load These Symbol Files:';
  err_dsf_invalid_index : String = 'Invalid DSF index';
  err_only_one_w32dasm_export : String = 'This file has already been processed by DeDe W32DASM export!';
  err_disasm_first : String = 'Disassemble target with W32DASM first';
  err_process1st : String = 'Process a target first';
  err_symbol_loaded : String = 'Symbol Already Loaded !';
  err_cant_open_file : String = 'Can''t open "%s"';
  err_read_beyond : String = 'Read beyond the stream. Position: ';
  err_proj_header_incorrect : String = 'Project Header Incorrect or Missing';
  err_invalid_unit_flag : String = 'Invalid Unit Flag';
  err_bad_signature : String = 'This is not a PE file! Signature: ';
  err_d1_not_supported : String = 'D1 files are not supported!';
  err_no_pefile_assigned : String = 'PEFile not assigned !';
  err_import_ref : String = 'Import Ref Engine Error';
  err_dasm_err : String = 'Disassembler Engine Error';
  err_load_symfile : String = 'Error loading symbol file "';
  err_invalid_process : String = 'Invalid Process!';
  err_select_dsf_name : String = 'Select a filename for the symbol file';
  err_no_exports : String = 'this file does not contains exports';
  err_invalid_file : String = 'Invalid File: %s';
  err_not_delphi_app1 : String = 'This is not a delphi application !';
  err_failed_enum_proc : String = 'Failed to enumerate processes';
  err_epf_failed : String = 'RVA Entry Point Finder Failed ! :(';
  err_has_no_import : String = 'This File Has No Imports !';
  err_has_no_export : String = 'This File Has No Exports !';
  err_invalid_rva_interval : String = 'Invalid RVA interval entered!';
  err_unk_dcu_flag : String = 'Unknown show flag: "%s"';
  err_2nd_ast_notallow : String = '2nd "*" is not allowed';
  err_not_enuff_code : String = 'Not enough code.';
  err_invalid_operand : String = 'Invalid AddrMethod and OperandType combination';
  err_invalid_operand_size : String = 'Invalid OperandSize';


  {SHORT DESCRIPTIONS}
  dscr_o1 : String =        'Image only, Windows CE, Windows'#13+
                 'NT and above. Indicates that the'#13+
                 'file does not contain base'#13+
                 'relocations and must therefore be'#13+
                 'loaded at its preferred base'#13+
                 'address. If the base address is not'#13+
                 'available, the loader reports an'#13+
                 'error. Operating systems running on'#13+
                 'top of MS-DOS (Win32s? are'#13+
                 'generally not able to use the'#13+
                 'preferred base address and so'#13+
                 'cannot run these images. However,'#13+
                 'beginning with version 4.0,'#13+
                 'Windows will use an application’s'#13+
                 'preferred base address. The default'#13+
                 'behavior of the linker is to strip'#13+
                 'base relocations from EXEs.';
  dscr_o2 : String =        'Image only. Indicates that the'#13+
                 'image file is valid and can be run. If'#13+
                 'this flag is not set, it generally'#13+
                 'indicates a linker error.';
  dscr_o4 : String =        'COFF line numbers have been'#13+'removed.';
  dscr_o8 : String =        'COFF symbol table entries for local'#13+'symbols have been removed.';
  dscr_o10 : String =       'Aggressively trim working set.';
  dscr_o20 : String =       'App can handle > 2gb addresses.';
  dscr_o40 : String =       'Little endian: LSB precedes MSB in'#13+'memory.';
  dscr_o80 : String =       'Use of this flag is reserved for'#13+'future use.';
  dscr_o100 : String =      'Machine based on 32-bit-word'#13+'architecture.';
  dscr_o200 : String =      'Debugging information removed'#13+'from image file.';
  dscr_o400 : String =      'If image is on removable media,'#13+'copy and run from swap file.';
  dscr_o1000 : String =     'Machine based on 32-bit-word'#13+'architecture.';
  dscr_o2000 : String =     'A DLL :)';
  dscr_o4000 : String =     'File should be run only on a UP'#13+'machine.';
  dscr_o8000 : String =     'Big endian: MSB precedes LSB in'#13+'memory.';


  //////////////////////////////////////////////////////
  //  NEW RESOURCES
  /////////////////////////////////////////////////////
  msg_reset_adj_sett : String = 'Reset adjusted settings ?';
  msg_finalclassdmp : String = 'Finalizing dump ...';
  msg_loaddoi : String = 'Loading %s ...';
  msg_dumpingclasses : String = 'Prepare to dump classes ...';
  wrn_d2_app : String = 'This appears to be D2 application.'#13#10+             'Only classes having DFM data will be dumped!';
  err_can_not_create_process : String = 'Can not create process ';
  msg_load_in_sice  : String =  'Do you want to compile to .sym file and load it in SoftIce now ?';
  msg_load_in_sice_manually  : String =  'You  may compile to .sym and load manually by:';
  msg_sym_sice_info  : String =  '  SoftIce is not active or is hidden. If DeDe detects that '#13+
                      'SoftIce is active it can compile the .map file to .sym and '#13+
                      '.nsm and load it in sice. Then you will be able to see all '#13+
                      'exported DeDe references while tracing ;-)';
  msg_read_package_info  : String =  'Dump package info structure ...';
  msg_verifying_file  : String =  'Verifying ...';
  wrn_KOL_found : String = 'Application using KOL found!';


implementation

function GetCRC32OfValueNames(sFileName : String) : LongWord;
var daini : TIniFile;
    tmp : TStringList;
    i : Integer;
begin
  Result:=0;
  if not FileExists(sFileName) then exit;

  daini:=TIniFile.Create(sFileName);
  tmp:=TStringList.Create;
  try
    crc32val:=0;
    daini.ReadSection('LANGRES',tmp);
    for i:=0 to tmp.Count-1 do
      if Trim(tmp[i])<>'' then updatecrc(Trim(UpperCase(tmp[i])));
  finally
    tmp.free;
    daini.free;
  end;

  Result:=crc32val;
end;

function FormatIt(s : String) : String;
var bSpace : Boolean;
         i : Integer;
begin
  s:=Trim(s);
  bSpace:=false;
  for i:=1 to Length(s) do
  begin
    if s[i]=#32
      then if bSpace then continue
                     else bSpace:=true
      else bSpace:=false;
    Result:=Result+s[i];
  end;

  s:=Result;
  i:=Pos('#13',s);
  while i<>0 do
  begin
    s:=Copy(s,1,i-1)+#13#10+Copy(s,i+3,Length(s)-i-2);
    i:=Pos('#13',s);
  end;
  Result:=s;
end;

procedure LoadResourcesFromIniFile(sFileName : String);
var daini : TIniFile;
    CRC32 : LongWord;
    s : String;
begin
  if not FileExists(sFileName) then exit;

//  CRC32 := GetCRC32OfValueNames(sFileName);
//
//  if CRC32 <> CURRENT_CRC32_VAL then
//  begin
//    s:=IntToHex(CRC32,8);
//    //InputQuery('New CRC32','CRC',s);
//    MessageDlg('  Unable to load DeDe resources from file '+sFileName+'.'#13+
//      'The CRC of value names is not valid!',mtError,[mbOK],0);
//    Exit;
//  end;

  daini:=TIniFile.Create(sFileName);
  try
    {MAIN MENU ITEMS}
    mm_file:=FormatIt(daini.ReadString('LANGRES','mm_file',mm_file));
    mm_file_process:=FormatIt(daini.ReadString('LANGRES','mm_file_process',mm_file_process));
    mm_file_open_project:=FormatIt(daini.ReadString('LANGRES','mm_file_open_project',mm_file_open_project));
    mm_file_save_project:=FormatIt(daini.ReadString('LANGRES','mm_file_save_project',mm_file_save_project));
    mm_file_save_project_as:=FormatIt(daini.ReadString('LANGRES','mm_file_save_project_as',mm_file_save_project_as));
    mm_file_loadsym:=FormatIt(daini.ReadString('LANGRES','mm_file_loadsym',mm_file_loadsym));
    mm_file_exit:=FormatIt(daini.ReadString('LANGRES','mm_file_exit',mm_file_exit));
    mm_dumpers:=FormatIt(daini.ReadString('LANGRES','mm_dumpers',mm_dumpers));
    mm_dumpers_bpl:=FormatIt(daini.ReadString('LANGRES','mm_dumpers_bpl',mm_dumpers_bpl));
    mm_dumpers_dcu:=FormatIt(daini.ReadString('LANGRES','mm_dumpers_dcu',mm_dumpers_dcu));
    mm_tools:=FormatIt(daini.ReadString('LANGRES','mm_tools',mm_tools));
    mm_tools_peedit:=FormatIt(daini.ReadString('LANGRES','mm_tools_peedit',mm_tools_peedit));
    mm_tools_peheadcon:=FormatIt(daini.ReadString('LANGRES','mm_tools_peheadcon',mm_tools_peheadcon));
    mm_tools_dump_active:=FormatIt(daini.ReadString('LANGRES','mm_tools_dump_active',mm_tools_dump_active));
    mm_tools_doibuild:=FormatIt(daini.ReadString('LANGRES','mm_tools_doibuild',mm_tools_doibuild));
    mm_tools_rvaconv:=FormatIt(daini.ReadString('LANGRES','mm_tools_rvaconv',mm_tools_rvaconv));
    mm_tools_opcodeasm:=FormatIt(daini.ReadString('LANGRES','mm_tools_opcodeasm',mm_tools_opcodeasm));
    mm_options:=FormatIt(daini.ReadString('LANGRES','mm_options',mm_options));
    mm_options_symbols:=FormatIt(daini.ReadString('LANGRES','mm_options_symbols',mm_options_symbols));
    mm_options_config:=FormatIt(daini.ReadString('LANGRES','mm_options_config',mm_options_config));
    mm_about:=FormatIt(daini.ReadString('LANGRES','mm_about',mm_about));

    {POPUP MENU ITEMS}
    pm_svrvspu_1:=FormatIt(daini.ReadString('LANGRES','pm_svrvspu_1',pm_svrvspu_1));
    pm_rvapu_copy_rva:=FormatIt(daini.ReadString('LANGRES','pm_rvapu_copy_rva',pm_rvapu_copy_rva));
    pm_rvapu_showadddata:=FormatIt(daini.ReadString('LANGRES','pm_rvapu_showadddata',pm_rvapu_showadddata));
    pm_rvapu_disassemble:=FormatIt(daini.ReadString('LANGRES','pm_rvapu_disassemble',pm_rvapu_disassemble));
    pm_DFMListPopUp_0:=FormatIt(daini.ReadString('LANGRES','pm_DFMListPopUp_0',pm_DFMListPopUp_0));
    pm_DFMListPopUp_2:=FormatIt(daini.ReadString('LANGRES','pm_DFMListPopUp_2',pm_DFMListPopUp_2));
    pm_DFMListPopUp_3:=FormatIt(daini.ReadString('LANGRES','pm_DFMListPopUp_3',pm_DFMListPopUp_3));
    pm_DFMListPopUp_4:=FormatIt(daini.ReadString('LANGRES','pm_DFMListPopUp_4',pm_DFMListPopUp_4));

    {TAB CONTROLS}
    tab_mpc_uts:=FormatIt(daini.ReadString('LANGRES','tab_mpc_uts',tab_mpc_uts));
    tab_mps_fmts:=FormatIt(daini.ReadString('LANGRES','tab_mps_fmts',tab_mps_fmts));
    tab_mps_dts:=FormatIt(daini.ReadString('LANGRES','tab_mps_dts',tab_mps_dts));
    tab_mps_fts:=FormatIt(daini.ReadString('LANGRES','tab_mps_fts',tab_mps_fts));
    tab_mps_xp:=FormatIt(daini.ReadString('LANGRES','tab_mps_xp',tab_mps_xp));
    tab_2_ev:=FormatIt(daini.ReadString('LANGRES','tab_2_ev',tab_2_ev));
    tab_2_ctrl:=FormatIt(daini.ReadString('LANGRES','tab_2_ctrl',tab_2_ctrl));

    {LISTVIEW CONTROLS}
    lv_ClassesLV_col0:=FormatIt(daini.ReadString('LANGRES','lv_ClassesLV_col0',lv_ClassesLV_col0));
    lv_ClassesLV_col1:=FormatIt(daini.ReadString('LANGRES','lv_ClassesLV_col1',lv_ClassesLV_col1));
    lv_ClassesLV_col2:=FormatIt(daini.ReadString('LANGRES','lv_ClassesLV_col2',lv_ClassesLV_col2));
    lv_ClassesLV_col3:=FormatIt(daini.ReadString('LANGRES','lv_ClassesLV_col3',lv_ClassesLV_col3));
    lv_DFMList_col0:=FormatIt(daini.ReadString('LANGRES','lv_DFMList_col0',lv_DFMList_col0));
    lv_DFMList_col1:=FormatIt(daini.ReadString('LANGRES','lv_DFMList_col1',lv_DFMList_col1));
    lv_DCULV_col0:=FormatIt(daini.ReadString('LANGRES','lv_DCULV_col0',lv_DCULV_col0));
    lv_DCULV_col1:=FormatIt(daini.ReadString('LANGRES','lv_DCULV_col1',lv_DCULV_col1));
    lv_EventLV_col0:=FormatIt(daini.ReadString('LANGRES','lv_EventLV_col0',''));
    lv_EventLV_col1:=FormatIt(daini.ReadString('LANGRES','lv_EventLV_col1',''));
    lv_EventLV_col2:=FormatIt(daini.ReadString('LANGRES','lv_EventLV_col2',''));
    lv_ControlsLV_col0:=FormatIt(daini.ReadString('LANGRES','lv_ControlsLV_col0',''));
    lv_ControlsLV_col1:=FormatIt(daini.ReadString('LANGRES','lv_ControlsLV_col1',''));

    {LABELS}
    lbl_MainForm_Label2:=FormatIt(daini.ReadString('LANGRES','lbl_MainForm_Label2',''));
    lbl_MainForm_cbDFM:=FormatIt(daini.ReadString('LANGRES','lbl_MainForm_cbDFM',''));
    lbl_MainForm_cbPAS:=FormatIt(daini.ReadString('LANGRES','lbl_MainForm_cbPAS',''));
    lbl_MainForm_cbDPR:=FormatIt(daini.ReadString('LANGRES','lbl_MainForm_cbDPR',''));
    lbl_MainForm_cbTXT:=FormatIt(daini.ReadString('LANGRES','lbl_MainForm_cbTXT',''));
    lbl_MainForm_Label1:=FormatIt(daini.ReadString('LANGRES','lbl_MainForm_Label1',''));
    lbl_MainForm_PrcsBtn:=FormatIt(daini.ReadString('LANGRES','lbl_MainForm_PrcsBtn',''));
    lbl_MainForm_ctrBtn:=FormatIt(daini.ReadString('LANGRES','lbl_MainForm_ctrBtn',''));
    //sandy
    lbl_MainForm_btnOpenDir:=FormatIt(daini.ReadString('LANGRES','lbl_MainForm_BtnOpenDir',''));


    lbl_MainForm_Label3:=FormatIt(daini.ReadString('LANGRES','lbl_MainForm_Label3',''));
    lbl_MainForm_REF:=FormatIt(daini.ReadString('LANGRES','lbl_MainForm_REF',''));
    lbl_MainForm_IDAMAP:=FormatIt(daini.ReadString('LANGRES','lbl_MainForm_IDAMAP',''));
    lbl_MainForm_AllStrCB:=FormatIt(daini.ReadString('LANGRES','lbl_MainForm_AllStrCB',''));
    lbl_MainForm_AllCallsCB:=FormatIt(daini.ReadString('LANGRES','lbl_MainForm_AllCallsCB',''));
    lbl_MainForm_CustomCB:=FormatIt(daini.ReadString('LANGRES','lbl_MainForm_CustomCB',''));
    lbl_MainForm_RVACB:=FormatIt(daini.ReadString('LANGRES','lbl_MainForm_RVACB',''));
    lbl_MainForm_ControlCB:=FormatIt(daini.ReadString('LANGRES','lbl_MainForm_ControlCB',''));
    lbl_MainForm_Label4:=FormatIt(daini.ReadString('LANGRES','lbl_MainForm_Label4',''));
    lbl_MainForm_Button1:=FormatIt(daini.ReadString('LANGRES','lbl_MainForm_Button1',''));
    lbl_MainForm_Label5:=FormatIt(daini.ReadString('LANGRES','lbl_MainForm_Label5',''));

    {LISTVIEW CONTROLS}
    lv_PLV_col0:=FormatIt(daini.ReadString('LANGRES','lv_PLV_col0',''));
    lv_PLV_col1:=FormatIt(daini.ReadString('LANGRES','lv_PLV_col1',''));
    lv_PLV_col2:=FormatIt(daini.ReadString('LANGRES','lv_PLV_col2',''));
    lv_PLV_col3:=FormatIt(daini.ReadString('LANGRES','lv_PLV_col3',''));
    lv_PLV_col4:=FormatIt(daini.ReadString('LANGRES','lv_PLV_col4',''));

    {LABELS}
    lbl_MemDmpForm_Label1:=FormatIt(daini.ReadString('LANGRES','lbl_MemDmpForm_Label1',''));
    lbl_MemDmpForm_Label2:=FormatIt(daini.ReadString('LANGRES','lbl_MemDmpForm_Label2',''));
    lbl_MemDmpForm_ProcDescrLbl:=FormatIt(daini.ReadString('LANGRES','lbl_MemDmpForm_ProcDescrLbl',''));
    lbl_MemDmpForm_Label3:=FormatIt(daini.ReadString('LANGRES','lbl_MemDmpForm_Label3',''));
    lbl_MemDmpForm_DumpBtn:=FormatIt(daini.ReadString('LANGRES','lbl_MemDmpForm_DumpBtn',''));
    lbl_MemDmpForm_RVABtn:=FormatIt(daini.ReadString('LANGRES','lbl_MemDmpForm_RVABtn',''));
    lbl_MemDmpForm_CancelBtn:=FormatIt(daini.ReadString('LANGRES','lbl_MemDmpForm_CancelBtn',''));
    lbl_MemDmpForm_Button1:=FormatIt(daini.ReadString('LANGRES','lbl_MemDmpForm_Button1',''));

    {TAB CONTROLS}
    tab_pc_tsh1:=FormatIt(daini.ReadString('LANGRES','tab_pc_tsh1',''));
    tab_pc_tsh2:=FormatIt(daini.ReadString('LANGRES','tab_pc_tsh2',''));
    tab_pc_tsh3:=FormatIt(daini.ReadString('LANGRES','tab_pc_tsh3',''));
    grp_SRTypeRG:=FormatIt(daini.ReadString('LANGRES','grp_SRTypeRG',''));

    {LABELS}
    lbl_PrefsForm_o1:=FormatIt(daini.ReadString('LANGRES','lbl_PrefsForm_o1',''));
    lbl_PrefsForm_o2:=FormatIt(daini.ReadString('LANGRES','lbl_PrefsForm_o2',''));
    lbl_PrefsForm_DumpALLCB:=FormatIt(daini.ReadString('LANGRES','lbl_PrefsForm_DumpALLCB',''));
    lbl_PrefsForm_ObjPropCB:=FormatIt(daini.ReadString('LANGRES','lbl_PrefsForm_ObjPropCB',''));
    lbl_PrefsForm_Label1:=FormatIt(daini.ReadString('LANGRES','lbl_PrefsForm_Label1',''));
    lbl_PrefsForm_AllDSFCb:=FormatIt(daini.ReadString('LANGRES','lbl_PrefsForm_AllDSFCb',''));
    lbl_SmartEmulation:=FormatIt(daini.ReadString('LANGRES','lbl_SmartEmulation',''));
    lbl_PrefsForm_okBtn:=FormatIt(daini.ReadString('LANGRES','lbl_PrefsForm_okBtn',''));
    lbl_PrefsForm_cancelBtn:=FormatIt(daini.ReadString('LANGRES','lbl_PrefsForm_cancelBtn',''));
    lbl_PrefsForm_Button3:=FormatIt(daini.ReadString('LANGRES','lbl_PrefsForm_Button3',''));
    lbl_PrefsForm_rmvBtn:=FormatIt(daini.ReadString('LANGRES','lbl_PrefsForm_rmvBtn',''));

    {MESSAGES}
    msg_processing:=FormatIt(daini.ReadString('LANGRES','msg_processing',''));
    msg_loadingtarget:=FormatIt(daini.ReadString('LANGRES','msg_loadingtarget',''));
    msg_dumpingdsfdata:=FormatIt(daini.ReadString('LANGRES','msg_dumpingdsfdata',''));
    msg_dumpingprocs:=FormatIt(daini.ReadString('LANGRES','msg_dumpingprocs',''));
    msg_initpointers:=FormatIt(daini.ReadString('LANGRES','msg_initpointers',''));
    msg_done:=FormatIt(daini.ReadString('LANGRES','msg_done',''));
    msg_done1:=FormatIt(daini.ReadString('LANGRES','msg_done1',''));
    msg_analizefile:=FormatIt(daini.ReadString('LANGRES','msg_analizefile',''));
    msg_dumping_unit_data:=FormatIt(daini.ReadString('LANGRES','msg_dumping_unit_data',''));
    msg_dump_success:=FormatIt(daini.ReadString('LANGRES','msg_dump_success',''));
    msg_ready_secs:=FormatIt(daini.ReadString('LANGRES','msg_ready_secs',''));
    msg_filesaved:=FormatIt(daini.ReadString('LANGRES','msg_filesaved',''));
    msg_notepad_offer:=FormatIt(daini.ReadString('LANGRES','msg_notepad_offer',''));
    msg_novice_delphi_programmer:=FormatIt(daini.ReadString('LANGRES','msg_novice_delphi_programmer',''));
    msg_saving_project:=FormatIt(daini.ReadString('LANGRES','msg_saving_project',''));
    msg_save_complete:=FormatIt(daini.ReadString('LANGRES','msg_save_complete',''));
    msg_peedit_offer:=FormatIt(daini.ReadString('LANGRES','msg_peedit_offer',''));
    msg_thinking:=FormatIt(daini.ReadString('LANGRES','msg_thinking',''));
    msg_loading_idata:=FormatIt(daini.ReadString('LANGRES','msg_loading_idata',''));
    msg_dsf_loaded:=FormatIt(daini.ReadString('LANGRES','msg_dsf_loaded',''));
    msg_exit_dede_confirm:=FormatIt(daini.ReadString('LANGRES','msg_exit_dede_confirm',''));
    msg_creating_exports:=FormatIt(daini.ReadString('LANGRES','msg_creating_exports',''));
    msg_file_created:=FormatIt(daini.ReadString('LANGRES','msg_file_created',''));
    msg_open_files:=FormatIt(daini.ReadString('LANGRES','msg_open_files',''));
    msg_dis_bepatient:=FormatIt(daini.ReadString('LANGRES','msg_dis_bepatient',''));
    msg_process_calls:=FormatIt(daini.ReadString('LANGRES','msg_process_calls',''));
    msg_save_alfwpj:=FormatIt(daini.ReadString('LANGRES','msg_save_alfwpj',''));
    msg_wpjalf_ready:=FormatIt(daini.ReadString('LANGRES','msg_wpjalf_ready',''));
    msg_reload_symbols_ask:=FormatIt(daini.ReadString('LANGRES','msg_reload_symbols_ask',''));
    msg_symbols_reloaded:=FormatIt(daini.ReadString('LANGRES','msg_symbols_reloaded',''));
    msg_load_exp_names:=FormatIt(daini.ReadString('LANGRES','msg_load_exp_names',''));
    msg_load_package:=FormatIt(daini.ReadString('LANGRES','msg_load_package',''));
    msg_load_exp_sym:=FormatIt(daini.ReadString('LANGRES','msg_load_exp_sym',''));
    msg_unload_package:=FormatIt(daini.ReadString('LANGRES','msg_unload_package',''));
    msg_dasm_exp:=FormatIt(daini.ReadString('LANGRES','msg_dasm_exp',''));
    msg_saveing_file:=FormatIt(daini.ReadString('LANGRES','msg_saveing_file',''));
    msg_dsf_success:=FormatIt(daini.ReadString('LANGRES','msg_dsf_success',''));
    msg_peh_corrsaved:=FormatIt(daini.ReadString('LANGRES','msg_peh_corrsaved',''));
    msg_save_succ:=FormatIt(daini.ReadString('LANGRES','msg_save_succ',''));
    msg_save_not_succ:=FormatIt(daini.ReadString('LANGRES','msg_save_not_succ',''));
    msg_load_dsf_now:=FormatIt(daini.ReadString('LANGRES','msg_load_dsf_now',''));
    msg_load_status:=FormatIt(daini.ReadString('LANGRES','msg_load_status',''));
    msg_load_status1:=FormatIt(daini.ReadString('LANGRES','msg_load_status1',''));
    msg_ok_when_loaded:=FormatIt(daini.ReadString('LANGRES','msg_ok_when_loaded',''));

    {TEXTS}
    txt_copyright:=Format(FormatIt(daini.ReadString('LANGRES','txt_copyright','')),[GlobsCurrDeDeVersion]);
    txt_delphi_version:=FormatIt(daini.ReadString('LANGRES','txt_delphi_version',''));
    txt_disassemble_proc:=FormatIt(daini.ReadString('LANGRES','txt_disassemble_proc',''));
    txt_begin_rva:=FormatIt(daini.ReadString('LANGRES','txt_begin_rva',''));
    txt_rightclick4more:=FormatIt(daini.ReadString('LANGRES','txt_rightclick4more',''));
    txt_sect8:=FormatIt(daini.ReadString('LANGRES','txt_sect8',''));
    txt_sect20:=FormatIt(daini.ReadString('LANGRES','txt_sect20',''));
    txt_sect40:=FormatIt(daini.ReadString('LANGRES','txt_sect40',''));
    txt_sect80:=FormatIt(daini.ReadString('LANGRES','txt_sect80',''));
    txt_sect200:=FormatIt(daini.ReadString('LANGRES','txt_sect200',''));
    txt_sect800:=FormatIt(daini.ReadString('LANGRES','txt_sect800',''));
    txt_sect1000:=FormatIt(daini.ReadString('LANGRES','txt_sect1000',''));
    txt_sect1000000:=FormatIt(daini.ReadString('LANGRES','txt_sect1000000',''));
    txt_sect2000000:=FormatIt(daini.ReadString('LANGRES','txt_sect2000000',''));
    txt_sect4000000:=FormatIt(daini.ReadString('LANGRES','txt_sect4000000',''));
    txt_sect8000000:=FormatIt(daini.ReadString('LANGRES','txt_sect8000000',''));
    txt_sect10000000:=FormatIt(daini.ReadString('LANGRES','txt_sect10000000',''));
    txt_sect20000000:=FormatIt(daini.ReadString('LANGRES','txt_sect20000000',''));
    txt_sect40000000:=FormatIt(daini.ReadString('LANGRES','txt_sect40000000',''));
    txt_sect80000000:=FormatIt(daini.ReadString('LANGRES','txt_sect80000000',''));
    txt_align_on_a:=FormatIt(daini.ReadString('LANGRES','txt_align_on_a',''));
    txt_boundary:=FormatIt(daini.ReadString('LANGRES','txt_boundary',''));
    txt_program:=FormatIt(daini.ReadString('LANGRES','txt_program',''));
    txt_program_sup_soon:=FormatIt(daini.ReadString('LANGRES','txt_program_sup_soon',''));
    txt_not_available:=FormatIt(daini.ReadString('LANGRES','txt_not_available',''));
    txt_old_version:=FormatIt(daini.ReadString('LANGRES','txt_old_version',''));
    txt_unk_ver:=FormatIt(daini.ReadString('LANGRES','txt_unk_ver',''));
    txt_epf_version:=FormatIt(daini.ReadString('LANGRES','txt_epf_version',''));
    txt_Remove:=FormatIt(daini.ReadString('LANGRES','txt_Remove',''));
    txt_from_list:=FormatIt(daini.ReadString('LANGRES','txt_from_list',''));
    txt_files_from_list:=FormatIt(daini.ReadString('LANGRES','txt_files_from_list',''));
    txt_dede_loader:=FormatIt(daini.ReadString('LANGRES','txt_dede_loader',''));

    {WANINGS}
    wrn_fileexists:=FormatIt(daini.ReadString('LANGRES','wrn_fileexists',''));
    wrn_not_using_vcl:=FormatIt(daini.ReadString('LANGRES','wrn_not_using_vcl',''));
    wrn_runtime_pkcg:=FormatIt(daini.ReadString('LANGRES','wrn_runtime_pkcg',''));
    wrn_w32dasm_active:=FormatIt(daini.ReadString('LANGRES','wrn_w32dasm_active',''));
    wrn_upx:=FormatIt(daini.ReadString('LANGRES','wrn_upx',''));
    wrn_neolit:=FormatIt(daini.ReadString('LANGRES','wrn_neolit',''));
    wrn_change_file:=FormatIt(daini.ReadString('LANGRES','wrn_change_file',''));

    {ERRORS}
    err_classdump:=FormatIt(daini.ReadString('LANGRES','err_classdump',''));
    err_classes_same_name:=FormatIt(daini.ReadString('LANGRES','err_classes_same_name',''));
    err_specifyfilename:=FormatIt(daini.ReadString('LANGRES','err_specifyfilename',''));
    err_filenotfound:=FormatIt(daini.ReadString('LANGRES','err_filenotfound',''));
    err_d2_app:=FormatIt(daini.ReadString('LANGRES','err_d2_app',''));
    err_might_not_delphi_app:=FormatIt(daini.ReadString('LANGRES','err_might_not_delphi_app',''));
    err_not_delphi_app:=FormatIt(daini.ReadString('LANGRES','err_not_delphi_app',''));
    err_cantload:=FormatIt(daini.ReadString('LANGRES','err_cantload',''));
    err_text_exceeds:=FormatIt(daini.ReadString('LANGRES','err_text_exceeds',''));
    err_invalid_dfm_index:=FormatIt(daini.ReadString('LANGRES','err_invalid_dfm_index',''));
    err_unabletogenproj:=FormatIt(daini.ReadString('LANGRES','err_unabletogenproj',''));
    err_dir_not_found:=FormatIt(daini.ReadString('LANGRES','err_dir_not_found',''));
    err_dir_not_exist:=FormatIt(daini.ReadString('LANGRES','err_dir_not_exist',''));
    err_class_not_found:=FormatIt(daini.ReadString('LANGRES','err_class_not_found',''));
    err_nothing_processed:=FormatIt(daini.ReadString('LANGRES','err_nothing_processed',''));
    err_rva_not_in_CODE:=FormatIt(daini.ReadString('LANGRES','err_rva_not_in_CODE',''));
    err_nothing_to_save:=FormatIt(daini.ReadString('LANGRES','err_nothing_to_save',''));
    err_dsf_ver_not_supp:=FormatIt(daini.ReadString('LANGRES','err_dsf_ver_not_supp',''));
    err_dsf_ver_not_supp_1:=FormatIt(daini.ReadString('LANGRES','err_dsf_ver_not_supp_1',''));
    err_dsf_unabletoload:=FormatIt(daini.ReadString('LANGRES','err_dsf_unabletoload',''));
    err_dsf_failedtoload:=FormatIt(daini.ReadString('LANGRES','err_dsf_failedtoload',''));
    err_dsf_invalid_index:=FormatIt(daini.ReadString('LANGRES','err_dsf_invalid_index',''));
    err_only_one_w32dasm_export:=FormatIt(daini.ReadString('LANGRES','err_only_one_w32dasm_export',''));
    err_disasm_first:=FormatIt(daini.ReadString('LANGRES','err_disasm_first',''));
    err_process1st:=FormatIt(daini.ReadString('LANGRES','err_process1st',''));
    err_symbol_loaded:=FormatIt(daini.ReadString('LANGRES','err_symbol_loaded',''));
    err_cant_open_file:=FormatIt(daini.ReadString('LANGRES','err_cant_open_file',''));
    err_read_beyond:=FormatIt(daini.ReadString('LANGRES','err_read_beyond',''));
    err_proj_header_incorrect:=FormatIt(daini.ReadString('LANGRES','err_proj_header_incorrect',''));
    err_invalid_unit_flag:=FormatIt(daini.ReadString('LANGRES','err_invalid_unit_flag',''));
    err_bad_signature:=FormatIt(daini.ReadString('LANGRES','err_bad_signature',''));
    err_d1_not_supported:=FormatIt(daini.ReadString('LANGRES','err_d1_not_supported',''));
    err_no_pefile_assigned:=FormatIt(daini.ReadString('LANGRES','err_no_pefile_assigned',''));
    err_import_ref:=FormatIt(daini.ReadString('LANGRES','err_import_ref',''));
    err_dasm_err:=FormatIt(daini.ReadString('LANGRES','err_dasm_err',''));
    err_load_symfile:=FormatIt(daini.ReadString('LANGRES','err_load_symfile',''));
    err_invalid_process:=FormatIt(daini.ReadString('LANGRES','err_invalid_process',''));
    err_select_dsf_name:=FormatIt(daini.ReadString('LANGRES','err_select_dsf_name',''));
    err_no_exports:=FormatIt(daini.ReadString('LANGRES','err_no_exports',''));
    err_invalid_file:=FormatIt(daini.ReadString('LANGRES','err_invalid_file',''));
    err_not_delphi_app1:=FormatIt(daini.ReadString('LANGRES','err_not_delphi_app1',''));
    err_failed_enum_proc:=FormatIt(daini.ReadString('LANGRES','err_failed_enum_proc',''));
    err_epf_failed:=FormatIt(daini.ReadString('LANGRES','err_epf_failed',''));
    err_has_no_import:=FormatIt(daini.ReadString('LANGRES','err_has_no_import',''));
    err_has_no_export:=FormatIt(daini.ReadString('LANGRES','err_has_no_export',''));
    err_invalid_rva_interval:=FormatIt(daini.ReadString('LANGRES','err_invalid_rva_interval',''));
    err_unk_dcu_flag:=FormatIt(daini.ReadString('LANGRES','err_unk_dcu_flag',''));
    err_2nd_ast_notallow:=FormatIt(daini.ReadString('LANGRES','err_2nd_ast_notallow',''));
    err_not_enuff_code:=FormatIt(daini.ReadString('LANGRES','err_not_enuff_code',''));
    err_invalid_operand:=FormatIt(daini.ReadString('LANGRES','err_invalid_operand',''));
    err_invalid_operand_size:=FormatIt(daini.ReadString('LANGRES','err_invalid_operand_size',''));

    {SHORT DESCRIPTIONS}
    dscr_o1:=FormatIt(daini.ReadString('LANGRES','dscr_o1',''));
    dscr_o2:=FormatIt(daini.ReadString('LANGRES','dscr_o2',''));
    dscr_o4:=FormatIt(daini.ReadString('LANGRES','dscr_o4',''));
    dscr_o8:=FormatIt(daini.ReadString('LANGRES','dscr_o8',''));
    dscr_o10:=FormatIt(daini.ReadString('LANGRES','dscr_o10',''));
    dscr_o20:=FormatIt(daini.ReadString('LANGRES','dscr_o20',''));
    dscr_o40:=FormatIt(daini.ReadString('LANGRES','dscr_o40',''));
    dscr_o80:=FormatIt(daini.ReadString('LANGRES','dscr_o80',''));
    dscr_o100:=FormatIt(daini.ReadString('LANGRES','dscr_o100',''));
    dscr_o200:=FormatIt(daini.ReadString('LANGRES','dscr_o200',''));
    dscr_o400:=FormatIt(daini.ReadString('LANGRES','dscr_o400',''));
    dscr_o1000:=FormatIt(daini.ReadString('LANGRES','dscr_o1000',''));
    dscr_o2000:=FormatIt(daini.ReadString('LANGRES','dscr_o2000',''));
    dscr_o4000:=FormatIt(daini.ReadString('LANGRES','dscr_o4000',''));
    dscr_o8000:=FormatIt(daini.ReadString('LANGRES','dscr_o8000',''));

    //////////////////////////////////////////////////////
    //  NEW RESOURCES
    /////////////////////////////////////////////////////
    msg_reset_adj_sett:=FormatIt(daini.ReadString('LANGRES','msg_reset_adj_sett',''));
    msg_finalclassdmp:=FormatIt(daini.ReadString('LANGRES','msg_finalclassdmp',''));
    msg_loaddoi:=FormatIt(daini.ReadString('LANGRES','msg_loaddoi',''));
    msg_dumpingclasses:=FormatIt(daini.ReadString('LANGRES','msg_dumpingclasses',''));
    wrn_d2_app:=FormatIt(daini.ReadString('LANGRES','wrn_d2_app',''));
    err_can_not_create_process:=FormatIt(daini.ReadString('LANGRES','err_can_not_create_process',''));
    msg_load_in_sice :=FormatIt(daini.ReadString('LANGRES','msg_load_in_sice ',''));
    msg_load_in_sice_manually :=FormatIt(daini.ReadString('LANGRES','msg_load_in_sice_manually ',''));
    msg_read_package_info :=FormatIt(daini.ReadString('LANGRES','msg_read_package_info ',''));
    msg_verifying_file :=FormatIt(daini.ReadString('LANGRES','msg_verifying_file ',''));
    wrn_KOL_found:=FormatIt(daini.ReadString('LANGRES','wrn_KOL_found',''));

  finally

    daini.free;
  end;

end;

end.
