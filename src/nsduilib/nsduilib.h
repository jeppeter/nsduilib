#ifndef __NSTBCIASKINENGINE_H__
#define __NSTBCIASKINENGINE_H__
#pragma  once

#include <UIlib.h>
#include "stdafx.h"
#include "pluginapi.h"
#include <windows.h>
#include "MsgDef.h"

#	if defined(NSDUILIB_EXPORTS)
#			define NSDUILIB_API  extern "C"  __declspec(dllexport)
#	else
#			define NSDUILIB_API  extern "C" __declspec(dllimport)
#	endif


/* 参数： 1. skin的路径（相对setup.exe生成的路径）
  *           2. skin布局文件名
  *           3. 安装页面tab的名字
  * 功能： 初始化界面
*/
NSDUILIB_API void InitTBCIASkinEngine(HWND hwndParent, int string_size, char *variables, stack_t **stacktop, extra_parameters *extra);

/* 参数： 1. control的名字
  * 功能： 寻找特定的control是否存在
*/
NSDUILIB_API void FindControl(HWND hwndParent, int string_size, char *variables, stack_t **stacktop, extra_parameters *extra);

/* 参数： 1. richedit control的名字
  *           2. 许可协议文件名字
  * 功能： 显示许可证文件
*/
NSDUILIB_API void ShowLicense(HWND hwndParent, int string_size, char *variables, stack_t **stacktop, extra_parameters *extra);

/* 参数： 1. 有click事件的control的名字
  *           2. 许可协议文件名字
  * 功能： 为控件绑定对应的事件，有click消息时执行对应代码
*/
NSDUILIB_API void  OnControlBindNSISScript(HWND hwndParent, int string_size, char *variables, stack_t **stacktop, extra_parameters *extra);

/* 参数： 1. control的名字
  *           2. 赋给control的数据
  *  		   3. 数据的类型 (现在提供三种数据类型： 1. text; 2. bkimage; 3. link; 4. enable )
  * 功能： 为控件绑定对应的事件，有click消息时执行对应代码
*/
NSDUILIB_API void  SetControlData(HWND hwndParent, int string_size, char *variables, stack_t **stacktop, extra_parameters *extra);

/* 参数： 1. control的名字
  *           2. 数据的类型 (现在提供一种数据类型： 1. text; )
  * 功能： 为控件绑定对应的事件，有click消息时执行对应代码
*/
NSDUILIB_API void  GetControlData(HWND hwndParent, int string_size, char *variables, stack_t **stacktop, extra_parameters *extra);

/* 参数： 1. TimerID(一般是回调函数的ID)
  *           2. interval
  * 功能： 创建定时器
*/
NSDUILIB_API void  TBCIACreatTimer(HWND hwndParent, int string_size, char *variables, stack_t **stacktop, extra_parameters *extra);

/* 参数： 1. TimerID(一般是回调函数的ID)
  * 功能： 杀死定时器
*/
NSDUILIB_API void  TBCIAKillTimer(HWND hwndParent, int string_size, char *variables, stack_t **stacktop, extra_parameters *extra);

/* 参数： 1. 消息HWND
  *            2. 消息ID
  *			   3. WPARAM
  *			   4. LPARAM
  * 功能： 发消息
*/
NSDUILIB_API void  TBCIASendMessage(HWND hwndParent, int string_size, char *variables, stack_t **stacktop, extra_parameters *extra);

/* 参数： 1. 标题（例如： 请选择文件夹）
  * 功能： 发消息
*/
NSDUILIB_API void  SelectFolderDialog(HWND hwndParent, int string_size, char *variables, stack_t **stacktop, extra_parameters *extra);

/* 参数： 1. 响应开始安装进度的进度条名字
  * 功能： 开始安装响应
*/
NSDUILIB_API void  StartInstall(HWND hwndParent, int string_size, char *variables, stack_t **stacktop, extra_parameters *extra);

/* 参数： 1. 响应开始卸载进度的进度条名字
  * 功能： 开始安装响应
*/
NSDUILIB_API void  StartUninstall(HWND hwndParent, int string_size, char *variables, stack_t **stacktop, extra_parameters *extra);

/* 参数： 无
  * 功能： 显示界面（注意：一定是最后才Show出来）
*/
NSDUILIB_API void  ShowPage(HWND hwndParent, int string_size, char *variables, stack_t **stacktop, extra_parameters *extra);

/* 参数： 无
  * 功能： 退出安装
*/
NSDUILIB_API void  ExitTBCIASkinEngine(HWND hwndParent, int string_size, char *variables, stack_t **stacktop, extra_parameters *extra);

/* 参数： 1. 布局文件的名字
               2. 标题控件名字
			   3. 提示内容控件名字
			   4. 关闭按钮控件名字
			   5. 确定按钮控件名字
			   6. 取消按钮控件名字
  * 功能： 初始化MessageBox
*/
NSDUILIB_API void  InitTBCIAMessageBox(HWND hwndParent, int string_size, char *variables, stack_t **stacktop, extra_parameters *extra);

/* Verify the Character in buffer
  * it must be in [a-zA-Z0-9_]  characters
*/
NSDUILIB_API void  VerifyCharaters(HWND hwndParent, int string_size, char *variables, stack_t **stacktop, extra_parameters *extra);
/******************************************
*   to make the icon to handle
******************************************/
NSDUILIB_API void  SetIconImage(HWND hwndParent, int string_size, char *variables, stack_t **stacktop, extra_parameters *extra);
/******************************************
verify number
******************************************/
NSDUILIB_API void  VerifyNumbers(HWND hwndParent, int string_size, char *variables, stack_t **stacktop, extra_parameters *extra);

/******************************************
to free skin engine and free resource
******************************************/
NSDUILIB_API void FreeSkinEngine(HWND hwndParent, int string_size, char *variables, stack_t **stacktop, extra_parameters *extra);

#endif



