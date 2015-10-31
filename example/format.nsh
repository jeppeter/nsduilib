
!ifndef __FORMAT_NSH__
!define __FORMAT_NSH__

!define NSD1_Debug `System::Call kernel32::OutputDebugString(ts)`
!include "LogicLib.nsh"
!include "WordFunc.nsh"

!macro DEBUG_INFO _Content
       ${NSD1_Debug} "${__FILE__}:${__LINE__} ${_Content}$\n"
!macroend

!macro FormatString _Result
!define  __inner_out_${__MACRO__} `__inner_out_${__MACRO__}_${__FILE__}_${__LINE__}`
!define  __inner_again_${__MACRO__} `__inner_agin_${__MACRO__}_${__FILE__}_${__LINE__}`
         # to pop the R0
         pop ${_Result}
${__inner_again_${__MACRO__}}:
         pop $1
         strcmp $1 "" ${__inner_out_${__MACRO__}}  ; this is the null ,so just out
!ifdef __UNINSTALL__
		${un.WordReplace} ${_Result} "%s"  $1 "+1" ${_Result} ; to replace just once
!else         
         ${WordReplace} ${_Result} "%s"  $1 "+1" ${_Result} ; to replace just once
!endif
         goto ${__inner_again_${__MACRO__}}
${__inner_out_${__MACRO__}}:
        # now $R0 is the result
!undef   __inner_out_${__MACRO__}
!undef   __inner_again_${__MACRO__}
!macroend


!macro AbortMessage _Message
!define __set_error_${__MACRO__} `__set_error_${__MACRO__}_${__FILE__}_${__LINE__}`
       # this is for the safe reason when we not call page callbacks
       #set the message when it is ok
       !insertmacro DEBUG_INFO ${_Message}
       IfSilent ${__set_error_${__MACRO__}} 0
       MessageBox MB_OK ${_Message}
${__set_error_${__MACRO__}}:
       SetErrors
!ifdef __UNINSTALL__
       call un.onUninstFailed
!else
       call .onInstFailed
!endif
       Quit
!undef __set_error_${__MACRO__}       
!macroend


!endif  # __FORMAT_NSH__