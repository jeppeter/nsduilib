#include "editui.h"
#include <output_debug.h>

EditUIWnd::EditUIWnd(LPCTSTR pszXMLPath)
    : CXMLWnd(pszXMLPath)
{
}

EditUIWnd::~EditUIWnd()
{
}


LRESULT EditUIWnd::HandleMessage(UINT uMsg, WPARAM wParam, LPARAM lParam)
{
	return __super::HandleMessage(uMsg,wParam,lParam);
}

CPaintManagerUI* EditUIWnd::getUIManager()
{
	return &(this->m_PaintManager);
}