# Fact: vlans
#
# Purpose: On Linux, return a list of all the VLANs on the system.
#
# Resolution: On Linux only, checks for and reads `/proc/net/vlan/config` and
# parses it.
#
# Caveats:
#
require 'facter/util/vlans'

Facter.add("vlans") do
  confine :kernel => :linux
  setcode do
    Facter::Util::Vlans.get_vlans
  end
end
