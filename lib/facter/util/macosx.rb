## macosx.rb
## Support methods for Apple OSX facts
##
## Copyright (C) 2007 Jeff McCune
## Author: Jeff McCune <jeff.mccune@northstarlabs.net>
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
