
Option Explicit

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
call includeFile( GetScriptDir() & "\vs_cmake.vbs")

Function CmakeRun(platform,srcdir,dstdir,args)
	dim cmd,retdir,curd,absdst,abssrc,unum
	retdir = GetCwd()
	abssrc = GetAbsPath(srcdir)
	absdst = GetAbsPath(dstdir)
	cmd = "cmake  -G " & chr(34) & platform & chr(34)
	On error resume next
	Err.Number = 0
	unum = Ubound(args)
	if Err.Number <> 0 Then
		unum = 0
	else
		for each  unum in args
			If unum <> "" Then
				cmd = cmd & " " & chr(34) & unum & chr(34)
			End If
		Next
	End If

	' to add the src dir
	cmd = cmd & " " & chr(34) & abssrc & chr(34)
	' now change directory
	cmd = "cmd.exe /C " & cmd
	Chdir(absdst)
	wscript.stdout.writeline("cmd (" & cmd &")")
	RunCommand(cmd)
	Chdir(retdir)
End Function


Function Usage(ec,fmt)
	dim fh
	set fh = WScript.Stderr
	if ec = 0 Then
		set fh = WScript.Stdout
	End if

	if fmt <> "" Then
		fh.Writeline(fmt)
	End if
	fh.Writeline(WScript.ScriptName & " [OPTIONS] -- [CMAKE_OPTIONS]")
	fh.Writeline(chr(9) &"-h|--help                    to display this information")
	fh.Writeline(chr(9) &"-d|--dir directory        to specify the directory running cmake")
	fh.Writeline(chr(9) &"-s|--source directory  to specify the source directory")
	fh.Writeline(chr(9) &"-a|--arch arch            to specify arch it can accept(x64|x86)")
	fh.Writeline(chr(9) &"--                                to stop parse args ,next is for cmake")
	WScript.Quit(ec)
End Function

dim cmakedir,sourcedir,cmakearch
dim cmakeargs()

sourcedir="."
cmakedir=""
cmakearch="x86"
Function ParseArgs(args)
	dim i,j,unum
	j = UBound(args)
	i = 0
	do While i < j
		if args(i) = "-h" or  args(i) = "--help" Then
		       Usage 0,""
		elseif args(i) = "-d" or args(i) = "--dir" Then
			if (i+1) = j Then
				Usage 3,args(i) &" need an arg"
			End If

			cmakedir = args((i + 1))
			i = i + 1
		elseif args(i) = "-s" or args(i) = "--source" Then
			if (i+1) = j Then
				Usage 3,args(i) &" need an arg"
			End If
			sourcedir = args((i + 1))
			i = i + 1
		elseif args(i) = "-a" or args(i) = "--arch" Then
			if (i+1) = j Then
				Usage 3,args(i) &" need an arg"
			End If
			cmakearch = args((i + 1))
			i = i + 1
		elseif args(i) = "--" Then
			' we skip this 
			i = i + 1
			while i < j 
				On error resume next
				Err.Number = 0
				unum = Ubound(cmakeargs)
				if Err.Number <> 0 Then
					unum = 0
				End If
				On error goto 0
				unum = unum + 1
				redim preserve cmakeargs(unum)
				cmakeargs((unum-1)) = args((i))
				i = i + 1				
			Wend
			exit do
		End if
		i = i + 1
	Loop

	On error resume next
	Err.Number = 0
	unum = Ubound(cmakeargs)
	if Err.Number <> 0 Then
		unum = 0
		wscript.stdout.writeline("cmakeargs 0")
	else
		wscript.stdout.write("cmakeargs:")
		for each  unum in cmakeargs
		wscript.stdout.write(" " & unum)
		Next
		wscript.stdout.writeline("")
	End If

	if cmakedir  = "" Then
		wscript.stderr.writeline("must specify cmakedir by(-d|--dir)")
		wscript.quit(4)
	End If
End Function




dim args(),num,i,vsver,vspdir,basedir,vscmake,platform
num = WScript.Arguments.Count()

if num = 0 Then
	Usage 3,"need args"
End if

redim args(num)

for i=0 to (num - 1)
	args(i) = WScript.Arguments.Item(i)
next

ParseArgs(args)


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

wscript.stdout.writeline("basedir ("& basedir & ")")

set vscmake = new VSCMakePlatform
if cmakearch = "x64" Then
	platform = vscmake.GetPlatform(vsver,1)
Else
	platform = vscmake.GetPlatform(vsver,0)
End If

wscript.stdout.writeline("Get Platform (" & platform &")")

call CmakeRun(platform, sourcedir,cmakedir,cmakeargs)

