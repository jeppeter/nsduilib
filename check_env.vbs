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

Function FilterText(line,filterctx)
    filterctx.FilterVersion(line)
    FilterText=true
End Function


Function CheckVisualStudio(basever)
    dim vsver,cmakestr
    dim vscmake
    vsver = IsInstallVisualStudio(10.0,"SOFTWARE\Microsoft\VisualStudio")
    If IsEmpty(vsver) Then
        CheckVisualStudio=false
        Exit Function
    End If
    If VersionCompare(basever,vsver) Then
        CheckVisualStudio=true
        Exit Function
    End If
    CheckVisualStudio=false
End Function

Class CmdExtractVersion
    Private m_version
    Public Function FilterVersion(line)
        dim re,result,num,a,resa,b
        set re = new regexp
        '  to get the gox.x.x version number
        re.Pattern = "\s+([0-9]+((\.[0-9]*)+))]$"
        set result = re.Execute(line)   
        num = 0
        if Not IsEmpty(result) Then
            for Each a in result
                re.Pattern = "[0-9]+((\.[0-9]*)+)"
                set resa = re.Execute(a)
                if Not IsEmpty(resa) Then
                    for Each b in resa
                        b = Trim(b)
                        m_version=b
                    Next
                End If
            Next
        End If
    End Function
    Public Function  GetVersion()
        GetVersion=m_version
    End Function
End Class

dim cmdversion

Function CheckMakePlatform(basever,is64)
    dim patharr
    dim pathval
    dim curpath
    dim curcmd
    dim curver
    dim re,result,a
    Dim process_architecture
    pathval = GetEnv("PATH")
    If IsNull(pathval) Then
        CheckMakePlatform=false
        Exit Function
    End If

    patharr = Split(pathval,";")
    For Each curpath in patharr
        If FileExists( curpath & "\" & "cmd.exe") Then
            curcmd = curpath & "\" & "cmd.exe"
            set cmdversion = new CmdExtractVersion
            call GetRunOut(curcmd,"/c ver","FilterText","cmdversion")
            WScript.Stdout.Writeline("cmd version " & cmdversion.GetVersion())
            If VersionCompare(basever,cmdversion.GetVersion()) Then
                ' now to test for the version
                curver = cmdversion.GetVersion()
                set re = new regexp
                re.Pattern = basever
                set result = re.Execute(curver)
                CheckMakePlatform=false
                For Each a in result 
                    CheckMakePlatform=true
                Next
                If Not CheckMakePlatform Then
                    Exit Function
                End If

                ' to check for the bits
                process_architecture = GetEnv("PROCESSOR_ARCHITECTURE")
                If process_architecture = "x86" Then
                    process_architecture = GetEnv("PROCESSOR_ARCHITEW6432")
                    if process_architecture <> "AMD64" Then
                        CheckMakePlatform=false
                    End If
                End If


                If not is64 Then
                    if CheckMakePlatform Then
                        CheckMakePlatform=false
                    Else
                        CheckMakePlatform=true
                    End If
                End If
            Else
                CheckMakePlatform=false
            End If
            Exit Function
        End If
    Next

    CheckMakePlatform=false
End Function

Class GolangExtractVersion
    Private m_version
    Public Function FilterVersion(line)
        dim re,result,num,a,resa,b
        set re = new regexp
        '  to get the gox.x.x version number
        re.Pattern = "go([0-9]+((.[0-9]*)+))\s+"
        set result = re.Execute(line)   
        num = 0
        if Not IsEmpty(result) Then
            for Each a in result
                re.Pattern = "[0-9]+((.[0-9]*)+)\s+"
                set resa = re.Execute(a)
                if Not IsEmpty(resa) Then
                    for Each b in resa
                        b = Trim(b)
                        m_version=b
                    Next
                End If
            Next
        End If
    End Function
    Public Function  GetVersion()
        GetVersion=m_version
    End Function
End Class


dim goversion

Function CheckGolangVersion(basever)
    dim patharr
    dim pathval
    dim curpath
    dim curgoexe
    pathval = GetEnv("PATH")
    If IsNull(pathval) Then
        CheckGolangVersion=false
        Exit Function
    End If

    patharr = Split(pathval,";")
    For Each curpath in patharr
        If FileExists( curpath & "\" & "go.exe") Then
            curgoexe = curpath & "\" & "go.exe"
            set goversion = new GolangExtractVersion
            call GetRunOut(curgoexe,"version","FilterText","goversion")
            If VersionCompare(basever,goversion.GetVersion()) Then
                CheckGolangVersion=true
            Else
                CheckGolangVersion=false
            End If
            Exit Function
        End If
    Next
    CheckGolangVersion=false
End Function


Class CMakeExtractVersion
    Private m_version
    Public Function FilterVersion(line)
        dim re,result,num,a,resa,b
        set re = new regexp
        '  
        re.Pattern = "cmake\s+version\s+([0-9]+((\.[0-9]*)+))(-[a-zA-Z0-9_])?"
        set result = re.Execute(line)   
        num = 0
        if Not IsEmpty(result) Then
            for Each a in result
                re.Pattern = "[0-9]+((\.[0-9]*)+)"
                set resa = re.Execute(a)
                if Not IsEmpty(resa) Then
                    for Each b in resa
                        b = Trim(b)
                        m_version=b
                    Next
                End If
            Next
        End If
    End Function
    Public Function  GetVersion()
        if IsEmpty(m_version) and IsNull(m_version) Then
            GetVersion="0.0.0"
        Else
            GetVersion=m_version
        End If
    End Function
End Class

dim cmakeversion


Function CheckCmakeVersion(basever)
    dim patharr
    dim pathval
    dim curpath
    dim curgoexe
    pathval = GetEnv("PATH")
    If IsNull(pathval) Then
        CheckCmakeVersion=false
        Exit Function
    End If

    patharr = Split(pathval,";")
    For Each curpath in patharr
        If FileExists( curpath & "\" & "cmake.exe") Then
            curgoexe = curpath & "\" & "cmake.exe"
            set cmakeversion = new CMakeExtractVersion
            call GetRunOut(curgoexe,"--version","FilterText","cmakeversion")
            WScript.Stdout.Writeline("cmake version " & cmakeversion.GetVersion())
            If VersionCompare(basever,cmakeversion.GetVersion()) Then
                CheckCmakeVersion=true
            Else
                CheckCmakeVersion=false
            End If
            Exit Function
        End If
    Next

    CheckCmakeVersion=false
End Function

Class NodeExtractVersion
    Private m_version
    Public Function FilterVersion(line)
        dim re,result,num,a,resa,b
        set re = new regexp
        '  
        re.Pattern = "v([0-9]+((\.[0-9]*)+))(-[a-zA-Z0-9_]+)?$"
        set result = re.Execute(line)   
        num = 0
        if Not IsEmpty(result) Then
            for Each a in result
                re.Pattern = "[0-9]+((\.[0-9]*)+)"
                set resa = re.Execute(a)
                if Not IsEmpty(resa) Then
                    for Each b in resa
                        b = Trim(b)
                        m_version=b
                    Next
                End If
            Next
        End If
    End Function
    Public Function  GetVersion()
        if IsEmpty(m_version) and IsNull(m_version) Then
            GetVersion="0.0.0"
        Else
            GetVersion=m_version
        End If
    End Function
End Class

dim nodeversion


Function CheckNodeVersion(basever)
    dim patharr
    dim pathval
    dim curpath
    dim curnode
    pathval = GetEnv("PATH")
    If IsNull(pathval) Then
        CheckNodeVersion=false
        Exit Function
    End If

    patharr = Split(pathval,";")
    For Each curpath in patharr
        If FileExists( curpath & "\" & "node.exe") Then
            curnode = curpath & "\" & "node.exe"
            set nodeversion = new NodeExtractVersion
            call GetRunOut(curnode,"--version","FilterText","nodeversion")
            WScript.Stdout.Writeline("node version " & nodeversion.GetVersion())
            If VersionCompare(basever,nodeversion.GetVersion()) Then
                CheckNodeVersion=true
            Else
                CheckNodeVersion=false
            End If
            Exit Function
        End If
    Next

    CheckNodeVersion=false
End Function


Class NpmExtractVersion
    Private m_version
    Public Function FilterVersion(line)
        dim re,result,num,a,resa,b
        set re = new regexp
        '  
        re.Pattern = "([0-9]+((\.[0-9]*)+))(-[a-zA-Z0-9_]+)?$"
        set result = re.Execute(line)   
        num = 0
        if Not IsEmpty(result) Then
            for Each a in result
                re.Pattern = "[0-9]+((\.[0-9]*)+)"
                set resa = re.Execute(a)
                if Not IsEmpty(resa) Then
                    for Each b in resa
                        b = Trim(b)
                        m_version=b
                    Next
                End If
            Next
        End If
    End Function
    Public Function  GetVersion()
        if IsEmpty(m_version) and IsNull(m_version) Then
            GetVersion="0.0.0"
        Else
            GetVersion=m_version
        End If
    End Function
End Class

dim npmversion
Function CheckNpm3Version(basever)
    dim patharr
    dim pathval
    dim curpath
    dim curnpm
    pathval = GetEnv("PATH")
    If IsNull(pathval) Then
        CheckNpm3Version=false
        Exit Function
    End If

    patharr = Split(pathval,";")
    For Each curpath in patharr
        If FileExists( curpath & "\" & "npm3.cmd") Then
            curnpm = curpath & "\" & "npm3.cmd"
            set npmversion = new NpmExtractVersion
            call GetRunOut(curnpm,"--version","FilterText","npmversion")
            WScript.Stdout.Writeline("npm version " & npmversion.GetVersion())
            If VersionCompare(basever,npmversion.GetVersion()) Then
                CheckNpm3Version=true
            Else
                CheckNpm3Version=false
            End If
            Exit Function
        End If
    Next

    CheckNpm3Version=false
End Function

Class NsisExtractVersion
    Private m_version
    Public Function FilterVersion(line)
        dim re,result,num,a,resa,b
        set re = new regexp
        '  
        re.Pattern = "v([0-9]+((\.[0-9]*)+))([a-zA-Z0-9_]+)?$"
        set result = re.Execute(line)   
        num = 0
        if Not IsEmpty(result) Then
            for Each a in result
                re.Pattern = "[0-9]+((\.[0-9]*)+)"
                set resa = re.Execute(a)
                if Not IsEmpty(resa) Then
                    for Each b in resa
                        b = Trim(b)
                        m_version=b
                    Next
                End If
            Next
        End If
    End Function
    Public Function  GetVersion()
        if IsEmpty(m_version) and IsNull(m_version) Then
            GetVersion="0.0.0"
        Else
            GetVersion=m_version
        End If
    End Function
End Class


dim nsisversion
Function CheckNsisVersion(basever)
    dim patharr
    dim pathval
    dim curpath
    dim curnsis
    pathval = GetEnv("PATH")
    If IsNull(pathval) Then
        CheckNsisVersion=false
        Exit Function
    End If

    patharr = Split(pathval,";")
    For Each curpath in patharr
        If FileExists( curpath & "\" & "makensis.exe") Then
            curnsis = curpath & "\" & "makensis.exe"
            set nsisversion = new NsisExtractVersion
            call GetRunOut(curnsis,"/VERSION","FilterText","nsisversion")
            WScript.Stdout.Writeline("nsis version " & nsisversion.GetVersion())
            If VersionCompare(basever,nsisversion.GetVersion()) Then
                CheckNsisVersion=true
            Else
                CheckNsisVersion=false
            End If
            Exit Function
        End If
    Next

    CheckNsisVersion=false
End Function

Class GitExtractVersion
    Private m_version
    Public Function FilterVersion(line)
        dim re,result,num,a,resa,b
        set re = new regexp
        '  to get the gox.x.x version number
        re.Pattern = "git\s+version\s+([0-9]+((\.[0-9]*)+))(.)*$"
        set result = re.Execute(line)   
        num = 0
        if Not IsEmpty(result) Then
            for Each a in result
                re.Pattern = "[0-9]+((\.[0-9]+)+)"
                set resa = re.Execute(a)
                if Not IsEmpty(resa) Then
                    for Each b in resa
                        b = Trim(b)
                        m_version=b
                    Next
                End If
            Next
        End If
    End Function
    Public Function  GetVersion()
        if IsEmpty(m_version) Then
            GetVersion="0.0.0"
        Else
            GetVersion=m_version
        End If
    End Function
End Class

dim gitversion

Function CheckGitVersion(basever)
    dim patharr
    dim pathval
    dim curpath
    dim curcmd
    pathval = GetEnv("PATH")
    If IsNull(pathval) Then
        CheckGitVersion=false
        Exit Function
    End If

    patharr = Split(pathval,";")
    For Each curpath in patharr
        If FileExists( curpath & "\" & "git.exe") Then
            curcmd = curpath & "\" & "git.exe"
            set gitversion = new GitExtractVersion
            call GetRunOut(curcmd,"version","FilterText","gitversion")
            WScript.Stdout.Writeline("git version " & gitversion.GetVersion())
            If VersionCompare(basever,gitversion.GetVersion()) Then
                ' now to test for the version
                CheckGitVersion=true
            Else
                CheckGitVersion=false
            End If
            Exit Function
        End If
    Next

    CheckGitVersion=false
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
    fh.Writeline(WScript.ScriptName & " [OPTIONS] [CHECK_TARGET]")
    fh.Writeline(chr(9) &"-h|--help                    to display this information")
    fh.Writeline("CHECK_TARGET can be below")
    fh.Writeline(chr(9) &"make_platform  version       to check running platform environment")
    fh.Writeline(chr(9) &"visual_studio version        to check for visual studio environment")
    fh.Writeline(chr(9) &"golang   version             to check for golang environment")
    fh.Writeline(chr(9) &"node  version                to check for node js environment")
    fh.Writeline(chr(9) &"npm3  version                to check npm environment")
    fh.Writeline(chr(9) &"cmake version                to check for cmake environment")
    fh.Writeline(chr(9) &"nsis  version                to check for nsis environment")
    fh.Writeline(chr(9) &"git   version                to check for git environment")
    WScript.Quit(ec)
End Function

Function ParseArgs(args)
    dim i,j,unum
    dim retval
    dim optarg
    j = UBound(args)
    i = 0
    do While i < j
        if args(i) = "-h" or  args(i) = "--help" Then
               Usage 0,""
        elseif args(i) = "make_platform"  Then
            If (i+1) > j Then
                Usage 3 , "visual_studio need version"
            End If
            optarg = args(i+1)
            retval = CheckMakePlatform(optarg,true)
            If Not retval Then
              Wscript.Stderr.Writeline("must run in 64bit mode windows version " & optarg)
              Wscript.Quit(3)
            End If
            i = i + 1
        elseif args(i) = "visual_studio" Then
            If (i+1) > j Then
                Usage 3 , "visual_studio need version"
            End If
            optarg = args(i+1)
            retval = CheckVisualStudio(optarg)
            If Not retval Then
               Wscript.Stderr.Writeline("must install visual studio version " & optarg)
               Wscript.Quit(3)
            End If
            i = i + 1
        elseif args(i) = "golang" Then
            If (i+1) > j Then
                Usage 3 , "golang need version"
            End If
            optarg = args(i+1)
            retval = CheckGolangVersion(optarg)
            If Not retval Then
                WScript.Stderr.Writeline("must install golang for version " & optarg)
                WScript.Quit(3)
            End If
            i = i + 1

        elseif args(i) = "cmake" Then
            If (i+1) > j Then
                Usage 3 , "cmake need version"
            End If
            optarg = args(i+1)
            retval = CheckCmakeVersion(optarg)
            If Not retval Then
                WScript.Stderr.Writeline("must install cmake for version " & optarg)
                WScript.Quit(3)
            End If
            i = i + 1
        elseif args(i) = "node" Then
            If (i+1) > j Then
                Usage 3 , "node need version"
            End If
            optarg = args(i+1)
            retval = CheckNodeVersion(optarg)
            If Not retval Then
                WScript.Stderr.Writeline("must install node for version " & optarg)
                WScript.Quit(3)
            End If
            i = i + 1
        elseif args(i) = "npm3" Then
            If (i+1) > j Then
                Usage 3 , "npm need version"
            End If
            optarg = args(i+1)
            retval = CheckNpm3Version(optarg)
            If Not retval Then
                WScript.Stderr.Writeline("must install npm3 for version " & optarg)
                WScript.Quit(3)
            End If
            i = i + 1
        elseif args(i) = "nsis" Then
            If (i+1) > j Then
                Usage 3 , "nsis need version"
            End If
            optarg = args(i+1)
            retval = CheckNsisVersion(optarg)
            If Not retval Then
                WScript.Stderr.Writeline("must install nsis for version " & optarg)
                WScript.Quit(3)
            End If
            i = i + 1
        elseif args(i) = "git" Then
            If (i+1) > j Then
                Usage 3 , "git need version"
            End If
            optarg = args(i+1)
            retval = CheckGitVersion(optarg)
            If Not retval Then
                WScript.Stderr.Writeline("must install git for version " & optarg)
                WScript.Quit(3)
            End If
            i = i + 1
        else
            Usage 3,"unknown args " + args(i)
        End if
        i = i + 1
    Loop

    On error resume next
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
