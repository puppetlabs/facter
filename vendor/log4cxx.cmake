cmake_minimum_required(VERSION 2.8.12)
include(ExternalProject)
include(${VENDOR_DIRECTORY}/aprutil.cmake)

set(LOG4CXX_SHARED_OBJECT_FILE "liblog4cxx.so.10.0.0")

if ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
    set(LOG4CXX_SHARED_OBJECT_FILE "liblog4cxx.10.0.0.dylib")
    set(LOG4CXX_LD_FLAGS "-Wl,-install_name,@rpath/${LOG4CXX_SHARED_OBJECT_FILE},-rpath,${CMAKE_BINARY_DIR}/src/aprutil/.libs,-rpath,${CMAKE_BINARY_DIR}/src/apr/.libs")
    set(LOG4CXX_CPP_FLAGS "-Wno-empty-body")
elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Intel")
elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
endif()

# Add an external project to build log4cxx
externalproject_add(
    log4cxx
    PREFIX "${PROJECT_BINARY_DIR}"
    URL "file://${VENDOR_DIRECTORY}/apache-log4cxx-0.10.0.tar.gz"
    URL_MD5 "b30ffb8da3665178e68940ff7a61084c"
    CONFIGURE_COMMAND ./configure --enable-shared --disable-static --with-apr=${APR_CONFIG_PATH} --with-apr-util=${APR_UTIL_CONFIG_PATH} CXXFLAGS=${LOG4CXX_CPP_FLAGS} LDFLAGS=${LOG4CXX_LD_FLAGS}
    PATCH_COMMAND patch -p1 < ${VENDOR_DIRECTORY}/log4cxx.patch
    BUILD_COMMAND make
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND ""
    ALWAYS 1
)
add_dependencies(log4cxx aprutil)

# Set some useful variables based on the source directory
externalproject_get_property(log4cxx SOURCE_DIR)
set(LOG4CXX_INCLUDE_DIRS "${SOURCE_DIR}/src/main/include")
set(LOG4CXX_SHARED_OBJECT_PATH "${SOURCE_DIR}/src/main/cpp/.libs/${LOG4CXX_SHARED_OBJECT_FILE}")
set(LOG4CXX_LIBRARIES "${LOG4CXX_SHARED_OBJECT_PATH}")

set_directory_properties(PROPERTIES ADDITIONAL_MAKE_CLEAN_FILES "${SOURCE_DIR}/src/main/cpp/*.o;${SOURCE_DIR}/src/main/cpp/.libs")

add_library(liblog4cxx SHARED IMPORTED)
set_target_properties(liblog4cxx
    PROPERTIES PREFIX ""
    IMPORTED_LOCATION "${LOG4CXX_SHARED_OBJECT_PATH}"
)
add_dependencies(liblog4cxx log4cxx)
install(FILES "${LOG4CXX_SHARED_OBJECT_PATH}" DESTINATION .)
