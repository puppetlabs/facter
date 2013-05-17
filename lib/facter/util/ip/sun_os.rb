# encoding: UTF-8

require 'facter/util/ip/base'

class Facter::Util::IP::SunOS < Facter::Util::IP::Base
  # A regex to match the netmask from `ifconfig` output.
  #
  # @return [Regexp]
  #
  # @api private
  NETMASK_REGEX = /netmask\s(\w{8})/

  # Get the value of an interface and label. For example, you may want to find
  # the MTU for eth0.
  #
  # @param interface [String] label [String] e.g ['eth0', 'MTU']
  #
  # @return [String] or [NilClass]
  #
  # @api private
  def self.value_for_interface_and_label(interface, label)
    super(interface, label, "#{ifconfig_path} #{interface}")
  end
end
