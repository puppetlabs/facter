cmake_minimum_required(VERSION 3.2.2)

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
    ${LEATHERMAN_UTIL_INCLUDE}
    ${LEATHERMAN_NOWIDE_INCLUDE}
)

add_executable(facter ${FACTER_SOURCES})
target_link_libraries(facter libfacter
    ${Boost_THREAD_LIBRARY}
    ${Boost_PROGRAM_OPTIONS_LIBRARY}
    ${LEATHERMAN_UTIL_LIB}
    ${LEATHERMAN_NOWIDE_LIB}
    ${CMAKE_THREAD_LIBS_INIT} # fix until Leatherman switches to private dependencies
)

leatherman_install(facter)
