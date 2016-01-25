# Fact: netmask
#
# Purpose: Returns the netmask for the main interfaces.
#
# Resolution: Uses the `facter/util/netmask` library routines.
#
# Caveats:
#

# netmask.rb
# Find the netmask of the primary ipaddress
# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# Copyright (C) 2007 Mark 'phips' Phillips
#
# idea and originial source by Mark 'phips' Phillips
#
require 'facter/util/netmask'

Facter.add("netmask") do
  confine :kernel => [ :sunos, :linux, :freebsd, :openbsd, :netbsd, :darwin, :"gnu/kfreebsd", :dragonfly, :AIX ]
  setcode do
    Facter::NetMask.get_netmask
  end
end

Facter.add(:netmask) do
  confine :kernel => :windows
  setcode do
    require 'facter/util/ip/windows'

    mask = nil

    adapters = Facter::Util::IP::Windows.get_preferred_ipv4_adapters
    adapters.find do |nic|
      nic.IPSubnet.any? do |subnet|
        mask = subnet if Facter::Util::IP::Windows.valid_ipv4_address?(subnet)
        mask
      end
    end

    mask
  end
end
