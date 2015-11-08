
Option Explicit

dim stderr,stdout,fso

Set fso = CreateObject ("Scripting.FileSystemObject") 
Set stdout = fso.GetStandardStream (1) 
Set stderr = fso.GetStandardStream (2) 

Function XmlSetValueChilds(parent,xpath,value)
	dim nodes,nd
	set nodes = parent.selectNodes(xpath)
	for each nd in nodes
		nd.text = value
	Next
End Function

Function XmlGetValueChilds(parent,xpath)
	dim nodes,nd
	set nodes = parent.selectNodes(xpath)
	for each nd in nodes
		stdout.WriteLine("[" &xpath& "]="& nd.text)
	Next
End Function

Function XmlFindValueNode(parent,xpath,attrname,regexp)
	dim nodes,nd,attrval
	set nodes = parent.selectNodes(xpath)
	For Each nd in nodes
		attrval = nd.getAttribute(attrname)
		stdout.writeline("["& xpath &"]@[" & attrname & "] = " & attrval )
	Next
End Function



if wscript.Arguments.length < 1 Then
	stderr.WriteLine("build_chg.vbs vcxproj")
	wscript.Quit(4)
End If

dim xmldom,root

set xmldom = CreateObject("Microsoft.XMLDOM")

xmldom.Async = False
xmldom.Load(wscript.Arguments(0))

if xmldom.parseError.errorCode <> 0 Then
	stderr.Writeline("can not parse " & wscript.Arguments(0) & " for xml")
Else
	stdout.Writeline("parse " & wscript.Arguments(0) & " succ")
End If

set root = xmldom.documentElement

'XmlSetValue root,"/Project/ItemDefinitionGroup/ClCompile/AdditionalIncludeDirectories","","","Use"
'XmlSetValue root,"//Project/ItemGroup/ClCompile","Include","","Use"
XmlGetValueChilds root,"//Project/ItemDefinitionGroup/ClCompile/PrecompiledHeader"
XmlSetValueChilds root,"//Project/ItemDefinitionGroup/ClCompile/PrecompiledHeader","Use"
XmlGetValueChilds root,"//Project/ItemDefinitionGroup/ClCompile/PrecompiledHeader"
XmlFindValueNode root,"//Project/ItemGroup/ClCompile","Include",""
'XmlSetValue root,"//Project/ItemDefinitionGroup/ClCompile/PrecompiledHeader","PrecompiledHeader","","Use"
'XmlSetValue root,"//Project/ItemDefinitionGroup/ClCompile/PrecompiledHeader","PrecompiledHeader","","Use"
'GetChild root,"PrecompiledHeader"

