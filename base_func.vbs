

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
			curbase = "0"
		Else
			curbase = basearr(i)
		End If

		If i > cmplen Then
			curcmp = "0"
		Else
			curcmp = cmparr(i)
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
    Do While Not execobj.Stdout.AtEndOfStream
        line = execobj.Stdout.ReadLine()

        Execute("retval = " & filterfunc & "(line," & filterctx & ")")      
        If retval Then
            retline = retline & line & chr(13) & chr(10)
        End If
    Loop
    GetRunOut=retline
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

	ReadDir=retfiles
End Function

