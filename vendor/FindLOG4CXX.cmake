################################################################################
#
# CMake script for finding Log4cxx.
# The default CMake search process is used to locate files.
#
# This script creates the following variables:
#  LOG4CXX_FOUND: Boolean that indicates if the package was found
#  LOG4CXX_INCLUDE_DIRS: Paths to the necessary header files
#  LOG4CXX_LIBRARIES: Package libraries
#  LOG4CXX_LIBRARY_DIRS: Path to package libraries
#
################################################################################

include(FindPackageHandleStandardArgs)

# See if LOG4CXX_ROOT is not already set in CMake
IF (NOT LOG4CXX_ROOT)
    # See if LOG4CXX_ROOT is set in process environment
    IF ( NOT $ENV{LOG4CXX_ROOT} STREQUAL "" )
        SET (LOG4CXX_ROOT "$ENV{LOG4CXX_ROOT}")
	MESSAGE(STATUS "Detected LOG4CXX_ROOT set to '${LOG4CXX_ROOT}'")
    ENDIF ()
ENDIF ()

# If LOG4CXX_ROOT is available, set up our hints
IF (LOG4CXX_ROOT)
    SET (LOG4CXX_INCLUDE_HINTS HINTS "${LOG4CXX_ROOT}/include" "${LOG4CXX_ROOT}")
    SET (LOG4CXX_LIBRARY_HINTS HINTS "${LOG4CXX_ROOT}/lib")
ENDIF ()

# Find headers and libraries
find_path(LOG4CXX_INCLUDE_DIR NAMES log4cxx/log4cxx.h ${LOG4CXX_INCLUDE_HINTS})
find_library(LOG4CXX_LIBRARY NAMES log4cxx ${LOG4CXX_LIBRARY_HINTS})
find_library(LOG4CXXD_LIBRARY NAMES log4cxx${CMAKE_DEBUG_POSTFIX} ${LOG4CXX_LIBRARY_HINTS})

# Set LOG4CXX_FOUND honoring the QUIET and REQUIRED arguments
find_package_handle_standard_args(LOG4CXX DEFAULT_MSG LOG4CXX_LIBRARY LOG4CXX_INCLUDE_DIR)

# Output variables
if(LOG4CXX_FOUND)
  # Include dirs
  set(LOG4CXX_INCLUDE_DIRS ${LOG4CXX_INCLUDE_DIR})

  # Libraries
  if(LOG4CXX_LIBRARY)
    set(LOG4CXX_LIBRARIES optimized ${LOG4CXX_LIBRARY})
  else(LOG4CXX_LIBRARY)
    set(LOG4CXX_LIBRARIES "")
  endif(LOG4CXX_LIBRARY)
  if(LOG4CXXD_LIBRARY)
    set(LOG4CXX_LIBRARIES debug ${LOG4CXXD_LIBRARY} ${LOG4CXX_LIBRARIES})
  endif(LOG4CXXD_LIBRARY)

  # Link dirs
  get_filename_component(LOG4CXX_LIBRARY_DIRS ${LOG4CXX_LIBRARY} PATH)
endif()

# Advanced options for not cluttering the cmake UIs
mark_as_advanced(LOG4CXX_INCLUDE_DIR LOG4CXX_LIBRARY)