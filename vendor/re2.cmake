cmake_minimum_required(VERSION 2.8.12)
include(ExternalProject)

set(RE2_SHARED_OBJECT_FILE "libre2.so.0")

if ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
    # Fix the install name to be on the reference path
    set(RE2_LD_FLAGS "-Wl,-install_name,@rpath/${RE2_SHARED_OBJECT_FILE}")
elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
    set(RE2_CPP_FLAGS "-Wno-unused-local-typedefs")
elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Intel")
elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
endif()

# Add an external project to build re2
externalproject_add(
    re2
    PREFIX "${PROJECT_BINARY_DIR}"
    URL "file://${VENDOR_DIRECTORY}/re2-20140304.tgz"
    URL_MD5 "e82a6491efdf2bc928dc3779abcb3bc8"
    CONFIGURE_COMMAND ""
    BUILD_COMMAND make CPPFLAGS=${RE2_CPP_FLAGS} LDFLAGS=${RE2_LD_FLAGS}
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND ""
)

# Set some useful variables based on the source directory
externalproject_get_property(re2 SOURCE_DIR)
set(RE2_INCLUDE_DIRS "${SOURCE_DIR}")
set(RE2_SHARED_OBJECT_PATH "${SOURCE_DIR}/obj/so/${RE2_SHARED_OBJECT_FILE}")
set(RE2_LIBRARIES "${RE2_SHARED_OBJECT_PATH}")

set_directory_properties(PROPERTIES ADDITIONAL_MAKE_CLEAN_FILES "${SOURCE_DIR}/obj")

add_library(libre2 SHARED IMPORTED)
set_target_properties(libre2
    PROPERTIES PREFIX ""
    IMPORTED_LOCATION "${RE2_SHARED_OBJECT_PATH}"
)
add_dependencies(libre2 re2)
install(FILES "${RE2_SHARED_OBJECT_PATH}" DESTINATION .)
