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
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston MA  02110-1301 USA

# Jeff McCune
# There's a lot more information coming out of system_profiler -xml
# We could add quite a bit more, but I didn't want to overload facter
# at this point in time.
# In particular, Installed Software might be an interesting addition.

module Facter::Macosx
  require 'thread'
  require 'facter/util/plist'
  
  # JJM I'd really like to dynamically generate these methods 
  # by looking at the _name key of the _items dict for each _dataType
  
  def self.hardware_overview
    # JJM Perhaps we should cache the XML data in a "class" level object.
    top_level_plist = Plist::parse_xml %x{/usr/sbin/system_profiler -xml SPHardwareDataType}
    system_hardware = top_level_plist[0]['_items'][0]
    system_hardware.delete '_name'
    system_hardware
  end
  
  # SPSoftwareDataType
  def self.os_overview
    top_level_plist = Plist::parse_xml %x{/usr/sbin/system_profiler -xml SPSoftwareDataType}
    os_stuff = top_level_plist[0]['_items'][0]
    os_stuff.delete '_name'
    os_stuff
  end
  
  def self.sw_vers
    ver = Hash.new
    [ "productName", "productVersion", "buildVersion" ].each do |option|
      ver["macosx_#{option}"] = %x{sw_vers -#{option}}.strip
    end
    ver
  end
end

Facter::Macosx.hardware_overview.each do |fact, value|
  Facter.add("sp_#{fact}") do
    confine :kernel => :darwin
    setcode do
      value
    end
  end
end

Facter::Macosx.os_overview.each do |fact, value|
  Facter.add("sp_#{fact}") do
    confine :kernel => :darwin
    setcode do
      value
    end
  end
end

Facter::Macosx.sw_vers.each do |fact, value|
  Facter.add(fact) do
    confine :kernel => :darwin
    setcode do
      value
    end
  end
end
