cmake_minimum_required(VERSION 2.8.12)

set(LIBFACTER_VERSION_MAJOR 0)
set(LIBFACTER_VERSION_MINOR 2)
set(LIBFACTER_VERSION_PATCH 0)

# Generate a file containing the above version numbers
configure_file (
    "version.h.in"
    "${CMAKE_CURRENT_LIST_DIR}/inc/facter/version.h"
)

# Set compiler-specific flags
set(CMAKE_CXX_FLAGS ${FACTER_CXX_FLAGS})

# Set the common (platform-independent) sources
set(LIBFACTER_COMMON_SOURCES
    "src/execution/execution.cc"
    "src/facts/array_value.cc"
    "src/facts/collection.cc"
    "src/facts/external/execution_resolver.cc"
    "src/facts/external/json_resolver.cc"
    "src/facts/external/resolver.cc"
    "src/facts/external/text_resolver.cc"
    "src/facts/external/yaml_resolver.cc"
    "src/facts/map_value.cc"
    "src/facts/resolver.cc"
    "src/facts/resolvers/disk_resolver.cc"
    "src/facts/resolvers/dmi_resolver.cc"
    "src/facts/resolvers/filesystem_resolver.cc"
    "src/facts/resolvers/identity_resolver.cc"
    "src/facts/resolvers/kernel_resolver.cc"
    "src/facts/resolvers/memory_resolver.cc"
    "src/facts/resolvers/networking_resolver.cc"
    "src/facts/resolvers/operating_system_resolver.cc"
    "src/facts/resolvers/processor_resolver.cc"
    "src/facts/resolvers/ssh_resolver.cc"
    "src/facts/resolvers/timezone_resolver.cc"
    "src/facts/resolvers/uptime_resolver.cc"
    "src/facts/resolvers/virtualization_resolver.cc"
    "src/facts/scalar_value.cc"
    "src/logging/logging.cc"
    "src/ruby/aggregate_resolution.cc"
    "src/ruby/api.cc"
    "src/ruby/chunk.cc"
    "src/ruby/confine.cc"
    "src/ruby/fact.cc"
    "src/ruby/module.cc"
    "src/ruby/resolution.cc"
    "src/ruby/ruby_value.cc"
    "src/ruby/simple_resolution.cc"
    "src/util/directory.cc"
    "src/util/dynamic_library.cc"
    "src/util/file.cc"
    "src/util/scoped_env.cc"
    "src/util/scoped_file.cc"
    "src/util/string.cc"
)

# Set the POSIX sources if on a POSIX platform
if (UNIX)
    set(LIBFACTER_STANDARD_SOURCES
        "src/execution/posix/execution.cc"
        "src/facts/posix/collection.cc"
        "src/facts/posix/identity_resolver.cc"
        "src/facts/posix/kernel_resolver.cc"
        "src/facts/posix/networking_resolver.cc"
        "src/facts/posix/processor_resolver.cc"
        "src/facts/posix/processor_resolver.cc"
        "src/facts/posix/ssh_resolver.cc"
        "src/facts/posix/timezone_resolver.cc"
        "src/facts/posix/uptime_resolver.cc"
        "src/logging/posix/log.cc"
        "src/ruby/posix/api.cc"
        "src/util/posix/dynamic_library.cc"
        "src/util/posix/environment.cc"
        "src/util/posix/scoped_addrinfo.cc"
        "src/util/posix/scoped_descriptor.cc"
    )
    if (OPENSSL_FOUND)
        set(LIBFACTER_STANDARD_SOURCES ${LIBFACTER_STANDARD_SOURCES} "src/util/posix/scoped_bio.cc")
    endif()

    set(POSIX_LIBRARIES pthread dl)
endif()

if (WIN32)
    set(LIBFACTER_STANDARD_SOURCES
        "src/execution/windows/execution.cc"
        "src/facts/external/windows/powershell_resolver.cc"
        "src/facts/windows/collection.cc"
        "src/logging/windows/log.cc"
        "src/ruby/windows/api.cc"
        "src/util/windows/dynamic_library.cc"
        "src/util/windows/environment.cc"
        "src/util/windows/scoped_error.cc"
        "src/util/windows/wmi.cc"
    )
endif()

# Set the platform-specific sources
if ("${CMAKE_SYSTEM_NAME}" MATCHES "Darwin")
    set(LIBFACTER_PLATFORM_SOURCES
        "src/facts/bsd/filesystem_resolver.cc"
        "src/facts/bsd/networking_resolver.cc"
        "src/facts/bsd/uptime_resolver.cc"
        "src/facts/osx/dmi_resolver.cc"
        "src/facts/osx/networking_resolver.cc"
        "src/facts/osx/collection.cc"
        "src/facts/osx/memory_resolver.cc"
        "src/facts/osx/processor_resolver.cc"
        "src/facts/osx/system_profiler_resolver.cc"
        "src/facts/osx/software_version_resolver.cc"
        "src/facts/osx/virtualization_resolver.cc"
        "src/util/bsd/scoped_ifaddrs.cc"
    )
elseif ("${CMAKE_SYSTEM_NAME}" MATCHES "SunOS")
    set(LIBFACTER_PLATFORM_SOURCES
        "src/util/solaris/k_stat.cc"
        "src/util/solaris/scoped_kstat.cc"
        "src/facts/solaris/collection.cc"
        "src/facts/solaris/disk_resolver.cc"
        "src/facts/solaris/uptime_resolver.cc"
        "src/facts/solaris/processor_resolver.cc"
        "src/facts/solaris/operating_system_resolver.cc"
        "src/facts/solaris/kernel_resolver.cc"
        "src/facts/solaris/filesystem_resolver.cc"
        "src/facts/solaris/dmi_resolver.cc"
        "src/facts/solaris/virtualization_resolver.cc"
        "src/facts/solaris/networking_resolver.cc"
        "src/facts/solaris/memory_resolver.cc"
        "src/facts/zfs/zpool_resolver.cc"
        "src/facts/zfs/zfs_resolver.cc"
        "src/facts/solaris/zpool_resolver.cc"
        "src/facts/solaris/zfs_resolver.cc"
        "src/facts/solaris/zone_resolver.cc"
    )
elseif ("${CMAKE_SYSTEM_NAME}" MATCHES "Linux")
    set(LIBFACTER_PLATFORM_SOURCES
        "src/facts/bsd/networking_resolver.cc"
        "src/facts/linux/disk_resolver.cc"
        "src/facts/linux/dmi_resolver.cc"
        "src/facts/linux/filesystem_resolver.cc"
        "src/facts/linux/memory_resolver.cc"
        "src/facts/linux/networking_resolver.cc"
        "src/facts/linux/operating_system_resolver.cc"
        "src/facts/linux/uptime_resolver.cc"
        "src/facts/linux/collection.cc"
        "src/facts/linux/processor_resolver.cc"
        "src/facts/linux/selinux_resolver.cc"
        "src/facts/linux/virtualization_resolver.cc"
        "src/util/bsd/scoped_ifaddrs.cc"
    )
    set(LIBFACTER_PLATFORM_LIBRARIES
        ${BLKID_LIBRARIES}
    )
elseif ("${CMAKE_SYSTEM_NAME}" MATCHES "FreeBSD")
    set(LIBFACTER_PLATFORM_SOURCES
        "src/facts/bsd/collection.cc"
        "src/facts/bsd/filesystem_resolver.cc"
        "src/facts/bsd/networking_resolver.cc"
        "src/facts/bsd/uptime_resolver.cc"
        "src/util/bsd/scoped_ifaddrs.cc"
    )
elseif ("${CMAKE_SYSTEM_NAME}" MATCHES "Windows")
    set(LIBFACTER_PLATFORM_SOURCES
        "src/facts/windows/dmi_resolver.cc"
        "src/facts/windows/kernel_resolver.cc"
        "src/facts/windows/memory_resolver.cc"
        "src/facts/windows/processor_resolver.cc"
        "src/facts/windows/virtualization_resolver.cc"
    )

    # The GetPerformanceInfo symbol has moved around a lot between Windows versions;
    # these options tie it to the backwards-compatible version.
    set(LIBFACTER_PLATFORM_LIBRARIES
        "Psapi.lib"
        "Version.lib"
        "Wbemuuid.lib")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DPSAPI_VERSION=1")
endif()

# Set include directories
include_directories(
    inc
    ${RAPIDJSON_INCLUDE_DIRS}
    ${Boost_INCLUDE_DIRS}
    ${OPENSSL_INCLUDE_DIRS}
    ${YAMLCPP_INCLUDE_DIRS}
)

link_directories(
    ${Boost_LIBRARY_DIRS}
    ${OPENSSL_LIBRARY_DIRS}
    ${YAMLCPP_LIBRARY_DIRS}
)

# Add the library target without a prefix (name already has the 'lib')
add_library(libfacter SHARED ${LIBFACTER_COMMON_SOURCES} ${LIBFACTER_STANDARD_SOURCES} ${LIBFACTER_PLATFORM_SOURCES})
set_target_properties(libfacter PROPERTIES PREFIX "" IMPORT_PREFIX "" VERSION "${LIBFACTER_VERSION_MAJOR}.${LIBFACTER_VERSION_MINOR}.${LIBFACTER_VERSION_PATCH}" COTIRE_UNITY_LINK_LIBRARIES_INIT "COPY_UNITY" COTIRE_ENABLE_PRECOMPILED_HEADER ${PRECOMPILED_HEADERS})

# Link in additional libraries
target_link_libraries(libfacter
    ${POSIX_LIBRARIES}
    ${Boost_LIBRARIES}
    ${OPENSSL_LIBRARIES}
    ${YAMLCPP_LIBRARIES}
    ${LIBFACTER_PLATFORM_LIBRARIES}
)

if (WIN32)
    install(TARGETS libfacter DESTINATION bin)
else()
    install(TARGETS libfacter DESTINATION lib)
endif()
install(DIRECTORY inc/facter DESTINATION include)

cotire(libfacter)

add_subdirectory(tests)
