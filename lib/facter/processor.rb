# processor.rb
# Additional Facts about the machine's CPUs
#
# Copyright (C) 2006 Mooter Media Ltd
# Author: Matthew Palmer <matt@solutionsfirst.com.au>
#

require 'thread'

if Facter.value(:kernel) == "Linux"
    processor_num = -1
    processor_list = []
    Thread::exclusive do
        File.readlines("/proc/cpuinfo").each do |l|
            if l =~ /processor\s+:\s+(\d+)/
                processor_num = $1.to_i
            elsif l =~ /model name\s+:\s+(.*)\s*$/
                processor_list[processor_num] = $1 unless processor_num == -1
                processor_num = -1
            end
        end
    end

    Facter.add("ProcessorCount") do
        confine :kernel => :linux
        setcode do
            processor_list.length.to_s
        end
    end

    processor_list.each_with_index do |desc, i|
        Facter.add("Processor#{i}") do
            confine :kernel => :linux
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
