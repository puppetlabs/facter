cmake_minimum_required(VERSION 2.8.12)
project(CFACTER)

if (NOT CMAKE_BUILD_TYPE)
    message(STATUS "Defaulting to a release build.")
    set(CMAKE_BUILD_TYPE "Release" CACHE STRING "Choose the type of build, options are: None Debug Release RelWithDebInfo MinSizeRel." FORCE)
endif()

option(BOOST_STATIC "Use Boost's static libraries" OFF)
option(YAMLCPP_STATIC "Use yaml-cpp's static libraries" OFF)
option(COVERALLS "Generate code coverage for Coveralls.io" OFF)

set(FACTER_PATH "" CACHE PATH "Specify the location to look for specific binaries before trying PATH.")
if (FACTER_PATH)
    # Specify a preferred location for binary lookup that will be prioritized over PATH.
    file(TO_CMAKE_PATH ${FACTER_PATH} FACTER_PATH_FIXED)
    add_definitions(-DFACTER_PATH="${FACTER_PATH_FIXED}")
    message(STATUS "Prioritizing binary lookup in ${FACTER_PATH_FIXED}")
endif()

set(FACTER_RUBY "" CACHE FILEPATH "Specify the location of libruby at compile-time, bypassing dynamic lookup.")
if (FACTER_RUBY)
    file(TO_CMAKE_PATH ${FACTER_RUBY} FACTER_RUBY_PATH)
    add_definitions(-DFACTER_RUBY="${FACTER_RUBY_PATH}")
    message(STATUS "Fixing lookup for libruby to ${FACTERPATH_PATH}")
endif()

enable_testing()

list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake")
list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/vendor/leatherman/cmake")
include(cotire)
if (MINGW)
    # MinGW crashes with large pre-compiled headers; ours definitely exceeds the limit.
    # See http://stackoverflow.com/questions/10841306/cc1plus-exe-crash-when-using-large-precompiled-header-file
    set(PRECOMPILED_HEADERS FALSE)
else()
    set(PRECOMPILED_HEADERS TRUE)
endif()

if ("${CMAKE_SYSTEM_NAME}" MATCHES "Darwin")
    # Allow searching in boxen installed homebrew directories
    # http://stackoverflow.com/questions/1487752/how-do-i-instruct-cmake-to-look-for-libraries-installed-by-macports
    set(CMAKE_LIBRARY_PATH ${CMAKE_LIBRARY_PATH} /opt/boxen/homebrew/lib)
    set(CMAKE_INCLUDE_PATH ${CMAKE_INCLUDE_PATH} /opt/boxen/homebrew/include)
endif()

# Find our dependency packages
if (BOOST_STATIC)
    set(Boost_USE_STATIC_LIBS ON)
else()
    # Boost.Log requires that BOOST_LOG_DYN_LINK is set when using dynamic linking. We set ALL for consistency.
    add_definitions(-DBOOST_ALL_DYN_LINK)
    set(Boost_USE_STATIC_LIBS OFF)
endif()

# We use system, filesystem, regex, and log directly. Log depends on system, filesystem, datetime, and thread.
# For Windows, we've added locale to correctly generate a UTF-8 compatible default locale.
set(BOOST_PKGS program_options system filesystem date_time thread regex log)
if (WIN32)
    list(APPEND BOOST_PKGS locale)
endif()
find_package(Boost 1.54 REQUIRED COMPONENTS ${BOOST_PKGS})

find_package(Ruby 1.9)

find_package(YAMLCPP REQUIRED)
if (NOT WITHOUT_OPENSSL)
    find_package(OPENSSL)
endif()
if ("${CMAKE_SYSTEM_NAME}" MATCHES "Linux" AND NOT WITHOUT_BLKID)
    find_package(BLKID)
endif()

if ("${CMAKE_SYSTEM_NAME}" MATCHES "Linux" AND NOT WITHOUT_CURL)
    find_package(CURL)
    if (CURL_FOUND)
        add_definitions(-DUSE_CURL)
    endif()
    set_package_properties(CURL PROPERTIES DESCRIPTION "A free and easy-to-use client-side URL transfer library" URL "http://curl.haxx.se/libcurl/")
    set_package_properties(CURL PROPERTIES TYPE OPTIONAL PURPOSE "Enables facts that require HTTP.")
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
    find_library(KSTAT_LIBRARY kstat)
    if (KSTAT_LIBRARY)
      set(CMAKE_REQUIRED_LIBRARIES ${CMAKE_REQUIRED_LIBRARIES} ${KSTAT_LIBRARY})
        link_libraries(kstat)
    endif()
endif()

# Set RPATH if not installing to a system library directory
list(FIND CMAKE_PLATFORM_IMPLICIT_LINK_DIRECTORIES "${CMAKE_INSTALL_PREFIX}/lib" INSTALL_IS_SYSTEM_DIR)
if ("${INSTALL_IS_SYSTEM_DIR}" STREQUAL "-1")
    set(CMAKE_MACOSX_RPATH 1)
    set(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")
endif()

# Pull in common cflags setting from leatherman
include(cflags)
set(FACTER_CXX_FLAGS "${LEATHERMAN_CXX_FLAGS}")

# Add Code Coverage
if (COVERALLS)
    set(FACTER_CXX_FLAGS "${FACTER_CXX_FLAGS} -fprofile-arcs -ftest-coverage")
endif()

# Force all binaries to be created in the same location.
set(EXECUTABLE_OUTPUT_PATH ${PROJECT_BINARY_DIR}/bin)
if (WIN32)
    # On Windows, DLL paths aren't hardcoded in the executable. We place all the executables and libraries
    # in the same directory to avoid having to setup the DLL search path in the dev environment.
    set(LIBRARY_OUTPUT_PATH    ${PROJECT_BINARY_DIR}/bin)

    # We currently support Windows Server 2003, which requires using deprecated APIs.
    # See http://msdn.microsoft.com/en-us/library/windows/desktop/aa383745(v=vs.85).aspx for version strings.
    # When Server 2003 support is discontinued, the networking facts implementation can be cleaned up, and
    # we can statically link symbols that are currently being looked up at runtime.
    # add_definitions(-DWINVER=0x0600 -D_WIN32_WINNT=0x0600)

    # The GetUserNameEx function requires the application have a defined security level.
    # We define security sufficient to get the current user's info.
    add_definitions(-DSECURITY_WIN32)

    # Use UNICODE APIs on Windows
    add_definitions(-DUNICODE -D_UNICODE)
else()
    add_definitions(-DUSE_POSIX_FUNCTIONS)
endif()

# Boost compilation options
add_definitions(-DBOOST_LOG_WITHOUT_WCHAR_T)

# Include vendor libraries
set(RAPIDJSON_INCLUDE_DIRS "${CMAKE_SOURCE_DIR}/vendor/rapidjson-0.11/include")
if (WIN32)
    # We disabled installing Boost.Nowide; add back the library we use.
    # CMake doesn't allow install targets in a different directory, so get the file.
    install(FILES ${CMAKE_BINARY_DIR}/bin/libnowide.dll DESTINATION bin)
endif()

#
# Add cpplint target
#
include(FindPythonInterp)
if (NOT PYTHONINTERP_FOUND)
    message(STATUS "Python not found; 'cpplint' target will not be available")
else()
    set(CPPLINT_FILTER
        "-build/c++11"            # <thread>, <condvar>, etc...
        "-whitespace/indent"      # We use 4 space indentation
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
        "-build/header_guard"     # Disable header guards (cpplint doesn't yet support enforcing #pragma once)
    )

    file(GLOB_RECURSE ALL_SOURCES lib/src/*.cc lib/src/*.h lib/src/*.hpp lib/inc/*.hpp lib/inc/*.h exe/*.cc exe/*.hpp exe/*.h)

    set(CPPLINT_PATH "${PROJECT_SOURCE_DIR}/scripts/cpplint.py")

    set(CPPLINT_ARGS "--extensions=cc,hpp,h")
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
    COMMAND cppcheck --enable=warning,performance --error-exitcode=2 --quiet "${PROJECT_SOURCE_DIR}/lib" "${PROJECT_SOURCE_DIR}/exe"
)

# Build against our leatherman tooling
set(LEATHERMAN_USE_LOCALE TRUE)
set(LEATHERMAN_USE_CATCH TRUE)
set(LEATHERMAN_USE_NOWIDE TRUE)
set(LEATHERMAN_USE_LOGGING TRUE)
add_subdirectory("vendor/leatherman")

# Pull in helper macros for working with leatherman libraries
include(leatherman)

add_subdirectory(lib)
add_subdirectory(exe)

# Add test executables for unit testing
add_test(NAME "library\\ tests" COMMAND libfacter_test)
add_test(NAME "cfacter\\ smoke" COMMAND cfacter)
