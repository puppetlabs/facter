# A base module for collecting IP-related
# information from all kinds of platforms.
module Facter::Util::IP
  # A map of all the different regexes that work for
  # a given platform or set of platforms.
  REGEX_MAP = {
    :linux => {
      :ipaddress  => /inet addr:([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/,
      :ipaddress6 => /inet6 addr: ((?![fe80|::1])(?>[0-9,a-f,A-F]*\:{1,2})+[0-9,a-f,A-F]{0,4})/,
      :macaddress => /(?:ether|HWaddr)\s+(\w{1,2}:\w{1,2}:\w{1,2}:\w{1,2}:\w{1,2}:\w{1,2})/,
      :netmask  => /Mask:([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/
    },
    :bsd   => {
      :aliases  => [:openbsd, :netbsd, :freebsd, :darwin, :"gnu/kfreebsd", :dragonfly],
      :ipaddress  => /inet\s+([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/,
      :ipaddress6 => /inet6 ((?![fe80|::1])(?>[0-9,a-f,A-F]*\:{1,2})+[0-9,a-f,A-F]{0,4})/,
      :macaddress => /(?:ether|lladdr)\s+(\w?\w:\w?\w:\w?\w:\w?\w:\w?\w:\w?\w)/,
      :netmask  => /netmask\s+0x(\w{8})/
    },
    :sunos => {
      :ipaddress  => /inet\s+([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/,
      :ipaddress6 => /inet6 ((?![fe80|::1])(?>[0-9,a-f,A-F]*\:{1,2})+[0-9,a-f,A-F]{0,4})/,
      :macaddress => /(?:ether|lladdr)\s+(\w?\w:\w?\w:\w?\w:\w?\w:\w?\w:\w?\w)/,
      :netmask  => /netmask\s+(\w{8})/
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
      output = %x{/sbin/ifconfig -a}
    when 'SunOS'
      output = %x{/usr/sbin/ifconfig -a}
    when 'HP-UX'
      output = %x{/bin/netstat -in | sed -e 1d}
    when 'windows'
      output = %x|#{ENV['SYSTEMROOT']}/system32/netsh interface ip show interface|
      output += %x|#{ENV['SYSTEMROOT']}/system32/netsh interface ipv6 show interface|
    end
    output
  end

  def self.get_single_interface_output(interface)
    output = ""
    case Facter.value(:kernel)
    when 'Linux', 'OpenBSD', 'NetBSD', 'FreeBSD', 'Darwin', 'GNU/kFreeBSD', 'DragonFly'
      output = %x{/sbin/ifconfig #{interface}}
    when 'SunOS'
      output = %x{/usr/sbin/ifconfig #{interface}}
    when 'HP-UX'
       mac = ""
       ifc = %x{/usr/sbin/ifconfig #{interface}}
       %x{/usr/sbin/lanscan}.scan(/(\dx\S+).*UP\s+(\w+\d+)/).each {|i| mac = i[0] if i.include?(interface) }
       mac = mac.sub(/0x(\S+)/,'\1').scan(/../).join(":")
       output = ifc + "\n" + mac
    end
    output
  end

  def self.get_output_for_interface_and_label(interface, label)
    return get_single_interface_output(interface) unless Facter.value(:kernel) == 'windows'

    if label == 'ipaddress6'
      output = %x|#{ENV['SYSTEMROOT']}/system32/netsh interface ipv6 show address \"#{interface}\"|
    else
      output = %x|#{ENV['SYSTEMROOT']}/system32/netsh interface ip show address \"#{interface}\"|
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
      bondinfo = IO.readlines("/proc/net/bonding/#{bonddev}")
      hwaddrre = /^Slave Interface: #{interface}\n[^\n].+?\nPermanent HW addr: (([0-9a-fA-F]{2}:?)*)$/m
      value = hwaddrre.match(bondinfo.to_s)[1].upcase
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

  def self.get_arp_value(interface)
    arp = Facter::Util::Resolution.exec("arp -en -i #{interface} | sed -e 1d")
    if arp =~ /^\S+\s+\w+\s+(\S+)\s+\w\s+\S+$/
     return $1
    end
  end
end
