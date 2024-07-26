#include <windows.h>
#include <tchar.h>
#include "pluginapi.h"
#include <win_output_debug.h>
#include <win_err.h>
#include <win_uniansi.h>

#pragma warning(disable:4996)

unsigned int g_stringsize;
stack_t **g_stacktop;
char *g_variables;


#define NSDUILIB_UNICODE_STRING   1

#if NSDUILIB_UNICODE_STRING == 1

// utility functions (not required but often useful)

int _UniToTchar(wchar_t*pstr, TCHAR* fmtstr, int maxsize)
{
  char* ansi=NULL;
  int ansisize=0;
  TCHAR* ptchar=NULL;
  int tsize=0;
  int ret;
  int wlen = 0;

  if (pstr == NULL) {
    return -1;
  }

  ret = UnicodeToAnsi(pstr,&ansi,&ansisize);
  if (ret < 0) {
    GETERRNO(ret);
    SETERRNO(ret);
    return ret;
  }

  ret = AnsiToTchar(ansi,&ptchar,&tsize);
  if (ret < 0) {
    GETERRNO(ret);
    goto fail;
  }

  wlen = ret * sizeof(TCHAR);
  if (wlen >= maxsize) {
    wlen = maxsize - sizeof(TCHAR);
  }
  memset(fmtstr,0,maxsize);
  memcpy(fmtstr,ptchar,wlen);

  AnsiToTchar(NULL,&ptchar,&tsize);
  UnicodeToAnsi(NULL,&ansi,&ansisize);
  return wlen;
fail:
  AnsiToTchar(NULL,&ptchar,&tsize);
  UnicodeToAnsi(NULL,&ansi,&ansisize);
  SETERRNO(ret);
  return ret;
}

int _UniToAnsi(wchar_t*pstr, char* fmtstr, int maxsize)
{
  char* ansi=NULL;
  int ansisize=0;
  int ret;
  int wlen = 0;

  if (pstr == NULL) {
    return -1;
  }

  ret = UnicodeToAnsi(pstr,&ansi,&ansisize);
  if (ret < 0) {
    GETERRNO(ret);
    goto fail;
  }

  wlen = ret;
  if (wlen >= maxsize) {
    wlen = maxsize - 1;
  }
  memset(fmtstr,0,maxsize);
  memcpy(fmtstr,ansi,wlen);

  UnicodeToAnsi(NULL,&ansi,&ansisize);
  return wlen;
fail:
  UnicodeToAnsi(NULL,&ansi,&ansisize);
  SETERRNO(ret);
  return ret;
}

int _TcharToUni(TCHAR* pstr,wchar_t* fmtstr,int maxlen)
{
  wchar_t* puni=NULL;
  int unisize=0;
  char* ansi=NULL;
  int ansisize=0;
  int ret;
  int wlen = 0;

  if (pstr == NULL) {
    return -1;
  }

  ret = TcharToAnsi(pstr,&ansi,&ansisize);
  if (ret <0) {
    GETERRNO(ret);
    goto fail;
  }

  ret = AnsiToUnicode(ansi,&puni,&unisize);
  if (ret < 0) {
    GETERRNO(ret);
    goto fail;
  }


  wlen = ret *sizeof(wchar_t);
  if (wlen >= maxlen) {
    wlen = maxlen - sizeof(wchar_t);
  }
  memset(fmtstr,0,maxlen);
  memcpy(fmtstr,puni,wlen);

  AnsiToUnicode(NULL,&puni,&unisize);
  TcharToAnsi(NULL,&ansi,&ansisize);
  return wlen;
fail:
  AnsiToUnicode(NULL,&puni,&unisize);
  TcharToAnsi(NULL,&ansi,&ansisize);
  SETERRNO(ret);
  return ret;

}


int NSISCALL popstring(TCHAR* str,int maxsize)
{
  stack_t *th;
  int wlen = 0;
  TCHAR* fmtstr=NULL;
  int fmtlen=0;
  int ret;
  if (!g_stacktop || !*g_stacktop) return 1;
  th = (*g_stacktop);
  DEBUG_BUFFER_FMT(th->text,wlen*2,"th->text");
  ret = _UniToTchar((wchar_t*)th->text,str,maxsize);
  if (ret < 0) {
    return 1;
  }
  *g_stacktop = th->next;
  GlobalFree((HGLOBAL)th);
  return 0;
}

int NSISCALL popstringA(char* str,int maxsize)
{
  stack_t *th;
  int ret;
  if (!g_stacktop || !*g_stacktop) return 1;
  th=(*g_stacktop);

  ret = _UniToAnsi((wchar_t*)th->text,str,maxsize);
  if (ret < 0) {
    return 1;
  }
  *g_stacktop = th->next;
  GlobalFree((HGLOBAL)th);
  return 0;
}

int NSISCALL popstringn(char *str, int maxlen)
{
  stack_t *th;
  int ret;
  if (!g_stacktop || !*g_stacktop) return 1;
  th=(*g_stacktop);
  ret = _UniToAnsi((wchar_t*)th->text,str,maxlen);
  if (ret < 0) {
    return 1;
  }
  *g_stacktop = th->next;
  GlobalFree((HGLOBAL)th);
  return 0;
}

void NSISCALL pushstring(TCHAR *str)
{
  stack_t *th;
  if (!g_stacktop) return;
  th = (stack_t*)GlobalAlloc(GPTR, sizeof(stack_t) + g_stringsize); 
  _TcharToUni(str,(wchar_t*)th->text,g_stringsize);
  th->next = *g_stacktop;
  *g_stacktop = th;
}

char * NSISCALL getuservariable(const int varnum)
{
  if (varnum < 0 || varnum >= __INST_LAST) return NULL;
  return g_variables+varnum*g_stringsize;
}

void NSISCALL setuservariable(const int varnum, const char *var)
{
  if (var != NULL && varnum >= 0 && varnum < __INST_LAST) 
    lstrcpyA(g_variables + varnum*g_stringsize, var);
}

// playing with integers

int NSISCALL myatoi(const char *s)
{
  int v=0;
  if (*s == '0' && (s[1] == 'x' || s[1] == 'X'))
  {
    s++;
    for (;;)
    {
      int c=*(++s);
      if (c >= '0' && c <= '9') c-='0';
      else if (c >= 'a' && c <= 'f') c-='a'-10;
      else if (c >= 'A' && c <= 'F') c-='A'-10;
      else break;
      v<<=4;
      v+=c;
    }
  }
  else if (*s == '0' && s[1] <= '7' && s[1] >= '0')
  {
    for (;;)
    {
      int c=*(++s);
      if (c >= '0' && c <= '7') c-='0';
      else break;
      v<<=3;
      v+=c;
    }
  }
  else
  {
    int sign=0;
    if (*s == '-') sign++; else s--;
    for (;;)
    {
      int c=*(++s) - '0';
      if (c < 0 || c > 9) break;
      v*=10;
      v+=c;
    }
    if (sign) v = -v;
  }

  return v;
}

unsigned NSISCALL myatou(const char *s)
{
  unsigned int v=0;

  for (;;)
  {
    unsigned int c=*s++;
    if (c >= '0' && c <= '9') c-='0';
    else break;
    v*=10;
    v+=c;
  }
  return v;
}

int NSISCALL myatoi_or(const char *s)
{
  int v=0;
  if (*s == '0' && (s[1] == 'x' || s[1] == 'X'))
  {
    s++;
    for (;;)
    {
      int c=*(++s);
      if (c >= '0' && c <= '9') c-='0';
      else if (c >= 'a' && c <= 'f') c-='a'-10;
      else if (c >= 'A' && c <= 'F') c-='A'-10;
      else break;
      v<<=4;
      v+=c;
    }
  }
  else if (*s == '0' && s[1] <= '7' && s[1] >= '0')
  {
    for (;;)
    {
      int c=*(++s);
      if (c >= '0' && c <= '7') c-='0';
      else break;
      v<<=3;
      v+=c;
    }
  }
  else
  {
    int sign=0;
    if (*s == '-') sign++; else s--;
    for (;;)
    {
      int c=*(++s) - '0';
      if (c < 0 || c > 9) break;
      v*=10;
      v+=c;
    }
    if (sign) v = -v;
  }

  // Support for simple ORed expressions
  if (*s == '|') 
  {
      v |= myatoi_or(s+1);
  }

  return v;
}

int NSISCALL popint()
{
  char buf[128];
  if (popstringn(buf,sizeof(buf)))
    return 0;

  return atoi(buf);
}

int NSISCALL popint_or()
{
  char buf[128];
  if (popstringn(buf,sizeof(buf)))
    return 0;

  return myatoi_or(buf);
}

void NSISCALL pushint(int value)
{
  TCHAR buffer[1024];
  _stprintf(buffer, _T("%d"), value);
  pushstring(buffer);
}


#else /*NSDUILIB_UNICODE_STRING*/

// utility functions (not required but often useful)
#ifdef _UNICODE

int NSISCALL popstring_debug(TCHAR* str,int maxsize)
{
	stack_t *th;
	if (!g_stacktop || !*g_stacktop) return 1;
	th = (*g_stacktop);
	DEBUG_BUFFER(th->text,strlen(th->text));
	//if (str) mbstowcs(str,th->text,strlen(th->text));
	if (str) MultiByteToWideChar(CP_ACP,0,th->text,-1,str,maxsize / sizeof(TCHAR));
	*g_stacktop = th->next;
	GlobalFree((HGLOBAL)th);
	return 0;
}


int NSISCALL popstring(TCHAR* str,int maxsize)
{
	stack_t *th;
	if (!g_stacktop || !*g_stacktop) return 1;
	th = (*g_stacktop);
  DEBUG_BUFFER_FMT(th->text,30,"th->text");
	//if (str) mbstowcs(str,th->text,strlen(th->text));
	if (str) MultiByteToWideChar(CP_ACP, 0, th->text,-1, str,maxsize/sizeof(TCHAR));
  DEBUG_BUFFER_FMT(str,maxsize,"pop tchar");
	*g_stacktop = th->next;
	GlobalFree((HGLOBAL)th);
	return 0;
}
#else
int NSISCALL popstring(TCHAR* str,int maxsize)
{
  stack_t *th;
  if (!g_stacktop || !*g_stacktop) return 1;
  th=(*g_stacktop);
  if (str) lstrcpyW(str,th->text);
  *g_stacktop = th->next;
  GlobalFree((HGLOBAL)th);
  return 0;
}
#endif /*_UNICODE*/

int NSISCALL popstringA(char* str,int maxsize)
{
	stack_t *th;
	if (!g_stacktop || !*g_stacktop) return 1;
	th=(*g_stacktop);
	if (str) lstrcpyA(str,th->text);
	*g_stacktop = th->next;
	GlobalFree((HGLOBAL)th);
	return 0;
}

int NSISCALL popstringn(char *str, int maxlen)
{
  stack_t *th;
  if (!g_stacktop || !*g_stacktop) return 1;
  th=(*g_stacktop);
  if (str) strncpy(str,th->text,maxlen?maxlen:g_stringsize);
  *g_stacktop = th->next;
  GlobalFree((HGLOBAL)th);
  return 0;
}

#ifdef _UNICODE
void NSISCALL pushstring(TCHAR *str)
{
	stack_t *th;
	if (!g_stacktop) return;
	th = (stack_t*)GlobalAlloc(GPTR, sizeof(stack_t) + g_stringsize);	
	WideCharToMultiByte(CP_ACP,0,str,_tcslen(str),th->text,g_stringsize,NULL,NULL);
	th->next = *g_stacktop;
	*g_stacktop = th;
}
#else
void NSISCALL pushstring(TCHAR *str)
{
  stack_t *th;
  if (!g_stacktop) return;
  th=(stack_t*)GlobalAlloc(GPTR,sizeof(stack_t)+g_stringsize);
  lstrcpynW(th->text,str,g_stringsize);
  th->next=*g_stacktop;
  *g_stacktop=th;
}
#endif

char * NSISCALL getuservariable(const int varnum)
{
  if (varnum < 0 || varnum >= __INST_LAST) return NULL;
  return g_variables+varnum*g_stringsize;
}

void NSISCALL setuservariable(const int varnum, const char *var)
{
	if (var != NULL && varnum >= 0 && varnum < __INST_LAST) 
		lstrcpyA(g_variables + varnum*g_stringsize, var);
}

// playing with integers

int NSISCALL myatoi(const char *s)
{
  int v=0;
  if (*s == '0' && (s[1] == 'x' || s[1] == 'X'))
  {
    s++;
    for (;;)
    {
      int c=*(++s);
      if (c >= '0' && c <= '9') c-='0';
      else if (c >= 'a' && c <= 'f') c-='a'-10;
      else if (c >= 'A' && c <= 'F') c-='A'-10;
      else break;
      v<<=4;
      v+=c;
    }
  }
  else if (*s == '0' && s[1] <= '7' && s[1] >= '0')
  {
    for (;;)
    {
      int c=*(++s);
      if (c >= '0' && c <= '7') c-='0';
      else break;
      v<<=3;
      v+=c;
    }
  }
  else
  {
    int sign=0;
    if (*s == '-') sign++; else s--;
    for (;;)
    {
      int c=*(++s) - '0';
      if (c < 0 || c > 9) break;
      v*=10;
      v+=c;
    }
    if (sign) v = -v;
  }

  return v;
}

unsigned NSISCALL myatou(const char *s)
{
  unsigned int v=0;

  for (;;)
  {
    unsigned int c=*s++;
    if (c >= '0' && c <= '9') c-='0';
    else break;
    v*=10;
    v+=c;
  }
  return v;
}

int NSISCALL myatoi_or(const char *s)
{
  int v=0;
  if (*s == '0' && (s[1] == 'x' || s[1] == 'X'))
  {
    s++;
    for (;;)
    {
      int c=*(++s);
      if (c >= '0' && c <= '9') c-='0';
      else if (c >= 'a' && c <= 'f') c-='a'-10;
      else if (c >= 'A' && c <= 'F') c-='A'-10;
      else break;
      v<<=4;
      v+=c;
    }
  }
  else if (*s == '0' && s[1] <= '7' && s[1] >= '0')
  {
    for (;;)
    {
      int c=*(++s);
      if (c >= '0' && c <= '7') c-='0';
      else break;
      v<<=3;
      v+=c;
    }
  }
  else
  {
    int sign=0;
    if (*s == '-') sign++; else s--;
    for (;;)
    {
      int c=*(++s) - '0';
      if (c < 0 || c > 9) break;
      v*=10;
      v+=c;
    }
    if (sign) v = -v;
  }

  // Support for simple ORed expressions
  if (*s == '|') 
  {
      v |= myatoi_or(s+1);
  }

  return v;
}

int NSISCALL popint()
{
  char buf[128];
  if (popstringn(buf,sizeof(buf)))
    return 0;

  return atoi(buf);
}

int NSISCALL popint_or()
{
  char buf[128];
  if (popstringn(buf,sizeof(buf)))
    return 0;

  return myatoi_or(buf);
}

void NSISCALL pushint(int value)
{
	TCHAR buffer[1024];
	_stprintf(buffer, _T("%d"), value);
	pushstring(buffer);
}

#endif
