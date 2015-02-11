cmake_minimum_required(VERSION 2.8.12)
project(CFACTER)

if (NOT CMAKE_BUILD_TYPE)
    message(STATUS "Defaulting to a release build.")
    set(CMAKE_BUILD_TYPE "Release" CACHE STRING "Choose the type of build, options are: None Debug Release RelWithDebInfo MinSizeRel." FORCE)
endif()

option(BOOST_STATIC "Use Boost's static libraries" OFF)
option(YAMLCPP_STATIC "Use yaml-cpp's static libraries" OFF)
option(COVERALLS "Generate code coverage for Coveralls.io" OFF)

enable_testing()

list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake")
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
if (RUBY_FOUND)
    execute_process(COMMAND ${RUBY_EXECUTABLE} -rrbconfig -e "puts RbConfig::CONFIG['vendordir']" OUTPUT_VARIABLE RUBY_VENDORDIR_OUT)
    string(STRIP ${RUBY_VENDORDIR_OUT} RUBY_VENDORDIR)
    message(STATUS "Ruby ${RUBY_VERSION} found, `make install` puts cfacter.rb in ${RUBY_VENDORDIR}")
    install(FILES gem/lib/cfacter.rb DESTINATION ${RUBY_VENDORDIR})
endif()

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

# Set compiler-specific flags
# Each of our project dirs sets CMAKE_CXX_FLAGS based on these. We do
# not set CMAKE_CXX_FLAGS globally because gtest is not warning-clean.
if ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
    set(FACTER_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -Wall -Wextra -Werror -Wno-unused-parameter -Wno-tautological-constant-out-of-range-compare")

    # Clang warns that 'register' is deprecated; 'register' is used throughout boost, so it can't be an error yet.
    # The warning flag is different on different clang versions so we need to extract the clang version.
    # And the Mavericks version of clang report its version in its own special way (at least on 10.9.5) - yay
    EXECUTE_PROCESS( COMMAND ${CMAKE_CXX_COMPILER} --version OUTPUT_VARIABLE clang_full_version_string )
    if ("${CMAKE_SYSTEM_NAME}" MATCHES "Darwin")
        string (REGEX REPLACE ".*based on LLVM ([0-9]+\\.[0-9]+).*" "\\1" CLANG_VERSION_STRING ${clang_full_version_string})
    else()
        string (REGEX REPLACE ".*clang version ([0-9]+\\.[0-9]+).*" "\\1" CLANG_VERSION_STRING ${clang_full_version_string})
    endif()
    MESSAGE( STATUS "CLANG_VERSION_STRING:         " ${CLANG_VERSION_STRING} )

    # Now based on clang version set the appropriate warning flag
    if ("${CLANG_VERSION_STRING}" VERSION_GREATER "3.4")
        set(FACTER_CXX_FLAGS "${FACTER_CXX_FLAGS} -Wno-deprecated-register")
    else()
        set(FACTER_CXX_FLAGS "${FACTER_CXX_FLAGS} -Wno-deprecated")
    endif()
elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
    # maybe-uninitialized is a relatively new GCC warning that Boost 1.57 violates; disable it for now until it's available in Clang as well
    # it's also sometimes wrong
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-maybe-uninitialized")

    # missing-field-initializers is disabled because GCC can't make up their mind how to treat C++11 initializers
    set(FACTER_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -Wall -Werror -Wno-unused-parameter -Wno-unused-local-typedefs -Wno-unknown-pragmas -Wno-missing-field-initializers")
    if (NOT "${CMAKE_SYSTEM_NAME}" MATCHES "SunOS")
        set(FACTER_CXX_FLAGS "${FACTER_CXX_FLAGS} -Wextra")
    endif()
elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Intel")
elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
    #set(FACTER_CXX_FLAGS "${CMAKE_CXX_FLAGS} /Wall")
endif()

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

    # We use networking APIs that require Windows Vista as a minimum. See
    # http://msdn.microsoft.com/en-us/library/windows/desktop/aa383745(v=vs.85).aspx
    # for version strings.
    # Supporting Windows Server 2003 requires
    # - using GetAdaptersInfo to get the network mask and Dhcp server; IPv6 mask may not be supported.
    # - Use WSA functions for sockaddr to string conversion, which includes more costly WSAStartup.
    # We currently load IsWow64Process from a DLL, but with these definitions that could be statically linked.
    add_definitions(-DWINVER=0x0600 -D_WIN32_WINNT=0x0600)

    # The GetUserNameEx function requires the application have a defined security level.
    # We define security sufficient to get the current user's info.
    add_definitions(-DSECURITY_WIN32)

    # Use UNICODE APIs on Windows
    add_definitions(-DUNICODE -D_UNICODE)
else()
    add_definitions(-DUSE_POSIX_FUNCTIONS)

    # On non-Windows platforms, this just tests the local implementations.
    set(BOOST_NOWIDE_SKIP_TESTS ON CACHE BOOL "Disable tests in Boost.Nowide")
endif()

# Disable installing Boost.Nowide so we don't pollute the installation.
set(BOOST_NOWIDE_SKIP_INSTALL ON CACHE BOOL "Disable installing Boost.Nowide")

# Boost compilation options
add_definitions(-DBOOST_LOG_WITHOUT_WCHAR_T)

# Include vendor libraries
add_subdirectory(vendor/gmock-1.7.0)
set(RAPIDJSON_INCLUDE_DIRS "${CMAKE_SOURCE_DIR}/vendor/rapidjson-0.11/include")
add_subdirectory(vendor/boost-nowide)
set(NOWIDE_INCLUDE_DIRS "${CMAKE_SOURCE_DIR}/vendor/boost-nowide")
if (WIN32)
    # Library only built on Windows, it would be empty on other platforms.
    set(NOWIDE_LIBRARIES nowide-shared)

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

    file(GLOB_RECURSE ALL_SOURCES lib/*.cc lib/*.h lib/*.hpp exe/*.cc exe/*.h exe/*.hpp)

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

add_subdirectory(lib)
add_subdirectory(exe)

# Add test executables for unit testing
add_test(NAME "library\\ tests" COMMAND libfacter_test --gtest_color=yes)
