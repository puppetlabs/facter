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
      # If the version is >= 0.9.9, use show instead of list
      if is_newer_nmcli?
        Facter::Core::Execution.exec("nmcli -f all d show #{device}").scan(/dhcp_server_identifier.*?(\d+\.\d+\.\d+\.\d+)$/).flatten.first
      else
        Facter::Core::Execution.exec("nmcli -f all d list iface #{device}").scan(/dhcp_server_identifier.*?(\d+\.\d+\.\d+\.\d+)$/).flatten.first
      end
    end
  end

  def self.network_manager_state
    # If the version is >= 0.9.9, use g instead of nm
    if is_newer_nmcli?
      output = Facter::Core::Execution.exec('nmcli -t -f STATE g 2>/dev/null')
    else
      output = Facter::Core::Execution.exec('nmcli -t -f STATE nm 2>/dev/null')
    end
    return nil unless output
    output.strip
  end

  def self.nmcli_version
    if version = Facter::Core::Execution.exec("nmcli --version")
      version.scan(/version\s(\d+)\.?(\d+)?\.?(\d+)?\.?(\d+)?/).flatten.map(&:to_i)
    end
  end

  def self.is_newer_nmcli?
    version = nmcli_version
    version && (version[0] > 0 || version[1] > 9 || (version[1] == 9 && version[2] >= 9))
  end
end
