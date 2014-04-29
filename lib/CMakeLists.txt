cmake_minimum_required(VERSION 2.8.12)

# Set compiler-specific flags
if ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -Wall -Wextra -Werror -Wno-unused-parameter -Wno-tautological-constant-out-of-range-compare")
elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -Wall -Wextra -Werror -Wno-unused-parameter")
elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Intel")
elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
endif()

# Set the common (platform-independent) sources
set(LIBFACTER_COMMON_SOURCES
    "${CMAKE_CURRENT_LIST_DIR}/src/facterlib.cc"
    "${CMAKE_CURRENT_LIST_DIR}/src/facts/array_value.cc"
    "${CMAKE_CURRENT_LIST_DIR}/src/facts/fact.cc"
    "${CMAKE_CURRENT_LIST_DIR}/src/facts/fact_map.cc"
    "${CMAKE_CURRENT_LIST_DIR}/src/facts/fact_resolver.cc"
    "${CMAKE_CURRENT_LIST_DIR}/src/facts/string_value.cc"
    "${CMAKE_CURRENT_LIST_DIR}/src/util/file.cc"
    "${CMAKE_CURRENT_LIST_DIR}/src/util/string.cc"
)

# Set the POSIX sources if on a POSIX platform
if (UNIX)
    set(LIBFACTER_POSIX_SOURCES
        "${CMAKE_CURRENT_LIST_DIR}/src/execution/posix/execution.cc"
        "${CMAKE_CURRENT_LIST_DIR}/src/facts/posix/kernel_resolver.cc"
        "${CMAKE_CURRENT_LIST_DIR}/src/facts/posix/networking_resolver.cc"
        "${CMAKE_CURRENT_LIST_DIR}/src/facts/posix/operating_system_resolver.cc"
        "${CMAKE_CURRENT_LIST_DIR}/src/logging/posix/logging.cc"
    )
endif()

# Set the platform-specific sources
if ("${CMAKE_SYSTEM_NAME}" MATCHES "Darwin")
    set(LIBFACTER_PLATFORM_SOURCES
        "${CMAKE_CURRENT_LIST_DIR}/src/facts/bsd/networking_resolver.cc"
        "${CMAKE_CURRENT_LIST_DIR}/src/facts/osx/networking_resolver.cc"
        "${CMAKE_CURRENT_LIST_DIR}/src/facts/osx/platform.cc"
    )
elseif ("${CMAKE_SYSTEM_NAME}" MATCHES "Linux")
    set(LIBFACTER_PLATFORM_SOURCES
        "${CMAKE_CURRENT_LIST_DIR}/src/facts/bsd/networking_resolver.cc"
        "${CMAKE_CURRENT_LIST_DIR}/src/facts/linux/lsb_resolver.cc"
        "${CMAKE_CURRENT_LIST_DIR}/src/facts/linux/networking_resolver.cc"
        "${CMAKE_CURRENT_LIST_DIR}/src/facts/linux/operating_system_resolver.cc"
        "${CMAKE_CURRENT_LIST_DIR}/src/facts/linux/platform.cc"
    )
endif()

# Add the library target without a prefix (name already has the 'lib')
add_library(libfacter SHARED ${LIBFACTER_COMMON_SOURCES} ${LIBFACTER_POSIX_SOURCES} ${LIBFACTER_PLATFORM_SOURCES})
set_target_properties(libfacter PROPERTIES PREFIX "")
install(TARGETS libfacter DESTINATION .)

# Set include directories
include_directories(
    inc
    ${RE2_INCLUDE_DIRS}
    ${RAPIDJSON_INCLUDE_DIRS}
    ${LOG4CXX_INCLUDE_DIRS}
    ${BOOST_INCLUDE_DIRS}
)

# Link in additional libraries
target_link_libraries(libfacter
    pthread
    ${RE2_LIBRARIES}
    ${LOG4CXX_LIBRARIES}
)

# Add a dependency on rapidjson
add_dependencies(libfacter rapidjson)

add_subdirectory(tests)
