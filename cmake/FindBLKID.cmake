################################################################################
#
# CMake script for finding libblkid.
# The default CMake search process is used to locate files.
#
# This script creates the following variables:
#  BLKID_FOUND: Boolean that indicates if the package was found
#  BLKID_INCLUDE_DIRS: Paths to the necessary header files
#  BLKID_LIBRARIES: Package libraries
#  BLKID_LIBRARY_DIRS: Path to package libraries
#
################################################################################

include(FindPackageHandleStandardArgs)

# See if BLKID_ROOT is not already set in CMake
if (NOT BLKID_ROOT)
    # See if BLKID_ROOT is set in process environment
    if (NOT $ENV{BLKID_ROOT} STREQUAL "")
        set(BLKID_ROOT "$ENV{BLKID_ROOT}")
        message(STATUS "Detected BLKID_ROOT set to '${BLKID_ROOT}'")
    endif()
endif()

# If BLKID_ROOT is available, set up our hints
if (BLKID_ROOT)
    set(BLKID_INCLUDE_HINTS HINTS "${BLKID_ROOT}/include" "${BLKID_ROOT}")
    set(BLKID_LIBRARY_HINTS HINTS "${BLKID_ROOT}/lib")
endif()

# Find headers and libraries
find_path(BLKID_INCLUDE_DIR NAMES blkid/blkid.h ${BLKID_INCLUDE_HINTS})
find_library(BLKID_LIBRARY NAMES blkid ${BLKID_LIBRARY_HINTS})

# Set BLKID_FOUND honoring the QUIET and REQUIRED arguments
find_package_handle_standard_args(BLKID DEFAULT_MSG BLKID_LIBRARY BLKID_INCLUDE_DIR)

# Output variables
if (BLKID_FOUND)
  # Include dirs
  set(BLKID_INCLUDE_DIRS ${BLKID_INCLUDE_DIR})

  # Libraries
  if (BLKID_LIBRARY)
    set(BLKID_LIBRARIES ${BLKID_LIBRARY})
  else()
    set(BLKID_LIBRARIES "")
  endif()

  # Link dirs
  get_filename_component(BLKID_LIBRARY_DIRS ${BLKID_LIBRARY} PATH)
endif()

# Advanced options for not cluttering the cmake UIs
mark_as_advanced(BLKID_INCLUDE_DIR BLKID_LIBRARY)
