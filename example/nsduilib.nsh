!ifndef __NS_DUILIB_NSH__
!define __NS_DUILIB_NSH__

!include "format.nsh"


!macro ExistControl _ctlname
!define __macro_exit_${__MACRO__} `__macro_exit_${__MACRO__}_${__FILE__}_${__LINE__}`
!define __set_error_${__MACRO__} `__set_error_${__MACRO__}_${__FILE__}_${__LINE__}`
!define __set_ok_${__MACRO__} `__set_ok_${__MACRO__}_${__FILE__}_${__LINE__}`
	
	push $R1
	nsduilib::FindControl "${_ctlname}"
	pop $R1

	${If} $R1 == "-1"
		push ""
		push "${_ctlname}"
		push "无法找到控件(%s)"
		!insertmacro FormatString $R1
		!insertmacro AbortMessage $R1
		goto ${__set_error_${__MACRO__}}
	${EndIf}
	goto ${__set_ok_${__MACRO__}}

${__set_ok_${__MACRO__}}:
	StrCpy $R0 "0"
	goto ${__macro_exit_${__MACRO__}}

${__set_error_${__MACRO__}}:
	StrCpy $R0 "-1"
	goto ${__macro_exit_${__MACRO__}}

${__macro_exit_${__MACRO__}}:
	pop $R1

!undef __set_ok_${__MACRO__}
!undef __set_error_${__MACRO__}
!undef __macro_exit_${__MACRO__}
!macroend

!macro BindControlFunction _ctlname _fnname
!define __macro_exit_${__MACRO__}  `__macro_exit_${__MACRO__}_${__FILE__}_${__LINE__}`
!define __set_error_${__MACRO__} `__set_error_${__MACRO__}_${__FILE__}_${__LINE__}`
!define __set_ok_${__MACRO__} `__set_ok_${__MACRO__}_${__FILE__}_${__LINE__}`


	push $0

	!insertmacro ExistControl "${_ctlname}"

	${If} $R0 != "0"
		goto ${__set_error_${__MACRO__}}
	${EndIf}

	GetFunctionAddress $0 "${_fnname}"
	nsduilib::OnControlBindNSISScript "${_ctlname}" $0
	goto ${__set_ok_${__MACRO__}}

${__set_ok_${__MACRO__}}:
	StrCpy $R0 "0"
	goto ${__macro_exit_${__MACRO__}}

${__set_error_${__MACRO__}}:
	StrCpy $R0 "-1"
	goto ${__macro_exit_${__MACRO__}}

${__macro_exit_${__MACRO__}}:
	pop $0

!undef __set_ok_${__MACRO__}
!undef __set_error_${__MACRO__}
!undef __macro_exit_${__MACRO__}
!macroend

!macro ShowLicense _licctl _licfile
!define __macro_exit_${__MACRO__}  `__macro_exit_${__MACRO__}_${__FILE__}_${__LINE__}`
!define __set_error_${__MACRO__} `__set_error_${__MACRO__}_${__FILE__}_${__LINE__}`
!define __set_ok_${__MACRO__} `__set_ok_${__MACRO__}_${__FILE__}_${__LINE__}`

	!insertmacro ExistControl "${_licctl}"
	${If} $R0 <> "0"
		goto ${__set_error_${__MACRO__}}
	${EndIf}
	nsduilib::ShowLicense "${_licctl}" "${_licfile}"
	pop $R0
	${If} $R0 <> "0"
		push ""
		push "${_licfile}"
		push "无法找到授权文件(%s)"
		!insertmacro FormatString $R0
		!insertmacro AbortMessage $R0
		goto ${__set_error_${__MACRO__}}
	${EndIf}
	goto ${__set_ok_${__MACRO__}}

${__set_ok_${__MACRO__}}:
	StrCpy $R0 "0"
	goto ${__macro_exit_${__MACRO__}}

${__set_error_${__MACRO__}}:
	StrCpy $R0 "-1"
	goto ${__macro_exit_${__MACRO__}}

${__macro_exit_${__MACRO__}}:

!undef __set_ok_${__MACRO__}
!undef __set_error_${__MACRO__}
!undef __macro_exit_${__MACRO__}
!macroend

!macro SetControlText _ctlname _ctltext
!define __macro_exit_${__MACRO__}  `__macro_exit_${__MACRO__}_${__FILE__}_${__LINE__}`
!define __set_error_${__MACRO__} `__set_error_${__MACRO__}_${__FILE__}_${__LINE__}`
!define __set_ok_${__MACRO__} `__set_ok_${__MACRO__}_${__FILE__}_${__LINE__}`

	!insertmacro ExistControl "${_ctlname}"
	${If} $R0 <> "0"
		goto ${__set_error_${__MACRO__}}
	${EndIf}
	nsduilib::SetControlData "${_ctlname}"  "${_ctltext}" "text"
	goto ${__set_ok_${__MACRO__}}

${__set_ok_${__MACRO__}}:
	StrCpy $R0 "0"
	goto ${__macro_exit_${__MACRO__}}

${__set_error_${__MACRO__}}:
	StrCpy $R0 "-1"
	goto ${__macro_exit_${__MACRO__}}

${__macro_exit_${__MACRO__}}:

!undef __set_ok_${__MACRO__}
!undef __set_error_${__MACRO__}
!undef __macro_exit_${__MACRO__}
!macroend

!macro SetControlSelect _ctlname _sel
!define __macro_exit_${__MACRO__}  `__macro_exit_${__MACRO__}_${__FILE__}_${__LINE__}`
!define __set_error_${__MACRO__} `__set_error_${__MACRO__}_${__FILE__}_${__LINE__}`
!define __set_ok_${__MACRO__} `__set_ok_${__MACRO__}_${__FILE__}_${__LINE__}`

	!insertmacro ExistControl "${_ctlname}"
	${If} $R0 <> "0"
		goto ${__set_error_${__MACRO__}}
	${EndIf}
	nsduilib::TBCIASendMessage "0" "WM_TBCIASETSTATE" "${_ctlname}"  "${_sel}"
	goto ${__set_ok_${__MACRO__}}

${__set_ok_${__MACRO__}}:
	StrCpy $R0 "0"
	goto ${__macro_exit_${__MACRO__}}

${__set_error_${__MACRO__}}:
	StrCpy $R0 "-1"
	goto ${__macro_exit_${__MACRO__}}

${__macro_exit_${__MACRO__}}:

!undef __set_ok_${__MACRO__}
!undef __set_error_${__MACRO__}
!undef __macro_exit_${__MACRO__}

!macroend

!macro StartInstall _ctlname
!define __macro_exit_${__MACRO__}  `__macro_exit_${__MACRO__}_${__FILE__}_${__LINE__}`
!define __set_error_${__MACRO__} `__set_error_${__MACRO__}_${__FILE__}_${__LINE__}`
!define __set_ok_${__MACRO__} `__set_ok_${__MACRO__}_${__FILE__}_${__LINE__}`

	!insertmacro ExistControl "${_ctlname}"
	${If} $R0 <> "0"
		goto ${__set_error_${__MACRO__}}
	${EndIf}
	nsduilib::StartInstall "${_ctlname}"
	goto ${__set_ok_${__MACRO__}}

${__set_ok_${__MACRO__}}:
	StrCpy $R0 "0"
	goto ${__macro_exit_${__MACRO__}}

${__set_error_${__MACRO__}}:
	StrCpy $R0 "-1"
	goto ${__macro_exit_${__MACRO__}}

${__macro_exit_${__MACRO__}}:

!undef __set_ok_${__MACRO__}
!undef __set_error_${__MACRO__}
!undef __macro_exit_${__MACRO__}
!macroend


!macro StartUninstall _ctlname
!define __macro_exit_${__MACRO__}  `__macro_exit_${__MACRO__}_${__FILE__}_${__LINE__}`
!define __set_error_${__MACRO__} `__set_error_${__MACRO__}_${__FILE__}_${__LINE__}`
!define __set_ok_${__MACRO__} `__set_ok_${__MACRO__}_${__FILE__}_${__LINE__}`

	!insertmacro ExistControl "${_ctlname}"
	${If} $R0 <> "0"
		goto ${__set_error_${__MACRO__}}
	${EndIf}
	nsduilib::StartUninstall "${_ctlname}"
	goto ${__set_ok_${__MACRO__}}

${__set_ok_${__MACRO__}}:
	StrCpy $R0 "0"
	goto ${__macro_exit_${__MACRO__}}

${__set_error_${__MACRO__}}:
	StrCpy $R0 "-1"
	goto ${__macro_exit_${__MACRO__}}

${__macro_exit_${__MACRO__}}:

!undef __set_ok_${__MACRO__}
!undef __set_error_${__MACRO__}
!undef __macro_exit_${__MACRO__}

!macroend

!macro SetBkImage _ctlname _imgname
!define __macro_exit_${__MACRO__}  `__macro_exit_${__MACRO__}_${__FILE__}_${__LINE__}`
!define __set_error_${__MACRO__} `__set_error_${__MACRO__}_${__FILE__}_${__LINE__}`
!define __set_ok_${__MACRO__} `__set_ok_${__MACRO__}_${__FILE__}_${__LINE__}`

	!insertmacro ExistControl "${_ctlname}"
	${If} $R0 <> "0"
		goto ${__set_error_${__MACRO__}}
	${EndIf}
	nsduilib::SetControlData "${_ctlname}" "${_imgname}" "bkimage"
	goto ${__set_ok_${__MACRO__}}

${__set_ok_${__MACRO__}}:
	StrCpy $R0 "0"
	goto ${__macro_exit_${__MACRO__}}

${__set_error_${__MACRO__}}:
	StrCpy $R0 "-1"
	goto ${__macro_exit_${__MACRO__}}

${__macro_exit_${__MACRO__}}:

!undef __set_ok_${__MACRO__}
!undef __set_error_${__MACRO__}
!undef __macro_exit_${__MACRO__}

!macroend

!macro nsGetCtrlText _ctlname _errmsg
	nsduilib::GetControlData "${_ctlname}" "text"
	pop $R0
	${If} $R0 == "error"
		MessageBox MB_OK "${_errmsg}"
		StrCpy $R0 "error"
	${EndIf}
!macroend

!macro nsValidCharacter _str _errmsg
	nsduilib::VerifyCharaters "${_str}"
	pop $R0
	${If} $R0 <> "0"
		MessageBox MB_OK "${_errmsg}"
		StrCpy $R0 "-1"
	${EndIf}
!macroend

!macro nsSetIconImage _imgname
	nsduilib::SetIconImage "${_imgname}"
	pop $R0
!macroend

!endif # __NS_DUILIB_NSH__