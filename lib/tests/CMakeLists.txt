cmake_minimum_required(VERSION 2.8.12)

find_package(Ruby 1.9)

# Set the common (platform-independent) sources
set(LIBFACTER_TESTS_COMMON_SOURCES
    "facts/array_value.cc"
    "facts/boolean_value.cc"
    "facts/double_value.cc"
    "facts/external/json_resolver.cc"
    "facts/external/text_resolver.cc"
    "facts/external/yaml_resolver.cc"
    "facts/collection.cc"
    "facts/integer_value.cc"
    "facts/map_value.cc"
    "facts/resolvers/disk_resolver.cc"
    "facts/resolvers/dmi_resolver.cc"
    "facts/resolvers/filesystem_resolver.cc"
    "facts/resolvers/identity_resolver.cc"
    "facts/resolvers/kernel_resolver.cc"
    "facts/resolvers/memory_resolver.cc"
    "facts/resolvers/networking_resolver.cc"
    "facts/resolvers/operating_system_resolver.cc"
    "facts/resolvers/processor_resolver.cc"
    "facts/resolvers/ruby_resolver.cc"
    "facts/resolvers/ssh_resolver.cc"
    "facts/resolvers/system_profiler_resolver.cc"
    "facts/resolvers/timezone_resolver.cc"
    "facts/resolvers/uptime_resolver.cc"
    "facts/resolvers/virtualization_resolver.cc"
    "facts/resolvers/zfs_resolver.cc"
    "facts/resolvers/zone_resolver.cc"
    "facts/resolvers/zpool_resolver.cc"
    "facts/schema.cc"
    "facts/string_value.cc"
    "logging/logging.cc"
    "log_capture.cc"
    "main.cc"
    "util/directory.cc"
    "util/environment.cc"
    "util/file.cc"
    "util/option_set.cc"
    "util/scoped_env.cc"
    "util/string.cc"
    "fixtures.cc"
)

# Set compiler-specific flags
set(CMAKE_CXX_FLAGS ${FACTER_CXX_FLAGS})

# Add the ruby tests if there's a ruby installed
if (RUBY_FOUND)
    set(LIBFACTER_TESTS_COMMON_SOURCES ${LIBFACTER_TESTS_COMMON_SOURCES} "ruby/ruby.cc")
endif()

# Set the POSIX sources if on a POSIX platform
if (UNIX)
    set(LIBFACTER_TESTS_CATEGORY_SOURCES
        "execution/posix/execution.cc"
        "facts/posix/collection.cc"
        "facts/posix/uptime_resolver.cc"
        "facts/external/posix/execution_resolver.cc"
        "util/posix/environment.cc"
        "util/posix/scoped_addrinfo.cc"
        "util/posix/scoped_descriptor.cc"
    )
    if (OPENSSL_FOUND)
        set(LIBFACTER_TESTS_CATEGORY_SOURCES ${LIBFACTER_TESTS_CATEGORY_SOURCES} "util/posix/scoped_bio.cc")
    endif()

     set(POSIX_TESTS_LIBRARIES ${POSIX_LIBRARIES})
endif()

set(LIBFACTER_TESTS_PLATFORM_LIBRARIES
    ${LIBFACTER_PLATFORM_LIBRARIES}
)

if (WIN32)
    set(LIBFACTER_TESTS_CATEGORY_SOURCES
        "execution/windows/execution.cc"
        "facts/windows/collection.cc"
        "facts/windows/networking_resolver.cc"
        "facts/external/windows/execution_resolver.cc"
        "facts/external/windows/powershell_resolver.cc"
        "util/windows/environment.cc"
    )
endif()

# Set the platform-specific sources
if ("${CMAKE_SYSTEM_NAME}" MATCHES "Darwin")
    set(LIBFACTER_TESTS_PLATFORM_SOURCES
        "util/bsd/scoped_ifaddrs.cc"
    )
elseif ("${CMAKE_SYSTEM_NAME}" MATCHES "Linux")
    set(LIBFACTER_TESTS_PLATFORM_SOURCES
        "util/bsd/scoped_ifaddrs.cc"
    )
endif()

include_directories(
    ../inc
    ${Boost_INCLUDE_DIRS}
    ${OPENSSL_INCLUDE_DIRS}
    ${YAMLCPP_INCLUDE_DIRS}
    ${LEATHERMAN_CATCH_INCLUDE}
)

add_executable(libfacter_test $<TARGET_OBJECTS:libfactersrc> ${LIBFACTER_TESTS_COMMON_SOURCES} ${LIBFACTER_TESTS_PLATFORM_SOURCES} ${LIBFACTER_TESTS_CATEGORY_SOURCES})
set_target_properties(libfacter_test PROPERTIES COTIRE_UNITY_LINK_LIBRARIES_INIT "COPY_UNITY" COTIRE_ENABLE_PRECOMPILED_HEADER ${PRECOMPILED_HEADERS} COTIRE_ADD_UNITY_BUILD FALSE COTIRE_PREFIX_HEADER_IGNORE_PATH "${LEATHERMAN_CATCH_INCLUDE}")
target_link_libraries(libfacter_test
    ${POSIX_TESTS_LIBRARIES}
    ${LIBFACTER_TESTS_PLATFORM_LIBRARIES}
    ${YAMLCPP_LIBRARIES}
    ${Boost_LIBRARIES}
    ${OPENSSL_LIBRARIES}
    ${LEATHERMAN_LIBRARIES}
    ${CURL_LIBRARIES}
)

cotire(libfacter_test)

# Generate a file containing the path to the fixtures
configure_file (
    "fixtures.hpp.in"
    "${CMAKE_CURRENT_LIST_DIR}/fixtures.hpp"
)
