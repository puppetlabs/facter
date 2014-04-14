cmake_minimum_required(VERSION 2.8.12)

set(CFACTER_SOURCES
    ${CMAKE_CURRENT_LIST_DIR}/cfacter.cc
)

set(LIBCFACTER_DIR ../lib)

add_subdirectory(${LIBCFACTER_DIR} ${LIBCFACTER_DIR})

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -Wall -Wextra -Werror -Wno-unused-parameter")

include_directories(
    ${LIBCFACTER_DIR}/inc
)

add_executable(cfacter ${CFACTER_SOURCES})
target_link_libraries(cfacter libcfacter)
install(TARGETS cfacter DESTINATION .)
