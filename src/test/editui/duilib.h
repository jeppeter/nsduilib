#ifndef __DUI_LIB_H__
#define __DUI_LIB_H__
#include <UIlib.h>

using namespace DuiLib;


#pragma warning( disable : 4996) 

#if  1
// ÒÔXMLÉú³É½çÃæµÄ´°¿Ú»ùÀà
class CXMLWnd : public WindowImplBase
{
public:
    explicit CXMLWnd(LPCTSTR pszXMLPath) 
        : m_strXMLPath(pszXMLPath){}

public:
    virtual LPCTSTR GetWindowClassName() const
    {
        return _T("XMLWnd");
    }

    virtual CDuiString GetSkinFile()
    {
        return m_strXMLPath;
    }

    virtual CDuiString GetSkinFolder()
    {
        return _T("");
    }

protected:
    CDuiString m_strXMLPath;
};

#else

class CXMLWnd : public WindowImplBase
{
public:
    explicit CXMLWnd(LPCTSTR pszXMLPath) 
        : m_strXMLPath(pszXMLPath){}

public:
    virtual LPCTSTR GetWindowClassName() const
    {
        return _T("XMLWnd");
    }

    virtual CDuiString GetSkinFile()
    {
        return m_strXMLPath;
    }

    virtual CDuiString GetSkinFolder()
    {
        return _T("");
    }

    virtual LPCTSTR GetResourceID() const  
    {  
        return MAKEINTRESOURCE(IDR_ZIP_SKIN);  
    };  
    virtual UILIB_RESOURCETYPE GetResourceType() const  
    {  
        return UILIB_ZIPRESOURCE;   
    };  
	
protected:
    CDuiString m_strXMLPath;
};

#endif


// ½«HWNDÏÔÊ¾µ½CControlUIÉÏÃæ
class CWndUI: public CControlUI
{
public:
    CWndUI(): m_hWnd(NULL){}

    virtual void SetInternVisible(bool bVisible = true)
    {
        __super::SetInternVisible(bVisible);
        ::ShowWindow(m_hWnd, bVisible);
    }

    virtual void SetPos(RECT rc)
    {
        __super::SetPos(rc);
        ::SetWindowPos(m_hWnd, NULL, rc.left, rc.top, rc.right - rc.left, rc.bottom - rc.top, SWP_NOZORDER | SWP_NOACTIVATE);
    }

    BOOL Attach(HWND hWndNew)
    {
        if (! ::IsWindow(hWndNew))
        {
            return FALSE;
        }

        m_hWnd = hWndNew;
        return TRUE;
    }

    HWND Detach()
    {
        HWND hWnd = m_hWnd;
        m_hWnd = NULL;
        return hWnd;
    }

protected:
    HWND m_hWnd;
};


#endif /*__DUI_LIB_H__*/