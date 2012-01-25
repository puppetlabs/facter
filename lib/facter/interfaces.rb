# Fact: interfaces
#
# Purpose: 
#    Get information regarding all primary interfaces available on the machine 
#
# Resolution: 
#    Generates facts regarding the information about all the network interfaces -
#    physical or virtual that are available on the machine (e.g. ipaddress, ipaddress6, 
#    macaddress and netmask)
#
#    The function 'get_all_interface_output' in util/ip.rb is used to get the details for 
#    each interface's ipaddress, macaddress, netmask:
#    Linux, OpenBSD, NetBSD, FreeBSD, Darwin, GNU/kFreeBSD, DragonFly use 'ifconfig -a'.
#    SunOS uses 'ifconfig -a'.
#    HP-UX uses 'netstat -in | sed -e 1d'
#    windows uses 'netsh'
#    
# Original concept Copyright (C) 2007 psychedelys <psychedelys@gmail.com>
# Update and *BSD support (C) 2007 James Turnbull <james@lovedthanlost.net>
#
require 'facter/util/ip'

Facter.add(:interfaces) do
  confine :kernel => Facter::Util::IP.supported_platforms
  setcode do
    Facter::Util::IP.get_interfaces.collect { |iface| Facter::Util::IP.alphafy(iface) }.join(",")
  end
end

Facter::Util::IP.get_interfaces.each do |interface|

  # Make a fact for each detail of each interface.  Yay.
  #   There's no point in confining these facts, since we wouldn't be able to create
  # them if we weren't running on a supported platform.
  %w{ipaddress ipaddress6 macaddress netmask}.each do |label|
    Facter.add(label + "_" + Facter::Util::IP.alphafy(interface)) do
      setcode do
        Facter::Util::IP.get_interface_value(interface, label)
      end
    end
  end
end
