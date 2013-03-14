# encoding: UTF-8

require 'ipaddr'

module Facter
  module Util
    class IP
    end
  end
end

class Facter::Util::IP::Base
  # A regex to match an IPv4 address from `ifconfig` output. This regex will
  # work for most platforms. You can override this in your subclass if you need
  # a different regex.
  #
  # @return [Regexp]
  #
  # @api private
  IPADDRESS_REGEX = /inet.*?([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/


  # A regex to match an IPv6 address from `ifconfig` output. This regex will
  # work for most platforms. You can override this in your subclass if you need
  # a different regex.
  #
  # @return [Regexp]
  #
  # @api private
  IPADDRESS6_REGEX = /
    inet6.*?((?![fe80|::1])(?>[0-9,a-f,A-F]*\:{1,2})+[0-9,a-f,A-F]{0,4})
  /x

  # A regex to match a MAC address from `ifconfig` output. This regex will work
  # for most platforms. You can override this in your subclass if you need a
  # different regex.
  #
  # @return [Regexp]
  #
  # @api private
  MACADDRESS_REGEX = /(?:ether|lladdr)\s+(\w?\w:\w?\w:\w?\w:\w?\w:\w?\w:\w?\w)/

  # A regex to match the netmask from `ifconfig` output. This regex will work
  # for most platforms. You can override this in your subclass if you need a
  # different regex.
  #
  # @return [Regexp]
  #
  # @api private
  NETMASK_REGEX = /netmask\s+0x(\w{8})/

  # A regex to match the MTU from `ifconfig` output. This regex will work for
  # most platforms. You can override this in your subclass if you need a
  # different regex.
  #
  # @return [Regexp]
  #
  # @api private
  MTU_REGEX = /mtu\s+(\d+)/

  # Returns the name of the Class without nesting. Mostly used for finding
  # the right class corresponding to the value of Facter.value(:kernel)
  #
  # @return [String] The string without nesting.
  #
  # @api private
  def self.to_s
    super.split('::').last
  end

  # Used in conjunction with the `.inherited` hook, this method will store
  # an Array of the Class' subclasses.
  #
  # @return [Array] The subclasses.
  #
  # @api private
  def self.subclasses
    @subclasses ||= []
  end

  # Most kernels will need to have their netmask converted from hex. If
  # your kernel doesn't display the netmask in hex, you'll need to
  # override this method in your subclass to return false.
  #
  # @return [Boolean] true
  #
  # @api private
  def self.convert_netmask_from_hex?
    true
  end

  # Network bonding is creation of a single bonded interface by combining 2 or
  # more Ethernet interfaces. I think this is mostly used in Linux so this base
  # method will return nil, however you should override this in your subclass if
  # need be. See the Facter::Util::IP::Linux.bonding_master method.
  #
  # @return [NilClass]
  #
  # @api private
  def self.bonding_master(interface)
  end

  # Returns an array of interfaces from `ifconfig`. e.g. ['eth0', 'eth1'] This
  # will work on most platforms, but override in your subclass if need be.
  #
  # @return [Array]
  #
  # @api private
  def self.interfaces
    exec("#{ifconfig_path} -a 2> /dev/null").to_s.scan(/^\w+/).uniq
  end

  # Get the value of an interface and label. For example, you may want to find
  # the MTU for eth0.
  #
  # @param interface [String] label [String] and optional command [String]
  #
  # @return [String] or [NilClass]
  #
  # @api private
  def self.value_for_interface_and_label(interface, label, cmd = nil)
    if regex = regex_for(label)
      cmd ||= "#{ifconfig_path} #{interface} 2> /dev/null"

      if match = regex.match(exec(cmd).to_s)
        if label == 'netmask' && convert_netmask_from_hex?
          match[1].scan(/../).map { |byte| byte.to_i(16) }.join('.')
        else
          match[1]
        end
      end
    end
  end

  # Returns the IP network for the given interface.
  #
  # @return [String] or [NilClass]
  #
  # @api private
  def self.network(interface)
    ipaddress = value_for_interface_and_label(interface, "ipaddress")
    netmask = value_for_interface_and_label(interface, "netmask")

    if ipaddress && netmask
      ip = IPAddr.new(ipaddress, Socket::AF_INET)
      subnet = IPAddr.new(netmask, Socket::AF_INET)

      ip.mask(subnet.to_s).to_s
    end
  end

  # This is a Ruby hook method that will help to maintain a list of
  # subclasses. See the `.subclasses` method for more information.
  #
  # @return [Array] The subclasses.
  #
  # @api private
  def self.inherited subclass
    subclasses << subclass
  end

  # This loops over `ifconfig` paths to find the first that is executable.
  #
  # @return [String]
  #
  # @api private
  def self.ifconfig_path
    %w[/bin/ifconfig /sbin/ifconfig /usr/sbin/ifconfig].find do |path|
      File.executable?(path)
    end
  end

  # Delegation method to Facter::Util::Resolution.exec.
  #
  # @param command [String] the command to execute
  #
  # @return [String] or [Nil]
  #
  # @api private
  def self.exec string
    Facter::Util::Resolution.exec string
  end

  # Grabs the corresponding regex constant. e.g. NETMASK_REGEX
  #
  # @param label [String] e.g. 'netmask'
  #
  # @return [Regexp] or [NilClass]
  #
  # @api private
  def self.regex_for label
    constant = "#{label.to_s.upcase}_REGEX"

    const_get(constant) if constants.find { |c| /^#{constant}$/.match(c) }
  end
end
