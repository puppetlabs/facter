cmake_minimum_required(VERSION 2.8.12)
project(CFACTER)
include(${VENDOR_DIRECTORY}/re2.cmake)

set(CFACTERLIB_SOURCES
    "${PROJECT_SOURCE_DIR}/cfacterlib.cc"
    "${PROJECT_SOURCE_DIR}/cfacterimpl.cc"
)

if ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -Wall -Wextra -Werror -Wno-unused-parameter -Wno-tautological-constant-out-of-range-compare")
elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -Wall -Wextra -Werror -Wno-unused-parameter")
elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Intel")
elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
endif()

# Add the library target without a prefix (name already has the 'lib')
add_library(libcfacter SHARED ${CFACTERLIB_SOURCES})
set_target_properties(libcfacter PROPERTIES PREFIX "")
install(TARGETS libcfacter DESTINATION .)

# Set include directories
include_directories(
    ${RE2_INCLUDE_DIRS}
)

# Link in additional libraries
target_link_libraries(libcfacter
    pthread
    libre2
)