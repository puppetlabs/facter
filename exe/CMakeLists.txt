cmake_minimum_required(VERSION 2.8.12)

set(CFACTER_SOURCES
    cfacter.cc
)

# Set compiler-specific flags
set(CMAKE_CXX_FLAGS ${FACTER_CXX_FLAGS})

include_directories(
    ../lib/inc # the libfacter headers
    ${Boost_INCLUDE_DIRS}
    ${YAMLCPP_INCLUDE_DIRS}
    ${NOWIDE_INCLUDE_DIRS}
)

add_executable(cfacter ${CFACTER_SOURCES})
target_link_libraries(cfacter libfacter ${Boost_LIBRARIES} ${NOWIDE_LIBRARIES})
set_target_properties(cfacter PROPERTIES COTIRE_UNITY_LINK_LIBRARIES_INIT "COPY_UNITY" COTIRE_ENABLE_PRECOMPILED_HEADER ${PRECOMPILED_HEADERS})
cotire(cfacter)

install(TARGETS cfacter DESTINATION bin)
