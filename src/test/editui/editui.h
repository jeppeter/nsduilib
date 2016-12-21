#ifndef __EDIT_UI_H__
#define __EDIT_UI_H__

#include "duilib.h"

class EditUIWnd : public CXMLWnd
{
public:
    explicit EditUIWnd(LPCTSTR pszXMLPath);
    virtual ~EditUIWnd();
    virtual LRESULT HandleMessage(UINT uMsg, WPARAM wParam, LPARAM lParam);
    CPaintManagerUI* getUIManager();
private:
};

#endif /*__EDIT_UI_H__*/