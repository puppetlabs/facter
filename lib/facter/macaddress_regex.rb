# Fact: macaddress_regex
#
# Purpose: Find an appropriate regex to extract information about ipaddresses
#
# Resolution: Returns a regular expression
#
# Caveats:
#

Facter.add(:macaddress_regex) do
  confine :kernel => :linux
  setcode do
    case Facter.value('ip_path')
    when '/sbin/ip'
      /link\/ether ((\w{1,2}:){5,}\w{1,2})/
    when '/sbin/ifconfig'
      /(?:ether|HWaddr)\s+((\w{1,2}:){5,}\w{1,2})/
    end
  end
end

Facter.add(:macaddress_regex) do
  confine :kernel => [ :openbsd, :netbsd, :freebsd, :darwin, :"gnu/kfreebsd",
                       :dragonfly, :sunos, :aix]
  setcode do
    /(?:ether|HWaddr) (\w{1,2}:\w{1,2}:\w{1,2}:\w{1,2}:\w{1,2}:\w{1,2})/
  end
end

Facter.add(:macaddress_regex) do
  confine :kernel => :"hp-ux"
  setcode do
    /0x(\w+)/
  end
end

Facter.add(:macaddress_regex) do
  confine :kernel => :windows
  setcode do
    //
  end
end
