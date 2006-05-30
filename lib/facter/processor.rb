#
# processor.rb
# Additional Facts about the machine's CPUs
#
# Copyright (C) 2006 Mooter Media Ltd
# Author: Matthew Palmer <matt@solutionsfirst.com.au>
#
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
#

processor_num = -1
processor_list = []
File.readlines("/proc/cpuinfo").each do |l|
	if l =~ /processor\s+:\s+(\d+)/
		processor_num = $1.to_i
	elsif l =~ /model name\s+:\s+(.*)\s*$/
		processor_list[processor_num] = $1 unless processor_num == -1
		processor_num = -1
	end
end

Facter.add("ProcessorCount") do
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
