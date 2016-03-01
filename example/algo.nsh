!ifndef __NS_ALGO_NSH__
!define __NS_ALGO_NSH__


!macro CompareMustLarge _num _cmpbase _errmsg
!define __macro_exit_${__MACRO__} `__macro_exit_${__MACRO__}_${__FILE__}_${__LINE__}`
!define __set_error_${__MACRO__} `__set_error_${__MACRO__}_${__FILE__}_${__LINE__}`
	IntCmp "${_num}" "${_cmpbase}" ${__set_error_${__MACRO__}} ${__set_error_${__MACRO__}}  ${__macro_exit_${__MACRO__}}
${__set_error_${__MACRO__}}:
	!insertmacro AbortMessage "${_errmsg}"
${__macro_exit_${__MACRO__}}:

!undef __set_error_${__MACRO__}
!undef __macro_exit_${__MACRO__}
!macroend 

!macro CompareMustLess _num _cmpbase _errmsg
!define __macro_exit_${__MACRO__} `__macro_exit_${__MACRO__}_${__FILE__}_${__LINE__}`
!define __set_error_${__MACRO__} `__set_error_${__MACRO__}_${__FILE__}_${__LINE__}`
	IntCmp "${_num}" "${_cmpbase}" ${__set_error_${__MACRO__}} ${__macro_exit_${__MACRO__}} ${__set_error_${__MACRO__}}
${__set_error_${__MACRO__}}:
	!insertmacro AbortMessage "${_errmsg}"
${__macro_exit_${__MACRO__}}:

!undef __set_error_${__MACRO__}
!undef __macro_exit_${__MACRO__}
!macroend

!macro CompareMustEqualLarge _num _cmpbase _errmsg
!define __macro_exit_${__MACRO__} `__macro_exit_${__MACRO__}_${__FILE__}_${__LINE__}`
!define __set_error_${__MACRO__} `__set_error_${__MACRO__}_${__FILE__}_${__LINE__}`
	IntCmp "${_num}" "${_cmpbase}" ${__macro_exit_${__MACRO__}} ${__set_error_${__MACRO__}}  ${__macro_exit_${__MACRO__}}
${__set_error_${__MACRO__}}:
	!insertmacro AbortMessage "${_errmsg}"
${__macro_exit_${__MACRO__}}:

!undef __set_error_${__MACRO__}
!undef __macro_exit_${__MACRO__}
!macroend 


!macro CompareMustEqualLess _num _cmpbase _errmsg
!define __macro_exit_${__MACRO__} `__macro_exit_${__MACRO__}_${__FILE__}_${__LINE__}`
!define __set_error_${__MACRO__} `__set_error_${__MACRO__}_${__FILE__}_${__LINE__}`
	IntCmp "${_num}" "${_cmpbase}" ${__macro_exit_${__MACRO__}} ${__macro_exit_${__MACRO__}} ${__set_error_${__MACRO__}}
${__set_error_${__MACRO__}}:
	!insertmacro AbortMessage "${_errmsg}"
${__macro_exit_${__MACRO__}}:

!undef __set_error_${__MACRO__}
!undef __macro_exit_${__MACRO__}
!macroend


!macro CompareLarge _num _cmpbase _errmsg
!define __macro_exit_${__MACRO__} `__macro_exit_${__MACRO__}_${__FILE__}_${__LINE__}`
!define __set_error_${__MACRO__} `__set_error_${__MACRO__}_${__FILE__}_${__LINE__}`
!define __set_ok_${__MACRO__} `__set_ok_${__MACRO__}_${__FILE__}_${__LINE__}`
	IntCmp "${_num}" "${_cmpbase}" ${__set_error_${__MACRO__}} ${__set_error_${__MACRO__}}  ${__set_ok_${__MACRO__}}
${__set_ok_${__MACRO__}}:
	StrCpy $R0 "0"
	goto ${__macro_exit_${__MACRO__}}

${__set_error_${__MACRO__}}:
	MessageBox MB_OK "${_errmsg}"
	StrCpy $R0 "-1"
	goto ${__macro_exit_${__MACRO__}}
${__macro_exit_${__MACRO__}}:

!undef __set_ok_${__MACRO__}
!undef __set_error_${__MACRO__}
!undef __macro_exit_${__MACRO__}
!macroend 


!macro CompareLess _num _cmpbase _errmsg
!define __macro_exit_${__MACRO__} `__macro_exit_${__MACRO__}_${__FILE__}_${__LINE__}`
!define __set_error_${__MACRO__} `__set_error_${__MACRO__}_${__FILE__}_${__LINE__}`
!define __set_ok_${__MACRO__} `__set_ok_${__MACRO__}_${__FILE__}_${__LINE__}`
	IntCmp "${_num}" "${_cmpbase}" ${__set_error_${__MACRO__}} ${__set_ok_${__MACRO__}} ${__set_error_${__MACRO__}}
${__set_ok_${__MACRO__}}:
	StrCpy $R0 "0"
	goto ${__macro_exit_${__MACRO__}}

${__set_error_${__MACRO__}}:
	MessageBox MB_OK "${_errmsg}"
	StrCpy $R0 "-1"
	goto ${__macro_exit_${__MACRO__}}
${__macro_exit_${__MACRO__}}:

!undef __set_ok_${__MACRO__}
!undef __set_error_${__MACRO__}
!undef __macro_exit_${__MACRO__}
!macroend 


!macro CompareEqualLarge _num _cmpbase _errmsg
!define __macro_exit_${__MACRO__} `__macro_exit_${__MACRO__}_${__FILE__}_${__LINE__}`
!define __set_error_${__MACRO__} `__set_error_${__MACRO__}_${__FILE__}_${__LINE__}`
!define __set_ok_${__MACRO__} `__set_ok_${__MACRO__}_${__FILE__}_${__LINE__}`
	IntCmp "${_num}" "${_cmpbase}" ${__set_ok_${__MACRO__}} ${__set_error_${__MACRO__}}  ${__set_ok_${__MACRO__}}
${__set_ok_${__MACRO__}}:
	StrCpy $R0 "0"
	goto ${__macro_exit_${__MACRO__}}

${__set_error_${__MACRO__}}:
	MessageBox MB_OK "${_errmsg}"
	StrCpy $R0 "-1"
	goto ${__macro_exit_${__MACRO__}}
${__macro_exit_${__MACRO__}}:

!undef __set_ok_${__MACRO__}
!undef __set_error_${__MACRO__}
!undef __macro_exit_${__MACRO__}
!macroend 

!macro CompareEqualLess _num _cmpbase _errmsg
!define __macro_exit_${__MACRO__} `__macro_exit_${__MACRO__}_${__FILE__}_${__LINE__}`
!define __set_error_${__MACRO__} `__set_error_${__MACRO__}_${__FILE__}_${__LINE__}`
!define __set_ok_${__MACRO__} `__set_ok_${__MACRO__}_${__FILE__}_${__LINE__}`
	IntCmp "${_num}" "${_cmpbase}" ${__set_ok_${__MACRO__}} ${__set_ok_${__MACRO__}} ${__set_error_${__MACRO__}}
${__set_ok_${__MACRO__}}:
	StrCpy $R0 "0"
	goto ${__macro_exit_${__MACRO__}}

${__set_error_${__MACRO__}}:
	MessageBox MB_OK "${_errmsg}"
	StrCpy $R0 "-1"
	goto ${__macro_exit_${__MACRO__}}
${__macro_exit_${__MACRO__}}:

!undef __set_ok_${__MACRO__}
!undef __set_error_${__MACRO__}
!undef __macro_exit_${__MACRO__}
!macroend 



!endif /*__NS_ALGO_NSH__*/