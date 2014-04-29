cmake_minimum_required(VERSION 2.8.12)

set(CFACTER_SOURCES
    ${CMAKE_CURRENT_LIST_DIR}/cfacter.cc
)

set(LIBFACTER_DIR ../lib)

add_subdirectory(${LIBFACTER_DIR} ${LIBFACTER_DIR})

# Set compiler-specific flags
if ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -Wall -Wextra -Werror -Wno-unused-parameter -Wno-tautological-constant-out-of-range-compare")
elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -Wall -Wextra -Werror -Wno-unused-parameter -Wno-unused-local-typedefs")
elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Intel")
elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
endif()

include_directories(
    ${LIBFACTER_DIR}/inc
    ${LOG4CXX_INCLUDE_DIRS}
    ${Boost_INCLUDE_DIRS}
)

add_executable(cfacter ${CFACTER_SOURCES})
target_link_libraries(cfacter libfacter ${LOG4CXX_LIBRARIES} ${Boost_LIBRARIES})
install(TARGETS cfacter DESTINATION .)
