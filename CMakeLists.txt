cmake_minimum_required(VERSION 2.8)
project(CFACTER)

set(CFACTER_VERSION_MAJOR 0)
set(CFACTER_VERSION_MINOR 0)
set(CFACTER_VERSION_PATCH 1)

# Generate a file containing the above version numbers
configure_file (
  "${PROJECT_SOURCE_DIR}/version.h.in"
  "${PROJECT_SOURCE_DIR}/version.h"
)

add_subdirectory(exe)
