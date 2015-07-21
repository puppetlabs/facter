cmake_minimum_required(VERSION 2.8.12)

set(LIBFACTER_VERSION_MAJOR 3)
set(LIBFACTER_VERSION_MINOR 0)
set(LIBFACTER_VERSION_PATCH 2)

# Get the HEAD SHA1
include(GetGitRevisionDescription)
get_git_head_revision(GIT_REFSPEC LIBFACTER_GIT_SHA1)

if ("${LIBFACTER_GIT_SHA1}" STREQUAL "" OR "${LIBFACTER_GIT_SHA1}" STREQUAL "GITDIR-NOTFOUND")
    set(LIBFACTER_GIT_SHA1 "")
    set(LIBFACTER_COMMIT "")
else()
    set(LIBFACTER_COMMIT " (commit ${LIBFACTER_GIT_SHA1})")
endif()

# Generate a file containing the above version numbers
configure_file (
    "version.h.in"
    "${CMAKE_CURRENT_LIST_DIR}/inc/facter/version.h"
)

# Set compiler-specific flags
set(CMAKE_CXX_FLAGS ${FACTER_CXX_FLAGS})
leatherman_logging_namespace("puppetlabs.facter")

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
    "src/facts/resolvers/augeas_resolver.cc"
    "src/facts/resolvers/disk_resolver.cc"
    "src/facts/resolvers/dmi_resolver.cc"
    "src/facts/resolvers/ec2_resolver.cc"
    "src/facts/resolvers/filesystem_resolver.cc"
    "src/facts/resolvers/gce_resolver.cc"
    "src/facts/resolvers/identity_resolver.cc"
    "src/facts/resolvers/kernel_resolver.cc"
    "src/facts/resolvers/load_average_resolver.cc"
    "src/facts/resolvers/memory_resolver.cc"
    "src/facts/resolvers/networking_resolver.cc"
    "src/facts/resolvers/operating_system_resolver.cc"
    "src/facts/resolvers/path_resolver.cc"
    "src/facts/resolvers/processor_resolver.cc"
    "src/facts/resolvers/ruby_resolver.cc"
    "src/facts/resolvers/ssh_resolver.cc"
    "src/facts/resolvers/system_profiler_resolver.cc"
    "src/facts/resolvers/timezone_resolver.cc"
    "src/facts/resolvers/uptime_resolver.cc"
    "src/facts/resolvers/virtualization_resolver.cc"
    "src/facts/resolvers/xen_resolver.cc"
    "src/facts/resolvers/zpool_resolver.cc"
    "src/facts/resolvers/zone_resolver.cc"
    "src/facts/resolvers/zfs_resolver.cc"
    "src/facts/scalar_value.cc"
    "src/logging/logging.cc"
    "src/ruby/aggregate_resolution.cc"
    "src/ruby/api.cc"
    "src/ruby/chunk.cc"
    "src/ruby/confine.cc"
    "src/ruby/fact.cc"
    "src/ruby/module.cc"
    "src/ruby/resolution.cc"
    "src/ruby/ruby.cc"
    "src/ruby/ruby_value.cc"
    "src/ruby/simple_resolution.cc"
    "src/util/directory.cc"
    "src/util/dynamic_library.cc"
    "src/util/environment.cc"
    "src/util/file.cc"
    "src/util/scope_exit.cc"
    "src/util/scoped_env.cc"
    "src/util/scoped_file.cc"
    "src/util/string.cc"
)

if (CURL_FOUND)
    set(LIBFACTER_COMMON_SOURCES ${LIBFACTER_COMMON_SOURCES}
       "src/http/client.cc"
       "src/http/request.cc"
       "src/http/response.cc"
    )
endif()

# Set the POSIX sources if on a POSIX platform
if (UNIX)
    set(LIBFACTER_STANDARD_SOURCES
        "src/execution/posix/execution.cc"
        "src/facts/posix/collection.cc"
        "src/facts/posix/identity_resolver.cc"
        "src/facts/posix/kernel_resolver.cc"
        "src/facts/posix/networking_resolver.cc"
        "src/facts/posix/operatingsystem_resolver.cc"
        "src/facts/posix/processor_resolver.cc"
        "src/facts/posix/ssh_resolver.cc"
        "src/facts/posix/timezone_resolver.cc"
        "src/facts/posix/uptime_resolver.cc"
        "src/facts/posix/xen_resolver.cc"
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
        "src/ruby/windows/api.cc"
        "src/util/windows/dynamic_library.cc"
        "src/util/windows/environment.cc"
        "src/util/windows/process.cc"
        "src/util/windows/registry.cc"
        "src/util/windows/system_error.cc"
        "src/util/windows/user.cc"
        "src/util/windows/wmi.cc"
        "src/util/windows/wsa.cc"
    )
endif()

# Set the platform-specific sources
if ("${CMAKE_SYSTEM_NAME}" MATCHES "Darwin")
    set(LIBFACTER_PLATFORM_SOURCES
        "src/facts/bsd/filesystem_resolver.cc"
        "src/facts/bsd/networking_resolver.cc"
        "src/facts/bsd/uptime_resolver.cc"
        "src/facts/glib/load_average_resolver.cc"
        "src/facts/osx/dmi_resolver.cc"
        "src/facts/osx/networking_resolver.cc"
        "src/facts/osx/collection.cc"
        "src/facts/osx/memory_resolver.cc"
        "src/facts/osx/operating_system_resolver.cc"
        "src/facts/osx/processor_resolver.cc"
        "src/facts/osx/system_profiler_resolver.cc"
        "src/facts/osx/virtualization_resolver.cc"
        "src/util/bsd/scoped_ifaddrs.cc"
    )
elseif ("${CMAKE_SYSTEM_NAME}" MATCHES "SunOS")
    set(LIBFACTER_PLATFORM_SOURCES
        "src/facts/glib/load_average_resolver.cc"
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
        "src/facts/solaris/zfs_resolver.cc"
        "src/facts/solaris/zone_resolver.cc"
        "src/facts/solaris/zpool_resolver.cc"
        "src/util/solaris/k_stat.cc"
        "src/util/solaris/scoped_kstat.cc"
    )
    set(LIBFACTER_PLATFORM_LIBRARIES
        kstat
        socket
        nsl
    )
elseif ("${CMAKE_SYSTEM_NAME}" MATCHES "Linux")
    set(LIBFACTER_PLATFORM_SOURCES
        "src/facts/bsd/networking_resolver.cc"
        "src/facts/glib/load_average_resolver.cc"
        "src/facts/linux/disk_resolver.cc"
        "src/facts/linux/dmi_resolver.cc"
        "src/facts/linux/filesystem_resolver.cc"
        "src/facts/linux/kernel_resolver.cc"
        "src/facts/linux/memory_resolver.cc"
        "src/facts/linux/networking_resolver.cc"
        "src/facts/linux/operating_system_resolver.cc"
        "src/facts/linux/os_linux.cc"
        "src/facts/linux/uptime_resolver.cc"
        "src/facts/linux/collection.cc"
        "src/facts/linux/processor_resolver.cc"
        "src/facts/linux/virtualization_resolver.cc"
        "src/util/bsd/scoped_ifaddrs.cc"
    )
    set(LIBFACTER_PLATFORM_LIBRARIES
        ${BLKID_LIBRARIES}
        rt
    )
elseif ("${CMAKE_SYSTEM_NAME}" MATCHES "FreeBSD")
    set(LIBFACTER_PLATFORM_SOURCES
        "src/facts/bsd/collection.cc"
        "src/facts/glib/load_average_resolver.cc"
        "src/facts/bsd/filesystem_resolver.cc"
        "src/facts/bsd/networking_resolver.cc"
        "src/facts/bsd/uptime_resolver.cc"
        "src/util/bsd/scoped_ifaddrs.cc"
    )
elseif ("${CMAKE_SYSTEM_NAME}" MATCHES "Windows")
    set(LIBFACTER_PLATFORM_SOURCES
        "src/facts/windows/dmi_resolver.cc"
        "src/facts/windows/identity_resolver.cc"
        "src/facts/windows/kernel_resolver.cc"
        "src/facts/windows/memory_resolver.cc"
        "src/facts/windows/networking_resolver.cc"
        "src/facts/windows/operating_system_resolver.cc"
        "src/facts/windows/processor_resolver.cc"
        "src/facts/windows/timezone_resolver.cc"
        "src/facts/windows/uptime_resolver.cc"
        "src/facts/windows/virtualization_resolver.cc"
    )

    # The GetPerformanceInfo symbol has moved around a lot between Windows versions;
    # these options tie it to the backwards-compatible version.
    set(LIBFACTER_PLATFORM_LIBRARIES
        Psapi.lib
        Version.lib
        Wbemuuid.lib
        Secur32.lib
        Ws2_32.lib
        iphlpapi.lib
        userenv.lib
    )
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DPSAPI_VERSION=1")
endif()

if (WIN32)
    set(LIBFACTER_INSTALL_DESTINATION bin)
else()
    # TODO: lib64 for certain operating systems?
    set(LIBFACTER_INSTALL_DESTINATION lib)
endif()

if (JRUBY_SUPPORT)
    include_directories(${JNI_INCLUDE_DIRS})
    set(LIBFACTER_COMMON_SOURCES ${LIBFACTER_COMMON_SOURCES} src/java/facter.cc)

    configure_file(
        Facter.java.in
        "${CMAKE_BINARY_DIR}/lib/com/puppetlabs/Facter.java"
    )

    include(UseJava)
    add_jar(facter-jruby "${CMAKE_BINARY_DIR}/lib/com/puppetlabs/Facter.java" OUTPUT_NAME facter OUTPUT_DIR "${CMAKE_BINARY_DIR}/lib" ENTRY_POINT com/puppetlabs/Facter)

    add_custom_command(TARGET facter-jruby POST_BUILD COMMAND javah ARGS -d "${CMAKE_CURRENT_LIST_DIR}/src/java" com.puppetlabs.Facter WORKING_DIRECTORY "${CMAKE_BINARY_DIR}/lib")
endif()

# Set include directories
include_directories(
    inc
    ${RAPIDJSON_INCLUDE_DIRS}
    ${Boost_INCLUDE_DIRS}
    ${OPENSSL_INCLUDE_DIRS}
    ${YAMLCPP_INCLUDE_DIRS}
    ${CURL_INCLUDE_DIRS}
    ${LEATHERMAN_INCLUDE_DIRS}
)

link_directories(
    ${Boost_LIBRARY_DIRS}
    ${OPENSSL_LIBRARY_DIRS}
    ${YAMLCPP_LIBRARY_DIRS}
    ${CURL_LIBRARY_DIRS}
)

# Add the library target without a prefix (name already has the 'lib') and use '.so' for all platforms (Ruby extension file extension)
add_library(libfactersrc OBJECT ${LIBFACTER_COMMON_SOURCES} ${LIBFACTER_STANDARD_SOURCES} ${LIBFACTER_PLATFORM_SOURCES})
set_target_properties(libfactersrc PROPERTIES POSITION_INDEPENDENT_CODE true COTIRE_ENABLE_PRECOMPILED_HEADER ${PRECOMPILED_HEADERS} COTIRE_ADD_UNITY_BUILD FALSE)
add_library(libfacter SHARED $<TARGET_OBJECTS:libfactersrc>)
set_target_properties(libfacter PROPERTIES PREFIX "" SUFFIX ".so" IMPORT_PREFIX "" IMPORT_SUFFIX ".so.a" VERSION "${LIBFACTER_VERSION_MAJOR}.${LIBFACTER_VERSION_MINOR}.${LIBFACTER_VERSION_PATCH}" COTIRE_UNITY_LINK_LIBRARIES_INIT "COPY_UNITY")

# Link in additional libraries
target_link_libraries(libfacter PRIVATE
    ${POSIX_LIBRARIES}
    ${LIBFACTER_PLATFORM_LIBRARIES}
    ${LEATHERMAN_LIBRARIES}
    ${Boost_LIBRARIES}
    ${OPENSSL_LIBRARIES}
    ${YAMLCPP_LIBRARIES}
    ${CURL_LIBRARIES}
)

# Generate the export header
include(GenerateExportHeader)
generate_export_header(libfacter EXPORT_FILE_NAME "${CMAKE_CURRENT_LIST_DIR}/inc/facter/export.h")

if ("${CMAKE_SYSTEM_NAME}" MATCHES "Linux")
    add_compiler_export_flags()
elseif (WIN32)
    add_compiler_export_flags()
    add_definitions("-Dlibfacter_EXPORTS")
endif()

install(TARGETS libfacter DESTINATION ${LIBFACTER_INSTALL_DESTINATION})
install(DIRECTORY inc/facter DESTINATION include)

if (RUBY_FOUND)
    configure_file (
        "facter.rb.in"
        "${CMAKE_BINARY_DIR}/lib/facter.rb"
    )

    # Generate a file for ruby testing
    configure_file (
        "spec_helper.rb.in"
        "${CMAKE_CURRENT_LIST_DIR}/spec/spec_helper.rb"
    )

    message(STATUS "Ruby ${RUBY_VERSION} found.")

    if (APPLE)
        # Unfortunately the default DLEXT for most rubies on OSX is "bundle"
        # Ruby calls dlopen for the extension, which doesn't care if the "bundle" really is a dylib
        # Therefore, workaround this by symlinking "libfacter.bundle" to "libfacter.so"
        add_custom_command(TARGET libfacter POST_BUILD COMMAND ln -sf libfacter.so libfacter.bundle WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
        message(STATUS "\"make install\" will create a symlink from ${CMAKE_INSTALL_PREFIX}/${LIBFACTER_INSTALL_DESTINATION}/libfacter.bundle to ${CMAKE_INSTALL_PREFIX}/${LIBFACTER_INSTALL_DESTINATION}/libfacter.so")
        install(CODE "EXECUTE_PROCESS(COMMAND ln -sf libfacter.so libfacter.bundle WORKING_DIRECTORY ${CMAKE_INSTALL_PREFIX}/${LIBFACTER_INSTALL_DESTINATION})")
    endif()

    execute_process(COMMAND ${RUBY_EXECUTABLE} -rrbconfig -e "puts RbConfig::CONFIG['vendordir']" OUTPUT_VARIABLE RUBY_VENDORDIR_OUT)
    string(STRIP ${RUBY_VENDORDIR_OUT} RUBY_VENDORDIR)
    message(STATUS "\"make install\" will install facter.rb to ${RUBY_VENDORDIR}")
    install(FILES ${CMAKE_BINARY_DIR}/lib/facter.rb DESTINATION ${RUBY_VENDORDIR})

    if (JRUBY_SUPPORT)
        message(STATUS "\"make install\" will install facter.jar to ${RUBY_VENDORDIR} to support JRuby")
        install(FILES ${CMAKE_BINARY_DIR}/lib/facter.jar DESTINATION ${RUBY_VENDORDIR})
    endif()
endif()

if (JRUBY_SUPPORT)
    add_dependencies(libfacter facter-jruby)
endif()

cotire(libfactersrc)

add_subdirectory(tests)
