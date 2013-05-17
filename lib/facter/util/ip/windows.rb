# encoding: UTF-8

require 'facter/util/ip/base'

class Facter::Util::IP::Windows < Facter::Util::IP::Base
  # A regex to match an IPv4 address from `ifconfig` output.
  #
  # @return [Regexp]
  #
  # @api private
  IPADDRESS_REGEX = /\s+IP\sAddress:\s+([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/

  # A regex to match an IPv6 address from `ifconfig` output.
  #
  # @return [Regexp]
  #
  # @api private
  IPADDRESS6_REGEX = /Address\s((?![fe80|::1])(?>[0-9,a-f,A-F]*\:{1,2})+[0-9,a-f,A-F]{0,4})/

  # A regex to match the netmask from `ifconfig` output.
  #
  # @return [Regexp]
  #
  # @api private
  NETMASK_REGEX = /\s+Subnet\sPrefix:\s+\S+\s+\(mask\s([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)\)/

  # The path to netsh.exe.
  #
  # @return [String]
  #
  # @api private
  NETSH = "#{ENV['SYSTEMROOT']}/system32/netsh.exe"

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

  # Uses netsh.exe to obtain a list of interfaces.
  #
  # @return [Array]
  #
  # @api private
  def self.interfaces
    cmd = "#{NETSH} interface %s show interface"
    output = exec("#{cmd % 'ip'} && #{cmd % 'ipv6'}").to_s

    output.scan(/\s* connected\s*(\S.*)/).flatten.uniq
  end

  # Get the value of an interface and label. For example, you may want to find
  # the MTU for eth0. Uses netsh.exe.
  #
  # @param interface [String] label [String]
  #
  # @return [String] or [NilClass]
  #
  # @api private
  def self.value_for_interface_and_label(interface, label)
    opt = label == 'ipaddress6' ? 'ipv6' : 'ip'
    cmd = "#{NETSH} interface #{opt} show address \"#{interface}\""

    super(interface, label, cmd)
  end
end
