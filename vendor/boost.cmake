cmake_minimum_required(VERSION 2.8.12)
include(ExternalProject)

# Set the Boost libraries we need built here
set(BOOST_TO_BUILD program_options)

# Add an external project to build boost
externalproject_add(
    boost
    PREFIX "${PROJECT_BINARY_DIR}"
    URL "file://${VENDOR_DIRECTORY}/boost_1_55_0.tar.gz"
    URL_MD5 "93780777cfbf999a600f62883bd54b17"
    CONFIGURE_COMMAND ./bootstrap.sh --with-libraries=${BOOST_TO_BUILD}
    BUILD_COMMAND ./b2
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND ""
)

# Set some useful variables based on the source directory
externalproject_get_property(boost SOURCE_DIR)
set(BOOST_INCLUDE_DIRS ${SOURCE_DIR})

if(APPLE)
    externalproject_add_step(
        boost
        installnames
        COMMAND ${PROJECT_SOURCE_DIR}/scripts/osx_boost_names.sh ${SOURCE_DIR}/stage/lib
        COMMENT "Fixing boost install names"
        DEPENDEES build
    )
endif()

if (APPLE)
    set(BOOST_SO_EXT "dylib")
else()
    set(BOOST_SO_EXT "so.1.55.0")
endif()

foreach(BOOST_LIBRARY ${BOOST_TO_BUILD})
    set(BOOST_LIBRARY_TARGET libboost_${BOOST_LIBRARY})
    add_library(${BOOST_LIBRARY_TARGET} SHARED IMPORTED)
    set(BOOST_LIBRARY_LOCATION "${SOURCE_DIR}/stage/lib/libboost_${BOOST_LIBRARY}.${BOOST_SO_EXT}")
    set_target_properties(${BOOST_LIBRARY_TARGET} PROPERTIES PREFIX "" IMPORTED_LOCATION ${BOOST_LIBRARY_LOCATION})
    install(FILES ${BOOST_LIBRARY_LOCATION} DESTINATION .)
endforeach()
