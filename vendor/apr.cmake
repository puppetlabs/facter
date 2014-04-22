cmake_minimum_required(VERSION 2.8.12)
include(ExternalProject)

set(APR_SHARED_OBJECT_FILE "libapr-1.so.0.5.0")

if ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
    set(APR_SHARED_OBJECT_FILE "libapr-1.0.dylib")
    set(APR_LD_FLAGS "-Wl,-install_name,@rpath/${APR_SHARED_OBJECT_FILE}")
    set(APR_CPP_FLAGS "-Wno-empty-body")
elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Intel")
elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
endif()

# Add an external project to build apr
externalproject_add(
    apr
    PREFIX "${PROJECT_BINARY_DIR}"
    URL "file://${VENDOR_DIRECTORY}/apr-1.5.0.tar.gz"
    URL_MD5 "6419a8f7e89ad51b5bad7b0c84cc818c"
    CONFIGURE_COMMAND ./configure --enable-shared --disable-static CXXFLAGS=${APR_CPP_FLAGS} LDFLAGS=${APR_LD_FLAGS}
    BUILD_COMMAND make
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND ""
    ALWAYS 1
)

# Set some useful variables based on the source directory
externalproject_get_property(apr SOURCE_DIR)
set(APR_INCLUDE_DIRS "${SOURCE_DIR}/include")
set(APR_SHARED_OBJECT_PATH "${SOURCE_DIR}/.libs/${APR_SHARED_OBJECT_FILE}")
set(APR_LIBRARIES "${APR_SHARED_OBJECT_PATH}")
set(APR_CONFIG_PATH "${SOURCE_DIR}/apr-1-config")

set_directory_properties(PROPERTIES ADDITIONAL_MAKE_CLEAN_FILES "${SOURCE_DIR}/.libs")

add_library(libapr SHARED IMPORTED)
set_target_properties(libapr
    PROPERTIES PREFIX ""
    IMPORTED_LOCATION "${APR_SHARED_OBJECT_PATH}"
)
add_dependencies(libapr apr)
install(FILES "${APR_SHARED_OBJECT_PATH}" DESTINATION .)
