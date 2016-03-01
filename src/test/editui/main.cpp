#include "editui.h"
#include <output_debug.h>

int APIENTRY _tWinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPTSTR lpCmdLine, int nCmdShow)
{
    ::CoInitialize(NULL);
    CPaintManagerUI::SetInstance(hInstance);

    EditUIWnd *pFrame = new EditUIWnd(_T("editui.xml"));
    //pFrame->Create(NULL, _T("BTVMGUI"), UI_WNDSTYLE_FRAME, WS_EX_WINDOWEDGE);
    pFrame->Create(NULL, _T("EDITUI"), 0,0);
    pFrame->ShowModal();
    DEBUG_INFO("\n");
    delete pFrame;
    DEBUG_INFO("\n");
    ::CoUninitialize();
    return 0;
}
