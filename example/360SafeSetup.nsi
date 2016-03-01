; 选择压缩方式
;SetCompressor /SOLID LZMA

; 引入的头文件
!include "nsDialogs.nsh"
!include "FileFunc.nsh"
!include  MUI.nsh
!include  LogicLib.nsh
!include  WinMessages.nsh
!include "MUI2.nsh"
!include "WordFunc.nsh"
!include "Library.nsh"
!include "basehelp.nsh"
!include "format.nsh"
!include "nsduilib.nsh"
!include "algo.nsh"
!include "valid.nsh"

!addplugindir "plugin"

!define  AD_URL "https://github.com/jeppeter/nsduilib"
; 引入的dll
#ReserveFile "${NSISDIR}\Plugins\system.dll"
#ReserveFile "${NSISDIR}\Plugins\nsDialogs.dll"
#ReserveFile "${NSISDIR}\Plugins\nsExec.dll"
#ReserveFile "${NSISDIR}\Plugins\InstallOptions.dll"
#

; 名称宏定义
!define PRODUCT_NAME              "360Safe"
!define PRODUCT_VERSION           "1.0.0.1"
!define PRODUCT_NAME_EN           "360Safe"
!define PRODUCT_ROOT_KEY          "HKLM"
!define PRODUCT_SUB_KEY           "SOFTWARE\360\360Safe"
!define PRODUCT_MAIN_EXE          "360Safe_ud.exe"
!define PRODUCT_MAIN_EXE_MUTEX    "{3D3CB097-93A1-440a-954F-6D253C50CE32}"
!define SETUP_MUTEX_NAME          "{50A3E52E-6F7F-4411-9791-63BD15BBF2C2}"
!define MUI_ICON                  ".\setup res\install.ico"    ; 安装icon
!define MUI_UNICON                ".\setup res\uninstall.ico"  ; 卸载icon

!define PORT_EDIT                 "portedit"
!define SVC_EDIT                  "svcedit"

!macro MutexCheck _mutexname _outvar _handle
System::Call 'kernel32::CreateMutexA(i 0, i 0, t "${_mutexname}" ) i.r1 ?e'
StrCpy ${_handle} $1
Pop ${_outvar}
!macroend 


Var Dialog
Var MessageBoxHandle
Var DesktopIconState
Var FastIconState
Var FreeSpaceSize
Var installPath
Var timerID
Var timerID4Uninstall
Var changebkimageIndex
Var changebkimage4UninstallIndex
Var RunNow
Var InstallState
Var LocalPath
Var 360Safetemp
Var gPort
Var gSvcName

Name      "${PRODUCT_NAME}"              ; 提示对话框的标题
OutFile   "${PRODUCT_NAME_EN}Setup.exe"  ; 输出的安装包名

InstallDir "$PROGRAMFILES\360\${PRODUCT_NAME_EN}"                   ;Default installation folder
InstallDirRegKey ${PRODUCT_ROOT_KEY} ${PRODUCT_SUB_KEY} "installDir"   ;Get installation folder from registry if available

;Request application privileges for Windows Vista
RequestExecutionLevel admin
;Languages 
!insertmacro MUI_LANGUAGE "English"

;--------------------------------------------------------------------------------------------------------------------------------------------------------------

;Installer Sections

Section "Dummy Section" SecDummy
 
  ;复制要发布的安装文件  
  SetOutPath "$INSTDIR"
  SetOverWrite on
  File /r /x .svn   ".\360Safe\*.*"
  SetOverWrite on
  SetRebootFlag false
  
  WriteUninstaller "$INSTDIR\Uninstall.exe"   ;Create uninstaller
  Call BuildShortCut

SectionEnd
 
;--------------------------------------------------------------------------------------------------------------------------------------------------------------

;Uninstaller Section

Section "Uninstall"
  ;执行uninstall.exe
  Delete "$SMSTARTUP\${PRODUCT_NAME}.lnk"
  Delete "$DESKTOP\${PRODUCT_NAME}.lnk"
  Delete "$QUICKLAUNCH\${PRODUCT_NAME}.lnk"

  SetShellVarContext all
  RMDir /r /REBOOTOK "$SMPROGRAMS\${PRODUCT_NAME}"
  
  SetShellVarContext current
  RMDir /r /REBOOTOK "$SMPROGRAMS\${PRODUCT_NAME}"
  RMDir /r /REBOOTOK "$APPDATA\taobao\${PRODUCT_NAME_EN}"

  SetRebootFlag false
  RMDir /r /REBOOTOK "$INSTDIR"
  DeleteRegKey ${PRODUCT_ROOT_KEY} "${PRODUCT_SUB_KEY}"

  SetRebootFlag false
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME_EN}"

  Delete "$INSTDIR\Uninstall.exe"
  ;RMDir "$INSTDIR"	
SectionEnd

;--------------------------------------------------------------------------------------------------------------------------------------------------------------

; 安装和卸载页面
Page         custom     360Safe
Page         instfiles  "" InstallShow

UninstPage   custom     un.360SafeUninstall
UninstPage   instfiles  "" un.UninstallShow

;--------------------------------------------------------------------------------------------------------------------------------------------------------------
Function AbortFunction
  call .onInstFailed
  quit
FunctionEnd


Function 360Safe
    !insertmacro DEBUG_INFO ""
   ;初始化窗口          
   nsduilib::InitTBCIASkinEngine /NOUNLOAD "$temp\${PRODUCT_NAME_EN}Setup\res" "InstallPackages.xml" "WizardTab" "360SafeSetup"
   Pop $Dialog
   !insertmacro DEBUG_INFO ""

   ;初始化MessageBox窗口
   nsduilib::InitTBCIAMessageBox "MessageBox.xml" "TitleLab" "TextLab" "CloseBtn" "YESBtn" "NOBtn"
   Pop $MessageBoxHandle   
   !insertmacro DEBUG_INFO ""

   ;全局按钮绑定函数
   ;最小化按钮绑定函数
   !insertmacro BindControlFunction "Wizard_MinBtn" "OnGlobalMinFunc"
   !insertmacro BindControlFunction "Wizard_CloseBtn" "OnGlobalCancelFunc"

   ;----------------------------第一个页面-----------------------------------------------
   ; 显示licence
   !insertmacro ShowLicense "LicenceRichEdit" "$temp\${PRODUCT_NAME_EN}Setup\res\Licence.txt"

   ;下一步按钮绑定函数
   !insertmacro BindControlFunction "Wizard_NextBtn4Page1" "OnNextBtnFunc"
   ;取消按钮绑定函数
   !insertmacro BindControlFunction "Wizard_CancelBtn4Page1" "OnGlobalCancelFunc"
   
   ;----------------------------第二个页面-----------------------------------------------
   ;安装路径编辑框设定数据
   !insertmacro BindControlFunction "Wizard_InstallPathEdit4Page2" "OnTextChangeFunc"	
   nsduilib::SetControlData "Wizard_InstallPathEdit4Page2"  $installPath "text"


   ${If} $InstallState == "Cover"
	ReadRegStr $LocalPath HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME_EN}" "InstallLocation"
	StrCmp $LocalPath "" +4 0
	nsduilib::SetControlData "Wizard_InstallPathEdit4Page2"  $LocalPath "text"
	nsduilib::SetControlData "Wizard_InstallPathEdit4Page2" "false" "enable"
	nsduilib::SetControlData "Wizard_InstallPathBtn4Page2" "false" "enable"
	nsduilib::SetControlData "Wizard_StartInstallBtn4Page2" "覆盖" "text"
   ${EndIf}

   
   ;可用磁盘空间设定数据
   !insertmacro SetControlText "Wizard_UsableSpaceLab4Page2" "$FreeSpaceSize"

   ;安装路径浏览按钮绑定函数
   !insertmacro BindControlFunction "Wizard_InstallPathBtn4Page2" "OnInstallPathBrownBtnFunc"

   ;上一步按钮绑定函数
   !insertmacro BindControlFunction "Wizard_BackBtn4Page2" "OnBackBtnFunc"

   ;开始安装按钮绑定函数
   !insertmacro BindControlFunction "Wizard_StartInstallBtn4Page2" "OnStartInstallBtnFunc"


   ;取消按钮绑定函数
   !insertmacro BindControlFunction "Wizard_CancelBtn4Page2" "OnGlobalCancelFunc"

   ;----------------------------第三个页面-----------------------------------------------
   ;取消按钮绑定函数
   !insertmacro BindControlFunction "Wizard_CancelBtn4Page3" "OnGlobalCancelFunc"

   ;切换背景绑定函数
   nsduilib::FindControl "Wizard_Background4Page3"
   Pop $0
   ${If} $0 == "-1"
	MessageBox MB_OK "Do not have Wizard_Background4Page3 button"
   ${Else}
        StrCpy $changebkimageIndex  "0"
	GetFunctionAddress $timerID OnChangeFunc   
	nsduilib::TBCIACreatTimer $timerID 2000  ;callback interval        
   ${EndIf}   

      !insertmacro DEBUG_INFO ""
     
   ;----------------------------第四个页面-----------------------------------------------  

   ;完成按钮绑定函数
   !insertmacro BindControlFunction "Wizard_FinishedBtn4Page4" "OnFinishedBtnFunc"

   ;链接按钮绑定函数
   !insertmacro BindControlFunction "Wizard_110Btn4Page4" "OnLinkBtnFunc"

   ;---------------------------------显示------------------------------------------------
   nsduilib::ShowPage
   pop $R0
   !insertmacro DEBUG_INFO "GetShowPage Ret ($R0)"
   ${If} $R0 <> "0"
      !insertmacro DEBUG_INFO " will abort"
      Call AbortFunction
   ${EndIF}

FunctionEnd

Function un.AbortFunction
  call un.onUserAbort
  quit
FunctionEnd


Function un.360SafeUninstall
   ;初始化窗口          
   nsduilib::InitTBCIASkinEngine /NOUNLOAD "$temp\${PRODUCT_NAME_EN}Setup\res" "UninstallPackages.xml" "WizardTab" "360SafeUninstaller"
   Pop $Dialog

   ;初始化MessageBox窗口
   nsduilib::InitTBCIAMessageBox "MessageBox.xml" "TitleLab" "TextLab" "CloseBtn" "YESBtn" "NOBtn"
   Pop $MessageBoxHandle   

   ;全局按钮绑定函数
   ;最小化按钮绑定函数
   !insertmacro BindControlFunction "Wizard_MinBtn" "un.OnGlobalMinFunc"
   ;关闭按钮绑定函数
   !insertmacro BindControlFunction "Wizard_CloseBtn" "un.OnGlobalCancelFunc"

   ;-------------------------------------确定卸载页面------------------------------------
   ;开始卸载按钮绑定函数
   !insertmacro BindControlFunction "UninstallBtn4UninstallPage" "un.OnStartUninstallBtnFunc"

   ;取消按钮绑定函数
   !insertmacro BindControlFunction "CancelBtn4UninstallPage" "un.OnGlobalCancelFunc"

   ;切换背景绑定函数
   nsduilib::FindControl "Wizard_BackgroundUninstallPage"
   Pop $0
   ${If} $0 == "-1"
	MessageBox MB_OK "Do not have Wizard_BackgroundUninstallPage button"
   ${Else}
        StrCpy $changebkimage4UninstallIndex  "0"
	GetFunctionAddress $timerID4Uninstall un.OnChangeFunc   
	nsduilib::TBCIACreatTimer $timerID4Uninstall 2000  ;callback interval        
   ${EndIf}   

    ;--------------------------------卸载完成页面----------------------------------------
   ;完成按钮绑定函数
   !insertmacro BindControlFunction "FinishedBtn4UninstallPage" "un.OnUninstallFinishedBtnFunc"

   ;链接按钮绑定函数
   !insertmacro BindControlFunction "Wizard_110Btn4UninstallPage" "un.OnLinkBtnFunc"

   nsduilib::ShowPage
   pop $R0
   !insertmacro DEBUG_INFO "GetShowPage Ret ($R0)"
   ${If} $R0 <> "0"
      !insertmacro DEBUG_INFO " will abort"
      Call un.AbortFunction
   ${EndIF}

FunctionEnd

;--------------------------------------------------------------------------------------------------------------------------------------------------------------
; 函数的定义

Function .onInit
  GetTempFileName $0
  StrCpy $360Safetemp $0
  Delete $0
  SetOutPath "$temp\${PRODUCT_NAME_EN}Setup\res"
  File ".\setup res\*.png"
  File ".\setup res\*.txt"
  File ".\setup res\*.xml"

  !insertmacro DEBUG_INFO ""
  StrCpy $installPath "$PROGRAMFILES\360\${PRODUCT_NAME_EN}"
  Call UpdateFreeSpace

  FindWindow $0 "UIMainFrame" "360安全卫士"  ;判断客户端是否在运行中
  ;Dumpstate::debug
  IsWindow $0 0 +5  
     MessageBox MB_RETRYCANCEL "您已经运行了360Safe程序。请关闭该程序后再试！" IDRETRY RetryInstall  IDCANCEL NotInstall
     RetryInstall:
       Goto -4;
     NotInstall:
       Goto +1     
  StrCmp $0 "0" 0 0
  !insertmacro DEBUG_INFO ""
  ; 判断mutex 知道是否还有安装卸载程序运行
  !insertmacro MutexCheck "${SETUP_MUTEX_NAME}" $0 $9
  StrCmp $0 0 launch
  MessageBox MB_OK "您已经运行了安装卸载程序！"
  Abort
  StrLen $0 "$(^Name)"
  IntOp $0 $0 + 1
  !insertmacro DEBUG_INFO ""
 loop:
   FindWindow $1 '#32770' '' 0 $1
   StrCmp $1 0 +1 +2
   IntOp $3 $3 + 1
   IntCmp $3 3 +5
   System::Call "user32::GetWindowText(i r1, t .r2, i r0) i."
   StrCmp $2 "$(^Name)" 0 loop
   System::Call "user32::SetForegroundWindow(i r1) i."
   System::Call "user32::ShowWindow(i r1,i 9) i."
   Abort

 launch: 
  ; 判断操作系统
  Call GetWindowsVersion
  Pop $R0
  StrCmp $R0 "98"   done
  StrCmp $R0 "2000" done
   Goto End
  done:
     MessageBox MB_OK "对不起，360Safe目前仅可以安装在Windows 7/XP/Vista操作系统上。"
     Abort
  End:  
  
  ; 检查版本
  SetOutPath "$360Safetemp\${PRODUCT_NAME_EN}Setup"
  File ".\360Safe\${PRODUCT_MAIN_EXE}"
  
  Var /GLOBAL local_setup_version
  ${GetFileVersion} "$360Safetemp\${PRODUCT_NAME_EN}Setup\${PRODUCT_MAIN_EXE}" $local_setup_version
  ReadRegStr $0 ${PRODUCT_ROOT_KEY} "${PRODUCT_SUB_KEY}" "Version"
  
  Var /Global local_check_version
  ${VersionCompare} "$local_setup_version" "$0" $local_check_version
  
  ; 覆盖安装
  ${If} $0 != ""
    ;相同版本
    ${If} $local_check_version == "0"
	StrCmp $local_check_version "0" 0 +4
	MessageBox MB_YESNO "您已经安装当前版本的${PRODUCT_NAME},是否覆盖安装？" IDYES true IDNO false
	true:
	   StrCpy $InstallState "Cover"
	   Goto CHECK_RUN
	false: 
	   Quit
    ;安装包版本较低
    ${ElseIf} $local_check_version == "2"
	MessageBox MB_OK|MB_ICONINFORMATION "您已经安装较新版本的${PRODUCT_NAME}，此旧版本无法完成安装，继续安装需先卸载已有版本"
	Quit
    ;安装包版本较高
    ${Else}
	Goto CHECK_RUN
    ${EndIf}    
  ${EndIf}
  !insertmacro DEBUG_INFO ""
  ;判断进程是否存在
  CHECK_RUN:
  ;NO_RUNNING_PROCESS:
  
  SectionGetSize ${SecDummy} $1
  
  !insertmacro DEBUG_INFO ""

  ${GetRoot} $360Safetemp $0
  System::Call kernel32::GetDiskFreeSpaceEx(tr0,*l,*l,*l.r0)
  System::Int64Op $0 / 1024
  Pop $2
  IntCmp $2 $1 "" "" +3
  MessageBox MB_OK|MB_ICONEXCLAMATION "临时目录所在磁盘空间不足，无法解压！"
  Quit  
FunctionEnd

Function .onGUIEnd
  RMDir /r $360Safetemp\${PRODUCT_NAME_EN}Temp
  IfFileExists $360Safetemp\${PRODUCT_NAME_EN}Temp 0 +2
  RMDir /r /REBOOTOK $360Safetemp\${PRODUCT_NAME_EN}Temp
FunctionEnd

Function BuildShortCut
  ;开始菜单
  CreateDirectory "$SMPROGRAMS\${PRODUCT_NAME}"
  CreateShortCut  "$SMPROGRAMS\${PRODUCT_NAME}\${PRODUCT_NAME}.lnk"       "$INSTDIR\${PRODUCT_MAIN_EXE}"
  CreateShortCut  "$SMPROGRAMS\${PRODUCT_NAME}\卸载${PRODUCT_NAME}.lnk"   "$INSTDIR\Uninstall.exe"   
  ;桌面快捷方式
  Call QueryDesktopIconState
  !insertmacro DEBUG_INFO "DesktopIconState ($DesktopIconState)"
  StrCmp $DesktopIconState "1" "" +2
  CreateShortCut "$DESKTOP\${PRODUCT_NAME}.lnk" "$INSTDIR\${PRODUCT_MAIN_EXE}"
    
  ;快速启动
  call QueryFastIconState
  !insertmacro DEBUG_INFO "FastIconState ($FastIconState)"
  StrCmp $FastIconState "1" "" +2
  CreateShortCut "$QUICKLAUNCH\${PRODUCT_NAME}.lnk" "$INSTDIR\${PRODUCT_MAIN_EXE}"
  
  ;注册表
  ;控制面板卸载连接
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME_EN}" "DisplayName" "${PRODUCT_NAME}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME_EN}" "UninstallString" '"$INSTDIR\Uninstall.exe"'
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME_EN}" "DisplayIcon" '"$INSTDIR\${PRODUCT_MAIN_EXE}"'
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME_EN}" "InstallLocation" "$INSTDIR"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME_EN}" "Publisher" "TBCIA出品"  
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME_EN}" "HelpLink" "http://safe.taobao.com"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME_EN}" "DisplayVersion" "1.0.0.1"
FunctionEnd

Function un.onInit
  ;判断客户端是否在运行中
  ;FindWindow $0 "UIMainFrame" "360安全卫士"
  ;Dumpstate::debug
  ;IsWindow $0 0 +4  
  ;MessageBox MB_OK "您已经运行了360Safe程序。如需卸载，请先关闭该程序！"
  ;Goto -3;
  ;Goto close_run_cancel
  
  ;判断客户端是否在运行中
  FindWindow $0 "UIMainFrame" "360安全卫士"
  ;Dumpstate::debug
  IsWindow $0 0 +5  
  MessageBox MB_RETRYCANCEL "您已经运行了360Safe程序。请关闭该程序后再试！" IDRETRY RetryUninstall  IDCANCEL NotUninstall
     RetryUninstall:
       Goto -3;
     NotUninstall:
        Goto +1     
  StrCmp $0 0 0 0
  
  ; 判断mutex 知道是否还有安装卸载程序运行
  !insertmacro MutexCheck "${SETUP_MUTEX_NAME}" $0 $9
  StrCmp $0 0 launch
  MessageBox MB_OK "您已经运行了安装卸载程序！"
  StrCmp $0 0 0 0
  StrLen $0 "$(^Name)"
  IntOp $0 $0 + 1

loop:
  FindWindow $1 '#32770' '' 0 $1
  StrCmp $1 0 +1 +2
  IntOp $3 $3 + 1
  IntCmp $3 3 +5
  System::Call "user32::GetWindowText(i r1, t .r2, i r0) i."
  StrCmp $2 "$(^Name)" 0 loop
  System::Call "user32::SetForegroundWindow(i r1) i."
  System::Call "user32::ShowWindow(i r1,i 9) i."
  Abort
launch: 
  ;判断进程是否存在
FunctionEnd

Function OnGlobalMinFunc
   nsduilib::TBCIASendMessage $Dialog WM_TBCIAMIN
FunctionEnd

Function OnGlobalCancelFunc
   nsduilib::TBCIASendMessage $Dialog WM_TBCIACANCEL "360Safe安装" "确定要退出360Safe安装？"
   Pop $0
   ${If} $0 == "0"
     nsduilib::ExitTBCIASkinEngine
   ${EndIf}
FunctionEnd

Function un.OnGlobalMinFunc
   nsduilib::TBCIASendMessage $Dialog WM_TBCIAMIN
FunctionEnd

Function un.OnGlobalCancelFunc
   nsduilib::TBCIASendMessage $Dialog WM_TBCIACANCEL "360Safe安装" "确定要退出360Safe安装？"
   Pop $0
   ${If} $0 == "0"
     nsduilib::ExitTBCIASkinEngine
   ${EndIf}
FunctionEnd

Function OnBackBtnFunc
   nsduilib::TBCIASendMessage $Dialog WM_TBCIABACK
FunctionEnd

Function OnNextBtnFunc
   nsduilib::TBCIASendMessage $Dialog WM_TBCIANEXT
FunctionEnd

Function OnStartInstallBtnFunc
  
  !insertmacro ValidPort
  ${If} $R0 <> "0"
         return
  ${EndIf}

  !insertmacro ValidService
  ${If} $R0 <> "0"
         return
  ${EndIf}

  nsduilib::TBCIASendMessage $Dialog WM_TBCIASTARTINSTALL
FunctionEnd

Function un.OnStartUninstallBtnFunc
   nsduilib::TBCIASendMessage $Dialog WM_TBCIASTARTUNINSTALL
FunctionEnd

Function RunAfterInstall
    StrCmp $RunNow "1" "" +2
    Exec '"$INSTDIR\${PRODUCT_MAIN_EXE}"'
FunctionEnd

Function OnFinishedBtnFunc
   nsduilib::TBCIASendMessage $Dialog WM_TBCIAOPTIONSTATE "Wizard_Runing360SafeBtn" ""
   Pop $0
   !insertmacro DEBUG_INFO "running 360 ($0)"
   ${If} $0 == "1"
     StrCpy $RunNow "1"
   ${Else}
     StrCpy $RunNow "0" 
   ${EndIf}

   ;开机运行
   nsduilib::TBCIASendMessage $Dialog WM_TBCIAOPTIONSTATE "Wizard_BootRuning360SafeBtn" ""
   Pop $0
   !insertmacro DEBUG_INFO "Bootrunning ($0)"
   ${If} $0 == "1"
      ;CreateShortCut "$SMSTARTUP\${PRODUCT_NAME}.lnk" "$INSTDIR\${PRODUCT_MAIN_EXE}" "" "$INSTDIR\${PRODUCT_MAIN_EXE}" 0
      WriteRegStr HKLM  "Software\Microsoft\Windows\CurrentVersion\Run" "360Safe"  "$INSTDIR\${PRODUCT_MAIN_EXE} -autorun"
   ${EndIf}

   !insertmacro DEBUG_INFO "runnow ($RunNow)"
   call RunAfterInstall
   nsduilib::TBCIAKillTimer $timerID
   nsduilib::TBCIASendMessage $Dialog WM_TBCIAFINISHEDINSTALL
FunctionEnd

Function un.OnUninstallFinishedBtnFunc
   DeleteRegValue HKLM  "Software\Microsoft\Windows\CurrentVersion\Run" "360Safe"
   nsduilib::TBCIASendMessage $Dialog WM_TBCIAFINISHEDINSTALL
   nsduilib::TBCIASendMessage $Dialog WM_TBCIAOPENURL "${AD_URL}"
FunctionEnd

Function OnLinkBtnFunc
   nsduilib::TBCIASendMessage $Dialog WM_TBCIAOPENURL "${AD_URL}"
   Pop $0
   ${If} $0 == "url error"
     MessageBox MB_OK "url error"
   ${EndIf}
FunctionEnd

Function OnTextChangeFunc
   ; 改变可用磁盘空间大小
   nsduilib::GetControlData Wizard_InstallPathEdit4Page2 "text"
   Pop $0
   ;MessageBox MB_OK $0
   StrCpy $INSTDIR $0

   ;重新获取磁盘空间
   Call UpdateFreeSpace

   ;更新磁盘空间文本显示
   nsduilib::FindControl "Wizard_UsableSpaceLab4Page2"
   Pop $0
   ${If} $0 == "-1"
	MessageBox MB_OK "Do not have Wizard_UsableSpaceLab4Page2 button"
   ${Else}
	;nsduilib::SetText2Control "Wizard_UsableSpaceLab4Page2"  $FreeSpaceSize
	nsduilib::SetControlData "Wizard_UsableSpaceLab4Page2"  $FreeSpaceSize  "text"
   ${EndIf}
   ;路径是否合法（合法则不为0Bytes）
   ${If} $FreeSpaceSize == "0Bytes"
	nsduilib::SetControlData "Wizard_StartInstallBtn4Page2" "false" "enable"
   ${Else}
	nsduilib::SetControlData "Wizard_StartInstallBtn4Page2" "true" "enable"
   ${EndIf}
FunctionEnd

Function OnChangeFunc
   ${If} $changebkimageIndex == "0"
        StrCpy $changebkimageIndex "1"
	nsduilib::SetControlData "Wizard_Background4Page3" "内嵌背景4Page3_1.png" "bkimage"
   ${Else}
        StrCpy $changebkimageIndex "0"
	nsduilib::SetControlData "Wizard_Background4Page3" "内嵌背景4Page3_2.png" "bkimage"
   ${EndIf}

FunctionEnd

Function QueryDesktopIconState
   nsduilib::TBCIASendMessage $Dialog WM_TBCIAOPTIONSTATE "Wizard_ShortCutBtn4Page2" ""
   Pop $0
   ${If} $0 == "1"
     StrCpy $DesktopIconState "1"
   ${Else}
     StrCpy $DesktopIconState "0" 
   ${EndIf}
FunctionEnd

Function QueryFastIconState
   nsduilib::TBCIASendMessage $Dialog WM_TBCIAOPTIONSTATE "Wizard_QuickLaunchBarBtn4Page2" ""
   Pop $1
   ${If} $1 == "1"
      StrCpy $FastIconState "1"
   ${Else}
      StrCpy $FastIconState "0"
   ${EndIf}
FunctionEnd

Function OnInstallPathBrownBtnFunc
   nsduilib::SelectFolderDialog "请选择文件夹" 
   Pop $installPath

   StrCpy $0 $installPath
   ${If} $0 == "-1"
   ${Else}
      StrCpy $INSTDIR "$installPath\${PRODUCT_NAME_EN}"
      ;设置安装路径编辑框文本
      nsduilib::FindControl "Wizard_InstallPathEdit4Page2"
      Pop $0
      ${If} $0 == "-1"
	 MessageBox MB_OK "Do not have Wizard_InstallPathBtn4Page2 button"
      ${Else}
	 ;nsduilib::SetText2Control "Wizard_InstallPathEdit4Page2"  $installPath
	 StrCpy $installPath $INSTDIR
	 nsduilib::SetControlData "Wizard_InstallPathEdit4Page2"  $installPath  "text"
      ${EndIf}
   ${EndIf}

   ;重新获取磁盘空间
   Call UpdateFreeSpace

   ;路径是否合法（合法则不为0Bytes）
   ${If} $FreeSpaceSize == "0Bytes"
	nsduilib::SetControlData "Wizard_StartInstallBtn4Page2" "false" "enable"
   ${Else}
	nsduilib::SetControlData "Wizard_StartInstallBtn4Page2" "true" "enable"
   ${EndIf}

   ;更新磁盘空间文本显示
   nsduilib::FindControl "Wizard_UsableSpaceLab4Page2"
   Pop $0
   ${If} $0 == "-1"
	MessageBox MB_OK "Do not have Wizard_UsableSpaceLab4Page2 button"
   ${Else}
	;nsduilib::SetText2Control "Wizard_UsableSpaceLab4Page2"  $FreeSpaceSize
	nsduilib::SetControlData "Wizard_UsableSpaceLab4Page2"  $FreeSpaceSize  "text"
   ${EndIf}   
FunctionEnd

Function UpdateFreeSpace
  ${GetRoot} $INSTDIR $0
  StrCpy $1 "Bytes"

  System::Call kernel32::GetDiskFreeSpaceEx(tr0,*l,*l,*l.r0)
   ${If} $0 > 1024
   ${OrIf} $0 < 0
      System::Int64Op $0 / 1024
      Pop $0
      StrCpy $1 "KB"
      ${If} $0 > 1024
      ${OrIf} $0 < 0
	 System::Int64Op $0 / 1024
	 Pop $0
	 StrCpy $1 "MB"
	 ${If} $0 > 1024
	 ${OrIf} $0 < 0
	    System::Int64Op $0 / 1024
	    Pop $0
	    StrCpy $1 "GB"
	 ${EndIf}
      ${EndIf}
   ${EndIf}

   StrCpy $FreeSpaceSize  "$0$1"
FunctionEnd

Function InstallShow
   ;进度条绑定函数
   nsduilib::FindControl "Wizard_InstallProgress"
   Pop $0
   ${If} $0 == "-1"
	MessageBox MB_OK "Do not have Wizard_InstallProgress button"
   ${Else}
	nsduilib::StartInstall  Wizard_InstallProgress
   ${EndIf}   
FunctionEnd 

Function un.UninstallShow 
   ;进度条绑定函数
   nsduilib::FindControl "Wizard_UninstallProgress"
   Pop $0
   ${If} $0 == "-1"
	MessageBox MB_OK "Do not have Wizard_InstallProgress button"
   ${Else}
	nsduilib::StartUninstall  Wizard_UninstallProgress
   ${EndIf} 
FunctionEnd

Function un.OnLinkBtnFunc
   nsduilib::TBCIASendMessage $Dialog WM_TBCIAOPENURL "${AD_URL}"
   Pop $0
   ${If} $0 == "url error"
     MessageBox MB_OK "url error"
   ${EndIf}
FunctionEnd

Function un.OnChangeFunc
   ${If} $changebkimage4UninstallIndex == "0"
        StrCpy $changebkimage4UninstallIndex "1"
	nsduilib::SetControlData "Wizard_BackgroundUninstallPage" "内嵌背景4Page3_1.png" "bkimage"
   ${Else}
        StrCpy $changebkimage4UninstallIndex "0"
	nsduilib::SetControlData "Wizard_BackgroundUninstallPage" "内嵌背景4Page3_2.png" "bkimage"
   ${EndIf}
FunctionEnd

Function un.onUserAbort
FunctionEnd

Function un.onUninstFailed
FunctionEnd

Function .onInstFailed
FunctionEnd