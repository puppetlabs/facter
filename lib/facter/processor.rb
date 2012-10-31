# Fact: processor
#
# Purpose:
#   Additional Facts about the machine's CPUs.
#
# Resolution:
#   On Linux and kFreeBSD, parse '/proc/cpuinfo' for each processor.
#   On AIX, parse the output of 'lsdev' for its processor section.
#   On Solaris, parse the output of 'kstat' for each processor.
#   On OpenBSD, use 'uname -p' and the sysctl variable for 'hw.ncpu' for CPU
#   count.
#
# Caveats:
#

# processor.rb
#
# Copyright (C) 2006 Mooter Media Ltd
# Author: Matthew Palmer <matt@solutionsfirst.com.au>
#

require 'thread'
require 'facter/util/processor'

## We have to enumerate these outside a Facter.add block to get the processorN descriptions iteratively
## (but we need them inside the Facter.add block above for tests on processorcount to work)
processor_list = case Facter::Util::Processor.kernel_fact_value
when "AIX"
  Facter::Util::Processor.aix_processor_list
when "HP-UX"
  Facter::Util::Processor.hpux_processor_list
when "SunOS"
  Facter::Util::Processor.enum_kstat
else
  Facter::Util::Processor.enum_cpuinfo
end

processor_list.each_with_index do |desc, i|
  Facter.add("Processor#{i}") do
    confine :kernel => [ :aix, :"hp-ux", :sunos, :linux, :"gnu/kfreebsd" ]
    setcode do
      desc
    end
  end
end

Facter.add("ProcessorCount") do
  confine :kernel => [ :linux, :"gnu/kfreebsd" ]
  setcode do
    processor_list = Facter::Util::Processor.enum_cpuinfo

    ## If this returned nothing, then don't resolve the fact
    if processor_list.length != 0
      processor_list.length.to_s
    end
  end
end

Facter.add("ProcessorCount") do
  confine :kernel => [ :linux, :"gnu/kfreebsd" ]
  setcode do
    ## The method above is preferable since it provides the description of the CPU as well
    ## but if that returned 0, then we enumerate sysfs
    sysfs_cpu_directory = '/sys/devices/system/cpu'
    if File.exists?(sysfs_cpu_directory)
      lookup_pattern = "#{sysfs_cpu_directory}" + "/cpu[0-9]*"
      cpuCount = Dir.glob(lookup_pattern).length
      cpuCount.to_s
    end
  end
end

Facter.add("ProcessorCount") do
  confine :kernel => :aix
  setcode do
    processor_list = Facter::Util::Processor.aix_processor_list

    processor_list.length.to_s
  end
end

Facter.add("ProcessorCount") do
  confine :kernel => :"hp-ux"
  setcode do
    processor_list = Facter::Util::Processor.hpux_processor_list
    processor_list.length.to_s
  end
end

Facter.add("Processor") do
  confine :kernel => :openbsd
  setcode do
    Facter::Util::Resolution.exec("uname -p")
  end
end

Facter.add("ProcessorCount") do
  confine :kernel => :openbsd
  setcode do
    Facter::Util::Resolution.exec("sysctl -n hw.ncpu")
  end
end

Facter.add("ProcessorCount") do
  confine :kernel => :Darwin
  setcode do
    Facter::Util::Resolution.exec("sysctl -n hw.ncpu")
  end
end

if Facter.value(:kernel) == "windows"
  processor_list = []

  Thread::exclusive do
    require 'facter/util/wmi'

    # get each physical processor
    Facter::Util::WMI.execquery("select * from Win32_Processor").each do |proc|
      # not supported before 2008
      begin
        processor_num = proc.NumberOfLogicalProcessors
      rescue RuntimeError => e
        processor_num = 1
      end

      processor_num.times do |i|
        processor_list << proc.Name.squeeze(" ")
      end
    end
  end

  processor_list.each_with_index do |name, i|
    Facter.add("Processor#{i}") do
      confine :kernel => :windows
      setcode do
        name
      end
    end
  end

  Facter.add("ProcessorCount") do
    confine :kernel => :windows
    setcode do
      processor_list.length.to_s
    end
  end
end

Facter.add("Processor") do
  confine :kernel => :dragonfly
  setcode do
    Facter::Util::Resolution.exec("sysctl -n hw.model")
  end
end

Facter.add("ProcessorCount") do
  confine :kernel => :dragonfly
  setcode do
    Facter::Util::Resolution.exec("sysctl -n hw.ncpu")
  end
end

Facter.add("ProcessorCount") do
  confine :kernel => :sunos
  setcode do
    kernelrelease = Facter.value(:kernelrelease)
    (major_version, minor_version) = kernelrelease.split(".").map { |str| str.to_i }
    result = nil

    if (major_version > 5) or (major_version == 5 and minor_version >= 8) then
      if kstat = Facter::Util::Resolution.exec("/usr/bin/kstat cpu_info")
        result = kstat.scan(/\bcore_id\b\s+\d+/).uniq.length
      end
    else
      if output = Facter::Util::Resolution.exec("/usr/sbin/psrinfo") then
        result = output.split("\n").length
      end
    end

    result
  end
end
