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


' now we should get the verfiy


dim instdir,vsver

instdir=GetVisualStudioInstdir(10.0)
vsver=IsInstallVisualStudio(10.0)
if IsNull(instdir) Then
	Wscript.Stderr.writeline("can not find visual studio installed")
	Wscript.Quit(3)
Else
	Wscript.Stdout.writeline("install["&vsver&"]="&instdir)
End If
