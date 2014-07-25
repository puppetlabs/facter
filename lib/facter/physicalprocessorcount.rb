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
  setcode do
    confine do
      !Facter.value(:processors).nil?
    end

    processors = Facter.value(:processors)
    if processors and (physicalprocessorcount = processors["physicalcount"])
      physicalprocessorcount.to_s
    else
      nil
    end
  end
end
