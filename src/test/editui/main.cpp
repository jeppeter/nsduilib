#include "editui.h"
#include <output_debug.h>

int APIENTRY _tWinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPTSTR lpCmdLine, int nCmdShow)
{
    CComboUI *pcombo = NULL;
    CListLabelElementUI* plist = NULL;
    int i;
    TCHAR insertchar[256];
    bool bret;
    ::CoInitialize(NULL);
    CPaintManagerUI::SetInstance(hInstance);

    EditUIWnd *pFrame = new EditUIWnd(_T("editui.xml"));
    //pFrame->Create(NULL, _T("BTVMGUI"), UI_WNDSTYLE_FRAME, WS_EX_WINDOWEDGE);
    pFrame->Create(NULL, _T("EDITUI"), 0, 0);
    pcombo = (CComboUI*) pFrame->getUIManager()->FindControl(_T("ComboInterface"));
    if (pcombo != NULL) {
        for (i = 0; i < 3; i++) {
            plist = new CListLabelElementUI();
            _sntprintf(insertchar, sizeof(insertchar) / sizeof(insertchar[0]), _T("list item %d"), i);
            plist->SetText(insertchar);
            DEBUG_INFO("insert[%d] %p\n",i,plist);
            pcombo->Add(plist);
        }
        pcombo->SelectItem(0, false);
    } else {
        ERROR_INFO("can not find ComboInterface\n");
    }

    pFrame->ShowModal();

    pcombo = (CComboUI*) pFrame->getUIManager()->FindControl(_T("ComboInterface"));
    if (pcombo != NULL) {
        i = 0;
        while (1) {
            bret = pcombo->RemoveAt(0);
            if (!bret){
                break;
            }
            DEBUG_INFO("remove[%d]\n",i);
            i ++;
        }
    }
    DEBUG_INFO("\n");
    delete pFrame;
    DEBUG_INFO("\n");
    ::CoUninitialize();
    return 0;
}
