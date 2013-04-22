# Fact: netmask6_regex
#
# Purpose: Find an appropriate regex to extract information about ipaddresses
#
# Resolution: Returns a regular expression
#
# Caveats:
#

Facter.add(:netmask6_regex) do
  confine :kernel => :linux
  setcode do
    case Facter.value('ip_path')
    when '/sbin/ip'
      /inet6 (?![fe80|::1])(?>[0-9,a-f,A-F]*\:{1,2})+[0-9,a-f,A-F]{0,4}\/(\d+)/
    when '/sbin/ifconfig'
      /inet6 addr: (?![fe80|::1])(?>[0-9,a-f,A-F]*\:{1,2})+[0-9,a-f,A-F]{0,4}\/(\d+)/
    end
  end
end

Facter.add(:netmask6_regex) do
  confine :kernel => [ :openbsd, :netbsd, :freebsd, :darwin, :"gnu/kfreebsd", :dragonfly ]
  setcode do
    /prefixlen (\w+)/
  end
end

Facter.add(:netmask6_regex) do
  confine :kernel => [ :sunos, :aix, :"hp-ux" ]
  setcode do
    /inet6 (?![fe80|::1])(?>[0-9,a-f,A-F]*\:{1,2})+[0-9,a-f,A-F]{0,4}\/(\d+)/
  end
end

Facter.add(:netmask6_regex) do
  confine :kernel => :windows
  setcode do
    /Address\s+(?![fe80|::1])(?>[0-9,a-f,A-F]*\:{1,2})+[0-9,a-f,A-F]{0,4}%(\d+)/
  end
end
