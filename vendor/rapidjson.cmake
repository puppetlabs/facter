cmake_minimum_required(VERSION 2.8.12)
include(ExternalProject)

# Add an external project to build rapidjson
externalproject_add(
    rapidjson
    PREFIX "${PROJECT_BINARY_DIR}"
    URL "file://${VENDOR_DIRECTORY}/rapidjson-0.11.tgz"
    URL_MD5 "a648ac1a286a85f0741151b9c8db56a4"
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND ""
    ALWAYS 1
)

# Set some useful variables based on the source directory
externalproject_get_property(rapidjson SOURCE_DIR)
set(RAPIDJSON_INCLUDE_DIRS "${SOURCE_DIR}/include")
