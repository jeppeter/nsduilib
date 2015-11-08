set(CMAKE_BUILD_TYPE Release) 
add_definitions(/DUILIB_STATIC)
file(GLOB CONTROL_UILIB_SRCS "Control/*.cpp")
file(GLOB CORE_UILIB_SRCS "Core/*.cpp")
file(GLOB LAYOUT_UILIB_SRCS "Layout/*.cpp")
file(GLOB UTILS_UILIB_SRCS "Utils/*.cpp")
file(GLOB UTILS_UILIB_CFILES "Utils/*.c")
add_library(duilib STATIC ${CONTROL_UILIB_SRCS} ${CORE_UILIB_SRCS} ${LAYOUT_UILIB_SRCS} ${UTILS_UILIB_SRCS} ${UTILS_UILIB_CFILES} StdAfx.cpp)

target_include_directories(duilib PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/../output_debug ${CMAKE_CURRENT_SOURCE_DIR})
target_link_libraries(duilib output_debug)

ChangeStaticRuntimeLib()

