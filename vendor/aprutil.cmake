cmake_minimum_required(VERSION 2.8.12)
include(ExternalProject)
include(${VENDOR_DIRECTORY}/apr.cmake)

set(APR_UTIL_SHARED_OBJECT_FILE "libaprutil-1.so.0.5.3")

if ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
    set(APR_UTIL_SHARED_OBJECT_FILE "libaprutil-1.0.dylib")
    set(APR_UTIL_LD_FLAGS "-Wl,-install_name,@rpath/${APR_UTIL_SHARED_OBJECT_FILE},-rpath,${CMAKE_BINARY_DIR}/src/apr/.libs")
elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Intel")
elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
endif()

# Add an external project to build apr-util
externalproject_add(
    aprutil
    PREFIX "${PROJECT_BINARY_DIR}"
    URL "file://${VENDOR_DIRECTORY}/apr-util-1.5.3.tar.gz"
    URL_MD5 "71a11d037240b292f824ba1eb537b4e3"
    CONFIGURE_COMMAND ./configure --with-apr=${APR_CONFIG_PATH} CXXFLAGS=${APR_UTIL_CPP_FLAGS} APRUTIL_LDFLAGS=${APR_UTIL_LD_FLAGS}
    BUILD_COMMAND make
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND ""
)
add_dependencies(aprutil apr)

# Set some useful variables based on the source directory
externalproject_get_property(aprutil SOURCE_DIR)
set(APR_UTIL_INCLUDE_DIRS "${SOURCE_DIR}/include")
set(APR_UTIL_SHARED_OBJECT_PATH "${SOURCE_DIR}/.libs/${APR_UTIL_SHARED_OBJECT_FILE}")
set(APR_UTIL_LIBRARIES "${APR_UTIL_SHARED_OBJECT_PATH}")
set(APR_UTIL_CONFIG_PATH "${SOURCE_DIR}/apu-1-config")

set_directory_properties(PROPERTIES ADDITIONAL_MAKE_CLEAN_FILES "${SOURCE_DIR}/.libs")

add_library(libaprutil SHARED IMPORTED)
set_target_properties(libaprutil
    PROPERTIES PREFIX ""
    IMPORTED_LOCATION "${APR_UTIL_SHARED_OBJECT_PATH}"
)
add_dependencies(libaprutil aprutil)
install(FILES "${APR_UTIL_SHARED_OBJECT_PATH}" DESTINATION .)
