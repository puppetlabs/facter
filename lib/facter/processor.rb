# Fact: processor
#
# Purpose:
#   Additional Facts about the machine's CPUs.
#
# Resolution:
#   On Linux and kFreeBSD, parse '/proc/cpuinfo' for each processor.
#   On AIX, parse the output of 'lsdev' for its processor section.
#   On Solaris, parse the output of 'kstat' for each processor.
#   On OpenBSD, use the sysctl variables 'hw.model' and 'hw.ncpu'
#   for the CPU model and the CPU count respectively.
#
# Caveats:
#

# processor.rb
#
# Copyright (C) 2006 Mooter Media Ltd
# Author: Matthew Palmer <matt@solutionsfirst.com.au>
#

require 'thread'
require 'facter/processors/util'
require 'facter/util/posix'

# We have to enumerate these outside a Facter.add block to get the processorN
# descriptions iteratively (but we need them inside the Facter.add block above
# for tests on processorcount to work)

Facter.collection.internal_loader.load("processors")
if processor_list = Facter.fact("processors").value["processorlist"]
  processor_list.each do |key, value|
    Facter.add("#{key}") do
      confine :kernel => [ :aix, :"hp-ux", :sunos, :linux, :"gnu/kfreebsd" ]
      setcode { value }
    end
  end
end

Facter.add("ProcessorCount") do
  confine :kernel => [ :linux, :"gnu/kfreebsd", :Darwin, :aix, :"hp-ux", :dragonfly, :freebsd, :openbsd, :sunos, :windows ]
  setcode { Facter.fact("processors").value["processorcount"] }
end

Facter.add("Processor") do
  confine :kernel =>  [:dragonfly, :freebsd, :openbsd]
  setcode { Facter.fact("processors").value["processor"] }
end
