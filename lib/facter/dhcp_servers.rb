# Fact: dhcp_servers
#
# Purpose:
#   Return the DHCP server addresses for all interfaces as a hash.
#   If the interface that is the default gateway is DHCP assigned, there
#   will also be a `"system"` entry in the hash.
#
#   This fact is structured. Values are returned as a group of key-value pairs.
#
# Resolution:
#   Parses the output of `nmcli` to find the DHCP server for the interface if available.
#
# Caveats:
#   Requires `nmcli` to be available and the interface must use network-manager.
#

require 'facter'
require 'facter/util/dhcp_servers'


Facter.add(:dhcp_servers) do
  confine :kernel => :linux
  confine do
    Facter::Core::Execution.which('nmcli')
  end
  confine do
    s = Facter::Util::DHCPServers.network_manager_state
    !s.empty? && (s != 'unknown')
  end

  setcode do
    gwdev   = Facter::Util::DHCPServers.gateway_device
    devices = Facter::Util::DHCPServers.devices

    dhcp_servers = {}
    devices.each do |device|
      if server = Facter::Util::DHCPServers.device_dhcp_server(device)
        dhcp_servers['system'] = server if device == gwdev
        dhcp_servers[device]   = server
      end
    end

    dhcp_servers.keys.length > 0 ? dhcp_servers : nil
  end
end
