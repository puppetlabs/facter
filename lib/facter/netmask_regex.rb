# Fact: netmask_regex
#
# Purpose: Find an appropriate regex to extract information about ipaddresses
#
# Resolution: Returns a regular expression
#
# Caveats:
#

Facter.add(:netmask_regex) do
  confine :kernel => :linux
  setcode do
    case Facter.value('ip_path')
    when '/sbin/ip'
      /inet [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+\/(\d+)/
    when '/sbin/ifconfig'
      /Mask:([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/
    end
  end
end

Facter.add(:netmask_regex) do
  confine :kernel => [ :openbsd, :netbsd, :freebsd, :darwin, :"gnu/kfreebsd", :dragonfly ]
  setcode do
    /netmask 0x(\w+)/
  end
end

Facter.add(:netmask_regex) do
  confine :kernel => [ :sunos, :aix ]
  setcode do
    /netmask (\w+)/
  end
end

Facter.add(:netmask_regex) do
  confine :kernel => :"hp-ux"
  setcode do
    /0x(\w+)/
  end
end

Facter.add(:netmask_regex) do
  confine :kernel => :windows
  setcode do
    /mask ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/
  end
end
