include(FindDependency)
find_dependency(WHEREAMI DISPLAY "whereami" HEADERS "whereami/whereami.hpp" LIBRARIES "libwhereami.a")

include(FeatureSummary)
set_package_properties(WHEREAMI PROPERTIES DESCRIPTION "A hypervisor detection library" URL "https://github.com/puppetlabs/libwhereami")
set_package_properties(WHEREAMI PROPERTIES PURPOSE "Reports hypervisors in use.")