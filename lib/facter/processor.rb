# Fact: processor
#
# Purpose:
#   Additional Facts about the machine's CPUs.
#
# Resolution:
#   On Linux and kFreeBSD, parse '/proc/cpuinfo' for each processor.
#   On AIX, parse the output of 'lsdev' for it's processor section.
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

if ["Linux", "GNU/kFreeBSD"].include? Facter.value(:kernel)
    processor_num = -1
    processor_list = []
    Thread::exclusive do
        File.readlines("/proc/cpuinfo").each do |l|
            if l =~ /processor\s+:\s+(\d+)/
                processor_num = $1.to_i
            elsif l =~ /model name\s+:\s+(.*)\s*$/
                processor_list[processor_num] = $1 unless processor_num == -1
                processor_num = -1
            elsif l =~ /processor\s+(\d+):\s+(.*)/
                processor_num = $1.to_i
                processor_list[processor_num] = $2 unless processor_num == -1
            end
        end
    end

    Facter.add("ProcessorCount") do
        confine :kernel => [ :linux, :"gnu/kfreebsd" ]
        setcode do
            processor_list.length.to_s
        end
    end

    processor_list.each_with_index do |desc, i|
        Facter.add("Processor#{i}") do
            confine :kernel => [ :linux, :"gnu/kfreebsd" ]
            setcode do
                desc
            end
        end
    end
end

if Facter.value(:kernel) == "AIX"
    processor_num = -1
    processor_list = {}
    Thread::exclusive do
        procs = Facter::Util::Resolution.exec('lsdev -Cc processor')
        procs.each do |proc|
            if proc =~ /^proc(\d+)/
                processor_num = $1.to_i
                # Not retrieving the frequency since AIX 4.3.3 doesn't support the
                # attribute and some people still use the OS.
                proctype = Facter::Util::Resolution.exec('lsattr -El proc0 -a type')
                if proctype =~ /^type\s+(\S+)\s+/
                    processor_list["processor#{processor_num}"] = $1
                end
            end
        end
    end

    Facter.add("ProcessorCount") do
        confine :kernel => :aix
        setcode do
            processor_list.length.to_s
        end
    end

    processor_list.each do |proc, desc|
        Facter.add(proc) do
            confine :kernel => :aix
            setcode do
                desc
            end
        end
    end
end

if Facter.value(:kernel) == "OpenBSD"
    Facter.add("Processor") do
        confine :kernel => :openbsd
        setcode do
            Facter::Util::Resolution.exec("uname -p")
        end
    end

    Facter.add("ProcessorCount") do
        confine :kernel => :openbsd
        setcode do
            Facter::Util::Resolution.exec("sysctl hw.ncpu | cut -d'=' -f2")
        end
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
