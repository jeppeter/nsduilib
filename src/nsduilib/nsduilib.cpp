#include "nsduilib.h"
#include "SkinEngine.h"
#include <map>
#include <shlobj.h>
#include <stdio.h>
#include <atlconv.h>
#include <string>
#include <win_output_debug.h>
#include <win_fileop.h>
#include <win_uniansi.h>
#include <win_window.h>
#include <Shlwapi.h>
using namespace DuiLib;

extern HINSTANCE g_hInstance;
extra_parameters* g_pluginParms;
DuiLib::CSkinEngine* g_pFrame = NULL;
BOOL g_bMSGLoopFlag = TRUE;
BOOL g_bErrorExit = FALSE;
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
    TCHAR* ptfullpath=NULL;
    int tfullsize=0;
    char* pfullpath=NULL;
    int fullsize=0;
    char* pskinpath=NULL;
    int skinsize=0;
    int ret;
    g_pluginParms = extra;
    EXDLL_INIT();
    extra->RegisterPluginCallback(g_hInstance, PluginCallback);
    USES_CONVERSION;
    {
        TCHAR skinPath[MAX_PATH];
        TCHAR skinLayoutFileName[MAX_PATH];
        TCHAR installPageTabName[MAX_PATH];
        TCHAR guiname[MAX_PATH];
        LPTSTR pZip = NULL, pDir = NULL;
        ZeroMemory(skinPath, MAX_PATH * sizeof(TCHAR));
        ZeroMemory(skinLayoutFileName, MAX_PATH * sizeof(TCHAR));
        ZeroMemory(installPageTabName, MAX_PATH * sizeof(TCHAR));

        popstring(skinPath, sizeof(skinPath)); // 皮肤路径
        popstring(skinLayoutFileName, sizeof(skinLayoutFileName)); //皮肤文件
        popstring( installPageTabName, sizeof(installPageTabName)); // 安装页面tab的名字
        popstring(guiname, sizeof(guiname));

        ret = TcharToAnsi(skinPath,&pskinpath,&skinsize);
        if (ret < 0) {
            goto fail;
        }

        ret = get_full_path(pskinpath,&pfullpath,&fullsize);
        if (ret < 0) {
            goto fail;
        }

        DEBUG_INFO("[%s] => [%s]", pskinpath,pfullpath);

        ret = AnsiToTchar(pfullpath,&ptfullpath,&tfullsize);
        if (ret < 0) {
            goto fail;
        }

        DuiLib::CPaintManagerUI::SetInstance(g_hInstance);
        /*now to set for the zip file*/

        g_installPageTabName = installPageTabName;
        g_skinPath = ptfullpath;

        g_pFrame = new DuiLib::CSkinEngine();
        if ( g_pFrame == NULL ) {
            goto fail;
        }
        pZip = StrStrI(ptfullpath, _T(".zip"));
        if (pZip && pZip[4] == 0x0 ) {
            pDir =  wcsrchr(ptfullpath, L'\\');
            if (pDir == NULL) {
                g_pFrame->SetZipFile(ptfullpath);
            } else {
                *pDir = 0x0;
                pDir ++;
                CPaintManagerUI::SetResourcePath(ptfullpath);
                g_pFrame->SetZipFile(pDir);
            }
        } else {
            CPaintManagerUI::SetResourcePath(ptfullpath);
        }
        g_pFrame->SetSkinXMLPath( skinLayoutFileName );
        g_pFrame->Create( NULL, guiname, UI_WNDSTYLE_FRAME, WS_EX_STATICEDGE | WS_EX_APPWINDOW );
        g_pFrame->CenterWindow();
        ShowWindow( g_pFrame->GetHWND(), FALSE );
        pushint( int(g_pFrame->GetHWND()));
    }
    TcharToAnsi(NULL,&pskinpath,&skinsize);
    AnsiToTchar(NULL,&ptfullpath,&tfullsize);
    get_full_path(NULL,&pfullpath,&fullsize);
    return;
fail:
    TcharToAnsi(NULL,&pskinpath,&skinsize);
    AnsiToTchar(NULL,&ptfullpath,&tfullsize);
    get_full_path(NULL,&pfullpath,&fullsize);
    pushint(0);
    return;
}

NSDUILIB_API void FindControl(HWND hwndParent, int string_size, char *variables, stack_t **stacktop, extra_parameters *extra)
{
    TCHAR controlName[MAX_PATH];
    char* ansicontrolName= NULL;
    int ansisize = 0;
    ZeroMemory(controlName, MAX_PATH * sizeof(TCHAR));
    EXDLL_INIT();

    popstring( controlName, sizeof(controlName));
    if (TcharToAnsi(controlName,&ansicontrolName,&ansisize) >= 0) {
        DEBUG_INFO("controlName [%s]",ansicontrolName);
        TcharToAnsi(NULL,&ansicontrolName,&ansisize);
    }
    DEBUG_BUFFER_FMT(controlName,sizeof(controlName),"controlName value");
    CControlUI* pControl = static_cast<CControlUI*>(g_pFrame->GetPaintManager().FindControl( controlName ));
    if ( pControl == NULL ) {
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
    FILE* infile = NULL;
    TCHAR *ptchlicense = NULL;
    char *pLicense = NULL;
    char *pptr = NULL;
    int leftsize = 0;
    size_t ret;
    BOOL bret;
    EXDLL_INIT();

    ZeroMemory(controlName, MAX_PATH * sizeof(TCHAR));
    ZeroMemory(fileName, MAX_PATH * sizeof(TCHAR));
    popstring( controlName, sizeof(controlName) );
    popstring( fileName, sizeof(fileName));
    CDuiString finalFileName = fileName;
    CRichEditUI* pRichEditControl = static_cast<CRichEditUI*>(g_pFrame->GetPaintManager().FindControl( controlName ));
    if ( pRichEditControl == NULL ) {
        goto fail;
    }

    // 读许可协议文件，append到richedit中
    USES_CONVERSION;
    infile = fopen( T2A(finalFileName.GetData()), "r+b" );
    if (infile == NULL) {
        goto fail;
    }
    fseek( infile, 0,  SEEK_END );
    int nSize = ftell(infile);
    fseek(infile, 0, SEEK_SET);
    pLicense = new char[nSize + 1];
    ptchlicense = new TCHAR[nSize + 2];
    if (pLicense == NULL || ptchlicense == NULL) {
        if (pLicense) {
            delete []pLicense;
        }
        pLicense = NULL;
        if (ptchlicense) {
            delete []ptchlicense;
        }
        ptchlicense = NULL;
        fclose(infile);
        return;
    }

    ZeroMemory(pLicense, sizeof(char) * (nSize + 1));
    ZeroMemory(ptchlicense, sizeof(TCHAR) * (nSize + 1));
    pptr = pLicense;
    leftsize = nSize;
    while (leftsize > 0) {
        ret = fread_s(pptr, leftsize, sizeof(char), leftsize, infile);
        if (ret < 0) {
            ERROR_INFO("ret = %d", ret);
            goto fail;
        }
        pptr += ret * sizeof(char);
        leftsize -= (ret * sizeof(char));
    }
    /*now we change the text*/
    //mbstowcs(ptchlicense,pLicense,nSize+1);
#ifdef _UNICODE
    pLicense[nSize] = 0x0;
    bret = MultiByteToWideChar(CP_ACP, 0, pLicense, nSize, ptchlicense, (nSize + 1));
    if (!bret) {
        ERROR_INFO("change license error %d\n", GetLastError());
        goto fail;
    }
#else
    memcpy(ptchlicense, pLicense, nSize);
#endif
    pRichEditControl->AppendText( ptchlicense);
    if (pLicense != NULL) {
        delete []pLicense;
        pLicense = NULL;
    }
    if (ptchlicense != NULL) {
        delete []ptchlicense;
        ptchlicense = NULL;
    }
    fclose( infile );
    pushint(0);
    return ;

fail:
    if (pLicense != NULL) {
        delete []pLicense;
        pLicense = NULL;
    }
    if (ptchlicense != NULL) {
        delete []ptchlicense;
        ptchlicense = NULL;
    }
    if (infile) {
        fclose( infile );
        infile = NULL;
    }
    pushint(-1);
    return;
}

NSDUILIB_API void  OnControlBindNSISScript(HWND hwndParent, int string_size, char *variables, stack_t **stacktop, extra_parameters *extra)
{
    TCHAR controlName[MAX_PATH];
    ZeroMemory(controlName, MAX_PATH * sizeof(TCHAR));
    EXDLL_INIT();

    popstring(controlName, sizeof(controlName));
    int callbackID = popint();
    g_pFrame->SaveToControlCallbackMap( controlName, callbackID );
}

NSDUILIB_API void  SetControlData(HWND hwndParent, int string_size, char *variables, stack_t **stacktop, extra_parameters *extra)
{
    TCHAR controlName[MAX_PATH];
    TCHAR controlData[MAX_PATH];
    TCHAR dataType[MAX_PATH];
    char* pansi=NULL;
    int ansisize=0;
    int ret;
    CComboUI* pcombo = NULL;
    bool bret;
    int controlint;
    CListLabelElementUI* plistui = NULL;

    EXDLL_INIT();

    ZeroMemory(controlName, MAX_PATH * sizeof(TCHAR));
    ZeroMemory(controlData, MAX_PATH * sizeof(TCHAR));
    ZeroMemory(dataType, MAX_PATH * sizeof(TCHAR));

    popstring( controlName, sizeof(controlName));
    popstring( controlData, sizeof(controlData));
    popstring( dataType, sizeof(dataType));

    if (g_pFrame == NULL) {
        /*nothing to handle*/
        goto out;
    }

    CControlUI* pControl = static_cast<CControlUI*>(g_pFrame->GetPaintManager().FindControl(controlName));
    if ( pControl == NULL ){
        goto out;
    }

    if ( _tcsicmp( dataType, _T("text") ) == 0 ) {
        if ( _tcsicmp( controlData, _T("error")) == 0 || _tcsicmp( controlData, _T("")) == 0 )
            pControl->SetText( pControl->GetText() );
        else
            pControl->SetText( controlData );
    } else if ( _tcsicmp( dataType, _T("bkimage") ) == 0 ) {
        if ( _tcsicmp( controlData, _T("error")) == 0 || _tcsicmp( controlData, _T("")) == 0 )
            pControl->SetBkImage( pControl->GetBkImage());
        else
            pControl->SetBkImage( controlData );
    } else if ( _tcsicmp( dataType, _T("link") ) == 0 ) {
        g_controlLinkInfoMap[controlName] = controlData;
    } else if ( _tcsicmp( dataType, _T("enable") ) == 0 ) {
        if ( _tcsicmp( controlData, _T("true")) == 0 )
            pControl->SetEnabled( true );
        else if ( _tcsicmp( controlData, _T("false")) == 0 )
            pControl->SetEnabled( false );
    } else if ( _tcsicmp( dataType, _T("visible") ) == 0 ) {
        if ( _tcsicmp( controlData, _T("true")) == 0 )
            pControl->SetVisible( true );
        else if ( _tcsicmp( controlData, _T("false")) == 0 )
            pControl->SetVisible( false );
    } else if ( _tcsicmp(dataType, _T("insertcombo")) == 0 ) {
        /*in insertsel ,it will be controlData for insert text*/
        pcombo = static_cast<CComboUI*>(pControl);
        if (pcombo != NULL) {
            plistui = new CListLabelElementUI();
            plistui->SetText(controlData);
            pcombo->Add(plistui);
            ret = TcharToAnsi(controlData,&pansi,&ansisize);
            if (ret >= 0) {
                DEBUG_INFO("pcombo visible(%s) [%s]\n",pcombo->IsVisible() ? "True" : "False",pansi);
            }
        }
    } else if ( _tcsicmp(dataType, _T("setcombo")) == 0 ) {
        /*in setsel ,it will be controlData for idx to selected*/
        pcombo = static_cast<CComboUI*>(pControl);
        bret = false;
        if (pcombo != NULL) {
            pushstring(controlData);
            controlint = popint();
            /*we should selected*/
            bret = pcombo->SelectItem(controlint, true);
            DEBUG_INFO("set %d (%s)\n", controlint,bret ? "True":"False");
        }
    } else if (_tcsicmp(dataType, _T("clearcombo")) == 0) {
        pcombo = static_cast<CComboUI*>(pControl);
        /*now first to make sure clear*/
        if (pcombo != NULL) {
            pcombo->RemoveAll();
        }
    }

out:
    TcharToAnsi(NULL,&pansi,&ansisize);
    return;    
}

NSDUILIB_API void  GetControlData(HWND hwndParent, int string_size, char *variables, stack_t **stacktop, extra_parameters *extra)
{
    TCHAR ctlName[MAX_PATH];
    TCHAR dataType[MAX_PATH];
    CComboUI* pcombo = NULL;
    CListLabelElementUI* plistui = NULL;
    int idx;

    EXDLL_INIT();

    ZeroMemory(ctlName, MAX_PATH * sizeof(TCHAR));
    ZeroMemory(dataType, MAX_PATH * sizeof(TCHAR));
    popstring( ctlName , sizeof(ctlName));
    popstring( dataType, sizeof(dataType));

    if (g_pFrame == NULL) {
        pushstring(_T("error"));
        return;
    }

    CControlUI* pControl = static_cast<CControlUI*>(g_pFrame->GetPaintManager().FindControl( ctlName ));
    if ( pControl == NULL ) {
        pushstring(_T("error"));
        return;
    }

    TCHAR temp[MAX_PATH] = {0};
    if ( _tcsicmp( dataType, _T("text") ) == 0 ) {
        _tcscpy( temp, pControl->GetText().GetData());
        pushstring( temp );
    }  else if (_tcsicmp(dataType, _T("getsel")) == 0) {
        /*to get selected idx*/
        pcombo = static_cast<CComboUI*>(pControl);
        idx = pcombo->GetCurSel();
        pushint(idx);
    }  else if (_tcsicmp(dataType, _T("getseltext"))  == 0) {
        /*to get the selected text*/
        pcombo = static_cast<CComboUI*>(pControl);
        idx = pcombo->GetCurSel();
        if (idx >= 0 ) {
            plistui = static_cast<CListLabelElementUI*>(pcombo->GetItemAt(idx));
            pushstring((TCHAR*)(plistui->GetText().GetData()));
        } else {
            pushstring(_T("error"));
        }
    } else {
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
    if ( g_pMessageBox == NULL ) {
        g_pMessageBox = new DuiLib::CTBCIAMessageBox();
        if ( g_pMessageBox == NULL ) return IDNO;
        g_pMessageBox->SetSkinXMLPath( g_messageBoxLayoutFileName );
        g_pMessageBox->Create( hwndParent, _T(""), UI_WNDSTYLE_FRAME, WS_EX_STATICEDGE | WS_EX_APPWINDOW , 0, 0, 0, 0 );
        g_pMessageBox->CenterWindow();
    }

    CControlUI* pTitleControl = static_cast<CControlUI*>(g_pMessageBox->GetPaintManager().FindControl( g_messageBoxTitleControlName ));
    CControlUI* pTipTextControl = static_cast<CControlUI*>(g_pMessageBox->GetPaintManager().FindControl( g_messageBoxTextControlName ));
    if ( pTitleControl != NULL )
        pTitleControl->SetText( lpTitle );
    if ( pTipTextControl != NULL )
        pTipTextControl->SetText( lpText );

    if ( g_pMessageBox->ShowModal() == -1 )
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

    ZeroMemory(msgID, MAX_PATH * sizeof(TCHAR));
    ZeroMemory(wParam, MAX_PATH * sizeof(TCHAR));
    ZeroMemory(lParam, MAX_PATH * sizeof(TCHAR));

    popstring( msgID, sizeof(msgID) );
    popstring( wParam, sizeof(wParam) );
    popstring( lParam , sizeof(lParam));

    if ( _tcsicmp( msgID, _T("WM_TBCIAMIN")) == 0 )
        ::SendMessage( hwnd, WM_TBCIAMIN, (WPARAM)wParam, (LPARAM)lParam );
    else if ( _tcsicmp( msgID, _T("WM_TBCIACLOSE")) == 0 )
        ::SendMessage( hwnd, WM_TBCIACLOSE, (WPARAM)wParam, (LPARAM)lParam );
    else if ( _tcsicmp( msgID, _T("WM_TBCIABACK")) == 0 )
        ::SendMessage( hwnd, WM_TBCIABACK, (WPARAM)g_installPageTabName.GetData(), (LPARAM)lParam );
    else if ( _tcsicmp( msgID, _T("WM_TBCIANEXT")) == 0 )
        ::SendMessage( hwnd, WM_TBCIANEXT, (WPARAM)g_installPageTabName.GetData(), (LPARAM)lParam );
    else if ( _tcsicmp( msgID, _T("WM_TBCIACANCEL")) == 0 ) {
        LPCTSTR lpTitle = (LPCTSTR)wParam;
        LPCTSTR lpText = (LPCTSTR)lParam;
        if ( IDYES == MessageBox( hwnd, lpText, lpTitle, MB_YESNO)/*TBCIAMessageBox( hwnd, lpTitle, lpText )*/) {
            pushint( 0 );
            ::SendMessage( hwnd, WM_TBCIACLOSE, (WPARAM)wParam, (LPARAM)lParam );
        } else
            pushint( -1 );
    } else if (_tcsicmp( msgID, _T("WM_QAUERYCANCEL")) == 0) {
        LPCTSTR lpTitle = (LPCTSTR)wParam;
        LPCTSTR lpText = (LPCTSTR)lParam;
        if ( IDYES == MessageBox( hwnd, lpText, lpTitle, MB_YESNO)/*TBCIAMessageBox( hwnd, lpTitle, lpText )*/) {
            pushint( 0 );
        } else
            pushint( -1 );
    } else if ( _tcsicmp( msgID, _T("WM_TBCIASTARTINSTALL")) == 0 ) {
        ::SendMessage( hwnd, WM_TBCIASTARTINSTALL, (WPARAM)g_installPageTabName.GetData(), (LPARAM)lParam );
    } else if ( _tcsicmp( msgID, _T("WM_TBCIASTARTUNINSTALL")) == 0 )
        ::SendMessage( hwnd, WM_TBCIASTARTUNINSTALL, (WPARAM)g_installPageTabName.GetData(), (LPARAM)lParam );
    else if ( _tcsicmp( msgID, _T("WM_TBCIAFINISHEDINSTALL")) == 0 )
        ::SendMessage( hwnd, WM_TBCIAFINISHEDINSTALL, (WPARAM)wParam, (LPARAM)lParam );
    else if ( _tcsicmp( msgID, _T("WM_TBCIAOPTIONSTATE")) == 0 ) { // 返回option的状态
        COptionUI* pOption = static_cast<COptionUI*>(g_pFrame->GetPaintManager().FindControl( wParam ));
        if ( pOption == NULL )
            return;
        pushint(  pOption->IsSelected() );
    } else if (_tcsicmp( msgID, _T("WM_TBCIASETSTATE")) == 0) {
        COptionUI* pOption = static_cast<COptionUI*>(g_pFrame->GetPaintManager().FindControl( wParam ));
        if ( pOption == NULL )
            return;
        if (_tcsicmp(lParam, _T("1")) == 0) {
            pOption->Selected(true);
        } else {
            pOption->Selected(false);
        }
        pOption->PaintStatusImage(g_pFrame->GetPaintManager().GetPaintDC());
        pushint(  pOption->IsSelected() );
    } else if (_tcsicmp(msgID, _T("WM_TBCIAEXIT")) == 0) {
        ::SendMessage(hwnd, WM_CLOSE, 0, 0);
    } else if ( _tcsicmp( msgID, _T("WM_TBCIAOPENURL")) == 0 ) {
        CDuiString url = (CDuiString)wParam;
        if ( url.Find( _T("https://") ) == -1  &&
                url.Find(_T("http://")) == -1) {
            pushstring( _T("url error") );
            return;
        }
        CDuiString lpCmdLine = _T("explorer \"");
        lpCmdLine += url;
        lpCmdLine += _T("\"");
        USES_CONVERSION;
        char strCmdLine[MAX_PATH];
#ifdef _UNICODE
        wcstombs(strCmdLine, lpCmdLine.GetData(), MAX_PATH);
#else
        strncpy(strCmdLine, lpCmdLine.GetData(), MAX_PATH);
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

    ZeroMemory(result, MAX_PATH * sizeof(TCHAR));
    ZeroMemory(title, MAX_PATH * sizeof(TCHAR));

    popstring( title , sizeof(title));
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
    if (!resultPIDL) {
        pushint(-1);
        return;
    }

    if (SHGetPathFromIDList(resultPIDL, result)) {
        if ( result[_tcslen(result) - 1] == _T('\\') )
            result[_tcslen(result) - 1] = _T('\0');
        pushstring(result);
    } else
        pushint(-1);

    CoTaskMemFree(resultPIDL);
}

void DisableConsoleWin()
{
    static int st_disabled = 0;
    HWND *pwnd=NULL;
    int wndsize=0;
    int ret;
    int numwnd=0;
    BOOL bret;
    int i;
    if(st_disabled == 0) {
        ret = get_win_handle_by_classname("ConsoleWindowClass",(int)GetCurrentProcessId(),&pwnd,&wndsize);
        if (ret >= 0) {
            numwnd = ret;
            if (numwnd > 0) {
                st_disabled = 1;
                for (i=0;i<numwnd;i++) {
                    DEBUG_INFO("window [0x%p]",pwnd[i]);
                    bret = ShowWindow(pwnd[i],SW_HIDE);
                    if (!bret) {
                        ERROR_INFO("can not SW_HIDE 0x%p",pwnd[i]);
                        st_disabled = 0;
                    }
                }
            } 
        }
        get_win_handle_by_classname(NULL,-1,&pwnd,&wndsize);
    }
    return;
}

BOOL CALLBACK TBCIAWindowProc(HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam)
{
    BOOL res = 0;
    std::map<HWND, WNDPROC>::iterator iter = g_windowInfoMap.find( hwnd );
    //DEBUG_INFO("message [%d] wParam[%d] lParam[%d]",message,wParam,lParam);
    DisableConsoleWin();
    if ( iter != g_windowInfoMap.end() ) {

        if (message == WM_PAINT) {
            ShowWindow( hwnd, SW_HIDE );
        } else if ( message == LVM_SETITEMTEXT ) { // TODO  安装细节显示  等找到消息再写
            ;
        } else if ( message == PBM_SETPOS ) {
            CProgressUI* pProgress = static_cast<CProgressUI*>(g_pFrame->GetPaintManager().FindControl( g_tempParam ));
            pProgress->SetMaxValue( 30000 );
            if ( pProgress == NULL )
                return 0;
            pProgress->SetValue( (int)wParam);

            if ( pProgress->GetValue() == 30000 ) {
                CTabLayoutUI* pTab = NULL;
                int currentIndex;
                pTab = static_cast<CTabLayoutUI*>(g_pFrame->GetPaintManager().FindControl( g_installPageTabName ));
                if ( pTab == NULL )
                    return -1;
                currentIndex = pTab->GetCurSel();
                pTab->SelectItem( currentIndex + 1 );
            }
        } else {
            res = CallWindowProc( iter->second, hwnd, message, wParam, lParam);
        }
    }
    return res;
}

void InstallCore( HWND hwndParent )
{
    TCHAR progressName[MAX_PATH];
    ZeroMemory(progressName, MAX_PATH * sizeof(TCHAR));
    popstring( progressName , sizeof(progressName));
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
    while ( ::GetMessage(&msg, NULL, 0, 0) && g_bMSGLoopFlag  && !g_bErrorExit) {
        //if (!CPaintManagerUI::TranslateMessage(&msg)){
        ::TranslateMessage(&msg);
        ::DispatchMessage(&msg);
        //}
    }

    if (g_bErrorExit) {
        pushint(-1);
    } else {
        pushint(0);
    }
    return ;
}

NSDUILIB_API void  ExitTBCIASkinEngine(HWND hwndParent, int string_size, char *variables, stack_t **stacktop, extra_parameters *extra)
{
    TCHAR hwnd[MAX_PATH];
    EXDLL_INIT();
    popstring(hwnd, sizeof(hwnd));
    g_bErrorExit = TRUE;
    return ;
}

NSDUILIB_API void  InitTBCIAMessageBox(HWND hwndParent, int string_size, char *variables, stack_t **stacktop, extra_parameters *extra)
{
    EXDLL_INIT();

    popstring( g_messageBoxLayoutFileName, sizeof(g_messageBoxLayoutFileName));

    popstring( g_messageBoxTitleControlName, sizeof(g_messageBoxTitleControlName));
    popstring( g_messageBoxTextControlName, sizeof(g_messageBoxTextControlName));

    popstring( g_messageBoxCloseBtnControlName, sizeof(g_messageBoxCloseBtnControlName));
    popstring( g_messageBoxYESBtnControlName, sizeof(g_messageBoxYESBtnControlName));
    popstring( g_messageBoxNOBtnControlName, sizeof(g_messageBoxNOBtnControlName));
}

NSDUILIB_API void  VerifyCharaters(HWND hwndParent, int string_size, char *variables, stack_t **stacktop, extra_parameters *extra)
{
    char characters[MAX_PATH];
    int ret, i;

    ret = popstringA(characters, MAX_PATH);
    if (ret != 0) {
        /*we have error*/
        pushint(-1);
        return ;
    }

    for (i = 0; i < MAX_PATH; i++) {
        if (characters[i] == 0x0) {
            break;
        }

        if ((characters[i] >= 'a' && characters[i] <= 'z') ||
                (characters[i] >= 'A' && characters[i] <= 'Z') ||
                (characters[i] >= '0' && characters[i] <= '9') ||
                characters[i] == '_') {
            continue;
        }

        /*this is error code*/
        pushint(-2);
        return;
    }

    pushint(0);
    return;
}

void SetIconImage(HWND hwndParent, int string_size, char *variables, stack_t **stacktop, extra_parameters *extra)
{
    TCHAR iconname[MAX_PATH];
    int ret;

    if (g_pFrame == NULL) {
        goto fail;
    }
    popstring(iconname, sizeof(iconname));

    ret = g_pFrame->SetIconRes(iconname);
    if (ret < 0) {
        goto fail;
    }

    pushint(0);
    return ;
fail:
    pushint(-1);
    return;
}

void  VerifyNumbers(HWND hwndParent, int string_size, char *variables, stack_t **stacktop, extra_parameters *extra)
{
    char numchar[MAX_PATH];
    int i, ishex;
    popstringA(numchar, sizeof(numchar));
    ishex = popint();
    for (i = 0; i < MAX_PATH; i++) {
        if (numchar[i] == 0) {
            break;
        }

        if (ishex) {
            if ((numchar[i] >= '0' && numchar[i] <= '9' ) ||
                    (numchar[i] >= 'a' && numchar[i] <= 'f') ||
                    (numchar[i] >= 'A' && numchar[i] <= 'F')) {

            } else {
                goto fail;
            }
        } else {
            if (numchar[i] >= '0' && numchar[i] <= '9') {
            } else {
                goto fail;
            }
        }
    }

    pushint(0);
    return;
fail:
    pushint(-1);
    return;
}

void FreeSkinEngine(HWND hwndParent, int string_size, char *variables, stack_t **stacktop, extra_parameters *extra)
{
    if (g_pFrame) {
        delete g_pFrame;
        g_pFrame = NULL;
    }
    return;
}