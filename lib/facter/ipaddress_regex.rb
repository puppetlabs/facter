# Fact: ipaddress_regex
#
# Purpose: Find an appropriate regex to extract information about ipaddresses
#
# Resolution: Returns a regular expression
#
# Caveats:
#

Facter.add(:ipaddress_regex) do
  confine :kernel => :linux
  setcode do
    case Facter.value('ip_path')
    when '/sbin/ip'
      /inet ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/
    when '/sbin/ifconfig'
      /inet addr: ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/
    end
  end
end

Facter.add(:ipaddress_regex) do
  confine :kernel => [ :openbsd, :netbsd, :freebsd, :darwin, :"gnu/kfreebsd", :dragonfly,
                       :aix]
  setcode do
    /inet addr: ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/
  end
end

Facter.add(:ipaddress_regex) do
  confine :kernel => [ :sunos, :"hp-ux" ]
  setcode do
    /inet\s+([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/
  end
end

Facter.add(:ipaddress_regex) do
  confine :kernel => :windows
  setcode do
    /IP Address:\s+([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/
  end
end
