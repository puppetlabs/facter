################################################################################
#
# CMake script for finding openssl.
# The default CMake search process is used to locate files.
#
# This script creates the following variables:
#  OPENSSL_FOUND: Boolean that indicates if the package was found
#  OPENSSL_INCLUDE_DIRS: Paths to the necessary header files
#  OPENSSL_LIBRARIES: Package libraries
#  OPENSSL_LIBRARY_DIRS: Path to package libraries
#
################################################################################

include(FindPackageHandleStandardArgs)

# See if OPENSSL_ROOT is not already set in CMake
if (NOT OPENSSL_ROOT)
    # See if OPENSSL_ROOT is set in process environment
    if (NOT $ENV{OPENSSL_ROOT} STREQUAL "")
        set(OPENSSL_ROOT "$ENV{OPENSSL_ROOT}")
        message(STATUS "Detected OPENSSL_ROOT set to '${OPENSSL_ROOT}'")
    endif()
endif()

# If OPENSSL_ROOT is available, set up our hints
if (OPENSSL_ROOT)
    set(OPENSSL_INCLUDE_HINTS HINTS "${OPENSSL_ROOT}/include" "${OPENSSL_ROOT}")
    set(OPENSSL_LIBRARY_HINTS HINTS "${OPENSSL_ROOT}/lib")
endif()

# Find headers and libraries
find_path(OPENSSL_INCLUDE_DIR NAMES openssl/ssl.h ${OPENSSL_INCLUDE_HINTS})
if (WIN32)
  find_library(OPENSSL_LIBRARY NAMES libeay32 ${OPENSSL_LIBRARY_HINTS})
else()
  find_library(OPENSSL_LIBRARY NAMES crypto ${OPENSSL_LIBRARY_HINTS})
endif()

# Set OPENSSL_FOUND honoring the QUIET and REQUIRED arguments
find_package_handle_standard_args(OPENSSL DEFAULT_MSG OPENSSL_LIBRARY OPENSSL_INCLUDE_DIR)

# Output variables
if(OPENSSL_FOUND)
  # Include dirs
  set(OPENSSL_INCLUDE_DIRS ${OPENSSL_INCLUDE_DIR})

  # Libraries
  if(OPENSSL_LIBRARY)
    set(OPENSSL_LIBRARIES ${OPENSSL_LIBRARY})
  else()
    set(OPENSSL_LIBRARIES "")
  endif()

  # Link dirs
  get_filename_component(OPENSSL_LIBRARY_DIRS ${OPENSSL_LIBRARY} PATH)
endif()

# Advanced options for not cluttering the cmake UIs
mark_as_advanced(OPENSSL_INCLUDE_DIR OPENSSL_LIBRARY)