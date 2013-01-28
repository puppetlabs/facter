# Fact: iphostnumber
#
# Purpose: On selected versions of Darwin, returns the host's IP address.
#
# Resolution:
#   Uses either the scutil program to get the localhost name, or parses output
#   of ifconfig for a MAC address.
#
# Caveats:
#

Facter.add(:iphostnumber) do
  confine :kernel => :darwin, :kernelrelease => "R6"
  setcode do
    %x{/usr/sbin/scutil --get LocalHostName}
  end
end
Facter.add(:iphostnumber) do
  confine :kernel => :darwin, :kernelrelease => "R6"
  setcode do
    ether = nil
    output = Facter::Util::IP.exec_ifconfig

    output =~ /HWaddr (\w\w:\w\w:\w\w:\w\w:\w\w:\w\w)/
    ether = $1

    ether
  end
end
