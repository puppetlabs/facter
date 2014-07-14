# Fact: network
#
# Purpose:
#   Get IP, network, and netmask information for available network
#   interfaces.
#
# Resolution:
#   Uses `facter/util/ip` to enumerate interfaces and return their information.
#
# Caveats:
#
require 'facter/util/ip'

Facter::Util::IP.get_interfaces.each do |interface|
  Facter.add("network_" + Facter::Util::IP.alphafy(interface)) do
    setcode do
      Facter::Util::IP.get_network_value(interface)
    end
  end
end
