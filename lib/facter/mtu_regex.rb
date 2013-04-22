# Fact: mtu_regex
#
# Purpose: Find an appropriate regex to extract information about ipaddresses
#
# Resolution: Returns a regular expression
#
# Caveats:
#

Facter.add(:mtu_regex) do
  confine :kernel => :linux
  setcode do
    case Facter.value('ip_path')
    when '/sbin/ip'
      /mtu (\d+)/
    when '/sbin/ifconfig'
      /MTU:(\d+)/
    end
  end
end

Facter.add(:mtu_regex) do
  confine :kernel => [ :openbsd, :netbsd, :freebsd, :darwin, :"gnu/kfreebsd",
                       :dragonfly, :sunos, :aix, :"hp-ux"]
  setcode do
    /mtu\s+(\d+)/
  end
end
