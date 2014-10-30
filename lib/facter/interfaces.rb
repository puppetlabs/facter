# Fact: interfaces
#
# Purpose:
#   Returns a comma-separated list of the system's network interfaces.
#
#   In addition to the main `interfaces` fact, this code will generate the
#   following facts for each interface:
#
#   * `ipaddress_<INTERFACE>`
#   * `ipaddress6_<INTERFACE>`
#   * `macaddress_<INTERFACE>`
#   * `netmask_<INTERFACE>`
#   * `mtu_<INTERFACE>`
#
# Resolution:
#
# Caveats:
#

# interfaces.rb
# Try to get additional Facts about the machine's network interfaces
#
# Original concept Copyright (C) 2007 psychedelys <psychedelys@gmail.com>
# Update and *BSD support (C) 2007 James Turnbull <james@lovedthanlost.net>
#

require 'facter/util/ip'
require 'facter/util/macaddress'

# Note that most of this only works on a fixed list of platforms; notably, Darwin
# is missing.

Facter.add(:interfaces) do
  confine :kernel => Facter::Util::IP.supported_platforms
  setcode do
    Facter::Util::IP.get_interfaces.collect { |iface| Facter::Util::IP.alphafy(iface) }.join(",")
  end
end

Facter::Util::IP.get_interfaces.each do |interface|

  # Make a fact for each detail of each interface.  Yay.
  #   There's no point in confining these facts, since we wouldn't be able to create
  # them if we weren't running on a supported platform.
  %w{ipaddress ipaddress6 macaddress netmask mtu}.each do |label|
    Facter.add(label + "_" + Facter::Util::IP.alphafy(interface)) do
      setcode do
        value = Facter::Util::IP.get_interface_value(interface, label)
        if label == "macaddress"
          value = Facter::Util::Macaddress.standardize(value)
        elsif label == "mtu"
          value = value.to_i
        end
        value
      end
    end
  end
end
