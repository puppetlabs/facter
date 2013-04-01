# encoding: UTF-8

# Fact: interfaces
#
# Purpose:
# Try to get additional Facts about the machine's network interfaces
#
# Caveats:
# Most of this only works on a fixed list of platforms; notably, Darwin is
# missing.

require 'facter/util/ip'

interfaces = Facter::Util::IP.interfaces

if interfaces.any?
  Facter.add(:interfaces) do
    setcode do
      alphafied_interfaces = interfaces.map do |interface|
        Facter::Util::IP.alphafy(interface)
      end

      alphafied_interfaces.join(",")
    end
  end

  interfaces.each do |interface|
    %w[ipaddress ipaddress6 macaddress netmask mtu].each do |label|
      Facter.add("#{label}_#{Facter::Util::IP.alphafy(interface)}") do
        setcode do
          Facter::Util::IP.value_for_interface_and_label(interface, label)
        end
      end
    end
  end
end
