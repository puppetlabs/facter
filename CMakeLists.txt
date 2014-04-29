cmake_minimum_required(VERSION 2.8.12)
project(CFACTER)

set(VENDOR_DIRECTORY "${PROJECT_SOURCE_DIR}/vendor")
list(APPEND CMAKE_MODULE_PATH ${VENDOR_DIRECTORY})

set(CFACTER_VERSION_MAJOR 0)
set(CFACTER_VERSION_MINOR 1)
set(CFACTER_VERSION_PATCH 0)

# Generate a file containing the above version numbers
configure_file (
    "${PROJECT_SOURCE_DIR}/version.h.in"
    "${PROJECT_SOURCE_DIR}/version.h"
)

# Find Boost
find_package(Boost 1.48 COMPONENTS program_options system filesystem REQUIRED)
if (NOT Boost_FOUND)
    message(FATAL_ERROR "Boost 1.48 or newer is required.  Please install it before building.")
endif()

# Find Log4cxx
find_package(LOG4CXX REQUIRED)
if (NOT LOG4CXX_FOUND)
    message(FATAL_ERROR "Log4cxx version 10.0 is required.  Please install it before building.")
endif()

# Find RE2
find_package(RE2 REQUIRED)
if (NOT RE2_FOUND)
    message(FATAL_ERROR "RE2 is required.  Please install it before building.")
endif()

# Include vendor libraries
include(${VENDOR_DIRECTORY}/rapidjson.cmake)
include(${VENDOR_DIRECTORY}/gmock.cmake)

if(APPLE)
    # Set the RPATH to OSX magic value @executable_path (where the loading executable is located)
    set(CMAKE_INSTALL_RPATH "@executable_path/")
    set(CMAKE_MACOSX_RPATH 1)
elseif(UNIX)
    # Set the RPATH to be magic value $ORIGIN (where the loading executable is located)
    set(CMAKE_INSTALL_RPATH "$ORIGIN")
endif()

# Set the default install path
if (CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    set(CMAKE_INSTALL_PREFIX "/opt/cfacter" CACHE PATH "default install path" FORCE)
endif()

add_subdirectory(exe)

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
