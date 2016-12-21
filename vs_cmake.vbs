Class VSCMakePlatform
	Public Function GetPlatform(vsver,isamd64)
		dim retstr
		if vsver = "14.0" Then
			retstr="Visual Studio 14 2015"
			if isamd64 Then
				retstr= retstr & " Win64"
			End If
		elseif vsver = "12.0" Then
			retstr="Visual Studio 12 2013"
			if isamd64 Then
				retstr= retstr & " Win64"
			End If
		else
			retstr=Empty
		End If
		GetPlatform=retstr
	End Function
End Class
