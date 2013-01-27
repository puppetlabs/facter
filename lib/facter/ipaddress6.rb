# Fact: ipaddress6
#
# Purpose: Returns the "main" IPv6 IP address of a system.

require 'facter/util/ip'

Facter.add(:ipaddress6) do
  has_weight 100
  confine :kernel => [ :linux, :freebsd, :openbsd, :darwin, :dragonfly, :"hp-ux",
                       :'gnu/kfreebsd', :aix, :windows, :netbsd, :sunos ]
  setcode do
    Facter::Util::IP::Ipaddress.get(nil, 'ipv6')
  end
end
