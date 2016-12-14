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
    ${LEATHERMAN_RUBY_INCLUDE}
    ${LEATHERMAN_FILE_UTIL_INCLUDE}
    ${LEATHERMAN_UTIL_INCLUDE}
    ${LEATHERMAN_NOWIDE_INCLUDE}
    ${CPPHOCON_INCLUDE_DIRS}
)

link_directories(
    ${CPPHOCON_LIBRARY_DIRS}
)

add_executable(facter ${FACTER_SOURCES})
set_target_properties(facter PROPERTIES VERSION ${PROJECT_VERSION})

if (${CMAKE_SYSTEM_NAME} MATCHES "Linux")
    target_link_libraries(facter rt)
endif()

target_link_libraries(facter libfacter
    ${CPPHOCON_LIBRARIES}
    ${LEATHERMAN_LIBRARIES}
    ${Boost_LIBRARIES}
    ${CMAKE_THREAD_LIBS_INIT} # fix until Leatherman switches to private dependencies
)

leatherman_install(facter)
