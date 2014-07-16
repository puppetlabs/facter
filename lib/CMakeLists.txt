cmake_minimum_required(VERSION 2.8.12)

set(LIBFACTER_VERSION_MAJOR 0)
set(LIBFACTER_VERSION_MINOR 2)
set(LIBFACTER_VERSION_PATCH 0)

# Generate a file containing the above version numbers
configure_file (
    "${CMAKE_CURRENT_LIST_DIR}/version.h.in"
    "${CMAKE_CURRENT_LIST_DIR}/inc/facter/version.h"
)

# Set compiler-specific flags
set(CMAKE_CXX_FLAGS ${FACTER_CXX_FLAGS})

# Set the common (platform-independent) sources
set(LIBFACTER_COMMON_SOURCES
    "${CMAKE_CURRENT_LIST_DIR}/src/facterlib.cc"
    "${CMAKE_CURRENT_LIST_DIR}/src/facts/array_value.cc"
    "${CMAKE_CURRENT_LIST_DIR}/src/facts/external/json_resolver.cc"
    "${CMAKE_CURRENT_LIST_DIR}/src/facts/external/resolver.cc"
    "${CMAKE_CURRENT_LIST_DIR}/src/facts/external/text_resolver.cc"
    "${CMAKE_CURRENT_LIST_DIR}/src/facts/external/yaml_resolver.cc"
    "${CMAKE_CURRENT_LIST_DIR}/src/facts/collection.cc"
    "${CMAKE_CURRENT_LIST_DIR}/src/facts/map_value.cc"
    "${CMAKE_CURRENT_LIST_DIR}/src/facts/resolver.cc"
    "${CMAKE_CURRENT_LIST_DIR}/src/facts/scalar_value.cc"
    "${CMAKE_CURRENT_LIST_DIR}/src/facts/value.cc"
    "${CMAKE_CURRENT_LIST_DIR}/src/ruby/api.cc"
    "${CMAKE_CURRENT_LIST_DIR}/src/util/directory.cc"
    "${CMAKE_CURRENT_LIST_DIR}/src/util/file.cc"
    "${CMAKE_CURRENT_LIST_DIR}/src/util/scoped_file.cc"
    "${CMAKE_CURRENT_LIST_DIR}/src/util/string.cc"
)

# Set the POSIX sources if on a POSIX platform
if (UNIX)
    set(LIBFACTER_POSIX_SOURCES
        "${CMAKE_CURRENT_LIST_DIR}/src/execution/posix/execution.cc"
        "${CMAKE_CURRENT_LIST_DIR}/src/facts/external/posix/execution_resolver.cc"
        "${CMAKE_CURRENT_LIST_DIR}/src/facts/posix/dmi_resolver.cc"
        "${CMAKE_CURRENT_LIST_DIR}/src/facts/posix/kernel_resolver.cc"
        "${CMAKE_CURRENT_LIST_DIR}/src/facts/posix/networking_resolver.cc"
        "${CMAKE_CURRENT_LIST_DIR}/src/facts/posix/operating_system_resolver.cc"
        "${CMAKE_CURRENT_LIST_DIR}/src/facts/posix/collection.cc"
        "${CMAKE_CURRENT_LIST_DIR}/src/facts/posix/processor_resolver.cc"
        "${CMAKE_CURRENT_LIST_DIR}/src/facts/posix/ssh_resolver.cc"
        "${CMAKE_CURRENT_LIST_DIR}/src/facts/posix/uptime_resolver.cc"
        "${CMAKE_CURRENT_LIST_DIR}/src/facts/posix/virtualization_resolver.cc"
        "${CMAKE_CURRENT_LIST_DIR}/src/logging/posix/logging.cc"
        "${CMAKE_CURRENT_LIST_DIR}/src/ruby/posix/api.cc"
        "${CMAKE_CURRENT_LIST_DIR}/src/util/posix/dynamic_library.cc"
        "${CMAKE_CURRENT_LIST_DIR}/src/util/posix/environment.cc"
        "${CMAKE_CURRENT_LIST_DIR}/src/util/posix/scoped_addrinfo.cc"
        "${CMAKE_CURRENT_LIST_DIR}/src/util/posix/scoped_bio.cc"
        "${CMAKE_CURRENT_LIST_DIR}/src/util/posix/scoped_descriptor.cc"
    )
endif()

# Set the platform-specific sources
if ("${CMAKE_SYSTEM_NAME}" MATCHES "Darwin")
    list(REMOVE_ITEM LIBFACTER_POSIX_SOURCES "${CMAKE_CURRENT_LIST_DIR}/src/ruby/posix/api.cc")
    set(LIBFACTER_PLATFORM_SOURCES
        "${CMAKE_CURRENT_LIST_DIR}/src/facts/osx/dmi_resolver.cc"
        "${CMAKE_CURRENT_LIST_DIR}/src/facts/bsd/networking_resolver.cc"
        "${CMAKE_CURRENT_LIST_DIR}/src/facts/bsd/uptime_resolver.cc"
        "${CMAKE_CURRENT_LIST_DIR}/src/facts/osx/networking_resolver.cc"
        "${CMAKE_CURRENT_LIST_DIR}/src/facts/osx/collection.cc"
        "${CMAKE_CURRENT_LIST_DIR}/src/facts/osx/processor_resolver.cc"
        "${CMAKE_CURRENT_LIST_DIR}/src/facts/osx/system_profiler_resolver.cc"
        "${CMAKE_CURRENT_LIST_DIR}/src/facts/osx/software_version_resolver.cc"
        "${CMAKE_CURRENT_LIST_DIR}/src/facts/osx/virtualization_resolver.cc"
        "${CMAKE_CURRENT_LIST_DIR}/src/ruby/osx/api.cc"
        "${CMAKE_CURRENT_LIST_DIR}/src/util/bsd/scoped_ifaddrs.cc"
    )
elseif ("${CMAKE_SYSTEM_NAME}" MATCHES "Linux")
    set(LIBFACTER_PLATFORM_SOURCES
        "${CMAKE_CURRENT_LIST_DIR}/src/facts/bsd/networking_resolver.cc"
        "${CMAKE_CURRENT_LIST_DIR}/src/facts/linux/block_device_resolver.cc"
        "${CMAKE_CURRENT_LIST_DIR}/src/facts/linux/dmi_resolver.cc"
        "${CMAKE_CURRENT_LIST_DIR}/src/facts/linux/lsb_resolver.cc"
        "${CMAKE_CURRENT_LIST_DIR}/src/facts/linux/networking_resolver.cc"
        "${CMAKE_CURRENT_LIST_DIR}/src/facts/linux/operating_system_resolver.cc"
        "${CMAKE_CURRENT_LIST_DIR}/src/facts/linux/uptime_resolver.cc"
        "${CMAKE_CURRENT_LIST_DIR}/src/facts/linux/collection.cc"
        "${CMAKE_CURRENT_LIST_DIR}/src/facts/linux/processor_resolver.cc"
        "${CMAKE_CURRENT_LIST_DIR}/src/facts/linux/selinux_resolver.cc"
        "${CMAKE_CURRENT_LIST_DIR}/src/facts/linux/virtualization_resolver.cc"
        "${CMAKE_CURRENT_LIST_DIR}/src/util/bsd/scoped_ifaddrs.cc"
    )
endif()

# Add the library target without a prefix (name already has the 'lib')
add_library(libfacter SHARED ${LIBFACTER_COMMON_SOURCES} ${LIBFACTER_POSIX_SOURCES} ${LIBFACTER_PLATFORM_SOURCES})
set_target_properties(libfacter PROPERTIES PREFIX "" VERSION "${LIBFACTER_VERSION_MAJOR}.${LIBFACTER_VERSION_MINOR}.${LIBFACTER_VERSION_PATCH}")
install(TARGETS libfacter DESTINATION lib)
install(DIRECTORY inc/facter DESTINATION include)

# Set include directories
include_directories(
    inc
    ${RE2_INCLUDE_DIRS}
    ${RAPIDJSON_INCLUDE_DIRS}
    ${LOG4CXX_INCLUDE_DIRS}
    ${Boost_INCLUDE_DIRS}
    ${OPENSSL_INCLUDE_DIRS}
    ${YAMLCPP_INCLUDE_DIRS}
)

# Link in additional libraries
target_link_libraries(libfacter
    pthread
    ${RE2_LIBRARIES}
    ${LOG4CXX_LIBRARIES}
    ${Boost_LIBRARIES}
    ${OPENSSL_LIBRARIES}
    ${YAMLCPP_LIBRARIES}
)

add_subdirectory(tests)
