# netmask.rb
# Find the netmask of the primary ipaddress
# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# Copyright (C) 2007 Mark 'phips' Phillips
#
# idea and originial source by Mark 'phips' Phillips
#

require 'facter/util/netmask'

Facter.add("netmask") do
    confine :kernel => [ :sunos, :linux, :freebsd, :openbsd, :netbsd, :darwin ]
    setcode do
        Facter::NetMask.get_netmask
    end
end

