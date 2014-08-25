# A function for finding dependencies
function(find_dependency)
    include(CMakeParseArguments)
    cmake_parse_arguments(FIND_DEPENDENCY "" "DISPLAY" "HEADERS;LIBRARIES" ${ARGN})

    set(FIND_DEPENDENCY_NAME ${ARGV0})

    # Find headers and libraries
    find_path(${FIND_DEPENDENCY_NAME}_INCLUDE_DIR NAMES ${FIND_DEPENDENCY_HEADERS} HINTS ENV ${FIND_DEPENDENCY_NAME}_INCLUDE_HINT)
    find_library(${FIND_DEPENDENCY_NAME}_LIBRARY NAMES ${FIND_DEPENDENCY_LIBRARIES} HINTS ENV ${FIND_DEPENDENCY_NAME}_LIBRARY_HINT)

    # Handle the find_package arguments
    include(FindPackageHandleStandardArgs)
    find_package_handle_standard_args(${FIND_DEPENDENCY_NAME} "${FIND_DEPENDENCY_DISPLAY} was not found." ${FIND_DEPENDENCY_NAME}_LIBRARY ${FIND_DEPENDENCY_NAME}_INCLUDE_DIR)

    # Set the output variables in the parent's scope
    if (${FIND_DEPENDENCY_NAME}_FOUND)
        set(${FIND_DEPENDENCY_NAME}_FOUND ${${FIND_DEPENDENCY_NAME}_FOUND} PARENT_SCOPE)

        # Include dirs
        set(${FIND_DEPENDENCY_NAME}_INCLUDE_DIRS ${${FIND_DEPENDENCY_NAME}_INCLUDE_DIR} PARENT_SCOPE)

        # Libraries
        if (${FIND_DEPENDENCY_NAME}_LIBRARY)
            set(${FIND_DEPENDENCY_NAME}_LIBRARIES ${${FIND_DEPENDENCY_NAME}_LIBRARY} PARENT_SCOPE)
        else()
            set(${FIND_DEPENDENCY_NAME}_LIBRARIES "" PARENT_SCOPE)
        endif()

        # Get the library name
        get_filename_component(${FIND_DEPENDENCY_NAME}_LIBRARY_DIRS ${${FIND_DEPENDENCY_NAME}_LIBRARY} PATH)
        set(${FIND_DEPENDENCY_NAME_LIBRARY} ${${FIND_DEPENDENCY_NAME_LIBRARY}} PARENT_SCOPE)

        # Add a define for the found package
        add_definitions(-DUSE_${FIND_DEPENDENCY_NAME})
    endif()

    # Advanced options for not cluttering the cmake UIs
    mark_as_advanced(${FIND_DEPENDENCY_NAME}_INCLUDE_DIR ${FIND_DEPENDENCY_NAME}_LIBRARY)
endfunction()
