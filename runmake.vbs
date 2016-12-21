

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

vsver=IsInstallVisualStudio(10.0,"SOFTWARE\Microsoft\VisualStudio")
if IsEmpty(vsver) Then
	wscript.stderr.writeline("Please Install visual studio new version than 14.0")
	WScript.Quit(3)
End If

vspdir=ReadReg("HKEY_CURRENT_USER\SOFTWARE\Microsoft\VisualStudio\"& vsver &"_Config\InstallDir")
if IsEmpty(vspdir) Then
	wscript.stderr.writeline("can not find visual studio install directory")
	wscript.quit(4)
End If

basedir=FindoutInstallBasedir(vspdir,vsver)
if basedir = "" Then
	wscript.stderr.writeline("can not find visual studio install directory on " & vspdir)
	wscript.quit(5)
End If

dim nmakeexe,cmd,makefile,makedep
dim args(),num,i
dim dt ,timestamp,version


nmakeexe=basedir+"\VC\bin\nmake.exe"
wscript.echo ("basedir (" & basedir & ") nmake (" & nmakeexe & ")")

' to format the command
num = WScript.Arguments.Count()

if num < 2 Then
	wscript.stderr.write("runmake.vbs makefile makedep" & chr(13) & chr(10))
	wscript.quit(4)
End if
makefile=wscript.Arguments(0)
makedep=wscript.Arguments(1)

call CheckVariable("INST_OS")
call CheckVariable("INST_ARCH")
call CheckVariable("VC_SETVAR_ARCH")

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

call SetEnv("TIMESTAMP_COMPILE",timestamp)

call CheckVariable("TIMESTAMP_COMPILE")
version=GetAppVersion("VERSION")
call SetEnv("APP_VERSION",version)
call CheckVariable("APP_VERSION")

cmd=chr(34) & nmakeexe & chr(34) & "  /f " &  chr(34) &  makefile & chr(34) & " "  &  chr(34) &  makedep & chr(34)
RunCommand(cmd)



