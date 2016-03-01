#include "nsduilib.h"
#include "SkinEngine.h"
#include <map>
#include <shlobj.h>
#include <stdio.h>
#include <atlconv.h>
#include <string>
#include "output_debug.h"
#include <Shlwapi.h>
using namespace DuiLib;

extern HINSTANCE g_hInstance;
extra_parameters* g_pluginParms;
DuiLib::CSkinEngine* g_pFrame = NULL;
BOOL g_bMSGLoopFlag = TRUE;
BOOL g_bErrorExit=FALSE;
std::map<HWND, WNDPROC> g_windowInfoMap;
DuiLib::CDuiString g_tempParam = _T("");
DuiLib::CDuiString g_installPageTabName = _T("");
std::map<DuiLib::CDuiString, DuiLib::CDuiString> g_controlLinkInfoMap;
CDuiString g_skinPath = _T("");

DuiLib::CTBCIAMessageBox* g_pMessageBox = NULL;

TCHAR g_messageBoxLayoutFileName[MAX_PATH] = {0};
TCHAR g_messageBoxTitleControlName[MAX_PATH] = {0};
TCHAR g_messageBoxTextControlName[MAX_PATH] = {0};

TCHAR g_messageBoxCloseBtnControlName[MAX_PATH] = {0}; 
TCHAR g_messageBoxYESBtnControlName[MAX_PATH] = {0}; 
TCHAR g_messageBoxNOBtnControlName[MAX_PATH] = {0}; 

static UINT_PTR PluginCallback(enum NSPIM msg)
{
	return 0;
}

NSDUILIB_API void InitTBCIASkinEngine(HWND hwndParent, int string_size, char *variables, stack_t **stacktop, extra_parameters *extra)
{
	DEBUG_INFO("\n");
	g_pluginParms = extra;
	EXDLL_INIT();
	extra->RegisterPluginCallback(g_hInstance, PluginCallback);
	DEBUG_INFO("\n");
	USES_CONVERSION;
	{
		TCHAR skinPath[MAX_PATH];
		TCHAR skinLayoutFileName[MAX_PATH];
		TCHAR installPageTabName[MAX_PATH];
		TCHAR guiname[MAX_PATH];
		LPTSTR pZip=NULL,pDir=NULL;
		ZeroMemory(skinPath, MAX_PATH*sizeof(TCHAR));
		ZeroMemory(skinLayoutFileName, MAX_PATH*sizeof(TCHAR));
		ZeroMemory(installPageTabName, MAX_PATH*sizeof(TCHAR));

		popstring(skinPath,sizeof(skinPath));  // 皮肤路径
		popstring(skinLayoutFileName,sizeof(skinLayoutFileName)); //皮肤文件
		popstring( installPageTabName,sizeof(installPageTabName)); // 安装页面tab的名字
		popstring(guiname,sizeof(guiname));

		DuiLib::CPaintManagerUI::SetInstance(g_hInstance);
		/*now to set for the zip file*/

		g_installPageTabName = installPageTabName;
		g_skinPath = skinPath;

		g_pFrame = new DuiLib::CSkinEngine();
		if( g_pFrame == NULL )
		{
			pushint(0);
			return;
		}
        pZip = StrStrI(skinPath,_T(".zip"));
        if (pZip && pZip[4] == 0x0 )
        {
            pDir =  wcsrchr(skinPath,L'\\');
            if (pDir == NULL)
            {   
                g_pFrame->SetZipFile(skinPath);
                DEBUG_INFO("set zip file %s\n",T2A(skinPath));
            }
            else
            {
                *pDir = 0x0;
                pDir ++;
                CPaintManagerUI::SetResourcePath(skinPath);
                g_pFrame->SetZipFile(pDir);
                DEBUG_INFO("set resource path %s zip %s\n",T2A(skinPath),T2A(pDir));
            }
        }
        else
        {
            CPaintManagerUI::SetResourcePath(skinPath);
        }
		g_pFrame->SetSkinXMLPath( skinLayoutFileName );
		g_pFrame->Create( NULL, guiname, UI_WNDSTYLE_FRAME, WS_EX_STATICEDGE | WS_EX_APPWINDOW );
		g_pFrame->CenterWindow();
		ShowWindow( g_pFrame->GetHWND(), FALSE );

		pushint( int(g_pFrame->GetHWND()));
		DEBUG_INFO("\n");
	}
	DEBUG_INFO("\n");
}

NSDUILIB_API void FindControl(HWND hwndParent, int string_size, char *variables, stack_t **stacktop, extra_parameters *extra)
{
	TCHAR controlName[MAX_PATH];
	ZeroMemory(controlName, MAX_PATH*sizeof(TCHAR));
	EXDLL_INIT();

	popstring( controlName,sizeof(controlName));
	CControlUI* pControl = static_cast<CControlUI*>(g_pFrame->GetPaintManager().FindControl( controlName ));
	if( pControl == NULL )
	{
		pushint( - 1 );
		return;
	}

	pushint( 0 );
	return ;
}

NSDUILIB_API void ShowLicense(HWND hwndParent, int string_size, char *variables, stack_t **stacktop, extra_parameters *extra)
{
	TCHAR controlName[MAX_PATH];
	TCHAR fileName[MAX_PATH];
	FILE* infile=NULL;
	TCHAR *ptchlicense=NULL;
	char *pLicense = NULL;
	char *pptr=NULL;
	int leftsize = 0;
	size_t ret;
	BOOL bret;
	EXDLL_INIT();

	ZeroMemory(controlName, MAX_PATH*sizeof(TCHAR));
	ZeroMemory(fileName, MAX_PATH*sizeof(TCHAR));
	popstring( controlName,sizeof(controlName) );
	popstring( fileName,sizeof(fileName));
	CDuiString finalFileName = fileName;
	CRichEditUI* pRichEditControl = static_cast<CRichEditUI*>(g_pFrame->GetPaintManager().FindControl( controlName ));
	if( pRichEditControl == NULL )
	{
		goto fail;
	}

	// 读许可协议文件，append到richedit中
	USES_CONVERSION;
	infile = fopen( T2A(finalFileName.GetData()), "r+b" );
	if (infile == NULL)
	{
		goto fail;
	}
	fseek( infile, 0,  SEEK_END );
	int nSize = ftell(infile);
	fseek(infile, 0, SEEK_SET);
	pLicense = new char[nSize+1];
	ptchlicense = new TCHAR[nSize+2];
	if (pLicense == NULL || ptchlicense == NULL)
	{
		if (pLicense)
		{
			delete []pLicense;
		}
		pLicense = NULL;
		if (ptchlicense)
		{
			delete []ptchlicense;
		}
		ptchlicense = NULL;
		fclose(infile);
		return;
	}

	ZeroMemory(pLicense, sizeof(char) * (nSize+1));
	ZeroMemory(ptchlicense,sizeof(TCHAR)* (nSize + 1));
	pptr = pLicense;
	leftsize = nSize;
	DEBUG_INFO("openfile 0x%p size %d\n",infile,nSize);
	while (leftsize > 0)
	{
		ret = fread_s(pptr, leftsize, sizeof(char), leftsize, infile);
		if (ret < 0)
		{
			DEBUG_INFO("ret = %d\n",ret);
			goto fail;
		}
		DEBUG_INFO("ret = %d\n",ret);
		pptr += ret* sizeof(char);
		leftsize -= (ret * sizeof(char));
	}
	/*now we change the text*/
	//mbstowcs(ptchlicense,pLicense,nSize+1);
#ifdef _UNICODE
	DEBUG_INFO("\n");
	pLicense[nSize] = 0x0;
	bret = MultiByteToWideChar(CP_ACP,0,pLicense,nSize,ptchlicense,(nSize + 1));
	if (!bret)
	{
		DEBUG_INFO("change license error %d\n",GetLastError());
		goto fail;
	}
#else
	memcpy(ptchlicense,pLicense,nSize);
#endif
	pRichEditControl->AppendText( ptchlicense);
	if (pLicense != NULL)
	{
		delete []pLicense;
		pLicense = NULL;
	}
	if (ptchlicense != NULL)
	{
		delete []ptchlicense;
		ptchlicense = NULL;
	}
	fclose( infile );
	pushint(0);
	return ;

fail:
	if (pLicense != NULL)
	{
		delete []pLicense;
		pLicense = NULL;
	}
	if (ptchlicense != NULL)
	{
		delete []ptchlicense;
		ptchlicense = NULL;
	}
	if (infile)
	{
		fclose( infile );
		infile = NULL;
	}
	pushint(-1);	
	return;
}

NSDUILIB_API void  OnControlBindNSISScript(HWND hwndParent, int string_size, char *variables, stack_t **stacktop, extra_parameters *extra)
{
	TCHAR controlName[MAX_PATH];
	ZeroMemory(controlName, MAX_PATH*sizeof(TCHAR));
	EXDLL_INIT();

	popstring(controlName,sizeof(controlName));
	int callbackID = popint();
	DEBUG_INFO("\n");
	g_pFrame->SaveToControlCallbackMap( controlName, callbackID );
	DEBUG_INFO("\n");
}

NSDUILIB_API void  SetControlData(HWND hwndParent, int string_size, char *variables, stack_t **stacktop, extra_parameters *extra)
{
	TCHAR controlName[MAX_PATH];
	TCHAR controlData[MAX_PATH];
	TCHAR dataType[MAX_PATH];

	EXDLL_INIT();

	ZeroMemory(controlName, MAX_PATH*sizeof(TCHAR));
	ZeroMemory(controlData, MAX_PATH*sizeof(TCHAR));
	ZeroMemory(dataType, MAX_PATH*sizeof(TCHAR));

	popstring( controlName,sizeof(controlName));
	popstring( controlData,sizeof(controlData));
	popstring( dataType,sizeof(dataType));

	CControlUI* pControl = static_cast<CControlUI*>(g_pFrame->GetPaintManager().FindControl( controlName ));
	if( pControl == NULL )
		return;

	if( _tcsicmp( dataType, _T("text") ) == 0 )
	{
		if( _tcsicmp( controlData, _T("error")) == 0 || _tcsicmp( controlData, _T("")) == 0 )
			pControl->SetText( pControl->GetText() );
		else
			pControl->SetText( controlData );
	}
	else if( _tcsicmp( dataType, _T("bkimage") ) == 0 )
	{
		if( _tcsicmp( controlData, _T("error")) == 0 || _tcsicmp( controlData, _T("")) == 0 )
			pControl->SetBkImage( pControl->GetBkImage());
		else
			pControl->SetBkImage( controlData );
	}
	else if( _tcsicmp( dataType, _T("link") ) == 0 )
	{
		g_controlLinkInfoMap[controlName] = controlData;
	}
	else if( _tcsicmp( dataType, _T("enable") ) == 0 )
	{
		if( _tcsicmp( controlData, _T("true")) == 0 )
			pControl->SetEnabled( true );
		else if( _tcsicmp( controlData, _T("false")) == 0 )
			pControl->SetEnabled( false );
	}
	else if( _tcsicmp( dataType, _T("visible") ) == 0 )
	{
		if( _tcsicmp( controlData, _T("true")) == 0 )
			pControl->SetVisible( true );
		else if( _tcsicmp( controlData, _T("false")) == 0 )
			pControl->SetVisible( false );
	}
}

NSDUILIB_API void  GetControlData(HWND hwndParent, int string_size, char *variables, stack_t **stacktop, extra_parameters *extra)
{
	TCHAR ctlName[MAX_PATH];
	TCHAR dataType[MAX_PATH];

	EXDLL_INIT();

	ZeroMemory(ctlName, MAX_PATH*sizeof(TCHAR));
	ZeroMemory(dataType, MAX_PATH*sizeof(TCHAR));
	popstring( ctlName ,sizeof(ctlName));
	popstring( dataType,sizeof(dataType));
	
	CControlUI* pControl = static_cast<CControlUI*>(g_pFrame->GetPaintManager().FindControl( ctlName ));
	if( pControl == NULL ){
		pushstring(_T("error"));
		return;
	}

	TCHAR temp[MAX_PATH] = {0};
	_tcscpy( temp, pControl->GetText().GetData());
	if( _tcsicmp( dataType, _T("text") ) == 0 ){
		pushstring( temp );
	}else{
		pushstring(_T("error"));
	}
	return;
}

void CALLBACK TimerProc(HWND hwnd, UINT uMsg, UINT_PTR idEvent, DWORD dwTime)
{
	g_pluginParms->ExecuteCodeSegment(idEvent - 1, 0);
}

NSDUILIB_API void  TBCIACreatTimer(HWND hwndParent, int string_size, char *variables, stack_t **stacktop, extra_parameters *extra)
{
	UINT callback;
	UINT interval;

	EXDLL_INIT();

	callback = popint();
	interval = popint();

	if (!callback || !interval)
		return;

	SetTimer( g_pFrame->GetHWND(), callback, interval, TimerProc );
}

NSDUILIB_API void  TBCIAKillTimer(HWND hwndParent, int string_size, char *variables, stack_t **stacktop, extra_parameters *extra)
{
	UINT id;
	EXDLL_INIT();

	id = popint();
	KillTimer(g_pFrame->GetHWND(), id);
}

UINT  TBCIAMessageBox( HWND hwndParent, LPCTSTR lpTitle, LPCTSTR lpText )
{
	if( g_pMessageBox == NULL )
	{
		g_pMessageBox = new DuiLib::CTBCIAMessageBox();
		if( g_pMessageBox == NULL ) return IDNO;
		g_pMessageBox->SetSkinXMLPath( g_messageBoxLayoutFileName );
		g_pMessageBox->Create( hwndParent, _T(""), UI_WNDSTYLE_FRAME, WS_EX_STATICEDGE | WS_EX_APPWINDOW , 0, 0, 0, 0 );
		g_pMessageBox->CenterWindow();
	}

	CControlUI* pTitleControl = static_cast<CControlUI*>(g_pMessageBox->GetPaintManager().FindControl( g_messageBoxTitleControlName ));
	CControlUI* pTipTextControl = static_cast<CControlUI*>(g_pMessageBox->GetPaintManager().FindControl( g_messageBoxTextControlName ));
	if( pTitleControl != NULL )
		pTitleControl->SetText( lpTitle );
	if( pTipTextControl != NULL )
		pTipTextControl->SetText( lpText );

	if( g_pMessageBox->ShowModal() == -1 )
		return IDYES;

	return IDNO;
}

NSDUILIB_API void  TBCIASendMessage(HWND hwndParent, int string_size, char *variables, stack_t **stacktop, extra_parameters *extra)
{
	HWND hwnd = (HWND)popint();
	TCHAR msgID[MAX_PATH];
	TCHAR wParam[MAX_PATH];
	TCHAR lParam[MAX_PATH];

	EXDLL_INIT();

 	ZeroMemory(msgID, MAX_PATH*sizeof(TCHAR));
	ZeroMemory(wParam, MAX_PATH*sizeof(TCHAR));
	ZeroMemory(lParam, MAX_PATH*sizeof(TCHAR));

	DEBUG_INFO("to send message stringsize %d MAX_PATH %d\n",g_stringsize,MAX_PATH);
	popstring( msgID,sizeof(msgID) );
	popstring( wParam,sizeof(wParam) );
	popstring( lParam ,sizeof(lParam));

	if( _tcsicmp( msgID, _T("WM_TBCIAMIN")) == 0 )
		::SendMessage( hwnd, WM_TBCIAMIN, (WPARAM)wParam, (LPARAM)lParam );
	else if( _tcsicmp( msgID, _T("WM_TBCIACLOSE")) == 0 )
		::SendMessage( hwnd, WM_TBCIACLOSE, (WPARAM)wParam, (LPARAM)lParam );
	else if( _tcsicmp( msgID, _T("WM_TBCIABACK")) == 0 )
		::SendMessage( hwnd, WM_TBCIABACK, (WPARAM)g_installPageTabName.GetData(), (LPARAM)lParam );
	else if( _tcsicmp( msgID, _T("WM_TBCIANEXT")) == 0 )
		::SendMessage( hwnd, WM_TBCIANEXT, (WPARAM)g_installPageTabName.GetData(), (LPARAM)lParam );
	else if( _tcsicmp( msgID, _T("WM_TBCIACANCEL")) == 0 )
	{
		LPCTSTR lpTitle = (LPCTSTR)wParam;
		LPCTSTR lpText = (LPCTSTR)lParam;
		DEBUG_BUFFER_FMT(lpTitle,_tcslen(lpTitle) + sizeof(TCHAR),"lpTitle :");
		DEBUG_BUFFER_FMT(lpText,_tcslen(lpText) + sizeof(TCHAR),"lpText :");
		if( IDYES == MessageBox( hwnd, lpText, lpTitle, MB_YESNO)/*TBCIAMessageBox( hwnd, lpTitle, lpText )*/)
		{
			pushint( 0 );
			::SendMessage( hwnd, WM_TBCIACLOSE, (WPARAM)wParam, (LPARAM)lParam );
		}
		else
			pushint( -1 );
	}
	else if (_tcsicmp( msgID, _T("WM_QAUERYCANCEL")) == 0)
	{
		LPCTSTR lpTitle = (LPCTSTR)wParam;
		LPCTSTR lpText = (LPCTSTR)lParam;
		if( IDYES == MessageBox( hwnd, lpText, lpTitle, MB_YESNO)/*TBCIAMessageBox( hwnd, lpTitle, lpText )*/)
		{
			pushint( 0 );
		}
		else
			pushint( -1 );
	}
	else if( _tcsicmp( msgID, _T("WM_TBCIASTARTINSTALL")) == 0 )
	{
		::SendMessage( hwnd, WM_TBCIASTARTINSTALL, (WPARAM)g_installPageTabName.GetData(), (LPARAM)lParam );
	}
	else if( _tcsicmp( msgID, _T("WM_TBCIASTARTUNINSTALL")) == 0 )
		::SendMessage( hwnd, WM_TBCIASTARTUNINSTALL, (WPARAM)g_installPageTabName.GetData(), (LPARAM)lParam );
	else if( _tcsicmp( msgID, _T("WM_TBCIAFINISHEDINSTALL")) == 0 )
		::SendMessage( hwnd, WM_TBCIAFINISHEDINSTALL, (WPARAM)wParam, (LPARAM)lParam );
	else if( _tcsicmp( msgID, _T("WM_TBCIAOPTIONSTATE")) == 0 ) // 返回option的状态
	{
		COptionUI* pOption = static_cast<COptionUI*>(g_pFrame->GetPaintManager().FindControl( wParam ));
		if( pOption == NULL )
			return;
		DEBUG_INFO("selected %s\n",pOption->IsSelected() ? "yes" : "no");
		pushint(  pOption->IsSelected() );
	}
	else if (_tcsicmp( msgID, _T("WM_TBCIASETSTATE")) == 0)
	{
		COptionUI* pOption = static_cast<COptionUI*>(g_pFrame->GetPaintManager().FindControl( wParam ));
		if( pOption == NULL )
			return;
		if (_tcsicmp(lParam,_T("1"))== 0)
		{
			pOption->Selected(true);
		}
		else
		{
			pOption->Selected(false);
		}
		DEBUG_INFO("selected %s\n",pOption->IsSelected() ? "yes" : "no");
		pOption->PaintStatusImage(g_pFrame->GetPaintManager().GetPaintDC());
		pushint(  pOption->IsSelected() );
	}
	else if (_tcsicmp(msgID,_T("WM_TBCIAEXIT"))==0)
	{
		::SendMessage(hwnd,WM_CLOSE,0,0);
	}
	else if( _tcsicmp( msgID, _T("WM_TBCIAOPENURL")) == 0 )
	{
		CDuiString url = (CDuiString)wParam;
		if( url.Find( _T("https://") ) == -1  &&
			url.Find(_T("http://")) == -1)
		{
			pushstring( _T("url error") );
			return;
		}
		CDuiString lpCmdLine = _T("explorer \"");
		lpCmdLine += url;
		lpCmdLine += _T("\"");
		USES_CONVERSION;
		char strCmdLine[MAX_PATH];
#ifdef _UNICODE
		wcstombs(strCmdLine,lpCmdLine.GetData(),MAX_PATH);
#else
		strncpy(strCmdLine,lpCmdLine.GetData(),MAX_PATH);
#endif
		WinExec( strCmdLine, SW_SHOWNORMAL);
	}
}

int CALLBACK BrowseCallbackProc(HWND hwnd, UINT uMsg, LPARAM lp, LPARAM pData)
{
	if (uMsg == BFFM_INITIALIZED)
		SendMessage(hwnd, BFFM_SETSELECTION, TRUE, pData);

	return 0;
}

NSDUILIB_API void SelectFolderDialog(HWND hwndParent, int string_size, char *variables, stack_t **stacktop, extra_parameters *extra)
{
	BROWSEINFO bi;
	TCHAR result[MAX_PATH];
	TCHAR title[MAX_PATH];
	LPITEMIDLIST resultPIDL;

	EXDLL_INIT();

	ZeroMemory(result, MAX_PATH*sizeof(TCHAR));
	ZeroMemory(title, MAX_PATH*sizeof(TCHAR));

	popstring( title ,sizeof(title));
	bi.hwndOwner = g_pFrame->GetHWND();
	bi.pidlRoot = NULL;
	bi.pszDisplayName = result;
	bi.lpszTitle = title;
#ifndef BIF_NEWDIALOGSTYLE
#define BIF_NEWDIALOGSTYLE 0x0040
#endif
	//bi.ulFlags = BIF_STATUSTEXT | BIF_RETURNONLYFSDIRS | BIF_NEWDIALOGSTYLE | BIF_NONEWFOLDERBUTTON;
	bi.ulFlags = BIF_STATUSTEXT | BIF_RETURNONLYFSDIRS | BIF_NEWDIALOGSTYLE ;
	bi.lpfn = BrowseCallbackProc;
	bi.lParam = NULL;
	bi.iImage = 0;

	resultPIDL = SHBrowseForFolder(&bi);
	if (!resultPIDL)
	{
		pushint(-1);
		return;
	}

	if (SHGetPathFromIDList(resultPIDL, result))
	{
		if( result[_tcslen(result)-1] == _T('\\') )
			result[_tcslen(result)-1] = _T('\0');
		pushstring(result);
	}
	else
		pushint(-1);

	CoTaskMemFree(resultPIDL);
}

BOOL CALLBACK TBCIAWindowProc(HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam)
{
	BOOL res = 0;
	std::map<HWND, WNDPROC>::iterator iter = g_windowInfoMap.find( hwnd );
	//DEBUG_INFO("hwnd 0x%x message 0x%x wparam 0x%x lparam 0x%x\n",hwnd,message,wParam,lParam);
	if( iter != g_windowInfoMap.end() )
	{

 		if (message == WM_PAINT)
 		{
 			ShowWindow( hwnd, SW_HIDE );
 		}
		else if( message == LVM_SETITEMTEXT ) // TODO  安装细节显示  等找到消息再写
		{
			;
		}
 		else if( message == PBM_SETPOS ) 
 		{
			CProgressUI* pProgress = static_cast<CProgressUI*>(g_pFrame->GetPaintManager().FindControl( g_tempParam ));
			pProgress->SetMaxValue( 30000 );
			if( pProgress == NULL )
				return 0;
			pProgress->SetValue( (int)wParam);

			if( pProgress->GetValue() == 30000 )
			{
				CTabLayoutUI* pTab = NULL;
				int currentIndex;
				pTab = static_cast<CTabLayoutUI*>(g_pFrame->GetPaintManager().FindControl( g_installPageTabName ));
				if( pTab == NULL )
					return -1;
				currentIndex = pTab->GetCurSel();
				pTab->SelectItem( currentIndex + 1 );
			}
 		}
 		else
 		{
			res = CallWindowProc( iter->second, hwnd, message, wParam, lParam);
		}
	}	
	return res;
}

void InstallCore( HWND hwndParent )
{
	TCHAR progressName[MAX_PATH];
	ZeroMemory(progressName, MAX_PATH*sizeof(TCHAR));
	popstring( progressName ,sizeof(progressName));
	g_tempParam = progressName;
	// 接管page instfiles的消息
	g_windowInfoMap[hwndParent] = (WNDPROC) SetWindowLong(hwndParent, GWL_WNDPROC, (long) TBCIAWindowProc);
	HWND hProgressHWND = FindWindowEx( FindWindowEx( hwndParent, NULL, _T("#32770"), NULL ), NULL, _T("msctls_progress32"), NULL );
	g_windowInfoMap[hProgressHWND] = (WNDPROC) SetWindowLong(hProgressHWND, GWL_WNDPROC, (long) TBCIAWindowProc);
	HWND hInstallDetailHWND = FindWindowEx( FindWindowEx( hwndParent, NULL, _T("#32770"), NULL ), NULL, _T("SysListView32"), NULL ); 
	g_windowInfoMap[hInstallDetailHWND] = (WNDPROC) SetWindowLong(hInstallDetailHWND, GWL_WNDPROC, (long) TBCIAWindowProc);
}

NSDUILIB_API void StartInstall(HWND hwndParent, int string_size, char *variables, stack_t **stacktop, extra_parameters *extra)
{
	EXDLL_INIT();
	InstallCore( hwndParent );
}

NSDUILIB_API void StartUninstall(HWND hwndParent, int string_size, char *variables, stack_t **stacktop, extra_parameters *extra)
{
	EXDLL_INIT();
	InstallCore( hwndParent );
}

NSDUILIB_API void ShowPage(HWND hwndParent, int string_size, char *variables, stack_t **stacktop, extra_parameters *extra)
{
	EXDLL_INIT();
	ShowWindow( g_pFrame->GetHWND(), TRUE );
	MSG msg = { 0 };
	g_bMSGLoopFlag = TRUE;
	g_bErrorExit = FALSE;
	while( ::GetMessage(&msg, NULL, 0, 0) && g_bMSGLoopFlag  && !g_bErrorExit) 
	{
		//if (!CPaintManagerUI::TranslateMessage(&msg)){
			::TranslateMessage(&msg);
			::DispatchMessage(&msg);
		//}
	}

	if (g_bErrorExit)
	{
		pushint(-1);
	}
	else
	{
		pushint(0);
	}
	return ;
}

NSDUILIB_API void  ExitTBCIASkinEngine(HWND hwndParent, int string_size, char *variables, stack_t **stacktop, extra_parameters *extra)
{
	TCHAR hwnd[MAX_PATH];
	EXDLL_INIT();
	popstring(hwnd,sizeof(hwnd));
	g_bErrorExit = TRUE;
	DEBUG_INFO("exit skin engine\n");
	return ;
}

NSDUILIB_API void  InitTBCIAMessageBox(HWND hwndParent, int string_size, char *variables, stack_t **stacktop, extra_parameters *extra)
{
	EXDLL_INIT();

	popstring( g_messageBoxLayoutFileName,sizeof(g_messageBoxLayoutFileName));

	popstring( g_messageBoxTitleControlName,sizeof(g_messageBoxTitleControlName));
	popstring( g_messageBoxTextControlName,sizeof(g_messageBoxTextControlName));

	popstring( g_messageBoxCloseBtnControlName,sizeof(g_messageBoxCloseBtnControlName));
	popstring( g_messageBoxYESBtnControlName,sizeof(g_messageBoxYESBtnControlName));
	popstring( g_messageBoxNOBtnControlName,sizeof(g_messageBoxNOBtnControlName));
}

NSDUILIB_API void  VerifyCharaters(HWND hwndParent, int string_size, char *variables, stack_t **stacktop, extra_parameters *extra)
{
	char characters[MAX_PATH];
	int ret,i;

	ret = popstringA(characters,MAX_PATH);
	if (ret != 0){
		/*we have error*/
		pushint(-1);
		return ;
	}

	for (i=0;i<MAX_PATH;i++){
		if (characters[i] == 0x0){
			break;
		}

		if ((characters[i] >= 'a' && characters[i] <= 'z') ||
			(characters[i] >= 'A' && characters[i] <= 'Z') || 
			(characters[i] >= '0' && characters[i] <= '9') ||
			characters[i] == '_'){
			continue;
		}

		/*this is error code*/
		pushint(-2);
		return;
	}

	pushint(0);
	return;
}
