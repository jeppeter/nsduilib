

#include "uniansi.h"
#include <Windows.h>
#include <assert.h>
#include "output_debug.h"

#pragma warning(disable:4996)

int UnicodeToAnsi(wchar_t* pWideChar, char** ppChar, int*pCharSize)
{
    char* pRetChar = *ppChar;
    int retcharsize = *pCharSize;
    int ret, wlen, needlen;

    if (pWideChar == NULL) {
        if (*ppChar) {
            delete [] pRetChar;
        }
        *ppChar = NULL;
        *pCharSize = 0;
        return 0;
    }
    wlen = (int)wcslen(pWideChar);
    needlen = WideCharToMultiByte(CP_ACP, 0, pWideChar, wlen, NULL, 0, NULL, NULL);
    if (retcharsize <= needlen) {
        retcharsize = (needlen + 1);
        pRetChar = new char[needlen + 1];
        assert(pRetChar);
    }

    ret = WideCharToMultiByte(CP_ACP, 0, pWideChar, wlen, pRetChar, retcharsize, NULL, NULL);
    if (ret != needlen) {
        ret = ERROR_INVALID_BLOCK;
        goto fail;
    }
    pRetChar[needlen] = '\0';
    needlen += 1;

    if ((*ppChar) && (*ppChar) != pRetChar) {
        char* pTmpChar = *ppChar;
        delete [] pTmpChar;
    }
    *ppChar = pRetChar;
    *pCharSize = retcharsize;

    return needlen;
fail:
    if (pRetChar && pRetChar != (*ppChar)) {
        delete [] pRetChar;
    }
    pRetChar = NULL;
    retcharsize = 0;
    SetLastError(ret);
    return -ret;
}


int AnsiToUnicode(char* pChar, wchar_t **ppWideChar, int*pWideCharSize)
{
    wchar_t *pRetWideChar = *ppWideChar;
    int retwidecharsize = *pWideCharSize;
    int ret, len, needlen;

    if (pChar == NULL) {
        if (*ppWideChar) {
            delete [] pRetWideChar;
        }
        *ppWideChar = NULL;
        *pWideCharSize = 0;
        return 0;
    }

    len = (int) strlen(pChar);
    needlen = MultiByteToWideChar(CP_ACP, 0, pChar, len, NULL, 0);
    if (retwidecharsize <= needlen) {
        retwidecharsize = needlen + 1;
        pRetWideChar = new wchar_t[retwidecharsize];
        assert(pRetWideChar);
    }

    ret = MultiByteToWideChar(CP_ACP, 0, pChar, len, pRetWideChar, retwidecharsize);
    if (ret != needlen) {
        ret = ERROR_INVALID_BLOCK;
        goto fail;
    }
    pRetWideChar[needlen] = '\0';

    if ( (*ppWideChar) && (*ppWideChar) != pRetWideChar) {
        wchar_t *pTmpWideChar = *ppWideChar;
        delete [] pTmpWideChar;
    }
    *ppWideChar = pRetWideChar;
    *pWideCharSize = retwidecharsize;
    return ret;
fail:
    if (pRetWideChar && pRetWideChar != (*ppWideChar)) {
        delete [] pRetWideChar;
    }
    pRetWideChar = NULL;
    retwidecharsize = 0;
    SetLastError(ret);
    return -ret;
}

#ifndef _UNICODE
int _chartoansi(const char *ptchar, char** ppChar, int*pCharSize)
{
	int needlen=0;
	int needsize=*pCharSize;
	int ret;
	char* pRetChar = *ppChar;

	if (ptchar == NULL){
		/*if null, we just free memory*/
		if (pRetChar){
			free(pRetChar);
		}
		*ppChar = NULL;
		*pCharSize = 0;
		return 0;
	}

	needlen = (int)strlen(ptchar);
	needlen += 1;
	if (pRetChar == NULL || *pCharSize < needlen){
		pRetChar =(char*) malloc(needlen);
		if (pRetChar == NULL){
			GETERRNO(ret);
			goto fail;
		}
		needsize = needlen;
	}

	memcpy(pRetChar,ptchar,needlen);
	if (pRetChar != *ppChar && *ppChar != NULL){
		free(*ppChar);
	}

	*ppChar = pRetChar;
	*pCharSize = needsize;

	return needlen;
fail:
	if (pRetChar != *ppChar && pRetChar != NULL){
		free(pRetChar);
	}
	pRetChar = NULL;
	return ret;
}

#endif


int TcharToAnsi(TCHAR *ptchar, char** ppChar, int*pCharSize)
{
	int ret;
#ifdef _UNICODE
	ret = UnicodeToAnsi(ptchar,ppChar,pCharSize);
#else
	ret = _chartoansi(ptchar,ppChar,pCharSize);
#endif
	return ret;
}

int AnsiToTchar(const char *pChar,TCHAR **pptchar,int *ptcharsize)
{
	int ret;
#ifdef _UNICODE
	ret = AnsiToUnicode((char*)pChar,pptchar,ptcharsize);
#else
	ret = _chartoansi(pChar,pptchar,ptcharsize);
#endif
	return ret;
}