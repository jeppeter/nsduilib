cmake_minimum_required(VERSION 2.8) 
include(cmake/functions.cmake)
message(STATUS "CMAKE_C_COMPILER_ID " ${CMAKE_C_COMPILER_ID})
message(STATUS "CMAKE_CXX_COMPILER_VERSION " ${CMAKE_CXX_COMPILER_VERSION})

add_definitions(-DUNICODE -D_UNICODE)
project(nsduilib)
set(CMAKE_BUILD_TYPE Release) 

set(CMAKE_CONFIGURATION_TYPES "Debug;Release")
add_subdirectory(output_debug)
add_subdirectory(duilib)
add_subdirectory(nsduilib)