Option Explicit

Const HKEY_CLASSES_ROOT = &H80000000
Const HKEY_CURRENT_USER = &H80000001
Const HKEY_LOCAL_MACHINE = &H80000002
Const HKEY_USERS = &H80000003
Const HKEY_CURRENT_CONFIG = &H80000004

Function GetRegSubkeys(root,pathkey)
	dim arraykey,objReg,retval,retarr

	set objReg = GetObject("winmgmts:{impersonationLevel=impersonate}!\\.\root\default:StdRegProv")
	err.number=0
	retval = objReg.EnumKey(root,pathkey,arraykey)
	if retval <> 0  Then
		wscript.stderr.writeline( "get "&pathkey & " error["& err.number &"]retval"&retval)
		set objReg = Nothing
		arraykey=Empty
		GetRegSubkeys=Empty
	ElseIf not IsArray(arraykey) Then
		wscript.stderr.writeline("get["&pathkey&"]ret not array("&arraykey&")")
		set objReg = Nothing
		redim retarr(0)
		retarr(0) = arraykey
		arraykey=Empty
		GetRegSubkeys=retarr
	else
		set objReg = Nothing
		GetRegSubkeys=arraykey
	End If
End Function


Function ReadReg(key)
	dim objShell,value
	Set objShell = WScript.CreateObject("WScript.Shell")
	On Error Resume Next
	Err.Number = 0
	value = objShell.RegRead(key)
	if Err.Number <> 0 Then
		Wscript.Stderr.Writeline("read["&key&"] error["&Err&"]")
		On Error goto 0
		ReadReg=Empty
	else
		On Error goto 0
		ReadReg=value
	End If
End Function

Function DeleteRegSubkeysInner(regobj,rootkey,path)
	dim arrsubkeys,key,curpath
	arrsubkeys=GetRegSubkeys(rootkey, path)
	If not IsEmpty(arrsubkeys) Then
		For Each key in arrsubkeys
			curpath = path & "\" & key
			call DeleteRegSubkeysInner(regobj, rootkey, curpath)
		Next
	End If

	regobj.DeleteKey rootkey,path
End Function

Function DeleteRegSubkeys(rootkey,path)
	dim regobj
	set regobj = GetObject("winmgmts:\\.\root\default:StdRegProv")
	call DeleteRegSubkeysInner(regobj, rootkey, path)
End Function


