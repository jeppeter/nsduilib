#project(nsduilib)
set(CMAKE_BUILD_TYPE Release) 

set(CMAKE_MFC_FLAG 1)
add_definitions(/DUILIB_STATIC /DNSDUILIB_EXPORTS)
add_library(nsduilib SHARED dllmain.cpp nsduilib.cpp pluginapi.c SkinEngine.cpp StdAfx.cpp)

target_include_directories(nsduilib PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/../../clibs/winlib
	${CMAKE_CURRENT_SOURCE_DIR}/../duilib)
target_link_libraries(nsduilib duilib Shlwapi winlib)

ChangeStaticRuntimeLib()