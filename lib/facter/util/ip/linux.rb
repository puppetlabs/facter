# encoding: UTF-8

require 'facter/util/ip/base'

class Facter::Util::IP::Linux < Facter::Util::IP::Base
  # A regex to match an IPv4 address from `ifconfig` output.
  #
  # @return [Regexp]
  #
  # @api private
  IPADDRESS_REGEX = /inet\s(?:addr:)?([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/

  # A regex to match an IPv6 address from `ifconfig` output.
  #
  # @return [Regexp]
  #
  # @api private
  IPADDRESS6_REGEX = /inet6\s(?:addr: )?((?![fe80|::1])(?>[0-9,a-f,A-F]*\:{1,2})+[0-9,a-f,A-F]{0,4})/


  # A regex to match a MAC address from `ifconfig` output.
  #
  # @return [Regexp]
  #
  # @api private
  MACADDRESS_REGEX = /(?:ether|HWaddr)\s+((\w{1,2}:){5,}\w{1,2})/

  # A regex to match the netmask from `ifconfig` output.
  #
  # @return [Regexp]
  #
  # @api private
  NETMASK_REGEX = /Mask:([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/

  # A regex to match the MTU from `ifconfig` output.
  #
  # @return [Regexp]
  #
  # @api private
  MTU_REGEX = /MTU:(\d+)/

  # Linux doesn't display netmask in hex.
  #
  # @return [Boolean] false by default
  #
  # @api private
  def self.convert_netmask_from_hex?
    false
  end

  # Network bonding is creation of a single bonded interface by combining 2 or
  # more Ethernet interfaces. This method returns the bonding master.
  #
  # @param interface [String] the interface, e.g. 'eth0'
  #
  # @return [String] or [NilClass]
  #
  # @api private
  def self.bonding_master(interface)
    # We need `ip` instead of `ifconfig` because it shows us the bonding master.
    return unless FileTest.executable?("/sbin/ip")

    # A bonding interface can never be an alias interface. Alias interfaces do
    # have a colon in their name and the ip link show command throws an error
    # message when we pass it an alias interface.
    return if interface.match(/:/)

    regex = /SLAVE[,>].* (bond[0-9]+)/
    ethbond = regex.match(%x{/sbin/ip link show #{interface}})

    ethbond[1] if ethbond
  end

  # Returns an array of interfaces. e.g. ['eth0', 'eth1'] We will check sysfs
  # first, since that is the fastest option, but fallback to `ifconfig` if
  # neccessary.
  #
  # @return [Array]
  #
  # @api private
  def self.interfaces
    if File.exist?('/sys/class/net')
      Dir.glob('/sys/class/net/*').map do |name|
        name.split('/').last
      end
    else
      super
    end
  end

  # Get the value of an interface and label. For example, you may want to find
  # the MTU for eth0. If an infiniband interface is passed, it will try to
  # obtain the real value.
  #
  # @param interface [String] label [String] and optional command [String]
  #
  # @return [String] or [NilClass]
  #
  # @api private
  def self.value_for_interface_and_label(interface, label)
    if label == 'macaddress'
      bonddev = bonding_master(interface)

      if infiniband?(interface)
        infiniband_macaddress(interface) || super
      elsif bonddev
        bonddev_macaddress(bonddev, interface) || super
      else
        super
      end
    else
      super
    end
  end

  private

  # Boolean method to test whether an interface is the infiniband.
  #
  # @param interface [String] e.g. 'ib0'
  #
  # @return [Boolean] true or false
  #
  # @api private
  def self.infiniband?(interface)
    !!/^ib/.match(interface)
  end

  # Attempts to obtain the real macaddress for an infiniband interface.
  #
  # @param interface [String] e.g. 'ib0'
  #
  # @return [String] or [NilClass]
  #
  # @api private
  def self.infiniband_macaddress(interface)
    sysfs = "/sys/class/net/#{interface}/address"

    if File.exists?(sysfs)
      exec("cat #{sysfs}")
    elsif File.exists?("/sbin/ip")
      exec("/sbin/ip link show #{interface}").
        to_s.
        scan(%r{infiniband\s+((\w{1,2}:){5,}\w{1,2})})[0]
    end
  end

  # Attempts to obtain the real macaddress for a bonded interface.
  #
  # @param bonddev [String] interface [String] e.g. 'bond0', 'eth0'
  #
  # @return [String] or [NilClass]
  #
  # @api private
  def self.bonddev_macaddress(bonddev, interface)
    path = "/proc/net/bonding/#{bonddev}"

    if File.exists?(path)
      bondinfo = File.read(path)
      regex = /
        ^Slave\sInterface:\s
        #{interface}\b.*?\bPermanent\sHW\saddr:\s(([0-9A-F]{2}:?)*)$
      /imx
      match = regex.match(bondinfo)

      match[1].upcase if match
    end
  end
end
