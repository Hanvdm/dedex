�
 TW32CUSTSETFORM 07  TPF0Tw32CustSetFormw32CustSetFormLeft� Top� BorderStylebsDialogCaption W32DASM Export - Custom SettingsClientHeight�ClientWidth@Color	clBtnFaceFont.CharsetDEFAULT_CHARSET
Font.ColorclWindowTextFont.Height�	Font.NameMS Sans Serif
Font.Style OldCreateOrderPositionpoScreenCenterOnCreate
FormCreate	OnDestroyFormDestroyOnShowFormShowPixelsPerInch`
TextHeight 	TGroupBoxFormsGBLeftTopWidth1Height� Caption    TabOrder  TLabelLabel1LeftTopWidth>HeightCaptionForms to skip  TLabelLabel2Left TopWidthPHeightCaptionForms to process  TListBoxSkipLBLeftTop(WidthHeight� Color��� DragModedmAutomatic
ItemHeightMultiSelect	TabOrder 
OnDragDropSkipLBDragDrop
OnDragOverSkipLBDragOverOnKeyUpSkipLBKeyUp  TListBox
SelectedLBLeft Top(WidthHeight� Color��� DragModedmAutomatic
ItemHeightMultiSelect	TabOrder
OnDragDropSelectedLBDragDrop
OnDragOverSelectedLBDragOverOnKeyUpSelectedLBKeyUp   	TGroupBoxRVAGBLeftTop� WidthHeightQCaption    TabOrder TLabelLabel3LeftTopWidth0HeightCaptionFrom RVA  TLabelLabel4Left� TopWidth&HeightCaptionTo RVA  TEditFromRVALeftTop,WidthaHeightColor��� TabOrder   TEditToRVALeft� Top,WidthaHeightColor��� TabOrder   TButtonButton1Left�TopWidthKHeightCaption&CancelTabOrderOnClickButton1Click  TButtonButton2Left�TopWidthKHeightCaption&OKTabOrderOnClickButton2Click  	TCheckBoxDSFCBLeftTop� Width� HeightCaption#Seek DSF References in the ALF fileChecked	State	cbCheckedTabOrderOnClick
DSFCBClick  	TCheckBoxFormsCBLeftTopWidthYHeightCaptionInclude FormsChecked	State	cbCheckedTabOrderOnClickFormsCBClick  	TGroupBox	GroupBox3LeftTop(Width1HeightqCaptionInformation TabOrder TLabelLabel5LeftTopWidth HeightNCaptionz        Depending on the target exe size and the ALF file size the full export of all references including additional DSF 
check may result adding of some hundred thousands lines. This operation might need lots of time. For example the 
full processing of a 3Mb exe file with corresponding 50Mb ALF file may need up to 2 or 3 hours. To make the export 
faster select only neseccary options and make sure you have at least 2x ALF file size free RAM (for 50Mb ALF file
- 100Mb RAM) and check your free disk space. Also be sure you have loaded only the DSF files you want to be 
used and ensure DeDe settings are adjusted as you like.   	TCheckBox	SaveRefCBLeft(Top� WidthHeightCaption5&Save text file with all references (your_target.ref)TabOrder  	TCheckBox
NoBackupCBLeft(Top� Width� HeightCaption'Don't back up files (to save diskspace)TabOrder   