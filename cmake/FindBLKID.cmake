include(FindDependency)
find_dependency(BLKID DISPLAY "blkid" HEADERS "blkid/blkid.h" LIBRARIES "blkid")

include(FeatureSummary)
set_package_properties(BLKID PROPERTIES DESCRIPTION "The library for the Linux blkid utility" URL "http://en.wikipedia.org/wiki/Util-linux")
set_package_properties(BLKID PROPERTIES TYPE OPTIONAL PURPOSE "Enables the partitions fact on Linux.")
