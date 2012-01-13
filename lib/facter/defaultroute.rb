require 'facter/util/ip'
require 'facter/util/netstat'
require 'ipaddr'

# Fact: defaultroute
#
# Purpose: Return the default route for a host.
#
# Resolution:
#   Runs netstat, and returns the gateway associated with the destination
#   "default" or "0.0.0.0".
#
# Caveats:
#

Facter.add(:defaultroute) do
  confine :kernel => Facter::Util::NetStat.supported_platforms
  setcode do
    Facter::Util::NetStat.get_route_value('default', 'gw') ||
    Facter::Util::NetStat.get_route_value('0.0.0.0', 'gw')
  end
end

# Fact: defaultroute_interface
#
# Purpose: Return the interface uses for the host's default route.
#
# Resolution:
#   Runs netstat, and returns the interface associated with the route for the
#   destination "default" or "0.0.0.0".
#
#   If the default route listing only includes the gateway and not the
#   interface (as is the case on Solaris), return the first interface whose
#   network range includes the default gateway.
#
# Caveats:
#

Facter.add(:defaultroute_interface) do
  confine :kernel => Facter::Util::NetStat.supported_platforms
  setcode do
    Facter::Util::NetStat.get_route_value('default', 'iface') ||
    Facter::Util::NetStat.get_route_value('0.0.0.0', 'iface')
  end
end

Facter.add(:defaultroute_interface) do
  confine :kernel => Facter::Util::IP.supported_platforms
  setcode do
    return nil unless defaultroute = Facter.value(:defaultroute)
    gw = IPAddr.new(defaultroute)

    Facter::Util::IP.get_interfaces.collect { |i| Facter::Util::IP.alphafy(i) }.
    detect do |i| 
      range = Facter.value('network_' + i) +
              '/' +
              Facter.value('netmask_' + i)
      IPAddr.new(range).include?(gw)
    end
  end
end
