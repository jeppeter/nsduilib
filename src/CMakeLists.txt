cmake_minimum_required(VERSION 2.8) 

project(nsduilib)
include(cmake/functions.cmake)

CheckMSVC()
add_definitions(-DUNICODE -D_UNICODE)
set(CMAKE_BUILD_TYPE Release) 

set(CMAKE_CONFIGURATION_TYPES "Debug;Release")
add_subdirectory(output_debug)
add_subdirectory(duilib)
add_subdirectory(nsduilib)