Class VSCMakePlatform
	Public Function GetPlatform(vsver,isamd64)
		dim retstr
		if vsver = "16.0" Then
			retstr = "-G " & chr(34) & "Visual Studio 16 2019" & chr(34) & " "
			if isamd64 Then
				retstr = retstr & "-A x64"
			Else
				retstr = retstr & "-A Win32"
			End If
		elseif vsver = "15.0" Then
		    retstr="-G " & chr(34) & "Visual Studio 15 2017"
		    if isamd64 Then
		         retstr = retstr & " Win64"
		    End If
		    retstr = retstr & chr(34)
		elseif vsver = "14.0" Then
			retstr= "-G " & chr(34) &  "Visual Studio 14 2015"
			if isamd64 Then
				retstr= retstr & " Win64"
			End If
			retstr = retstr & chr(34)
		elseif vsver = "12.0" Then
			retstr="-G " & chr(34) &  "Visual Studio 12 2013"
			if isamd64 Then
				retstr= retstr & " Win64"
			End If
			retstr = retstr & chr(34)
		else
			retstr=Empty
		End If
		GetPlatform=retstr
	End Function
End Class
