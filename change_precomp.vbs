
Option Explicit

sub includeFile (fSpec)
    dim fileSys, file, fileData
    set fileSys = createObject ("Scripting.FileSystemObject")
    set file = fileSys.openTextFile (fSpec)
    fileData = file.readAll ()
    file.close
    executeGlobal fileData
    set file = nothing
    set fileSys = nothing
end sub

dim fso ,scriptpath
Set fso = CreateObject("Scripting.FileSystemObject") 
ScriptPath = fso.GetParentFolderName(Wscript.ScriptFullName)
includeFile scriptpath & "\xmlfunc.vbs"


if wscript.Arguments.length < 1 Then
	Wscript.stderr.WriteLine("build_chg.vbs vcxproj")
	wscript.Quit(4)
End If

dim xmldom,root,reg,fnd,newelm,retval

set xmldom = CreateObject("Msxml2.DOMDocument.3.0")

xmldom.Async = False
xmldom.Load(wscript.Arguments(0))

if xmldom.parseError.errorCode <> 0 Then
	Wscript.stderr.Writeline("can not parse " & wscript.Arguments(0) & " for xml")
Else
	Wscript.stdout.Writeline("parse " & wscript.Arguments(0) & " succ")
End If


set root = xmldom.documentElement
XmlSetValueChilds root,"//Project/ItemDefinitionGroup/ClCompile/PrecompiledHeader","Use"
SetPreCompileValue xmldom,"stb_image.c","NotUsing"
SetPreCompileValue xmldom,"XUnzip.cpp","NotUsing"
SetPreCompileValue xmldom,"StdAfx.cpp","Create"


xmldom.save Wscript.Arguments(0)

