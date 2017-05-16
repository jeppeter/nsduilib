

Option Explicit

Sub includeFile(fSpec)
    With CreateObject("Scripting.FileSystemObject")
       executeGlobal .openTextFile(fSpec).readAll()
    End With
End Sub

Function GetAppVersion(fname)
	dim objFSO,objReadFile,content
	Set objFSO = CreateObject("Scripting.FileSystemObject")
	Set objReadFile = objFSO.OpenTextFile(fname, 1, False)
	content = objReadFile.ReadAll
	content = Replace(content, vbCr, "")
	content = Replace(content, vbLf, "")	
	GetAppVersion=content
End Function


dim basedir,vsver,vspdir,iidx,jidx

Function GetScriptDir()
	dim fso ,scriptpath
	Set fso = CreateObject("Scripting.FileSystemObject") 
	GetScriptDir=fso.GetParentFolderName(Wscript.ScriptFullName)
End Function


call includeFile( GetScriptDir() & "\reg_op.vbs")
call includeFile( GetScriptDir() & "\vs_find.vbs")
call includeFile( GetScriptDir() & "\base_func.vbs")

Function Usage(ec,fmt)
    dim fh
    set fh = WScript.Stderr
    if ec = 0 Then
        set fh = WScript.Stdout
    End if

    if fmt <> "" Then
        fh.Writeline(fmt)
    End if
    fh.Writeline(WScript.ScriptName & " [OPTIONS] [FILE] [TARGETS]...")
    fh.Writeline(chr(9) &"-h|--help                    to display this information")
    fh.Writeline(chr(9) &"-t|--timestamp ENVVAR        to set timestamp in the environment value")
    fh.Writeline(chr(9) &"-c|--check ENVVAR            to check environment value set")
    fh.Writeline(chr(9) &"-V|--versionvar ENVVAR       to set version variable")
    fh.Writeline(chr(9) &"-v|--var var=cc              to set variable ")
    fh.Writeline(chr(9) &"--vcmode vcmode              to set vcmode [amd64|x86|x86_amd64|x86_arm] default(amd64)")
    fh.Writeline(chr(9) &"-N|--novc                    to not set vcmode default(False)")
    fh.Writeline(chr(9) &"-R|--reserve                 to make reserve mode")
    fh.Writeline(chr(9) &"[FILE]                       file of makefile")
    fh.Writeline(chr(9) &"[TARGETS]...                 target to compile")
    WScript.Quit(ec)
End Function

Function ParseArgs(args)
	dim i
	dim max
	dim argobj
	max = Ubound(args)
	set argobj = new DictObject
	argobj.Add "vcmode","amd64"
	argobj.Add "novc",False
	argobj.Add "reserve",False
	i = 0
	Do While i < max
		if args(i) = "-h" or args(i) = "--help" Then
			Usage 0, ""
		Elseif args(i) = "-t" or args(i) = "--timestamp" Then
			If (i+1) >= max Then
				Usage 3,args(i) & " need arg"
			End If
			argobj.Add "timestamp",args(i+1)
			i = i + 1
		Elseif args(i) = "-c" or args(i) = "--check" Then
			If (i+1) >= max Then
				Usage 3,args(i) & " need arg"
			End If
			argobj.Append "check",args(i+1)
			i = i + 1
		Elseif args(i) = "-V" or args(i) = "--versionvar" Then
			If (i+1) >= max Then
				Usage 3,args(i) & " need arg"
			End If
			argobj.Add "versionvar",args(i+1)
			i = i + 1
		Elseif args(i) = "-v" or args(i) = "--var" Then
			If (i+1) >= max Then
				Usage 3,args(i) & " need arg"
			End If
			If not StrHasChar(args(i+1),"=") Then
				Usage 4,args(i+1) & " not has = in char"
			End If
			argobj.Append "vars",args(i+1)
			i = i + 1
		Elseif args(i) = "--vcmode" Then
			If (i+1) >= max Then
				Usage 3,args(i) & " need arg"
			End If
			If args(i+1) = "amd64" or args(i+1) = "x86" or _
				args(i+1) = "x86_amd64" or args(i+1) = "x86_arm" Then
				argobj.Add "vcmode",args(i+1)
			Else
				Usage 5,args(i) & " not in [amd64|x86|x86_arm|x86_amd64]"
			End If
			i = i + 1
		Elseif args(i) = "-N" or args(i) = "--novc" Then
			argobj.Add "novc",True
		Elseif args(i) = "-R" or args(i) = "--reserve" Then
			argobj.Add "reserve",True
		Else
			Exit Do
		End If
		i = i + 1
	Loop

	do While i < max
		if StrHasChar(args(i),"=") Then
			argobj.Append "vars",args(i)
		Else
			argobj.Append "args",args(i)
		End If
		i = i + 1
	Loop
	set ParseArgs=argobj
End Function

Function GetNmakeCommand(argobj)
	dim cmd,temparr1,j,jmax
	cmd = "nmake.exe"
	If argobj.Exists("vars") Then
		set temparr1 = argobj.Value("vars")
		j = 0
		jmax = temparr1.Size()
		Do While j < jmax
			cmd = cmd & " " & chr(34) & temparr1.GetItem(j) & chr(34)
			j = j + 1
		Loop
	End If
	GetNmakeCommand=cmd
End Function


dim num,i,argobj,j,jmax
dim tmparr1
num = WScript.Arguments.Count()

if num = 0 Then
    Usage 3,"need args"
End if

redim args(num)

for i=0 to (num - 1)
    args(i) = WScript.Arguments.Item(i)
next

set argobj = ParseArgs(args)


vsver=IsInstallVisualStudio(10.0)
If IsEmpty(vsver) Then
    wscript.stderr.writeline("can not find visual studio installed")
    wscript.Quit(3)
End If
basedir=GetVisualStudioInstdir(10.0)
if IsEmpty(basedir) Then
	wscript.stderr.writeline("can not find visual studio install directory")
	wscript.quit(5)
End If

dim nmakeexe,cmd,makefile,makedep
dim dt ,timestamp,version
dim runcon,tempfile

nmakeexe = GetNmake(basedir,vsver)
if IsEmpty(nmakeexe) Then
	Wscript.Stderr.Writeline("can not get nmake")
	Wscript.Quit(7)
End If

wscript.echo ("basedir (" & basedir & ") nmake (" & nmakeexe & ")")

If argobj.Exists("check") Then
	dim arrobj
	set arrobj = argobj.Value("check")
	i = 0
	num = arrobj.Size()
	Do While i < num
		call CheckVariable(arrobj.GetItem(i))
		i = i + 1
	Loop
End If

If argobj.Exists("timestamp") Then
	dt=now
	timestamp = year(dt)
	if len(month(dt)) < 2  Then
		timestamp = timestamp & "0" & month(dt)
	else
		timestamp = timestamp & month(dt)
	End IF

	if len(day(dt)) < 2 Then
		timestamp = timestamp & "0" & day(dt)
	else
		timestamp = timestamp & day(dt)
	End If

	call SetEnv(argobj.Value("timestamp"),timestamp)
End If

if argobj.Exists("versionvar") Then
	version=GetAppVersion("VERSION")
	call SetEnv(argobj.Value("versionvar"),version)
End If

If argobj.Value("novc") Then
	if argobj.Exists("vars") Then
		dim temparr1
		dim curvar
		dim curkey,curval
		dim arr1
		set temparr1 = argobj.Value("vars")
		j = 0
		jmax = temparr1.Size()
		Do While j < jmax
			curvar = temparr1.GetItem(j)
			arr1=Split(curvar,"=")
			curkey=arr1(0)
			curval=arr1(1)
			SetEnv curkey,curval
			j = j + 1
		Loop
	End If


	if argobj.Exists("args") Then
		set arrobj = argobj.Value("args")
		makefile=arrobj.GetItem(0)
		if arrobj.Size() >= 2 Then
			i = 1
			Do While i < arrobj.Size()
				cmd = GetNmake(basedir,vsver)
				cmd = chr(34) & cmd & chr(34) & " /f " & chr(34) & makefile & chr(34)
				makedep=arrobj.GetItem(i)
				cmd = cmd &  " " & chr(34) & makedep & chr(34)
				WScript.Stderr.Writeline("cmd["&cmd&"]")
				RunCommand(cmd)
				i = i + 1
			Loop
		Else
			cmd = GetNmake(basedir,vsver)
			cmd =  chr(34) & cmd & chr(34) & " /f " & chr(34) & makefile  & chr(34)
			WScript.Stderr.Writeline("cmd["&cmd&"]")
			RunCommand(cmd)
		End If
	Else
		cmd = GetNmake(basedir,vsver)
		WScript.Stderr.Writeline("cmd["&cmd&"]")
		RunCommand(cmd)
	End If
Else
	runcon = ""
	if vsver = "12.0" or vsver = "14.0" Then
		runcon = runcon & "call " & chr(34) & basedir & "\VC\vcvarsall.bat" & chr(34) & " "  & argobj.Value("vcmode")  & chr(13) & chr(10)
	Elseif vsver = "15.0" Then
		runcon = runcon & "call " & chr(34) & basedir & "\VC\Auxiliary\Build\vcvarsall.bat" & chr(34) & " " & argobj.Value("vcmode") & chr(13) & chr(10)
	Else
		Wscript.Stderr.Writeline("vsver["&vsver&"]not supported")
		Wscript.Quit(3)
	End If
	runcon = runcon & "cscript.exe //Nologo " & chr(34) & WScript.ScriptFullName & chr(34)
	runcon = runcon & " --novc"
	If argobj.Exists("timestamp") Then
		runcon = runcon & " --timestamp " & chr(34) & argobj.Value("timestamp") & chr(34)
	End If

	If argobj.Exists("check") Then
		set tmparr1 = argobj.Value("check")
		jmax = tmparr1.Size()
		j = 0
		Do While j < jmax
			runcon = runcon & " --check " & chr(34) & tmparr1.GetItem(j) & chr(34)
			j = j + 1
		Loop
	End If

	If argobj.Exists("vars") Then
		set tmparr1 = argobj.Value("vars")
		num = tmparr1.Size()
		i = 0
		Do While i < num
			runcon = runcon & " --var " & chr(34) & tmparr1.GetItem(i) & chr(34)
			i = i + 1
		Loop
	End If

	runcon = runcon & " --vcmode " & argobj.Value("vcmode")

	If argobj.Exists("args") Then
		set tmparr1 = argobj.Value("args")
		i = 0
		num = tmparr1.Size()
		Do While i < num
			runcon = runcon & " " & chr(34) & tmparr1.GetItem(i) & chr(34)
			i = i + 1
		Loop
	End If
	WScript.Stderr.Writeline("runcon [" &runcon& "]")
	tempfile=WriteTempFile(runcon,"XXXXXX.bat")
	cmd = chr(34) & tempfile & chr(34)
	WScript.Stderr.Writeline("cmd [" &cmd& "]")
	RunCommand(cmd)
	if not argobj.Value("reserve") Then
		RemoveFileSafe(tempfile)
	Else
		Wscript.Stderr.Writeline("tempfile["&tempfile&"]")
	End If
End If