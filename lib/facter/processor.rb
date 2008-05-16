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
