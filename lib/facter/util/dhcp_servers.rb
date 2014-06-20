require 'facter/util/file_read'

module Facter::Util::DHCPServers
  def self.gateway_device
    interface = nil
    if routes = Facter::Util::FileRead.read('/proc/net/route')
      routes.each_line do |line|
        device, destination = line.split(' ')
        if destination == '00000000'
          interface = device
          break
        end
      end
    end
    interface
  end

  def self.devices
    if Facter::Core::Execution.which('nmcli')
      Facter::Core::Execution.exec("nmcli d").split("\n").select {|d| d =~ /\sconnected/i }.collect{ |line| line.split[0] }
    else
      []
    end
  end

  def self.device_dhcp_server(device)
    if Facter::Core::Execution.which('nmcli')
      version = self.nmcli_version
      # If the version is >= 0.9.9, use show instead of list
      if version && version[0] > 0 || version[1] > 9 || (version[1] == 9 && version[2] >= 9)
        Facter::Core::Execution.exec("nmcli -f all d show #{device}").scan(/dhcp_server_identifier.*?(\d+\.\d+\.\d+\.\d+)$/).flatten.first
      else
        Facter::Core::Execution.exec("nmcli -f all d list iface #{device}").scan(/dhcp_server_identifier.*?(\d+\.\d+\.\d+\.\d+)$/).flatten.first
      end
    end
  end

  def self.nmcli_version
    if version = Facter::Core::Execution.exec("nmcli --version")
      version.scan(/version\s(\d+)\.?(\d+)?\.?(\d+)?\.?(\d+)?/).flatten.map(&:to_i)
    end
  end
end
