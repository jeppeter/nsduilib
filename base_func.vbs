Option Explicit

Function RunCommand(cmd)
	dim objsh,res
	set objsh = wscript.CreateObject("WScript.Shell")
	res = objsh.Run(cmd,1,true)
	if res <> 0 Then
		WScript.Stderr.WriteLine("run command ("& cmd &") error ("& res &")")
		WScript.Quit(res)
	End if
End Function

Function RemoveDir(dirname)
	dim fso
	set fso =  CreateObject("Scripting.FileSystemObject")
	fso.DeleteFolder(dirname)
End Function


Function GetCwd()
	dim fso
	set fso = WScript.CreateObject("Scripting.FileSystemObject")
	GetCwd = fso.GetAbsolutePathName(".")
	set fso = Nothing
End Function

Function GetAbsPath(path)
	dim fso
	set fso = WScript.CreateObject("Scripting.FileSystemObject")
	GetAbsPath= fso.GetAbsolutePathName(path)
	set fso = Nothing
End Function

Function GetWholePath(fname)
	dim fso
	set fso = WScript.CreateObject("Scripting.FileSystemObject")
	GetWholePath = fso.GetAbsolutePathName(fname)
	set fso = Nothing
End Function

Function CheckVariable(varname)
	dim wsh,val,key
	set wsh = WScript.CreateObject("WScript.Shell")
	key = "%" & varname & "%"
	val = wsh.ExpandEnvironmentStrings(key)
	if val  = key Then
		wscript.stderr.write("variable (" + varname + ") not defined" & chr(13) & chr(10)) 
		wscript.quit(4)
	end if
End Function

Function GetEnv(varname)
	dim wsh,val,key
	set wsh = WScript.CreateObject("WScript.Shell")
	key = "%" & varname & "%"
	val = wsh.ExpandEnvironmentStrings(key)
	if val  = key Then
		GetEnv=null
	else
		GetEnv=val
	end if
End Function

Function GetTempName(pattern)
	dim fso,fname,tempdir,shell,extname,objRegEx,tempname
	set fso = CreateObject("Scripting.FileSystemObject")
	set shell = CreateObject("WScript.Shell")
	Set objRegEx =  CreateObject("VBScript.RegExp")
	objRegEx.Global = True
	objRegEx.IgnoreCase = True
	objRegEx.Pattern = "XXXXXX"
	tempdir = shell.ExpandEnvironmentStrings("%TEMP%")
	fname = fso.GetTempName()
	extname = fso.GetBaseName(fname)
	'WScript.Stderr.Writeline("extname of " & fname & "=" & extname)
	tempname = objRegEx.Replace(pattern,extname)
	If tempname = pattern Then
		tempname = fname
	End If
	GetTempName=tempdir & "\" & tempname
End Function

Function WriteTempFile(str,pattern)
	dim tempfile
	dim fso,fh
	tempfile=GetTempName(pattern)
	set fso = CreateObject("Scripting.FileSystemObject")
	set fh = fso.CreateTextFile(tempfile,True)
	fh.Write(str)
	WriteTempFile=tempfile
End Function

Function SetEnv(key,value)
	dim objShell,colprocenvars
	Set objShell = WScript.CreateObject("WScript.Shell")
	Set colprocenvars = objShell.Environment("Process")	
	colprocenvars(key) = value
End Function


Function Chdir(path)
	Dim oShell : Set oShell = CreateObject("WScript.Shell")
	oShell.CurrentDirectory = path
	set oShell=Nothing
End Function



Function FileExists(pathf)
	dim fso
	set fso = CreateObject("Scripting.FileSystemObject")
	If (fso.FileExists(pathf)) Then
		FileExists=1
	Else
		FileExists=0
	End If	
End Function

Function RemoveFileSafe(fname)
	dim fso
	set fso = CreateObject("Scripting.FileSystemObject")
	If FileExists(fname) Then
		fso.DeleteFile fname
	End If
End Function


Function FolderExists(pathd)
	dim fso
	set fso = CreateObject("Scripting.FileSystemObject")
	If (fso.FolderExists(pathd)) Then
		FolderExists=1
	Else
		FolderExists=0
	End If	
End Function


Function VersionCompare(basever,cmpver)
	dim basearr,cmparr
	dim curbase,curcmp
	dim baselen,cmplen,maxlen
	dim i
	basearr = Split(basever,".")
	cmparr = Split(cmpver,".")
	baselen = UBound(basearr)
	cmplen = UBound(cmparr)
	maxlen = baselen
	If cmplen > baselen Then
		maxlen = cmplen
	End If

	For i =0 to maxlen Step 1
		if i > baselen Then
			curbase = 0
		Else
			curbase = CInt(basearr(i))
		End If

		If i > cmplen Then
			curcmp = 0
		Else
			curcmp = CInt(cmparr(i))
		End If
		If curcmp < curbase Then
			VersionCompare=false
			Exit Function
		End If
		If curcmp > curbase   Then
			VersionCompare=true
			Exit Function
		End If
	Next

	VersionCompare=true
End Function

Function GetRunOut(exefile,commands,ByRef filterfunc,ByRef filterctx)
    dim objshell
    dim execobj
    dim cmd,line,retline,retval
    cmd = "cmd.exe /c " & chr(34) & exefile & chr(34) & " " & commands
    set objshell = WScript.CreateObject("WScript.Shell")
    set execobj = objshell.Exec(cmd)
    retline = ""
    retval=false
    Do While Not execobj.Stdout.AtEndOfStream
        line = execobj.Stdout.ReadLine()

        if not retval Then
	        Execute("retval = " & filterfunc & "(line," & filterctx & ")")      
        End If
    Loop
    if not retval Then
    	line = execobj.Stdout.ReadLine()
    	Execute("retval = " & filterfunc & "(line," & filterctx & ")")
    End If
    GetRunOut=retline
End Function


Function StrHasChar(instr,ch)
	dim xlen
	dim i
	dim curch
	xlen=Len(instr)
	For i=0 to xlen-1 
		curch=Mid(instr,i+1,1)
		if curch = ch Then
			StrHasChar=True
			exit Function
		End If
	Next
	StrHasChar=False	
End Function


Function ReadDirAll(dir)
	dim fso
	dim folder
	dim lists
	dim files,retfiles,dirs
	dim i
	dim curfile
	Set fso = CreateObject("Scripting.FileSystemObject")
	Set folder = fso.GetFolder(dir)
	set files = folder.Files
	set dirs = folder.SubFolders
    i = 0
    retfiles=""
	For Each curfile in files
		If i <> 0 Then
		       retfiles = retfiles & ";"
		End If
		retfiles = retfiles & curfile
		i = i + 1
	Next
	

	For Each curfile in dirs
		If i <> 0 Then
		       retfiles = retfiles & ";"
		End If
		retfiles = retfiles & curfile
		i = i + 1
	Next


	ReadDirAll=retfiles
End Function

Function ReadDir(dir)
	dim fso
	dim folder
	dim lists
	dim files,retfiles,dirs
	dim i
	dim curfile
	Set fso = CreateObject("Scripting.FileSystemObject")
	Set folder = fso.GetFolder(dir)
	set dirs = folder.SubFolders
    i = 0
    retfiles=""	

	For Each curfile in dirs
		If i <> 0 Then
		       retfiles = retfiles & ";"
		End If
		retfiles = retfiles & curfile
		i = i + 1
	Next


	ReadDir=retfiles
End Function


Class ArrayObject
	Private m_array()
	Public Sub Push(item)
		dim size
		dim newsize
		size = UBound(m_array)
		newsize = size + 1
		ReDim Preserve m_array(newsize)
		m_array(size)=item
	End Sub

	Public Property Get GetItem(idx)
		dim size
		size = UBound(m_array)
		If idx >= size Then
			GetItem=null
		Else
			GetItem=m_array(idx)
		End If
	End Property

	Public Property Get Size()
		Size = UBound(m_array)
	End Property

	Private Sub Class_Initialize()
		ReDim m_array(0)
	End Sub

	Private Sub Class_Terminate()
		ReDim m_array(0)
	End Sub

End Class


Class DictObject
	Private m_dict

	Public Sub Add(k,v)
		if m_dict.Exists(k) Then
			m_dict.Remove(k)
		End If
		m_dict.Add k,v
	End Sub

	Public Property Get Size()
		Size = UBound(m_dict.Keys()) + 1
	End Property

	Public Property Get Key(idx)
		dim size
		size = UBound(m_dict.Keys()) + 1
		if idx < size Then
			Key=m_dict.Keys()(idx)
		Else
			Key=null
		End If
	End Property

	Public Sub Append(key,val)
		dim obj
		if m_dict.Exists(key) Then
			m_dict.Item(key).Push(val)
		Else
			set obj = new ArrayObject
			obj.Push(val)
			m_dict.Add key,obj
		End If		
	End Sub

	

	Public Sub Delete(key)
		m_dict.remove(key)
	End Sub

	Public Property Get Exists(k)
		Exists=m_dict.Exists(k)
	End Property

	Public Property Get Value(k)
		dim obj
		On Error Resume Next
		Err.Clear
		Value=m_dict.Item(k)
		if Err.Number <> 0 Then
			set Value=m_dict.Item(k)
		End If
		On Error Goto 0
	End Property

	Private Sub Class_Initialize()
		set m_dict = CreateObject("Scripting.Dictionary")
	End Sub

	Private Sub Class_Terminate()
		set m_dict=Nothing
	End Sub

End Class

