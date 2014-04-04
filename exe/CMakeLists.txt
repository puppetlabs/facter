cmake_minimum_required(VERSION 2.8.12)
project(CFACTER)

set(CFACTER_SOURCES
    ${PROJECT_SOURCE_DIR}/cfacter.cc
)

set(LIBCFACTER_DIR ../lib)

add_subdirectory(${LIBCFACTER_DIR} ${LIBCFACTER_DIR})

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -Wall -Wextra -Werror -Wno-unused-parameter")

include_directories(
    "${PROJECT_SOURCE_DIR}/${LIBCFACTER_DIR}"
)

link_directories(
    "${PROJECT_SOURCE_DIR}/${LIBCFACTER_DIR}"
)

add_executable(cfacter ${CFACTER_SOURCES})
target_link_libraries(cfacter libcfacter)
install(TARGETS cfacter DESTINATION .)