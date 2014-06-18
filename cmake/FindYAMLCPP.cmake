################################################################################
#
# CMake script for finding yaml-cpp.
# The default CMake search process is used to locate files.
#
# This script creates the following variables:
#  YAMLCPP_FOUND: Boolean that indicates if the package was found
#  YAMLCPP_INCLUDE_DIRS: Paths to the necessary header files
#  YAMLCPP_LIBRARIES: Package libraries
#  YAMLCPP_LIBRARY_DIRS: Path to package libraries
#
################################################################################

include(FindPackageHandleStandardArgs)

# See if YAMLCPP_ROOT is not already set in CMake
if (NOT YAMLCPP_ROOT)
    # See if YAMLCPP_ROOT is set in process environment
    if (NOT $ENV{YAMLCPP_ROOT} STREQUAL "")
        set(YAMLCPP_ROOT "$ENV{YAMLCPP_ROOT}")
        message(STATUS "Detected YAMLCPP_ROOT set to '${YAMLCPP_ROOT}'")
    endif()
endif()

# If YAMLCPP_ROOT is available, set up our hints
if (YAMLCPP_ROOT)
    set(YAMLCPP_INCLUDE_HINTS HINTS "${YAMLCPP_ROOT}/include" "${YAMLCPP_ROOT}")
    set(YAMLCPP_LIBRARY_HINTS HINTS "${YAMLCPP_ROOT}/lib")
endif()

# Find headers and libraries
find_path(YAMLCPP_INCLUDE_DIR NAMES yaml-cpp/yaml.h ${YAMLCPP_INCLUDE_HINTS})
find_library(YAMLCPP_LIBRARY NAMES yaml-cpp ${YAMLCPP_LIBRARY_HINTS})

# Set YAMLCPP_FOUND honoring the QUIET and REQUIRED arguments
find_package_handle_standard_args(YAMLCPP DEFAULT_MSG YAMLCPP_LIBRARY YAMLCPP_INCLUDE_DIR)

# Output variables
if (YAMLCPP_FOUND)
  # Include dirs
  set(YAMLCPP_INCLUDE_DIRS ${YAMLCPP_INCLUDE_DIR})

  # Libraries
  if (YAMLCPP_LIBRARY)
    set(YAMLCPP_LIBRARIES ${YAMLCPP_LIBRARY})
  else()
    set(YAMLCPP_LIBRARIES "")
  endif()

  # Link dirs
  get_filename_component(YAMLCPP_LIBRARY_DIRS ${YAMLCPP_LIBRARY} PATH)
endif()

# Advanced options for not cluttering the cmake UIs
mark_as_advanced(YAMLCPP_INCLUDE_DIR YAMLCPP_LIBRARY)