################################################################################
#
# CMake script for finding RE2.
# The default CMake search process is used to locate files.
#
# This script creates the following variables:
#  RE2_FOUND: Boolean that indicates if the package was found
#  RE2_INCLUDE_DIRS: Paths to the necessary header files
#  RE2_LIBRARIES: Package libraries
#  RE2_LIBRARY_DIRS: Path to package libraries
#
################################################################################

include(FindPackageHandleStandardArgs)

# See if RE2_ROOT is not already set in CMake
if (NOT RE2_ROOT)
    # See if RE2_ROOT is set in process environment
    if (NOT $ENV{RE2_ROOT} STREQUAL "")
        set(RE2_ROOT "$ENV{RE2_ROOT}")
	message(STATUS "Detected RE2_ROOT set to '${RE2_ROOT}'")
    endif()
endif()

# If RE2_ROOT is available, set up our hints
if (RE2_ROOT)
    set(RE2_INCLUDE_HINTS HINTS "${RE2_ROOT}/include" "${RE2_ROOT}")
    set(RE2_LIBRARY_HINTS HINTS "${RE2_ROOT}/lib")
endif()

# Find headers and libraries
find_path(RE2_INCLUDE_DIR NAMES re2/re2.h ${RE2_INCLUDE_HINTS})
find_library(RE2_LIBRARY NAMES re2 ${RE2_LIBRARY_HINTS})

# Set RE2_FOUND honoring the QUIET and REQUIRED arguments
find_package_handle_standard_args(RE2 DEFAULT_MSG RE2_LIBRARY RE2_INCLUDE_DIR)

# Output variables
if(RE2_FOUND)
  # Include dirs
  set(RE2_INCLUDE_DIRS ${RE2_INCLUDE_DIR})

  # Libraries
  if(RE2_LIBRARY)
    set(RE2_LIBRARIES ${RE2_LIBRARY})
  else()
    set(RE2_LIBRARIES "")
  endif()

  # Link dirs
  get_filename_component(RE2_LIBRARY_DIRS ${RE2_LIBRARY} PATH)
endif()

# Advanced options for not cluttering the cmake UIs
mark_as_advanced(RE2_INCLUDE_DIR RE2_LIBRARY)