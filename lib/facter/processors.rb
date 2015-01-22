# Fact: processors
#
# Purpose:
#   Provide additional facts about the machine's CPUs, including:
#   Models: A list of processors present on the system.
#   Count:  The number of hardware threads.
#   Physicalcount: The number of physical processors.
#   Speed: The speed of the processors on the system.
#
#   This fact is structured. These values are returned as a group of key-value pairs.
#
# Resolution:
#   Linux and kFreeBSD parse `/proc/cpuinfo` for each processor.
#   AIX parses the output of `lsdev` for its processor section.
#   Solaris parses the output of `kstat` for each processor.
#   OpenBSD uses the sysctl variables `hw.model` and `hw.ncpu` for the CPU model
#   and the CPU count respectively.
#   Darwin utilizes the system profiler to collect the physical CPU count and speed.
#
# Caveats:
#   The 'speed' sub-fact is not currently supported on all platforms.

require 'facter/processors/os'

Facter.add(:processors, :type => :aggregate) do
  confine do
    !os.nil?
  end

  def os
    @os ||= Facter::Processors.implementation
  end

  chunk(:models) do
    processor_hash = {}
    processor_list = os.get_processor_list
    if processor_list.length > 0
      processor_hash["models"] = processor_list
      processor_hash
    end
  end

  chunk(:count) do
    processor_hash = {}
    if (processor_count = os.get_processor_count)
      processor_hash["count"] = processor_count
      processor_hash
    end
  end

  chunk(:physicalcount) do
    processor_hash = {}
    if (physical_processor_count = os.get_physical_processor_count)
      processor_hash["physicalcount"] = physical_processor_count
      processor_hash
    end
  end

  chunk(:speed) do
    processor_hash = {}
    if (processor_speed = os.get_processor_speed)
      processor_hash["speed"] = processor_speed
      processor_hash
    end
  end
end
