# Fact: processors
#
#
#  Purpose:
#     Additional facts about the machine's CPU's, including
#     processor lists, models, counts, and speeds.
#
#  Resolution:
#     Each kernel utilizes its own implementation object to collect
#     processor data. Linux and kFreeBSD parse `/proc/cpuinfo` for each
#     processor. AIX parses the output of `lsdev` for its processor section.
#     For Solaris, we parse the output of `kstat` for each processor. OpenBSD uses
#     the sysctl variables 'hw.model' and 'hw.ncpu' for the CPU model and the
#     CPU count respectively. Darwin utilizes the system profiler to collect
#     the physical CPU count and speed.

require 'facter/processors/os'

Facter.add(:processors, :type => :aggregate) do
  def os
    @os ||= Facter::Processors.implementation
  end

  chunk(:processorlist) do
    processor_hash = {}
    processor_hash["processorlist"] = {}
    processorlist = os.get_processor_list

    if processorlist.length > 0
      processorlist.each_with_index do |processor, i|
        processor_hash["processorlist"]["processor#{i}"] = processor
      end
      processor_hash
    end
  end

  chunk(:processorcount) do
    processor_hash = {}
    if processor_count = os.get_processor_count
      processor_hash["processorcount"] = processor_count
      processor_hash
    end
  end

  chunk(:physicalprocessorcount) do
    processor_hash = {}
    if physical_processor_count = os.get_physical_processor_count
      processor_hash["physicalprocessorcount"] = physical_processor_count
      processor_hash
    end
  end

  chunk(:processorspeed) do
    processor_hash = {}
    if processor_speed = os.get_processor_speed
      processor_hash["processorspeed"] = processor_speed
      processor_hash
    end
  end
end
