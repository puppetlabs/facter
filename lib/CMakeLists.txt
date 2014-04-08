cmake_minimum_required(VERSION 2.8.12)
include(${VENDOR_DIRECTORY}/re2.cmake)
include(${VENDOR_DIRECTORY}/rapidjson.cmake)

set(CFACTERLIB_SOURCES
    "${CMAKE_CURRENT_LIST_DIR}/cfacterlib.cc"
    "${CMAKE_CURRENT_LIST_DIR}/cfacterimpl.cc"
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
    ${RAPIDJSON_INCLUDE_DIRS}
)

# Link in additional libraries
target_link_libraries(libcfacter
    pthread
    libre2
)

# Add a dependency on rapidjson
add_dependencies(libcfacter rapidjson)
