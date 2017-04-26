
Option Explicit


Function FormatBatch(basedir,compiletarget,slnfile,target,fname,vsver)
	dim fso,fh,cmdline
	set fso = WScript.CreateObject("Scripting.FileSystemObject")
	set fh = fso.CreateTextFile(fname,True)

	if vsver = "12.0" or vsver = "14.0" Then
		cmdline = "call " & chr(34) & basedir & "\VC\vcvarsall.bat" & chr(34) & " " & compiletarget
		fh.WriteLine(cmdline)
		cmdline = chr(34) & basedir & "\Common7\IDE\devenv.exe" & chr(34) & " " & chr(34) & slnfile & chr(34) & " /useenv /build "  & chr(34) & target & chr(34) 
		fh.WriteLine(cmdline)
	Else
		if compiletarget = "amd64"  Then
			cmdline = "call " & chr(34) & basedir & "\VC\Auxiliary\Build\vcvarsall.bat" & chr(34) & " x64"
			fh.Writeline(cmdline)
			cmdline = chr(34) & basedir & "\Common7\IDE\devenv.exe" & chr(34) & " " & chr(34) & slnfile & chr(34) & " /useenv /build " & chr(34) & target & chr(34)
			fh.Writeline(cmdline)
		Elseif compiletarget = "amd64_x86" Then
			cmdline = "call " & chr(34) & basedir & "\VC\Auxiliary\Build\vcvarsall.bat" & chr(34) & " x64_x86"
			fh.Writeline(cmdline)
			cmdline = chr(34) & basedir & "\Common7\IDE\devenv.exe" & chr(34) & " " & chr(34) & slnfile & chr(34) & " /useenv /build " & chr(34) & target & chr(34)
			fh.Writeline(cmdline)
		Else
			Wscript.Stderr.Writeline("not supported compiletarget["& compiletarget &"]")
		End If
	End If
	fh.Close
	set fh = Nothing
	set fso = Nothing
End Function


Sub includeFile(fSpec)
    With CreateObject("Scripting.FileSystemObject")
       executeGlobal .openTextFile(fSpec).readAll()
    End With
End Sub


Function GetScriptDir()
	dim fso ,scriptpath
	Set fso = CreateObject("Scripting.FileSystemObject") 
	GetScriptDir=fso.GetParentFolderName(Wscript.ScriptFullName)
End Function


call includeFile( GetScriptDir() & "\reg_op.vbs")
call includeFile( GetScriptDir() & "\vs_find.vbs")
call includeFile( GetScriptDir() & "\base_func.vbs")

dim targets(),models(),sln

Function Usage(ec,fmt)
	dim fh
	set fh = WScript.Stderr
	if ec = 0 Then
		set fh = WScript.Stdout
	End if

	if fmt <> "" Then
		fh.Writeline(fmt)
	End if
	fh.Writeline(WScript.ScriptName & " [OPTIONS]")
	fh.Writeline(chr(9) &"-h|--help                to display this information")
	fh.Writeline(chr(9) &"-s|--sln slnfile         to specify the sln file name")
	fh.Writeline(chr(9) &"-t|--target target  model   to specify target in sln file")
	WScript.Quit(ec)
End Function

Function ParseArgs(args)
	dim i,j,unum
	j = UBound(args)
	i = 0
	While i < j
		if args(i) = "-h" or  args(i) = "--help" Then
		       Usage 0,""
		elseif args(i) = "-s" or args(i) = "--sln" Then
			if (i+1) = j Then
				Usage 3,args(i) &" need an arg"
			End If

			sln = args((i + 1))
			i = i + 1
		elseif args(i) = "-t" or args(i) = "--target" Then
			if (i+2) = j Then
				Usage 3,args(i) &" need an arg"
			End If
			On error resume next
			Err.Number = 0
			unum = Ubound(targets)
			if Err.Number <> 0 Then
				unum = 0
			End If
			On error goto 0
			WScript.Stdout.Writeline("targets "& unum)
			unum = unum + 1
			redim preserve targets(unum)
			targets((unum-1)) = args((i + 1))
			WScript.Stdout.Writeline("target add("& targets((unum-1)) &")")
			i = i + 1
			
			On error resume next
			Err.Number = 0
			unum = Ubound(models)
			if Err.Number <> 0 Then
				unum = 0
			End If
			On error goto 0
			WScript.Stdout.Writeline("models "& unum)
			unum = unum + 1
			redim preserve models(unum)
			models((unum-1)) = args((i + 1))
			WScript.Stdout.Writeline("model add("& models((unum-1)) &")")
			i = i + 1
		End if
		i = i + 1
	Wend
End Function

Function ReplaceString(s,o,p)
	dim sarr,i,repl,c
	sarr=Split(s,"")
	repl=""
	for  i=0 to  len(s)
		c=Right(left(s,i),1)
		if c = o Then
			repl = repl & p
		else 
			repl = repl & c
		End If
	Next

	ReplaceString=repl
End Function


dim args(),num,i
num = WScript.Arguments.Count()

if num = 0 Then
	Usage 3,"need args"
End if

redim args(num)

for i=0 to (num - 1)
	args(i) = WScript.Arguments.Item(i)
next

ParseArgs(args)


dim basedir,vsver,vspdir,iidx,jidx

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

iidx=0

do while iidx < Ubound(targets)
	dim d,m,fname
	if targets(iidx) <> "" Then
		d = targets(iidx)
		m = models(iidx)
		fname = ReplaceString(d,"|","_")
		fname = fname & ".bat"
		wscript.stderr.writeline("fname " & fname)
		call FormatBatch(basedir,m, sln, d, fname,vsver)
		call RunCommand(fname)
	End If
	iidx = iidx + 1
Loop

