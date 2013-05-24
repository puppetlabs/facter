# A base module for collecting IP-related
# information from all kinds of platforms.
module Facter::Util::IP
  # A map of all the different regexes that work for
  # a given platform or set of platforms.
  REGEX_MAP = {
    :linux => {
      :ipaddress  => /inet (?:addr:)?([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/,
      :ipaddress6 => /inet6 (?:addr: )?((?![fe80|::1])(?>[0-9,a-f,A-F]*\:{1,2})+[0-9,a-f,A-F]{0,4})/,
      :macaddress => /(?:ether|HWaddr)\s+((\w{1,2}:){5,}\w{1,2})/,
      :netmask  => /(?:Mask:|netmask )([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/,
      :mtu  => /MTU:(\d+)/
    },
    :bsd   => {
      :aliases  => [:openbsd, :netbsd, :freebsd, :darwin, :"gnu/kfreebsd", :dragonfly],
      :ipaddress  => /inet\s+([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/,
      :ipaddress6 => /inet6 ((?![fe80|::1])(?>[0-9,a-f,A-F]*\:{1,2})+[0-9,a-f,A-F]{0,4})/,
      :macaddress => /(?:ether|lladdr)\s+(\w?\w:\w?\w:\w?\w:\w?\w:\w?\w:\w?\w)/,
      :netmask  => /netmask\s+0x(\w{8})/,
      :mtu => /mtu\s+(\d+)/
    },
    :sunos => {
      :ipaddress  => /inet\s+([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/,
      :ipaddress6 => /inet6 ((?![fe80|::1])(?>[0-9,a-f,A-F]*\:{1,2})+[0-9,a-f,A-F]{0,4})/,
      :macaddress => /(?:ether|lladdr)\s+(\w?\w:\w?\w:\w?\w:\w?\w:\w?\w:\w?\w)/,
      :netmask  => /netmask\s+(\w{8})/,
      :mtu => /mtu\s+(\d+)/
    },
    :"hp-ux" => {
      :ipaddress  => /\s+inet (\S+)\s.*/,
      :macaddress => /(\w{1,2}:\w{1,2}:\w{1,2}:\w{1,2}:\w{1,2}:\w{1,2})/,
      :netmask  => /.*\s+netmask (\S+)\s.*/
    },
    :windows => {
      :ipaddress  => /\s+IP Address:\s+([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/,
      :ipaddress6 => /Address ((?![fe80|::1])(?>[0-9,a-f,A-F]*\:{1,2})+[0-9,a-f,A-F]{0,4})/,
      :netmask  => /\s+Subnet Prefix:\s+\S+\s+\(mask ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)\)/
    }
  }

  # Convert an interface name into purely alphanumeric characters.
  def self.alphafy(interface)
    interface.gsub(/[^a-z0-9_]/i, '_')
  end

  def self.convert_from_hex?(kernel)
    kernels_to_convert = [:sunos, :openbsd, :netbsd, :freebsd, :darwin, :"hp-ux", :"gnu/kfreebsd", :dragonfly]
    kernels_to_convert.include?(kernel)
  end

  def self.supported_platforms
    REGEX_MAP.inject([]) do |result, tmp|
      key, map = tmp
      if map[:aliases]
        result += map[:aliases]
      else
        result << key
      end
      result
    end
  end

  def self.get_interfaces
    return [] unless output = Facter::Util::IP.get_all_interface_output()

    # windows interface names contain spaces and are quoted and can appear multiple
    # times as ipv4 and ipv6
    return output.scan(/\s* connected\s*(\S.*)/).flatten.uniq if Facter.value(:kernel) == 'windows'

    # Our regex appears to be stupid, in that it leaves colons sitting
    # at the end of interfaces.  So, we have to trim those trailing
    # characters.  I tried making the regex better but supporting all
    # platforms with a single regex is probably a bit too much.
    output.scan(/^\S+/).collect { |i| i.sub(/:$/, '') }.uniq
  end

  def self.get_all_interface_output
    case Facter.value(:kernel)
    when 'Linux', 'OpenBSD', 'NetBSD', 'FreeBSD', 'Darwin', 'GNU/kFreeBSD', 'DragonFly'
      output = Facter::Util::IP.exec_ifconfig(["-a","2>/dev/null"])
    when 'SunOS'
      output = Facter::Util::IP.exec_ifconfig(["-a"])
    when 'HP-UX'
      # (#17487)[https://projects.puppetlabs.com/issues/17487]
      # Handle NIC bonding where asterisks and virtual NICs are printed.
      if output = hpux_netstat_in
        output.gsub!(/\*/, "")                  # delete asterisks.
        output.gsub!(/^[^\n]*none[^\n]*\n/, "") # delete lines with 'none' instead of IPs.
        output.sub!(/^[^\n]*\n/, "")            # delete the header line.
        output
      end
    when 'windows'
      output = %x|#{ENV['SYSTEMROOT']}/system32/netsh.exe interface ip show interface|
      output += %x|#{ENV['SYSTEMROOT']}/system32/netsh.exe interface ipv6 show interface|
    end
    output
  end


  ##
  # exec_ifconfig uses the ifconfig command
  #
  # @return [String] the output of `ifconfig #{arguments} 2>/dev/null` or nil
  def self.exec_ifconfig(additional_arguments=[])
    Facter::Util::Resolution.exec("#{self.get_ifconfig} #{additional_arguments.join(' ')}")
  end
  ##
  # get_ifconfig looks up the ifconfig binary
  #
  # @return [String] path to the ifconfig binary
  def self.get_ifconfig
    common_paths=["/bin/ifconfig","/sbin/ifconfig","/usr/sbin/ifconfig"]
    common_paths.select{|path| File.executable?(path)}.first
  end
  ##
  # hpux_netstat_in is a delegate method that allows us to stub netstat -in
  # without stubbing exec.
  def self.hpux_netstat_in
    Facter::Util::Resolution.exec("/bin/netstat -in")
  end

  def self.get_infiniband_macaddress(interface)
    if File.exists?("/sys/class/net/#{interface}/address") then
      ib_mac_address = `cat /sys/class/net/#{interface}/address`.chomp
    elsif File.exists?("/sbin/ip") then
      ip_output = %x{/sbin/ip link show #{interface}}
      ib_mac_address = ip_output.scan(%r{infiniband\s+((\w{1,2}:){5,}\w{1,2})})
    else
      ib_mac_address = "FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF"
      Facter.debug("ip.rb: nothing under /sys/class/net/#{interface}/address and /sbin/ip not available")
    end
    ib_mac_address
  end

  def self.ifconfig_interface(interface)
    output = Facter::Util::IP.exec_ifconfig([interface,"2>/dev/null"])
  end

  def self.get_single_interface_output(interface)
    output = ""
    case Facter.value(:kernel)
    when 'OpenBSD', 'NetBSD', 'FreeBSD', 'Darwin', 'GNU/kFreeBSD', 'DragonFly'
      output = Facter::Util::IP.ifconfig_interface(interface)
    when 'Linux'
      ifconfig_output = Facter::Util::IP.ifconfig_interface(interface)
      if interface =~ /^ib/ then
        real_mac_address = get_infiniband_macaddress(interface)
        output = ifconfig_output.sub(%r{(?:ether|HWaddr)\s+((\w{1,2}:){5,}\w{1,2})}, "HWaddr #{real_mac_address}")
      else
        output = ifconfig_output
      end
    when 'SunOS'
      output = Facter::Util::IP.exec_ifconfig([interface])
    when 'HP-UX'
       mac = ""
       ifc = hpux_ifconfig_interface(interface)
       hpux_lanscan.scan(/(\dx\S+).*UP\s+(\w+\d+)/).each {|i| mac = i[0] if i.include?(interface) }
       mac = mac.sub(/0x(\S+)/,'\1').scan(/../).join(":")
       output = ifc + "\n" + mac
    end
    output
  end

  def self.hpux_ifconfig_interface(interface)
    Facter::Util::IP.exec_ifconfig([interface])
  end

  def self.hpux_lanscan
    Facter::Util::Resolution.exec("/usr/sbin/lanscan")
  end

  def self.get_output_for_interface_and_label(interface, label)
    return get_single_interface_output(interface) unless Facter.value(:kernel) == 'windows'

    if label == 'ipaddress6'
      output = %x|#{ENV['SYSTEMROOT']}/system32/netsh.exe interface ipv6 show address \"#{interface}\"|
    else
      output = %x|#{ENV['SYSTEMROOT']}/system32/netsh.exe interface ip show address \"#{interface}\"|
    end
    output
  end

  def self.get_bonding_master(interface)
    if Facter.value(:kernel) != 'Linux'
      return nil
    end
    # We need ip instead of ifconfig because it will show us
    # the bonding master device.
    if not FileTest.executable?("/sbin/ip")
      return nil
    end
    # A bonding interface can never be an alias interface. Alias
    # interfaces do have a colon in their name and the ip link show
    # command throws an error message when we pass it an alias
    # interface.
    if interface =~ /:/
      return nil
    end
    regex = /SLAVE[,>].* (bond[0-9]+)/
      ethbond = regex.match(%x{/sbin/ip link show #{interface}})
    if ethbond
      device = ethbond[1]
    else
      device = nil
    end
    device
  end

  ##
  # get_interface_value obtains the value of a specific attribute of a specific
  # interface.
  #
  # @param interface [String] the interface identifier, e.g. "eth0" or "bond0"
  #
  # @param label [String] the attribute of the interface to obtain a value for,
  # e.g. "netmask" or "ipaddress"
  #
  # @api private
  #
  # @return [String] representing the requested value.  An empty array is
  # returned if the kernel is not supported by the REGEX_MAP constant.
  def self.get_interface_value(interface, label)
    tmp1 = []

    kernel = Facter.value(:kernel).downcase.to_sym

    # If it's not directly in the map or aliased in the map, then we don't know how to deal with it.
    unless map = REGEX_MAP[kernel] || REGEX_MAP.values.find { |tmp| tmp[:aliases] and tmp[:aliases].include?(kernel) }
      return []
    end

    # Pull the correct regex out of the map.
    regex = map[label.to_sym]

    # Linux changes the MAC address reported via ifconfig when an ethernet interface
    # becomes a slave of a bonding device to the master MAC address.
    # We have to dig a bit to get the original/real MAC address of the interface.
    bonddev = get_bonding_master(interface)
    if label == 'macaddress' and bonddev
      bondinfo = read_proc_net_bonding("/proc/net/bonding/#{bonddev}")
      re = /^Slave Interface: #{interface}\b.*?\bPermanent HW addr: (([0-9A-F]{2}:?)*)$/im
      if match = re.match(bondinfo)
        value = match[1].upcase
      end
    else
      output_int = get_output_for_interface_and_label(interface, label)

      output_int.each_line do |s|
        if s =~ regex
          value = $1
            if label == 'netmask' && convert_from_hex?(kernel)
              value = value.scan(/../).collect do |byte| byte.to_i(16) end.join('.')
            end
          tmp1.push(value)
        end
      end

      if tmp1
        value = tmp1.shift
      end
    end
  end

  ##
  # read_proc_net_bonding is a seam method for mocking purposes.
  #
  # @param path [String] representing the path to read, e.g. "/proc/net/bonding/bond0"
  #
  # @api private
  #
  # @return [String] modeling the raw file read
  def self.read_proc_net_bonding(path)
    File.read(path) if File.exists?(path)
  end
  private_class_method :read_proc_net_bonding

  def self.get_network_value(interface)
    require 'ipaddr'

    ipaddress = get_interface_value(interface, "ipaddress")
    netmask = get_interface_value(interface, "netmask")

    if ipaddress && netmask
      ip = IPAddr.new(ipaddress, Socket::AF_INET)
      subnet = IPAddr.new(netmask, Socket::AF_INET)
      network = ip.mask(subnet.to_s).to_s
    end
  end
end
