cmake_minimum_required(VERSION 2.8.12)

set(FACTER_SOURCES
    facter.cc
)

# Set compiler-specific flags
set(CMAKE_CXX_FLAGS ${FACTER_CXX_FLAGS})
leatherman_logging_namespace("puppetlabs.facter")

include_directories(
    ../lib/inc # the libfacter headers
    ${Boost_INCLUDE_DIRS}
    ${YAMLCPP_INCLUDE_DIRS}
    ${LEATHERMAN_NOWIDE_INCLUDE}
)

add_executable(facter ${FACTER_SOURCES})
target_link_libraries(facter libfacter ${Boost_PROGRAM_OPTIONS_LIBRARY} ${LEATHERMAN_NOWIDE_LIB})

install(TARGETS facter DESTINATION bin)
