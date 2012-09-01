# Fact: ipaddress6
#
# Purpose: Returns the "main" IPv6 IP address of a system.
#
# Resolution:
#  OS dependant code that parses the output of various networking
#  tools and currently not very intelligent. Returns the first
#  non-loopback and non-linklocal address found in the ouput unless
#  a default route can be mapped to a routeable interface. Guessing
#  an interface is currently only possible with BSD type systems
#  to many assumptions have to be made on other platforms to make
#  this work with the current code. Most code ported or modeled
#  after the ipaddress fact for the sake of similar functionality
#  and familiar mechanics.
#
# Caveats:
#

# Cody Herriges <c.a.herriges@gmail.com>
#
# Used the ipaddress fact that is already part of
# Facter as a template.
require 'facter/util/ip'

Facter.add(:ipaddress6) do
  has_weight 100
  confine :kernel => %w{Linux FreeBSD OpenBSD Darwin DragonFly HP-UX GNU/kFreeBSD AIX windows}
  setcode do
    Facter::Util::IP.ipaddress(nil, 'ipv6')
  end
end

Facter.add(:ipaddress6) do
  has_weight 100
  confine :kernel => %w{NetBSD SunOS}
  setcode do
    Facter::Util::IP.ipaddress(nil, 'ipv6', /^127\.|^0\.0\.0\.0/)
  end
end
