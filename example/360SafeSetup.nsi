; ѡ��ѹ����ʽ
;SetCompressor /SOLID LZMA

; �����ͷ�ļ�
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
; �����dll
#ReserveFile "${NSISDIR}\Plugins\system.dll"
#ReserveFile "${NSISDIR}\Plugins\nsDialogs.dll"
#ReserveFile "${NSISDIR}\Plugins\nsExec.dll"
#ReserveFile "${NSISDIR}\Plugins\InstallOptions.dll"
#

; ���ƺ궨��
!define PRODUCT_NAME              "360Safe"
!define PRODUCT_VERSION           "1.0.0.1"
!define PRODUCT_NAME_EN           "360Safe"
!define PRODUCT_ROOT_KEY          "HKLM"
!define PRODUCT_SUB_KEY           "SOFTWARE\360\360Safe"
!define PRODUCT_MAIN_EXE          "360Safe_ud.exe"
!define PRODUCT_MAIN_EXE_MUTEX    "{3D3CB097-93A1-440a-954F-6D253C50CE32}"
!define SETUP_MUTEX_NAME          "{50A3E52E-6F7F-4411-9791-63BD15BBF2C2}"
!define MUI_ICON                  ".\setup res\install.ico"    ; ��װicon
!define MUI_UNICON                ".\setup res\uninstall.ico"  ; ж��icon

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

Name      "${PRODUCT_NAME}"              ; ��ʾ�Ի���ı���
OutFile   "${PRODUCT_NAME_EN}Setup.exe"  ; ����İ�װ����

InstallDir "$PROGRAMFILES\360\${PRODUCT_NAME_EN}"                   ;Default installation folder
InstallDirRegKey ${PRODUCT_ROOT_KEY} ${PRODUCT_SUB_KEY} "installDir"   ;Get installation folder from registry if available

;Request application privileges for Windows Vista
RequestExecutionLevel admin
;Languages 
!insertmacro MUI_LANGUAGE "English"

;--------------------------------------------------------------------------------------------------------------------------------------------------------------

;Installer Sections

Section "Dummy Section" SecDummy
 
  ;����Ҫ�����İ�װ�ļ�  
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
  ;ִ��uninstall.exe
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

; ��װ��ж��ҳ��
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
   ;��ʼ������          
   nsduilib::InitTBCIASkinEngine /NOUNLOAD "$temp\${PRODUCT_NAME_EN}Setup\res" "InstallPackages.xml" "WizardTab" "360SafeSetup"
   Pop $Dialog
   !insertmacro DEBUG_INFO ""

   ;��ʼ��MessageBox����
   nsduilib::InitTBCIAMessageBox "MessageBox.xml" "TitleLab" "TextLab" "CloseBtn" "YESBtn" "NOBtn"
   Pop $MessageBoxHandle   
   !insertmacro DEBUG_INFO ""
   !insertmacro nsSetIconImage "install.png"
   ${If} $R0 <> "0"
      MessageBox MB_OK "can not init install.png"
      !insertmacro DEBUG_INFO "can not init install.png"
       Call AbortFunction
   ${EndIf}
   !insertmacro DEBUG_INFO "load install.png"

   ;ȫ�ְ�ť�󶨺���
   ;��С����ť�󶨺���
   !insertmacro BindControlFunction "Wizard_MinBtn" "OnGlobalMinFunc"
   !insertmacro DEBUG_INFO "Wizard_MinBtn"
   !insertmacro BindControlFunction "Wizard_CloseBtn" "OnGlobalCancelFunc"
   
   !insertmacro DEBUG_INFO "Wizard_CloseBtn"

   ;----------------------------��һ��ҳ��-----------------------------------------------
   ; ��ʾlicence
   !insertmacro ShowLicense "LicenceRichEdit" "$temp\${PRODUCT_NAME_EN}Setup\res\Licence.txt"
   !insertmacro DEBUG_INFO "Licence"

   ;��һ����ť�󶨺���
   !insertmacro BindControlFunction "Wizard_NextBtn4Page1" "OnNextBtnFunc"
   ;ȡ����ť�󶨺���
   !insertmacro BindControlFunction "Wizard_CancelBtn4Page1" "OnGlobalCancelFunc"
   !insertmacro DEBUG_INFO "Wizard_CancelBtn4Page1"
   
   ;----------------------------�ڶ���ҳ��-----------------------------------------------
   ;��װ·���༭���趨����
   !insertmacro BindControlFunction "Wizard_InstallPathEdit4Page2" "OnTextChangeFunc"	
   nsduilib::SetControlData "Wizard_InstallPathEdit4Page2"  $installPath "text"
   nsduilib::SetControlData "ComboInterface" "dummy" "clearcombo"
   nsduilib::SetControlData "ComboInterface" "NetInterface1" "insertcombo"
	 nsduilib::SetControlData "ComboInterface" "NetInterface2" "insertcombo"
	 nsduilib::SetControlData "ComboInterface" "NetInterface3" "insertcombo"

   ${If} $InstallState == "Cover"
	ReadRegStr $LocalPath HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME_EN}" "InstallLocation"
	StrCmp $LocalPath "" +4 0
	nsduilib::SetControlData "Wizard_InstallPathEdit4Page2"  $LocalPath "text"
	nsduilib::SetControlData "Wizard_InstallPathEdit4Page2" "false" "enable"
	nsduilib::SetControlData "Wizard_InstallPathBtn4Page2" "false" "enable"
	nsduilib::SetControlData "Wizard_StartInstallBtn4Page2" "����" "text"
   ${EndIf}

   !insertmacro DEBUG_INFO "Wizard_StartInstallBtn4Page2"
   ;���ô��̿ռ��趨����
   !insertmacro SetControlText "Wizard_UsableSpaceLab4Page2" "$FreeSpaceSize"

   ;��װ·�������ť�󶨺���
   !insertmacro BindControlFunction "Wizard_InstallPathBtn4Page2" "OnInstallPathBrownBtnFunc"

   ;��һ����ť�󶨺���
   !insertmacro BindControlFunction "Wizard_BackBtn4Page2" "OnBackBtnFunc"

   ;��ʼ��װ��ť�󶨺���
   !insertmacro BindControlFunction "Wizard_StartInstallBtn4Page2" "OnStartInstallBtnFunc"


   ;ȡ����ť�󶨺���
   !insertmacro BindControlFunction "Wizard_CancelBtn4Page2" "OnGlobalCancelFunc"

   ;----------------------------������ҳ��-----------------------------------------------
   ;ȡ����ť�󶨺���
   !insertmacro BindControlFunction "Wizard_CancelBtn4Page3" "OnGlobalCancelFunc"

   ;�л������󶨺���
   nsduilib::FindControl "Wizard_Background4Page3"
   Pop $0
   ${If} $0 == "-1"
	MessageBox MB_OK "Do not have Wizard_Background4Page3 button"
   ${Else}
        StrCpy $changebkimageIndex  "0"
	GetFunctionAddress $timerID OnChangeFunc   
	nsduilib::TBCIACreatTimer $timerID 2000  ;callback interval        
   ${EndIf}   

      !insertmacro DEBUG_INFO "cc"
     
   ;----------------------------���ĸ�ҳ��-----------------------------------------------  

   ;��ɰ�ť�󶨺���
   !insertmacro BindControlFunction "Wizard_FinishedBtn4Page4" "OnFinishedBtnFunc"

   ;���Ӱ�ť�󶨺���
   !insertmacro BindControlFunction "Wizard_110Btn4Page4" "OnLinkBtnFunc"

   ;---------------------------------��ʾ------------------------------------------------
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
   ;��ʼ������          
   nsduilib::InitTBCIASkinEngine /NOUNLOAD "$temp\${PRODUCT_NAME_EN}Setup\res" "UninstallPackages.xml" "WizardTab" "360SafeUninstaller"
   Pop $Dialog

   ;��ʼ��MessageBox����
   nsduilib::InitTBCIAMessageBox "MessageBox.xml" "TitleLab" "TextLab" "CloseBtn" "YESBtn" "NOBtn"
   Pop $MessageBoxHandle   

   ;ȫ�ְ�ť�󶨺���
   ;��С����ť�󶨺���
   !insertmacro BindControlFunction "Wizard_MinBtn" "un.OnGlobalMinFunc"
   ;�رհ�ť�󶨺���
   !insertmacro BindControlFunction "Wizard_CloseBtn" "un.OnGlobalCancelFunc"

   ;-------------------------------------ȷ��ж��ҳ��------------------------------------
   ;��ʼж�ذ�ť�󶨺���
   !insertmacro BindControlFunction "UninstallBtn4UninstallPage" "un.OnStartUninstallBtnFunc"

   ;ȡ����ť�󶨺���
   !insertmacro BindControlFunction "CancelBtn4UninstallPage" "un.OnGlobalCancelFunc"

   ;�л������󶨺���
   nsduilib::FindControl "Wizard_BackgroundUninstallPage"
   Pop $0
   ${If} $0 == "-1"
	MessageBox MB_OK "Do not have Wizard_BackgroundUninstallPage button"
   ${Else}
        StrCpy $changebkimage4UninstallIndex  "0"
	GetFunctionAddress $timerID4Uninstall un.OnChangeFunc   
	nsduilib::TBCIACreatTimer $timerID4Uninstall 2000  ;callback interval        
   ${EndIf}   

    ;--------------------------------ж�����ҳ��----------------------------------------
   ;��ɰ�ť�󶨺���
   !insertmacro BindControlFunction "FinishedBtn4UninstallPage" "un.OnUninstallFinishedBtnFunc"

   ;���Ӱ�ť�󶨺���
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
; �����Ķ���

Function .onInit
  GetTempFileName $0
  StrCpy $360Safetemp $0
  Delete $0
  SetOutPath "$temp\${PRODUCT_NAME_EN}Setup\res"
  File ".\setup res\*.png"
  File ".\setup res\*.txt"
  File ".\setup res\*.xml"
  File ".\setup res\*.ico"

  !insertmacro DEBUG_INFO ""
  StrCpy $installPath "$PROGRAMFILES\360\${PRODUCT_NAME_EN}"
  Call UpdateFreeSpace

  FindWindow $0 "UIMainFrame" "360��ȫ��ʿ"  ;�жϿͻ����Ƿ���������
  ;Dumpstate::debug
  IsWindow $0 0 +5  
     MessageBox MB_RETRYCANCEL "���Ѿ�������360Safe������رոó�������ԣ�" IDRETRY RetryInstall  IDCANCEL NotInstall
     RetryInstall:
       Goto -4;
     NotInstall:
       Goto +1     
  StrCmp $0 "0" 0 0
  !insertmacro DEBUG_INFO ""
  ; �ж�mutex ֪���Ƿ��а�װж�س�������
  !insertmacro MutexCheck "${SETUP_MUTEX_NAME}" $0 $9
  StrCmp $0 0 launch
  MessageBox MB_OK "���Ѿ������˰�װж�س���"
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
  ; �жϲ���ϵͳ
  Call GetWindowsVersion
  Pop $R0
  StrCmp $R0 "98"   done
  StrCmp $R0 "2000" done
   Goto End
  done:
     MessageBox MB_OK "�Բ���360SafeĿǰ�����԰�װ��Windows 7/XP/Vista����ϵͳ�ϡ�"
     Abort
  End:  
  
  ; ���汾
  SetOutPath "$360Safetemp\${PRODUCT_NAME_EN}Setup"
  File ".\360Safe\${PRODUCT_MAIN_EXE}"
  
  Var /GLOBAL local_setup_version
  ${GetFileVersion} "$360Safetemp\${PRODUCT_NAME_EN}Setup\${PRODUCT_MAIN_EXE}" $local_setup_version
  ReadRegStr $0 ${PRODUCT_ROOT_KEY} "${PRODUCT_SUB_KEY}" "Version"
  
  Var /Global local_check_version
  ${VersionCompare} "$local_setup_version" "$0" $local_check_version
  
  ; ���ǰ�װ
  ${If} $0 != ""
    ;��ͬ�汾
    ${If} $local_check_version == "0"
	StrCmp $local_check_version "0" 0 +4
	MessageBox MB_YESNO "���Ѿ���װ��ǰ�汾��${PRODUCT_NAME},�Ƿ񸲸ǰ�װ��" IDYES true IDNO false
	true:
	   StrCpy $InstallState "Cover"
	   Goto CHECK_RUN
	false: 
	   Quit
    ;��װ���汾�ϵ�
    ${ElseIf} $local_check_version == "2"
	MessageBox MB_OK|MB_ICONINFORMATION "���Ѿ���װ���°汾��${PRODUCT_NAME}���˾ɰ汾�޷���ɰ�װ��������װ����ж�����а汾"
	Quit
    ;��װ���汾�ϸ�
    ${Else}
	Goto CHECK_RUN
    ${EndIf}    
  ${EndIf}
  !insertmacro DEBUG_INFO ""
  ;�жϽ����Ƿ����
  CHECK_RUN:
  ;NO_RUNNING_PROCESS:
  
  SectionGetSize ${SecDummy} $1
  
  !insertmacro DEBUG_INFO ""

  ${GetRoot} $360Safetemp $0
  System::Call kernel32::GetDiskFreeSpaceEx(tr0,*l,*l,*l.r0)
  System::Int64Op $0 / 1024
  Pop $2
  IntCmp $2 $1 "" "" +3
  MessageBox MB_OK|MB_ICONEXCLAMATION "��ʱĿ¼���ڴ��̿ռ䲻�㣬�޷���ѹ��"
  Quit  
FunctionEnd

Function .onGUIEnd
  RMDir /r $360Safetemp\${PRODUCT_NAME_EN}Temp
  IfFileExists $360Safetemp\${PRODUCT_NAME_EN}Temp 0 +2
  RMDir /r /REBOOTOK $360Safetemp\${PRODUCT_NAME_EN}Temp
FunctionEnd

Function BuildShortCut
  ;��ʼ�˵�
  CreateDirectory "$SMPROGRAMS\${PRODUCT_NAME}"
  CreateShortCut  "$SMPROGRAMS\${PRODUCT_NAME}\${PRODUCT_NAME}.lnk"       "$INSTDIR\${PRODUCT_MAIN_EXE}"
  CreateShortCut  "$SMPROGRAMS\${PRODUCT_NAME}\ж��${PRODUCT_NAME}.lnk"   "$INSTDIR\Uninstall.exe"   
  ;�����ݷ�ʽ
  Call QueryDesktopIconState
  !insertmacro DEBUG_INFO "DesktopIconState ($DesktopIconState)"
  StrCmp $DesktopIconState "1" "" +2
  CreateShortCut "$DESKTOP\${PRODUCT_NAME}.lnk" "$INSTDIR\${PRODUCT_MAIN_EXE}"
    
  ;��������
  call QueryFastIconState
  !insertmacro DEBUG_INFO "FastIconState ($FastIconState)"
  StrCmp $FastIconState "1" "" +2
  CreateShortCut "$QUICKLAUNCH\${PRODUCT_NAME}.lnk" "$INSTDIR\${PRODUCT_MAIN_EXE}"
  
  ;ע���
  ;�������ж������
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME_EN}" "DisplayName" "${PRODUCT_NAME}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME_EN}" "UninstallString" '"$INSTDIR\Uninstall.exe"'
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME_EN}" "DisplayIcon" '"$INSTDIR\${PRODUCT_MAIN_EXE}"'
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME_EN}" "InstallLocation" "$INSTDIR"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME_EN}" "Publisher" "TBCIA��Ʒ"  
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME_EN}" "HelpLink" "http://safe.taobao.com"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME_EN}" "DisplayVersion" "1.0.0.1"
FunctionEnd

Function un.onInit
  ;�жϿͻ����Ƿ���������
  ;FindWindow $0 "UIMainFrame" "360��ȫ��ʿ"
  ;Dumpstate::debug
  ;IsWindow $0 0 +4  
  ;MessageBox MB_OK "���Ѿ�������360Safe��������ж�أ����ȹرոó���"
  ;Goto -3;
  ;Goto close_run_cancel
  
  ;�жϿͻ����Ƿ���������
  FindWindow $0 "UIMainFrame" "360��ȫ��ʿ"
  ;Dumpstate::debug
  IsWindow $0 0 +5  
  MessageBox MB_RETRYCANCEL "���Ѿ�������360Safe������رոó�������ԣ�" IDRETRY RetryUninstall  IDCANCEL NotUninstall
     RetryUninstall:
       Goto -3;
     NotUninstall:
        Goto +1     
  StrCmp $0 0 0 0
  
  ; �ж�mutex ֪���Ƿ��а�װж�س�������
  !insertmacro MutexCheck "${SETUP_MUTEX_NAME}" $0 $9
  StrCmp $0 0 launch
  MessageBox MB_OK "���Ѿ������˰�װж�س���"
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
  ;�жϽ����Ƿ����
FunctionEnd

Function OnGlobalMinFunc
   nsduilib::TBCIASendMessage $Dialog WM_TBCIAMIN
FunctionEnd

Function OnGlobalCancelFunc
   nsduilib::TBCIASendMessage $Dialog WM_TBCIACANCEL "360Safe��װ" "ȷ��Ҫ�˳�360Safe��װ��"
   Pop $0
   ${If} $0 == "0"
     nsduilib::ExitTBCIASkinEngine
   ${EndIf}
FunctionEnd

Function un.OnGlobalMinFunc
   nsduilib::TBCIASendMessage $Dialog WM_TBCIAMIN
FunctionEnd

Function un.OnGlobalCancelFunc
   nsduilib::TBCIASendMessage $Dialog WM_TBCIACANCEL "360Safe��װ" "ȷ��Ҫ�˳�360Safe��װ��"
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
  nsduilib::GetControlData "ComboInterface" "getsel"
  pop $R0
    ${If} $R0 == "-1"
      nsduilib::SetControlData "ComboInterface" "0" "setcombo"
    ${EndIf}
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

  nsduilib::GetControlData "ComboInterface" "getseltext"
  pop $R0
  !insertmacro DEBUG_INFO "get selected [$R0]"

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

   ;��������
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
   ; �ı���ô��̿ռ��С
   nsduilib::GetControlData Wizard_InstallPathEdit4Page2 "text"
   Pop $0
   ;MessageBox MB_OK $0
   StrCpy $INSTDIR $0

   ;���»�ȡ���̿ռ�
   Call UpdateFreeSpace

   ;���´��̿ռ��ı���ʾ
   nsduilib::FindControl "Wizard_UsableSpaceLab4Page2"
   Pop $0
   ${If} $0 == "-1"
	MessageBox MB_OK "Do not have Wizard_UsableSpaceLab4Page2 button"
   ${Else}
	;nsduilib::SetText2Control "Wizard_UsableSpaceLab4Page2"  $FreeSpaceSize
	nsduilib::SetControlData "Wizard_UsableSpaceLab4Page2"  $FreeSpaceSize  "text"
   ${EndIf}
   ;·���Ƿ�Ϸ����Ϸ���Ϊ0Bytes��
   ${If} $FreeSpaceSize == "0Bytes"
	nsduilib::SetControlData "Wizard_StartInstallBtn4Page2" "false" "enable"
   ${Else}
	nsduilib::SetControlData "Wizard_StartInstallBtn4Page2" "true" "enable"
   ${EndIf}
FunctionEnd

Function OnChangeFunc
   ${If} $changebkimageIndex == "0"
        StrCpy $changebkimageIndex "1"
	nsduilib::SetControlData "Wizard_Background4Page3" "��Ƕ����4Page3_1.png" "bkimage"
   ${Else}
        StrCpy $changebkimageIndex "0"
	nsduilib::SetControlData "Wizard_Background4Page3" "��Ƕ����4Page3_2.png" "bkimage"
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
   nsduilib::SelectFolderDialog "��ѡ���ļ���" 
   Pop $installPath

   StrCpy $0 $installPath
   ${If} $0 == "-1"
   ${Else}
      StrCpy $INSTDIR "$installPath\${PRODUCT_NAME_EN}"
      ;���ð�װ·���༭���ı�
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

   ;���»�ȡ���̿ռ�
   Call UpdateFreeSpace

   ;·���Ƿ�Ϸ����Ϸ���Ϊ0Bytes��
   ${If} $FreeSpaceSize == "0Bytes"
	nsduilib::SetControlData "Wizard_StartInstallBtn4Page2" "false" "enable"
   ${Else}
	nsduilib::SetControlData "Wizard_StartInstallBtn4Page2" "true" "enable"
   ${EndIf}

   ;���´��̿ռ��ı���ʾ
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
   ;�������󶨺���
   nsduilib::FindControl "Wizard_InstallProgress"
   Pop $0
   ${If} $0 == "-1"
	MessageBox MB_OK "Do not have Wizard_InstallProgress button"
   ${Else}
	nsduilib::StartInstall  Wizard_InstallProgress
   ${EndIf}   
FunctionEnd 

Function un.UninstallShow 
   ;�������󶨺���
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
	nsduilib::SetControlData "Wizard_BackgroundUninstallPage" "��Ƕ����4Page3_1.png" "bkimage"
   ${Else}
        StrCpy $changebkimage4UninstallIndex "0"
	nsduilib::SetControlData "Wizard_BackgroundUninstallPage" "��Ƕ����4Page3_2.png" "bkimage"
   ${EndIf}
FunctionEnd

Function un.onUserAbort
FunctionEnd

Function un.onUninstFailed
FunctionEnd

Function .onInstFailed
FunctionEnd