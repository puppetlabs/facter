# Fact: dhcp_servers
#
# Purpose:
#   Return the DHCP server addresses for all interfaces as a hash.
#   If the interface that is the default gateway is dhcp assigned, there
#   will also be a 'system' entry in the hash.
#
# Resolution:
#   Parses the output of nmcli to find the DHCP server for the interface if available
#
# Caveats:
#   Requires nmcli to be available and the interface must use network-manager.
#

require 'facter'
require 'facter/util/dhcp_servers'


Facter.add(:dhcp_servers) do
  confine :kernel => :linux
  confine do
    Facter::Core::Execution.which('nmcli')
  end

  setcode do
    gwdev   = Facter::Util::Dhcp_servers.gateway_device
    devices = Facter::Util::Dhcp_servers.devices

    dhcp_servers = {}
    devices.each do |device|
      if server = Facter::Util::Dhcp_servers.device_dhcp_server(device)
        dhcp_servers['system'] = server if device == gwdev
        dhcp_servers[device]   = server
      end
    end

    dhcp_servers.keys.length > 0 ? dhcp_servers : nil
  end
end
