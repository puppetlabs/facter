module Facter::Util::Dhcp_servers
  def self.gateway_device
    Facter::Util::Resolution.exec("route -n").scan(/^0\.0\.0\.0.*?(\S+)$/).flatten.first
  end

  def self.devices
    if Facter::Core::Execution.which('nmcli')
      Facter::Util::Resolution.exec("nmcli d").split("\n").select {|d| d =~ /\sconnected/i }.collect{ |line| line.split[0] }
    else
      []
    end
  end

  def self.device_dhcp_server(device)
    if Facter::Core::Execution.which('nmcli')
      Facter::Util::Resolution.exec("nmcli d list iface #{device}").scan(/dhcp_server_identifier.*?(\d+\.\d+\.\d+\.\d+)$/).flatten.first
    end
  end
end
