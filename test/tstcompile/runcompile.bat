
pushd .

del Z:\nsduilib\build\nsduilib\nsduilib.dir\Release\*.obj
del Z:\nsduilib\build\nsduilib\Release\*.dll
del Z:\nsduilib\build\nsduilib\Release\*.lib
del Z:\nsduilib\build\nsduilib\Release\*.exp

cd Z:\nsduilib\build\nsduilib

cl.exe /c /IZ:\nsduilib\src\nsduilib\..\..\clibs\winlib /IZ:\nsduilib\src\nsduilib\..\..\src\duilib /IZ:\nsduilib\src\nsduilib  /W3 /WX- /O2 /Ob2 /Oy- /D WIN32 /D _WINDOWS /D NDEBUG /D UNICODE /D _UNICODE /D UILIB_STATIC /D NSDUILIB_EXPORTS /D _WINDLL /Gm- /EHsc /MT /GS /fp:precise /Zc:wchar_t /Zc:forScope /Zc:inline /GR /Fo"Z:\nsduilib\src\nsduilib\dllmain.obj" /Fd"Z:\nsduilib\src\nsduilib\nsduilib.pdb" /Gd /TP Z:\nsduilib\src\nsduilib\dllmain.cpp

cl.exe /c /IZ:\nsduilib\src\nsduilib\..\..\clibs\winlib /IZ:\nsduilib\src\nsduilib\..\..\src\duilib /IZ:\nsduilib\src\nsduilib  /W3 /WX- /O2 /Ob2 /Oy- /D WIN32 /D _WINDOWS /D NDEBUG /D UNICODE /D _UNICODE /D UILIB_STATIC /D NSDUILIB_EXPORTS /D _WINDLL /Gm- /EHsc /MT /GS /fp:precise /Zc:wchar_t /Zc:forScope /Zc:inline /GR /Fo"Z:\nsduilib\src\nsduilib\nsduilib.obj" /Fd"Z:\nsduilib\src\nsduilib\nsduilib.pdb" /Gd /TP Z:\nsduilib\src\nsduilib\nsduilib.cpp

cl.exe /c /IZ:\nsduilib\src\nsduilib\..\..\clibs\winlib /IZ:\nsduilib\src\nsduilib\..\..\src\duilib /IZ:\nsduilib\src\nsduilib  /W3 /WX- /O2 /Ob2 /Oy- /D WIN32 /D _WINDOWS /D NDEBUG /D UNICODE /D _UNICODE /D UILIB_STATIC /D NSDUILIB_EXPORTS /D _WINDLL /Gm- /EHsc /MT /GS /fp:precise /Zc:wchar_t /Zc:forScope /Zc:inline /GR /Fo"Z:\nsduilib\src\nsduilib\SkinEngine.obj" /Fd"Z:\nsduilib\src\nsduilib\nsduilib.pdb" /Gd /TP Z:\nsduilib\src\nsduilib\SkinEngine.cpp

cl.exe /c /IZ:\nsduilib\src\nsduilib\..\..\clibs\winlib /IZ:\nsduilib\src\nsduilib\..\..\src\duilib /IZ:\nsduilib\src\nsduilib  /W3 /WX- /O2 /Ob2 /Oy- /D WIN32 /D _WINDOWS /D NDEBUG /D UNICODE /D _UNICODE /D UILIB_STATIC /D NSDUILIB_EXPORTS /D _WINDLL /Gm- /EHsc /MT /GS /fp:precise /Zc:wchar_t /Zc:forScope /Zc:inline /GR /Fo"Z:\nsduilib\src\nsduilib\StdAfx.obj" /Fd"Z:\nsduilib\src\nsduilib\nsduilib.pdb" /Gd /TP Z:\nsduilib\src\nsduilib\StdAfx.cpp

cl.exe /c /IZ:\nsduilib\src\nsduilib\..\..\clibs\winlib /IZ:\nsduilib\src\nsduilib\..\..\src\duilib /IZ:\nsduilib\src\nsduilib  /W3 /WX- /O2 /Ob2 /Oy- /D WIN32 /D _WINDOWS /D NDEBUG /D UNICODE /D _UNICODE /D UILIB_STATIC /D NSDUILIB_EXPORTS /D _WINDLL /Gm- /EHsc /MT /GS /fp:precise /Zc:wchar_t /Zc:forScope /Zc:inline /GR /Fo"Z:\nsduilib\src\nsduilib\pluginapi.obj" /Fd"Z:\nsduilib\src\nsduilib\nsduilib.pdb" /Gd /TC Z:\nsduilib\src\nsduilib\pluginapi.c

link.exe /ERRORREPORT:PROMPT /INCREMENTAL:NO  /OUT:"Z:\nsduilib\src\nsduilib\nsduilib.dll" Shlwapi.lib kernel32.lib user32.lib gdi32.lib winspool.lib shell32.lib ole32.lib oleaut32.lib uuid.lib comdlg32.lib advapi32.lib /MANIFEST /MANIFESTUAC:"level='asInvoker' uiAccess='false'" /manifest:embed /manifestinput:D:\vs2015\VC\Include\Manifest\dpiaware.manifest /PDB:"Z:\nsduilib\src\nsduilib\nsduilib.pdb" /SUBSYSTEM:CONSOLE /TLBID:1 /DYNAMICBASE /NXCOMPAT /IMPLIB:"Z:\nsduilib\src\nsduilib\nsduilib.lib" /MACHINE:X86 /SAFESEH  /machine:X86 /DLL Z:\nsduilib\src\nsduilib\..\..\clibs\staticlib\winlib.lib Z:\nsduilib\src\nsduilib\..\..\src\duilib\duilib.lib Z:\nsduilib\src\nsduilib\dllmain.obj Z:\nsduilib\src\nsduilib\nsduilib.obj Z:\nsduilib\src\nsduilib\SkinEngine.obj Z:\nsduilib\src\nsduilib\StdAfx.obj Z:\nsduilib\src\nsduilib\pluginapi.obj

popd