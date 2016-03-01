!ifndef __NS_VALID_NSH__
!define __NS_VALID_NSH__


!macro ValidPort
!define __macro_exit_${__MACRO__} `__macro_exit_${__MACRO__}_${__FILE__}_${__LINE__}`
!define __set_error_${__MACRO__} `__set_error_${__MACRO__}_${__FILE__}_${__LINE__}`
!define __set_ok_${__MACRO__} `__set_ok_${__MACRO__}_${__FILE__}_${__LINE__}`
	push $R1
   !insertmacro nsGetCtrlText "${PORT_EDIT}" "can not get port information"
   /*we store the R0 to R1 for it will give */
   StrCpy $R1 $R0 
   ${If} $R1 == "error"
      goto ${__set_error_${__MACRO__}}
   ${EndIf}
   !insertmacro CompareLarge $R1 "0" "please use port must more than 0"
   ${If} $R0 <> "0"
      goto ${__set_error_${__MACRO__}}
   ${EndIf}

   !insertmacro CompareLess $R1 "65536" "please use port less than 65536"
   ${If} $R0 <> "0"
      goto ${__set_error_${__MACRO__}}
   ${EndIf}
   /*copy the value store*/
   StrCpy $gPort $R1
   goto ${__set_ok_${__MACRO__}}
${__set_ok_${__MACRO__}}:
	StrCpy $R0 "0"
	goto ${__macro_exit_${__MACRO__}}

${__set_error_${__MACRO__}}:
	StrCpy $R0 "-1"
	goto ${__macro_exit_${__MACRO__}}
${__macro_exit_${__MACRO__}}:
	pop $R1

!undef __set_error_${__MACRO__}
!undef __set_ok_${__MACRO__}
!undef __macro_exit_${__MACRO__}
!macroend


!macro ValidService
!define __macro_exit_${__MACRO__} `__macro_exit_${__MACRO__}_${__FILE__}_${__LINE__}`
!define __set_error_${__MACRO__} `__set_error_${__MACRO__}_${__FILE__}_${__LINE__}`
!define __set_ok_${__MACRO__} `__set_ok_${__MACRO__}_${__FILE__}_${__LINE__}`
	push $R1
   !insertmacro nsGetCtrlText "${SVC_EDIT}" "can not get service name"
   /*we store the R0 to R1 for it will give */
   StrCpy $R1 $R0 
   ${If} $R1 == "error"
      goto ${__set_error_${__MACRO__}}
   ${EndIf}

   !insertmacro nsValidCharacter $R1 "service name include not [a-zA-Z0-9_] bytes"
   ${If} $R0 <> "0"
   		 goto ${__set_error_${__MACRO__}}
   ${EndIf}

   /*copy the value store*/
   StrCpy $gSvcName $R1
   goto ${__set_ok_${__MACRO__}}
${__set_ok_${__MACRO__}}:
	StrCpy $R0 "0"
	goto ${__macro_exit_${__MACRO__}}

${__set_error_${__MACRO__}}:
	StrCpy $R0 "-1"
	goto ${__macro_exit_${__MACRO__}}
${__macro_exit_${__MACRO__}}:
	pop $R1

!undef __set_error_${__MACRO__}
!undef __set_ok_${__MACRO__}
!undef __macro_exit_${__MACRO__}
!macroend



!endif /*__NS_VALID_NSH__*/