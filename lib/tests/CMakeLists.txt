cmake_minimum_required(VERSION 2.8.12)

# Set compiler-specific flags
if ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -Wall -Wextra -Werror -Wno-unused-parameter -Wno-tautological-constant-out-of-range-compare")
elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -Wall -Wextra -Werror -Wno-unused-parameter -Wno-unused-local-typedefs")
elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Intel")
elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
endif()

# Set the common (platform-independent) sources
set(LIBFACTER_TESTS_COMMON_SOURCES
    "${CMAKE_CURRENT_LIST_DIR}/environment.cc"
    "${CMAKE_CURRENT_LIST_DIR}/facts/array_value.cc"
    "${CMAKE_CURRENT_LIST_DIR}/facts/integer_value.cc"
    "${CMAKE_CURRENT_LIST_DIR}/facts/posix/uptime_resolver.cc"
    "${CMAKE_CURRENT_LIST_DIR}/util/string.cc"
    "${CMAKE_CURRENT_LIST_DIR}/util/file.cc"
    "${CMAKE_CURRENT_LIST_DIR}/util/option_set.cc"
    "${CMAKE_CURRENT_LIST_DIR}/fixtures.cc"
)

# Set the POSIX sources if on a POSIX platform
if (UNIX)
    set(LIBFACTER_TESTS_POSIX_SOURCES
        "${CMAKE_CURRENT_LIST_DIR}/execution/posix/execution.cc"
        "${CMAKE_CURRENT_LIST_DIR}/util/posix/scoped_addrinfo.cc"
        "${CMAKE_CURRENT_LIST_DIR}/util/posix/scoped_descriptor.cc"
        "${CMAKE_CURRENT_LIST_DIR}/logging/posix/logging.cc"
    )
endif()

# Set the platform-specific sources
if ("${CMAKE_SYSTEM_NAME}" MATCHES "Darwin")
    set(LIBFACTER_TESTS_PLATFORM_SOURCES
        "${CMAKE_CURRENT_LIST_DIR}/util/bsd/scoped_ifaddrs.cc"
    )
elseif ("${CMAKE_SYSTEM_NAME}" MATCHES "Linux")
    set(LIBFACTER_TESTS_PLATFORM_SOURCES
        "${CMAKE_CURRENT_LIST_DIR}/util/bsd/scoped_ifaddrs.cc"
    )
endif()

include_directories(
    ../inc
    ${LOG4CXX_INCLUDE_DIRS}
    ${Boost_INCLUDE_DIRS}
    ${GMOCK_INCLUDE_DIRS}
)

add_executable(libfacter_test ${LIBFACTER_TESTS_COMMON_SOURCES} ${LIBFACTER_TESTS_PLATFORM_SOURCES} ${LIBFACTER_TESTS_POSIX_SOURCES})
target_link_libraries(libfacter_test libfacter ${LOG4CXX_LIBRARIES} ${Boost_LIBRARIES} ${GMOCK_LIBRARIES})

# Generate a file containing the above version numbers
configure_file (
    "${CMAKE_CURRENT_LIST_DIR}/fixtures.hpp.in"
    "${CMAKE_CURRENT_LIST_DIR}/fixtures.hpp"
)
