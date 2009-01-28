#
# macosx.rb
# Additional Facts coming from Mac OS X system_profiler command
#
# Copyright (C) 2007 Jeff McCune
# Author: Jeff McCune <jeff.mccune@northstarlabs.net>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation (version 2 of the License)
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.    See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston MA    02110-1301 USA

# Jeff McCune
# There's a lot more information coming out of system_profiler -xml
# We could add quite a bit more, but I didn't want to overload facter
# at this point in time.
# In particular, Installed Software might be an interesting addition.

require 'facter/util/macosx'

if Facter.value(:kernel) == "Darwin"
    Facter::Util::Macosx.hardware_overview.each do |fact, value|
        Facter.add("sp_#{fact}") do
            confine :kernel => :darwin
            setcode do
                value.to_s
            end
        end
    end

    Facter::Util::Macosx.os_overview.each do |fact, value|
        Facter.add("sp_#{fact}") do
            confine :kernel => :darwin
            setcode do
                value.to_s
            end
        end
    end

    Facter::Util::Macosx.sw_vers.each do |fact, value|
        Facter.add(fact) do
            confine :kernel => :darwin
            setcode do
                value
            end
        end
    end
end
