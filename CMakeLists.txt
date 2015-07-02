cmake_minimum_required(VERSION 2.8.12)
project(FACTER)

# Set this early, so it's available. AIX gets weird, man.
if("${CMAKE_SYSTEM_NAME}" MATCHES "AIX")
    set(AIX TRUE)
endif()

if (NOT CMAKE_BUILD_TYPE)
    message(STATUS "Defaulting to a release build.")
    set(CMAKE_BUILD_TYPE "Release" CACHE STRING "Choose the type of build, options are: None Debug Release RelWithDebInfo MinSizeRel." FORCE)
endif()

option(YAMLCPP_STATIC "Use yaml-cpp's static libraries" OFF)

option(CURL_STATIC "Use curl's static libraries" OFF)

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

if ("${CMAKE_SYSTEM_NAME}" MATCHES "Darwin")
    # Allow searching in boxen installed homebrew directories
    # http://stackoverflow.com/questions/1487752/how-do-i-instruct-cmake-to-look-for-libraries-installed-by-macports
    set(CMAKE_LIBRARY_PATH ${CMAKE_LIBRARY_PATH} /opt/boxen/homebrew/lib)
    set(CMAKE_INCLUDE_PATH ${CMAKE_INCLUDE_PATH} /opt/boxen/homebrew/include)
endif()

# Before we find any packages, we want to pull in the common leatherman options, as they can affect commonly-used packages.
include(options)

# We use system, filesystem, regex, and log directly. Log depends on system, filesystem, datetime, and thread.
# For Windows, we've added locale to correctly generate a UTF-8 compatible default locale.
set(BOOST_PKGS program_options system filesystem date_time thread regex log chrono)
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

if ((("${CMAKE_SYSTEM_NAME}" MATCHES "Linux") OR WIN32) AND NOT WITHOUT_CURL)
    find_package(CURL)
    if (CURL_FOUND)
        add_definitions(-DUSE_CURL)
        if (CURL_STATIC)
            add_definitions(-DCURL_STATICLIB)
            if (WIN32)
                # Linking statically on Windows requires some extra libraries.
                list(APPEND CURL_LIBRARIES wldap32.lib ws2_32.lib)
            endif()
        endif()
    endif()
    set_package_properties(CURL PROPERTIES DESCRIPTION "A free and easy-to-use client-side URL transfer library" URL "http://curl.haxx.se/libcurl/")
    set_package_properties(CURL PROPERTIES TYPE OPTIONAL PURPOSE "Enables facts that require HTTP.")
endif()

if (NOT WITHOUT_JRUBY AND NOT WIN32)
    find_package(JNI)
    set_package_properties(JNI PROPERTIES DESCRIPTION "Java Native Interface (JNI) is a programming framework that enables Java code running in a Java Virtual Machine (JVM) to call and be called by native applications.")
    set_package_properties(JNI PROPERTIES TYPE OPTIONAL PURPOSE "Enables JRuby support in Facter.")

    if (JNI_FOUND)
        find_package(Java)
        set_package_properties(Java PROPERTIES DESCRIPTION "Java compiler for JNI.")
        set_package_properties(Java PROPERTIES TYPE OPTIONAL PURPOSE "Enables JRuby support in Facter.")

        if (Java_JAVAC_EXECUTABLE)
            set(JRUBY_SUPPORT TRUE)
            set(CMAKE_JAVA_COMPILE_FLAGS -source 1.6 -target 1.6)
            add_definitions(-DUSE_JRUBY_SUPPORT)
        endif()
    endif()
endif()

# Display a summary of the features
include(FeatureSummary)
feature_summary(WHAT ALL)

# Set RPATH if not installing to a system library directory
list(FIND CMAKE_PLATFORM_IMPLICIT_LINK_DIRECTORIES "${CMAKE_INSTALL_PREFIX}/lib" INSTALL_IS_SYSTEM_DIR)
if ("${INSTALL_IS_SYSTEM_DIR}" STREQUAL "-1")
    set(CMAKE_MACOSX_RPATH 1)
    set(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")
endif()

# Pull in common cflags setting from leatherman
include(cflags)
set(FACTER_CXX_FLAGS "${LEATHERMAN_CXX_FLAGS}")

# Force all binaries to be created in the same location.
set(EXECUTABLE_OUTPUT_PATH ${PROJECT_BINARY_DIR}/bin)
if (WIN32)
    # On Windows, DLL paths aren't hardcoded in the executable. We place all the executables and libraries
    # in the same directory to avoid having to setup the DLL search path in the dev environment.
    set(LIBRARY_OUTPUT_PATH ${PROJECT_BINARY_DIR}/bin)
else()
    set(LIBRARY_OUTPUT_PATH ${PROJECT_BINARY_DIR}/lib)
endif()

add_definitions(${LEATHERMAN_DEFINITIONS})

# Include vendor libraries
set(RAPIDJSON_INCLUDE_DIRS "${PROJECT_SOURCE_DIR}/vendor/rapidjson-0.11/include")
if (WIN32)
    # We disabled installing Boost.Nowide; add back the library we use.
    # CMake doesn't allow install targets in a different directory, so get the file.
    install(FILES ${CMAKE_BINARY_DIR}/bin/libnowide.dll DESTINATION bin)
endif()

# Build against our leatherman tooling
set(LEATHERMAN_USE_LOCALE TRUE)
set(LEATHERMAN_USE_CATCH TRUE)
set(LEATHERMAN_USE_NOWIDE TRUE)
set(LEATHERMAN_USE_LOGGING TRUE)
set(LEATHERMAN_USE_UTIL TRUE)
if(WIN32)
	set(LEATHERMAN_USE_WINDOWS TRUE)
endif()
set(LEATHERMAN_USE_FILE_UTIL TRUE)
add_subdirectory("vendor/leatherman")

#
# Add cpplint and cppcheck targets
#
file(GLOB_RECURSE ALL_SOURCES lib/src/*.cc lib/inc/*.hpp lib/inc/version.h exe/*.cc exe/*.hpp exe/*.h)
add_cpplint_files(${ALL_SOURCES})
enable_cpplint()

add_cppcheck_dirs("${PROJECT_SOURCE_DIR}/lib" "${PROJECT_SOURCE_DIR}/exe")
enable_cppcheck()

# Pull in helper macros for working with leatherman libraries
include(leatherman)

add_subdirectory(lib)
add_subdirectory(exe)

# Add test executables for unit testing
add_test(NAME "libfacter\\ tests" COMMAND libfacter_test)
if (RUBY_FOUND)
    find_program(BUNDLER_PATH NAMES bundle.bat bundle)
    if (BUNDLER_PATH)
        add_test(NAME "libfacter\\ specs" COMMAND ${BUNDLER_PATH} exec rspec WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}/lib")
    endif()
endif()
add_test(NAME "facter\\ smoke" COMMAND facter)

# Install the man page
if ("${CMAKE_SYSTEM_NAME}" MATCHES "OpenBSD")
    set(MANDIR man/man8/)
else()
    set(MANDIR share/man/man8/)
endif()

install(FILES ${PROJECT_SOURCE_DIR}/man/man8/facter.8 DESTINATION ${MANDIR})
