# ipmess.rb
# Try to get additional Facts about the machine's network interfaces
#
# Original concept Copyright (C) 2007 psychedelys <psychedelys@gmail.com>
# Update and *BSD support (C) 2007 James Turnbull <james@lovedthanlost.net>
#

require 'facter/util/ip'

Facter.add(:interfaces) do
    confine :kernel => [ :sunos, :freebsd, :openbsd, :netbsd, :linux ]
    setcode do
        Facter::IPAddress.get_interfaces.join(",")
    end
end

case Facter.value(:kernel)
when 'SunOS', 'Linux', 'OpenBSD', 'NetBSD', 'FreeBSD'
    Facter::IPAddress.get_interfaces.each do |interface|
        mi = interface.gsub(/[:.]/, '_')

        Facter.add("ipaddress_" + mi) do
            confine :kernel => [ :sunos, :freebsd, :openbsd, :netbsd, :linux ]
            setcode do
                label = 'ipaddress'
                Facter::IPAddress.get_interface_value(interface, label)
            end
        end

        Facter.add("macaddress_" + mi) do
            confine :kernel => [ :sunos, :freebsd, :openbsd, :netbsd, :linux ]
            setcode do
                label = 'macaddress'
                Facter::IPAddress.get_interface_value(interface, label)
            end
        end

        Facter.add("netmask_" + mi) do
            confine :kernel => [ :sunos, :freebsd, :openbsd, :netbsd, :linux ]
            setcode do
                label = 'netmask'
                Facter::IPAddress.get_interface_value(interface, label)
            end
        end
    end
end
