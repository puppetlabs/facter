# encoding: UTF-8

require 'facter/util/ip/base'

class Facter::Util::IP::HPUX < Facter::Util::IP::Base
  # A regex to match an IPv4 address from `ifconfig` output.
  #
  # @return [Regexp]
  #
  # @api private
  IPADDRESS_REGEX = /\s+inet (\S+)\s.*/

  # A regex to match a MAC address from `ifconfig` output.
  #
  # @return [Regexp]
  #
  # @api private
  MACADDRESS_REGEX = /(\w{1,2}:\w{1,2}:\w{1,2}:\w{1,2}:\w{1,2}:\w{1,2})/

  # A regex to match the netmask from `ifconfig` output.
  #
  # @return [Regexp]
  #
  # @api private
  NETMASK_REGEX = /.*\s+netmask (\S+)\s.*/

  # The path to the `lanscan` executable.
  #
  # @return [Regexp]
  #
  # @api private
  LANSCAN = '/usr/sbin/lanscan'

  def self.to_s
    'HP-UX'
  end

  # Gets an array of interfaces from `netstat`. The cryptic text replacements in
  # the method handles NIC bonding where asterisks and virtual NICs are printed.
  # See (#17487)[https://projects.puppetlabs.com/issues/17487] for more info.
  #
  # @return [Array]
  #
  # @api private
  def self.interfaces
    exec("/bin/netstat -in").
      to_s.
      gsub(/\*/, "").
      gsub(/^[^\n]*none[^\n]*\n/, "").
      sub(/^[^\n]*\n/, "").
      scan(/^\w+/)
  end

  def self.value_for_interface_and_label(interface, label)
    value = super(interface, label)

    if !value && label == 'macaddress'
      if macaddress = lanscan.to_s[/\dx(\S+).*UP\s+#{interface}/, 1]
        macaddress.scan(/../).join(':')
      end
    else
      value
    end
  end

  private

  # Execute lanscan.
  #
  # @return [String] or [NilClass]
  #
  # @api private
  def self.lanscan
    exec(LANSCAN) if File.exist?(LANSCAN)
  end
end
