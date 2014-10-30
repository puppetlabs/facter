# Fact: physicalprocessorcount
#
# Purpose: Return the number of physical processors.
#
# Resolution:
#   Uses the physicalprocessorcount key of the processors structured
#   fact, which itself attempts to use sysfs to get the physical IDs of
#   the processors and falls back to `/proc/cpuinfo` and `physical id` if
#   sysfs is not available.
#
# Caveats:
#

Facter.add('physicalprocessorcount') do
  confine do
    !Facter.value(:processors).nil?
  end

  setcode do
    processors = Facter.value(:processors)
    if (physicalprocessorcount = processors["physicalcount"])
      physicalprocessorcount
    else
      nil
    end
  end
end
