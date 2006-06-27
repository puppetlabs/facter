#
# memory.rb
# Additional Facts for memory/swap usage
#
# Copyright (C) 2006 Mooter Media Ltd
# Author: Matthew Palmer <matt@solutionsfirst.com.au>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation (version 2 of the License)
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston MA  02110-1301 USA

module Facter::Memory
    require 'thread'

    def self.meminfo_number(tag)
        memsize = ""
        Thread::exclusive do
            File.readlines("/proc/meminfo").each do |l|
                if l =~ /^#{tag}:\s+(\d+)\s+(\S+)/
                    memsize = scale_number($1.to_f, $2)
                end
            end
        end
            
        memsize
    end

    def self.scale_number(size, multiplier)
        suffixes = ['', 'kB', 'MB', 'GB', 'TB']

        s = suffixes.shift
        while s != multiplier
            s = suffixes.shift
        end

        while size > 1024.0
            size /= 1024.0
            s = suffixes.shift
        end
                    
        return "%.2f %s" % [size, s]
    end
end

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
