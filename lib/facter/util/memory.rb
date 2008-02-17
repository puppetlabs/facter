## memory.rb
## Support module for memory related facts
##
## This program is free software; you can redistribute it and/or
## modify it under the terms of the GNU General Public License
## as published by the Free Software Foundation (version 2 of the License)
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 51 Franklin St, Fifth Floor, Boston MA  02110-1301 USA
##

module Facter::Memory
    require 'thread'

    def self.meminfo_number(tag)
        memsize = ""
        Thread::exclusive do
            size, scale = [0, ""]
            File.readlines("/proc/meminfo").each do |l|
                size, scale = [$1.to_f, $2] if l =~ /^#{tag}:\s+(\d+)\s+(\S+)/
                # MemoryFree == memfree + cached + buffers
                #  (assume scales are all the same as memfree)
                if tag == "MemFree" &&
                    l =~ /^(?:Buffers|Cached):\s+(\d+)\s+(?:\S+)/
                    size += $1.to_f
                end
            end
            memsize = scale_number(size, scale)
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

