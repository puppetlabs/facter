# encoding: UTF-8

require 'facter/util/wmi'
require 'facter/util/ip'

class Facter::Util::IP::Windows
  # The WMI query used to return ip information
  #
  # @return [String]
  #
  # @api private
  WMI_IP_INFO_QUERY = 'SELECT Description, ServiceName, IPAddress, IPConnectionMetric, InterfaceIndex, Index, IPSubnet, MACAddress, MTU, SettingID FROM Win32_NetworkAdapterConfiguration WHERE IPConnectionMetric IS NOT NULL AND IPEnabled = TRUE'

  # Mapping fact names to WMI properties of the Win32_NetworkAdapterConfiguration
  #
  # @api private
  WINDOWS_LABEL_WMI_MAP = {
      :ipaddress => 'IPAddress',
      :ipaddress6 => 'IPAddress',
      :macaddress => 'MACAddress',
      :netmask => 'IPSubnet'
  }

  def self.to_s
    'windows'
  end

  # Windows doesn't display netmask in hex.
  #
  # @return [Boolean] false by default
  #
  # @api private
  def self.convert_netmask_from_hex?
    false
  end

  # Retrieves a list of unique interfaces names.
  #
  # @return [Array<String>]
  #
  # @api private
  def self.interfaces
    interface_names = []

    network_adapter_configurations.map do |nic|
      Facter::Util::WMI.execquery("SELECT * FROM Win32_NetworkAdapter WHERE Index = #{nic.Index} AND NetEnabled = TRUE").each do |sub_nic|
        interface_names << sub_nic.NetConnectionId unless sub_nic.NetConnectionId.nil? or sub_nic.NetConnectionId.empty?
      end
    end

    interface_names.uniq
  end

  # Get the value of an interface and label. For example, you may want to find
  # the MTU for eth0.
  #
  # @param [String] interface the name of the interface returned by the {#interfaces} method.
  # @param [String] label the type of value to return, e.g. ipaddress
  # @return [String] the value, or nil if not defined
  #
  # @api private
  def self.value_for_interface_and_label(interface, label)
    wmi_value = WINDOWS_LABEL_WMI_MAP[label.downcase.to_sym]
    label_value = nil
    Facter::Util::WMI.execquery("SELECT Index FROM Win32_NetworkAdapter WHERE NetConnectionID = '#{interface}'").each do |nic|
      Facter::Util::WMI.execquery("SELECT #{wmi_value} FROM Win32_NetworkAdapterConfiguration WHERE Index = #{nic.Index}").each do |nic_config|
        case label.downcase.to_sym
        when :ipaddress
          nic_config.IPAddress.any? do |addr|
            label_value = addr if valid_ipv4_address?(addr)
            label_value
          end
        when :ipaddress6
          nic_config.IPAddress.any? do |addr|
            label_value = addr if Facter::Util::IP::Windows.valid_ipv6_address?(addr)
            label_value
          end
        when :netmask
          nic_config.IPSubnet.any? do |addr|
            label_value = addr if Facter::Util::IP::Windows.valid_ipv4_address?(addr)
            label_value
          end
        when :macaddress
          label_value = nic_config.MACAddress
        end
      end
    end

    label_value
  end

  # Returns an array of partial Win32_NetworkAdapterConfiguration objects.
  #
  # @return [Array<WIN32OLE>] objects
  #
  # @api private
  def self.network_adapter_configurations
    nics = []
    # WIN32OLE doesn't implement Enumerable
    Facter::Util::WMI.execquery(WMI_IP_INFO_QUERY).each do |nic|
      nics << nic
    end
    nics
  end

  # Gets a list of active IPv4 network adapter configurations sorted by the
  # lowest IP connection metric. If two configurations have the same metric,
  # then the IPv4 specific binding order as specified in the registry will
  # be used.
  #
  # @return [Array<WIN32OLE>]
  #
  # @api private
  def self.get_preferred_ipv4_adapters
    get_preferred_network_adapters(Bindings4.new)
  end

  # Gets a list of active IPv6 network adapter configurations sorted by the
  # lowest IP connection metric. If two configurations have the same metric,
  # then the IPv6 specific binding order as specified in the registry will
  # be used.
  #
  # @return [Array<WIN32OLE>]
  #
  # @api private
  def self.get_preferred_ipv6_adapters
    get_preferred_network_adapters(Bindings6.new)
  end

  # Gets a list of active network adapter configurations sorted by the lowest
  # IP connection metric. If two configurations have the same metric, then
  # the adapter binding order as specified in the registry will be used.
  # Note the order may different for IPv4 vs IPv6 addresses.
  #
  # @see http://support.microsoft.com/kb/894564
  # @return [Array<WIN32OLE>]
  #
  # @api private
  def self.get_preferred_network_adapters(bindings)
    network_adapter_configurations.select do |nic|
      bindings.bindings.include?(nic.SettingID)
    end.sort do |nic_left,nic_right|
      cmp = nic_left.IPConnectionMetric <=> nic_right.IPConnectionMetric
      if cmp == 0
        bindings.bindings[nic_left.SettingID] <=> bindings.bindings[nic_right.SettingID]
      else
        cmp
      end
    end
  end

  class Bindings4
    def initialize
      @key = 'SYSTEM\CurrentControlSet\Services\Tcpip\Linkage'
    end

    def bindings
      require 'facter/util/registry'
      bindings = {}

      Facter::Util::Registry.hklm_read(@key, 'Bind').each_with_index do |entry, index|
        match_data = entry.match(/\\Device\\(\{.*\})/)
        unless match_data.nil?
          bindings[match_data[1]] = index
        end
      end

      bindings
    rescue
      {}
    end
  end

  class Bindings6 < Bindings4
    def initialize
      @key = 'SYSTEM\CurrentControlSet\Services\Tcpip6\Linkage'
    end
  end

  # Determines if the value passed in is a valid ipv4 address.
  #
  # @param [String] ip_address the IPv4 address to validate
  # @return [Boolean]
  #
  # @api private
  def self.valid_ipv4_address?(ip_address)
    String(ip_address).scan(/(?:[0-9]{1,3}\.){3}[0-9]{1,3}/).each do |match|
      # excluding 169.254.x.x in Windows - this is the DHCP APIPA
      #  meaning that if the node cannot get an ip address from the dhcp server,
      #  it auto-assigns a private ip address
      unless match == "127.0.0.1" or match =~ /^169.254.*/
        return !!match
      end
    end

    false
  end

  # Determines if the value passed in is a valid ipv6 address.
  #
  # @param [String] ip_address the IPv6 address to validate
  # @return [Boolean]
  #
  # @api private
  def self.valid_ipv6_address?(ip_address)
    String(ip_address).scan(/(?>[0-9,a-f,A-F]*\:{1,2})+[0-9,a-f,A-F]{0,4}/).each do |match|
      unless match =~ /fe80.*/ or match == "::1"
        return !!match
      end
    end

    false
  end

end
