cmake_minimum_required(VERSION 2.8.12)
project(CFACTER)

if (NOT CMAKE_BUILD_TYPE)
    message(STATUS "Defaulting to a release build.")
    set(CMAKE_BUILD_TYPE "Release" CACHE STRING "Choose the type of build, options are: None Debug Release RelWithDebInfo MinSizeRel." FORCE)
endif()

set(VENDOR_DIRECTORY "${PROJECT_SOURCE_DIR}/vendor")
list(APPEND CMAKE_MODULE_PATH ${VENDOR_DIRECTORY})

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
