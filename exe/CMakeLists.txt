cmake_minimum_required(VERSION 2.8.12)

set(CFACTER_SOURCES
    ${CMAKE_CURRENT_LIST_DIR}/cfacter.cc
)

# Set compiler-specific flags
set(CMAKE_CXX_FLAGS ${FACTER_CXX_FLAGS})

include_directories(
    ../lib/inc # the libfacter headers
    ${LOG4CXX_INCLUDE_DIRS}
    ${Boost_INCLUDE_DIRS}
)

add_executable(cfacter ${CFACTER_SOURCES})
target_link_libraries(cfacter libfacter ${LOG4CXX_LIBRARIES} ${Boost_LIBRARIES})
install(TARGETS cfacter DESTINATION bin)
