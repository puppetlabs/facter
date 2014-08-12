cmake_minimum_required(VERSION 2.8.12)
project(CFACTER)

if (NOT CMAKE_BUILD_TYPE)
    message(STATUS "Defaulting to a release build.")
    set(CMAKE_BUILD_TYPE "Release" CACHE STRING "Choose the type of build, options are: None Debug Release RelWithDebInfo MinSizeRel." FORCE)
endif()

enable_testing()

list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake")

if ("${CMAKE_SYSTEM_NAME}" MATCHES "Darwin")
    # Allow searching in boxen installed homebrew directories
    # http://stackoverflow.com/questions/1487752/how-do-i-instruct-cmake-to-look-for-libraries-installed-by-macports
    set(CMAKE_LIBRARY_PATH ${CMAKE_LIBRARY_PATH} /opt/boxen/homebrew/lib)
    set(CMAKE_INCLUDE_PATH ${CMAKE_INCLUDE_PATH} /opt/boxen/homebrew/include)
endif()

# Find our dependency packages
# We use system, filesystem, regex, and log directly. Log depends on system, filesystem, datetime, and thread.
set(Boost_USE_STATIC_LIBS OFF)
add_definitions(-DBOOST_ALL_DYN_LINK)
find_package(Boost 1.54 REQUIRED COMPONENTS program_options system filesystem date_time thread regex log)
find_package(YAMLCPP REQUIRED)
if (NOT WITHOUT_OPENSSL)
    find_package(OPENSSL)
endif()
if ("${CMAKE_SYSTEM_NAME}" MATCHES "Linux" AND NOT WITHOUT_BLKID)
    find_package(BLKID)
endif()

# Display a summary of the features
include(FeatureSummary)
feature_summary(WHAT ALL)

if ("${CMAKE_SYSTEM_NAME}" MATCHES "SunOS")
    find_library(SOCKET_LIBRARY socket)
    if (SOCKET_LIBRARY)
        set(CMAKE_REQUIRED_LIBRARIES ${CMAKE_REQUIRED_LIBRARIES} ${SOCKET_LIBRARY})
        link_libraries(socket)
    endif()
endif()

# Set RPATH if not installing to a system library directory
list(FIND CMAKE_PLATFORM_IMPLICIT_LINK_DIRECTORIES "${CMAKE_INSTALL_PREFIX}/lib" INSTALL_IS_SYSTEM_DIR)
if ("${INSTALL_IS_SYSTEM_DIR}" STREQUAL "-1")
    set(CMAKE_MACOSX_RPATH 1)
    set(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")
endif()

# Set compiler-specific flags
# Each of our project dirs sets CMAKE_CXX_FLAGS based on these. We do
# not set CMAKE_CXX_FLAGS globally because gtest is not warning-clean.
if ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
    # Clang warns that 'register' is deprecated; 'register' is used throughout boost, so it can't be an error yet.
    set(FACTER_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -Wall -Wextra -Werror -Wno-unused-parameter -Wno-tautological-constant-out-of-range-compare -Wno-deprecated-register")
elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
    set(FACTER_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -Wall -Werror -Wno-unused-parameter -Wno-unused-local-typedefs -Wno-unknown-pragmas")
    if (NOT "${CMAKE_SYSTEM_NAME}" MATCHES "SunOS")
        set(FACTER_CXX_FLAGS "${FACTER_CXX_FLAGS} -Wextra")
    endif()
    if ("${CMAKE_SYSTEM_NAME}" MATCHES "Windows")
        set(FACTER_CXX_FLAGS "${FACTER_CXX_FLAGS} -Wno-missing-field-initializers")
    endif()
elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Intel")
elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
    #set(FACTER_CXX_FLAGS "${CMAKE_CXX_FLAGS} /Wall")
endif()

# Include vendor libraries
add_subdirectory(vendor/gmock-1.7.0)
set(RAPIDJSON_INCLUDE_DIRS "${CMAKE_SOURCE_DIR}/vendor/rapidjson-0.11/include")

#
# Add cpplint target
#
include(FindPythonInterp)
if (NOT PYTHONINTERP_FOUND)
    message(STATUS "Python not found; 'cpplint' target will not be available")
else()
    set(CPPLINT_FILTER
        "-build/include"          # Why?
        "-build/namespaces"       # What's a namespace to do
        "-legal/copyright"        # Not yet
        "-runtime/references"     # Not sure about this religion
        "-readability/streams"    # What?
        "-readability/namespace"  # Ignore nested namespace comment formatting
        "-whitespace/braces"      # Is there a k&r setting?
        "-whitespace/line_length" # Well yeah, but ... not just now
        "-runtime/arrays"         # Sizing an array with a 'const int' doesn't make it variable sized
        "-readability/todo"       # Seriously? todo comments need to identify an owner? pffft
        "-whitespace/empty_loop_body" # Can't handle do { ... } while(expr);
        "-runtime/int"            # Some C types are needed for library interop
        "-runtime/explicit"       # Using implicit conversion from string to regex for regex calls.
    )

    file(GLOB_RECURSE ALL_SOURCES lib/*.cc lib/*.h lib/*.hpp exe/*.cc exe/*.h exe/*.hpp)

    set(CPPLINT_PATH "${PROJECT_SOURCE_DIR}/scripts/cpplint.py")

    set(CPPLINT_ARGS "--extensions=cc,hpp,h;--root=lib/inc")
    if (CPPLINT_FILTER)
        string(REPLACE ";" "," CPPLINT_FILTER "${CPPLINT_FILTER}")
        set(CPPLINT_ARGS "${CPPLINT_ARGS};--filter=${CPPLINT_FILTER}")
    endif()
    if (MSVC)
        set(CPPLINT_ARGS "${CPPLINT_ARGS};--output=vs7")
    endif()

    add_custom_target(cpplint
        COMMAND ${PYTHON_EXECUTABLE} ${CPPLINT_PATH} ${CPPLINT_ARGS} ${ALL_SOURCES}
        VERBATIM
    )
endif()

add_custom_target(cppcheck
    COMMAND cppcheck lib exe
)

add_subdirectory(lib)
add_subdirectory(exe)

# Add test executables for unit testing
add_test("library\\ tests" "${PROJECT_BINARY_DIR}/lib/tests/libfacter_test" "--gtest_color=yes")
