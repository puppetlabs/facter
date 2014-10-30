# Fact: processor
#
# Purpose:
#   Additional Facts about the machine's CPUs.
#
# Resolution:
#   Utilizes values from the processors structured fact, which itself
#   uses various methods to collect CPU information, with implementation
#   dependent upon the OS of the system in question.
#
# Caveats:
#

# processor.rb
#
# Copyright (C) 2006 Mooter Media Ltd
# Author: Matthew Palmer <matt@solutionsfirst.com.au>
#


# We have to enumerate these outside a Facter.add block to get the processorN
# descriptions iteratively (but we need them inside the Facter.add block above
# for tests on processorcount to work)
processors = Facter.value(:processors)
if processors && (processor_list = processors["models"])
  processor_list.each_with_index do |processor, i|
    Facter.add("processor#{i}") do
      setcode { processor }
    end
  end
end

Facter.add("ProcessorCount") do
  confine do
    !Facter.value(:processors).nil?
  end

  setcode do
    if (processorcount = processors["count"])
      processorcount
    else
      nil
    end
  end
end

Facter.add("Processor") do
  confine :kernel => [:dragonfly,:freebsd,:openbsd]
  setcode do
    Facter::Util::POSIX.sysctl("hw.model")
  end
end
