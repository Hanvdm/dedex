; 该脚本使用 HM VNISEdit 脚本编辑器向导产生

; 安装程序初始定义常量
!define PRODUCT_NAME "DeDe"
!define PRODUCT_VERSION "3.12"
!define PRODUCT_BUILDVERSION "09.6.25.14"
!define PRODUCT_PUBLISHER "Sandy"
!define PRODUCT_WEB_SITE "http://www.sandy.cn"
!define PRODUCT_DIR_REGKEY "Software\Microsoft\Windows\CurrentVersion\App Paths\DeDe.exe"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"


SetCompressor lzma

; ------ MUI 现代界面定义 (1.67 版本以上兼容) ------
!include "MUI.nsh"

; MUI 预定义常量
!define MUI_ABORTWARNING
!define MUI_ICON "ico\orange-install.ico"
!define MUI_UNICON "ico\orange-uninstall.ico"
!define MUI_WELCOMEFINISHPAGE_BITMAP "ico\orange.bmp"

; 欢迎页面
!insertmacro MUI_PAGE_WELCOME
; 许可协议页面
;!define MUI_LICENSEPAGE_RADIOBUTTONS
;!insertmacro MUI_PAGE_LICENSE "${PATH_COMMONFILE}\License.txt"
; 组件选择页面
!insertmacro MUI_PAGE_COMPONENTS
; 安装目录选择页面
!insertmacro MUI_PAGE_DIRECTORY
; 安装过程页面
!insertmacro MUI_PAGE_INSTFILES
; 安装完成页面
!define MUI_FINISHPAGE_RUN "$INSTDIR\DeDe.exe"
!insertmacro MUI_PAGE_FINISH

; 安装卸载过程页面
!insertmacro MUI_UNPAGE_INSTFILES

; 安装界面包含的语言设置
!insertmacro MUI_LANGUAGE "SimpChinese"

; 安装预释放文件
!insertmacro MUI_RESERVEFILE_INSTALLOPTIONS
; ------ MUI 现代界面定义结束 ------

Name "${PRODUCT_NAME} V${PRODUCT_VERSION}"
OutFile "DeDe V${PRODUCT_VERSION} Build${PRODUCT_BUILDVERSION}.exe"
InstallDir "$PROGRAMFILES\DeDe"
InstallDirRegKey HKLM "${PRODUCT_UNINST_KEY}" "UninstallString"
ShowInstDetails show
ShowUnInstDetails show

Section "Main" SEC101
  ;永远选择
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
 *  以下是安装程序的卸载部分  *
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

#-- 根据 NSIS 脚本编辑规则，所有 Function 区段必须放置在 Section 区段之后编写，以避免安装程序出现未可预知的问题。--#

!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC101} "Main"

!insertmacro MUI_FUNCTION_DESCRIPTION_END


Function un.onInit
  MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "你确实要完全移除 $(^Name) ，及其所有的组件？" IDYES +2
  Abort
FunctionEnd

Function un.onUninstSuccess
  HideWindow
  MessageBox MB_ICONINFORMATION|MB_OK "$(^Name) 已成功地从你的计算机移除。"
FunctionEnd
