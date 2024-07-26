// Copyright (c) 2010-2011, duilib develop team(www.duilib.com).
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or 
// without modification, are permitted provided that the 
// following conditions are met.
//
// Redistributions of source code must retain the above copyright
// notice, this list of conditions and the following disclaimer.
//
// Redistributions in binary form must reproduce the above 
// copyright notice, this list of conditions and the following
// disclaimer in the documentation and/or other materials 
// provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND 
// CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
// INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF 
// MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
// CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
// BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
// WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
// NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS 
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//
// DirectUI - UI Library
//
// Written by Bjarke Viksoe (bjarke@viksoe.dk)
// Copyright (c) 2006-2007 Bjarke Viksoe.
//
// This code may be used in compiled form in any way you desire. These
// source files may be redistributed by any means PROVIDING it is 
// not sold for profit without the authors written consent, and 
// providing that this notice and the authors name is included. 
//
// This file is provided "as is" with no expressed or implied warranty.
// The author accepts no liability if it causes any damage to you or your
// computer whatsoever. It's free, so don't hassle me about it.
//
// Beware of bugs.
//
//

#include <Windows.h>
#include <win_output_debug.h>
#include <win_output_debug_cfg.h>

HINSTANCE g_hInstance;

int init_dll_debug(int loglvl)
{
    int ret;
    OutputCfg cfgs;
    OutfileCfg* pcfg = NULL;


    pcfg = new OutfileCfg();
    ret = pcfg->set_file_type(NULL, WINLIB_DEBUGOUT_FILE_BACKGROUND, 0, 0);
    if (ret < 0) {
        GETERRNO(ret);
        goto fail;
    }

    ret = pcfg->set_level(loglvl);
    if (ret < 0) {
        GETERRNO(ret);
        goto fail;
    }

    ret = pcfg->set_format(WINLIB_OUTPUT_ALL_MASK);
    if (ret < 0) {
        GETERRNO(ret);
        goto fail;
    }

    ret = cfgs.insert_config(*pcfg);
    if (ret < 0) {
        GETERRNO(ret);
        goto fail;
    }

    delete pcfg;
    pcfg = NULL;


    ret = InitOutputEx2(&cfgs);
    if (ret < 0) {
        GETERRNO(ret);
        goto fail;
    }

    DEBUG_INFO("init level [%d]",loglvl);

    return 0;
fail:
    if (pcfg) {
        delete pcfg;
    }
    pcfg = NULL;
    INIT_LOG(loglvl);
    ERROR_INFO("fail init error[%d]", ret);
    SETERRNO(ret);
    return ret;
}

int nsduilib_debug_init()
{
	char* valstr = NULL;
	int outlevel = 0;

	valstr = getenv("NSDUILIB_LEVEL");
	if (valstr == NULL) {
		return 0;
	}
	outlevel = atoi(valstr);
	return init_dll_debug(outlevel);
}

BOOL WINAPI DllMain(HANDLE hInst, ULONG ul_reason_for_call, LPVOID lpReserved)
{
	g_hInstance = (HINSTANCE) hInst;
 	if (ul_reason_for_call == DLL_PROCESS_ATTACH) {
 		nsduilib_debug_init();
 	}

    return TRUE;
}

