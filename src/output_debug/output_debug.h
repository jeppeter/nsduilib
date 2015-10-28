#ifndef  __OUTPUT_DEBUG_H__
#define  __OUTPUT_DEBUG_H__

#include <stdio.h>
#include <stdlib.h>
#include <windows.h>



#ifdef __cplusplus
extern "C"{
#endif
void DebugOutString(const char* file,int lineno,const char* fmt,...);
//INJECTBASE_API void DebugBuffer(const char* file,int lineno,unsigned char* pBuffer,int buflen);
void DebugBufferFmt(const char* file,int lineno,unsigned char* pBuffer,int buflen,const char* fmt,...);
#ifdef __cplusplus
};
#endif




#define  DEBUG_INFO(fmt,...) DebugOutString(__FILE__,__LINE__,fmt,__VA_ARGS__)
#define  ERROR_INFO(fmt,...) DebugOutString(__FILE__,__LINE__,fmt,__VA_ARGS__)
#define  DEBUG_BUFFER(ptr,blen) DebugBufferFmt(__FILE__,__LINE__,(unsigned char*)ptr,blen,NULL)
#define  DEBUG_BUFFER_FMT(ptr,blen,...) DebugBufferFmt(__FILE__,__LINE__,(unsigned char*)ptr,blen,__VA_ARGS__)



#endif /*__OUTPUT_DEBUG_H__*/
