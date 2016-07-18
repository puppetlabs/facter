include(FindDependency)
find_dependency(CPPHOCON DISPLAY "cpp-hocon" HEADERS "hocon/config.hpp" LIBRARIES "libcpp-hocon.a")

include(FeatureSummary)
set_package_properties(CPPHOCON PROPERTIES DESCRIPTION "A C++ parser for the HOCON configuration language" URL "https://github.com/puppetlabs/cpp-hocon")
set_package_properties(CPPHOCON PROPERTIES TYPE REQUIRED PURPOSE "Allows parsing of the Facter config file.")
