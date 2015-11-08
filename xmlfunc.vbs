Option Explicit

Function XmlSetValueChilds(parent,xpath,value)
	dim nodes,nd
	set nodes = parent.selectNodes(xpath)
	for each nd in nodes
		nd.text = value
	Next
End Function


Function XmlFindValueNode(parent,xpath,attrname,regexp)
	dim nodes,nd,attrval
	set nodes = parent.selectNodes(xpath)
	set XmlFindValueNode=Nothing
	For Each nd in nodes
		attrval = nd.getAttribute(attrname)
		if regexp.Test(attrval) Then
		set XmlFindValueNode=nd
		Exit Function
		End If
	Next
End Function

Function GetXmlns(xmldom)
	dim root,attrname,attrval
	set root = xmldom.documentElement
	GetXmlns= root.getAttribute("xmlns")
End Function

Function CreateIfNoElement(xmldom,parent,nodename)
	dim chlds,nd
	For Each nd in parent.childnodes
		if nd.nodename = nodename Then			
			set CreateIfNoElement=nd
			Exit Function
		End If
	Next
	set nd=xmldom.createNode(1, nodename,GetXmlns(xmldom))
	parent.appendChild(nd)
	set CreateIfNoElement=nd
End Function

Function SetPreCompileValue(xmldom,filename,value)
	dim fnnode,nd,reg,root
	set reg = new regexp

	reg.IgnoreCase = true
	reg.Pattern = filename &"$"

	set root = xmldom.documentElement
	set fnnode = XmlFindValueNode(root,"//Project/ItemGroup/ClCompile","Include",reg)
	if fnnode is Nothing Then
		Wscript.StdErr.WriteLine("can not find (" & filename & ")")
		wscript.Quit(3)
	Else
		set nd=CreateIfNoElement(xmldom,fnnode,"PrecompiledHeader")
		nd.text = value
		SetPreCompileValue=0
	End If	
End Function

