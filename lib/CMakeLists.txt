cmake_minimum_required(VERSION 2.8)
project(CFACTER)

set(CFACTERLIB_SOURCES
  ${PROJECT_SOURCE_DIR}/cfacterlib.cc
  ${PROJECT_SOURCE_DIR}/cfacterimpl.cc
)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -Wall -Wextra -Werror -Wno-unused-parameter")

add_library(libcfacter SHARED ${CFACTERLIB_SOURCES})
set_target_properties(libcfacter PROPERTIES PREFIX "")
install (TARGETS libcfacter DESTINATION lib)