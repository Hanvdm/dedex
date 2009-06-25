; �ýű�ʹ�� HM VNISEdit �ű��༭���򵼲���

; ��װ�����ʼ���峣��
!define PRODUCT_NAME "DeDe"
!define PRODUCT_VERSION "3.12"
!define PRODUCT_BUILDVERSION "09.6.25.14"
!define PRODUCT_PUBLISHER "Sandy"
!define PRODUCT_WEB_SITE "http://www.sandy.cn"
!define PRODUCT_DIR_REGKEY "Software\Microsoft\Windows\CurrentVersion\App Paths\DeDe.exe"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"


SetCompressor lzma

; ------ MUI �ִ����涨�� (1.67 �汾���ϼ���) ------
!include "MUI.nsh"

; MUI Ԥ���峣��
!define MUI_ABORTWARNING
!define MUI_ICON "ico\orange-install.ico"
!define MUI_UNICON "ico\orange-uninstall.ico"
!define MUI_WELCOMEFINISHPAGE_BITMAP "ico\orange.bmp"

; ��ӭҳ��
!insertmacro MUI_PAGE_WELCOME
; ���Э��ҳ��
;!define MUI_LICENSEPAGE_RADIOBUTTONS
;!insertmacro MUI_PAGE_LICENSE "${PATH_COMMONFILE}\License.txt"
; ���ѡ��ҳ��
!insertmacro MUI_PAGE_COMPONENTS
; ��װĿ¼ѡ��ҳ��
!insertmacro MUI_PAGE_DIRECTORY
; ��װ����ҳ��
!insertmacro MUI_PAGE_INSTFILES
; ��װ���ҳ��
!define MUI_FINISHPAGE_RUN "$INSTDIR\DeDe.exe"
!insertmacro MUI_PAGE_FINISH

; ��װж�ع���ҳ��
!insertmacro MUI_UNPAGE_INSTFILES

; ��װ�����������������
!insertmacro MUI_LANGUAGE "SimpChinese"

; ��װԤ�ͷ��ļ�
!insertmacro MUI_RESERVEFILE_INSTALLOPTIONS
; ------ MUI �ִ����涨����� ------

Name "${PRODUCT_NAME} V${PRODUCT_VERSION}"
OutFile "DeDe V${PRODUCT_VERSION} Build${PRODUCT_BUILDVERSION}.exe"
InstallDir "$PROGRAMFILES\DeDe"
InstallDirRegKey HKLM "${PRODUCT_UNINST_KEY}" "UninstallString"
ShowInstDetails show
ShowUnInstDetails show

Section "Main" SEC101
  ;��Զѡ��
  SectionIn RO
  
  SetOutPath "$INSTDIR"
  SetOverwrite on
  File "Whatsnew.txt"
  File "..\bin\dede.exe"
  File "..\bin\DFMClass11.dll"
  
  SetOutPath "$INSTDIR\LANGRES"
  File "..\bin\LANGRES\english.ini"
  File "..\bin\LANGRES\Chinese_Simplified.ini"

  CreateDirectory "$SMPROGRAMS\DeDe"
  CreateShortCut "$SMPROGRAMS\DeDe\DeDe.lnk" "$INSTDIR\DeDe.exe"
  CreateShortCut "$DESKTOP\DeDe.lnk" "$INSTDIR\DeDe.exe"
  
SectionEnd


Section -AdditionalIcons
  SetOutPath $INSTDIR
  CreateShortCut "$SMPROGRAMS\DeDe\uninst.lnk" "$INSTDIR\uninst.exe"
SectionEnd

Section -Post
  WriteUninstaller "$INSTDIR\uninst.exe"
  WriteRegStr HKLM "${PRODUCT_DIR_REGKEY}" "" "$INSTDIR\DeDe.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayName" "$(^Name)"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "UninstallString" "$INSTDIR\uninst.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayIcon" "$INSTDIR\DeDe.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "URLInfoAbout" "${PRODUCT_WEB_SITE}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"
SectionEnd

/******************************
 *  �����ǰ�װ�����ж�ز���  *
 ******************************/
Section Uninstall
  
  Delete "$INSTDIR\dede.exe"
  Delete "$INSTDIR\DFMClass11.dll"
  
  Delete "$INSTDIR\LANGRES\english.ini"
  Delete "$INSTDIR\LANGRES\Chinese_Simplified.ini"

  Delete "$DESKTOP\DeDe.lnk"
  Delete "$SMPROGRAMS\DeDe\DeDe.lnk"
  Delete "$SMPROGRAMS\DeDe\uninst.lnk"
  
  RMDir "$SMPROGRAMS\DeDe"
  RMDir "$INSTDIR\LANGRES"
  RMDir "$INSTDIR"

  DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}"
  DeleteRegKey HKLM "${PRODUCT_DIR_REGKEY}"
  SetAutoClose true
SectionEnd

#-- ���� NSIS �ű��༭�������� Function ���α�������� Section ����֮���д���Ա��ⰲװ�������δ��Ԥ֪�����⡣--#

!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC101} "Main"

!insertmacro MUI_FUNCTION_DESCRIPTION_END


Function un.onInit
  MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "��ȷʵҪ��ȫ�Ƴ� $(^Name) ���������е������" IDYES +2
  Abort
FunctionEnd

Function un.onUninstSuccess
  HideWindow
  MessageBox MB_ICONINFORMATION|MB_OK "$(^Name) �ѳɹ��ش���ļ�����Ƴ���"
FunctionEnd
