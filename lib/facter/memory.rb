# memory.rb
# Additional Facts for memory/swap usage
#
# Copyright (C) 2006 Mooter Media Ltd
# Author: Matthew Palmer <matt@solutionsfirst.com.au>
#
#
require 'facter/util/memory'

{:MemorySize => "MemTotal",
 :MemoryFree => "MemFree",
 :SwapSize   => "SwapTotal",
 :SwapFree   => "SwapFree"}.each do |fact, name|
    Facter.add(fact) do
        confine :kernel => :linux
        setcode do
            Facter::Memory.meminfo_number(name)
        end
    end
end
