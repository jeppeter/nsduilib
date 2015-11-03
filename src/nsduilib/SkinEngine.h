#ifndef __SKINENGINE_H__
#define  __SKINENGINE_H__
#pragma  once

#include "UIlib.h"
#include <map>
#include "MsgDef.h"

namespace DuiLib
{

class CSkinEngine : public WindowImplBase
{
public:
    CSkinEngine() ;
    ~CSkinEngine()
    {
        if (this->m_pcodevecs) {
            delete this->m_pcodevecs;
            this->m_pcodevecs = NULL;
        }

        if (this->m_pnamevecs) {
            delete this->m_pnamevecs;
            this->m_pnamevecs = NULL;
        }

    }
    virtual CDuiString GetSkinFolder();
    virtual CDuiString GetSkinFile();
    virtual UILIB_RESOURCETYPE GetResourceType() const;
    virtual CDuiString GetZIPFileName() const;
    void SetZipFile(LPCTSTR zipname);

    LPCTSTR GetWindowClassName() const
    {
        return _T("nsTBCIASkinEngine");
    }
    UINT GetClassStyle() const
    {
        return CS_DBLCLKS;
    }
    void OnFinalMessage(HWND /*hWnd*/)
    {
        delete this;
    }

    void Notify(TNotifyUI& msg);

    LRESULT OnCreate(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled);
    LRESULT OnClose(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled);
    LRESULT OnDestroy(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled);
    LRESULT OnNcActivate(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled);
    LRESULT OnNcCalcSize(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled);
    LRESULT OnNcPaint(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled);
    LRESULT OnNcHitTest(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled);
    LRESULT OnSize(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled);
    LRESULT OnSysCommand(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled);
    LRESULT OnTBCIAMinMSG(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled);
    LRESULT OnTBCIACloseMSG(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled);
    LRESULT OnTBCIABackMSG(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled);
    LRESULT OnTBCIANextMSG(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled);
    LRESULT OnTBCIAStartInstallMSG(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled);
    LRESULT OnTBCIAStartUninstallMSG(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled);
    LRESULT OnTBCIAFinishedInstallMSG(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled);
    LRESULT HandleMessage(UINT uMsg, WPARAM wParam, LPARAM lParam);

    void       SetSkinXMLPath( LPCTSTR path );
    LPCTSTR GetSkinXMLPath();

    CPaintManagerUI& GetPaintManager();
    void SaveToControlCallbackMap( CDuiString ctlName, int callback );
    

private:
    TCHAR                               m_skinXMLPath[MAX_PATH];
    UILIB_RESOURCETYPE                  m_restype;
    TCHAR                               m_zipname[MAX_PATH];
    std::map<CDuiString, int> m_controlCallbackMap;
    std::vector<CDuiString> *m_pnamevecs;
    std::vector<int> *m_pcodevecs;
};

//////////////////////////////////////////////////////////////////////////
/// CTBCIAMessageBox

class CTBCIAMessageBox : public CWindowWnd, public INotifyUI
{
public:
    CTBCIAMessageBox() {}
    ~CTBCIAMessageBox() {}

    LPCTSTR GetWindowClassName() const
    {
        return _T("nsTBCIASkinEngine");
    }
    UINT GetClassStyle() const
    {
        return CS_DBLCLKS;
    }
    void OnFinalMessage(HWND /*hWnd*/)
    {
        m_pm.RemoveNotifier(this);
        delete this;
    }

    void Notify(TNotifyUI& msg);

    LRESULT OnCreate(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled);
    LRESULT OnClose(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled);
    LRESULT OnDestroy(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled);
    LRESULT OnNcActivate(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled);
    LRESULT OnNcCalcSize(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled);
    LRESULT OnNcPaint(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled);
    LRESULT OnNcHitTest(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled);
    LRESULT OnSize(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled);
    LRESULT OnSysCommand(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled);
    LRESULT HandleMessage(UINT uMsg, WPARAM wParam, LPARAM lParam);

    void       SetSkinXMLPath( LPCTSTR path );
    LPCTSTR GetSkinXMLPath();

    CPaintManagerUI& GetPaintManager();
    void SaveToControlCallbackMap( CDuiString ctlName, int callback )
    {
        m_controlCallbackMap[ctlName] = callback;
    }

private:
    CPaintManagerUI              m_pm;
    TCHAR                               m_skinXMLPath[MAX_PATH];
    std::map<CDuiString, int> m_controlCallbackMap;
};

} // namespace DuiLib
#endif