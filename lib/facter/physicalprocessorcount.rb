# Fact: physicalprocessorcount
#
# Purpose: Return the number of physical processors.
#
# Resolution:
#   Uses the 'physicalprocessorcount' of the 'processors' structured
#   fact, which itself attempts to use sysfs to get the physical IDs of
#   the processors and falls back to /proc/cpuinfo and "physical id" if 
#   sysfs is not available.
#
# Caveats:
#

Facter.add('physicalprocessorcount') do
  confine :kernel => [:linux, :windows, :sunos, :darwin, :openbsd]
  setcode { Facter.fact("processors").value["physicalprocessorcount"] }
end
