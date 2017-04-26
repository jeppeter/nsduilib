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


call includeFile( GetScriptDir() & "\base_func.vbs")
call includeFile( GetScriptDir() & "\reg_op.vbs")
call includeFile( GetScriptDir() & "\vs_find.vbs")

Function RemoveTmpExpr(tmpdir,expr_re1)
	dim re
	dim curfile
	dim listfiles
	dim sarr
	dim matched,results,a
	dim expr_re
	dim curdir
	expr_re = expr_re1
	set re = new regexp
	re.Pattern = expr_re
	listfiles=ReadDirAll(tmpdir)
	sarr=Split(listfiles,";")
	For Each curfile in sarr
		matched = 0
		set results = re.Execute(curfile)
		For Each a in results
			matched  =1
		Next

		If matched <> 0 Then
			WScript.Stdout.Writeline("match (" & expr_re & ") ("& curfile &")"  )
			RemoveDir(curfile)
		End If
	Next
End Function

Function RemoveNpm(tmpdir)
	RemoveTmpExpr tmpdir,"npm(-[a-fA-F0-9]+)+"
End Function

Function RemoveGoBuild(tmpdir)
	RemoveTmpExpr tmpdir,"go-build([a-fA-F0-9]+)"
End Function
dim tmpdirs,tmparrs
dim curtmp

tmpdirs=GetEnv("TEMP")
tmparrs=Split(tmpdirs,";")

For Each curtmp in tmparrs
	RemoveNpm(curtmp)
	RemoveGoBuild(curtmp)
Next
