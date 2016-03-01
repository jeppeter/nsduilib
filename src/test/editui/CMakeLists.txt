set(CMAKE_MFC_FLAG 1)
set(MSVC_RUNTIME "static")
file(GLOB EDITUI_CPP_FILES *.cpp)


add_executable(editui ${EDITUI_CPP_FILES})
add_definitions(/DUILIB_STATIC)
set(CMAKE_EXE_LINKER_FLAGS_DEBUG "/NODEFAULTLIB:uafxcwd.lib  /NODEFAULTLIB:libcmtd.lib")
set(CMAKE_EXE_LINKER_FLAGS_RELEASE "/NODEFAULTLIB:uafxcw.lib /NODEFAULTLIB:libcmt.lib")
target_include_directories(editui PUBLIC ${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_CURRENT_SOURCE_DIR}/../../duilib ${CMAKE_CURRENT_SOURCE_DIR}/../../output_debug)
target_link_libraries(editui duilib output_debug)
set_target_properties(editui PROPERTIES LINK_FLAGS_DEBUG "libcmtd.lib uafxcwd.lib" )
set_target_properties(editui PROPERTIES LINK_FLAGS_RELEASE "libcmt.lib uafxcw.lib" )


#set_target_properties(btvmgui PROPERTIES LINK_INTERFACE_LIBRARIES_DEBUG "uafxcwd.lib libcmtd.lib")

set_target_properties(editui PROPERTIES LINK_FLAGS "/SUBSYSTEM:WINDOWS")
ChangeStaticRuntimeLib()
