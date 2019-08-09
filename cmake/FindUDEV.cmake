# based on https://gist.github.com/GabrielNagy/09a25f06a431684bbfa07a736f2191cb
# `find_dependency()` is provided by the FindDependency.cmake file.
# Facter can build against libudev.h to gather disk facts:
# https://github.com/puppetlabs/facter/blob/d5507926aca43adcbcc39f8cc5eeddcd81bc241f/lib/src/facts/linux/disk_resolver.cc#L83-L94
include(FindDependency)
find_dependency(UDEV DISPLAY "udev" HEADERS "libudev.h" LIBRARIES "udev")

include(FeatureSummary)
set_package_properties(UDEV PROPERTIES DESCRIPTION "A device manager for the Linux kernel" URL "http://www.freedesktop.org/wiki/Software/systemd")
set_package_properties(UDEV PROPERTIES PURPOSE "Reports disks serial numbers.")
