# Fact: network
#
# Purpose:
# Get IP, network and netmask information for available network interfaces.
#
# Resolution:
# Uses 'facter/util/ip' to enumerate interfaces and return their information.

require 'facter/util/ip'

Facter::Util::IP.interfaces.each do |interface|
  Facter.add("network_" + Facter::Util::IP.alphafy(interface)) do
    setcode do
      Facter::Util::IP.network(interface)
    end
  end
end
