# Fact: ip_path
#
# Purpose: Find an appropriate binary for checking ip information.
#
# Resolution: Returns the first working binary.
#
# Caveats:
#

Facter.add(:ip_path) do
  confine :kernel => [ :linux, :openbsd, :netbsd, :freebsd, :darwin,
                       :"gnu/kfreebsd", :dragonfly, :sunos ]
  setcode do
    [ '/sbin/ip', '/sbin/ifconfig', '/usr/sbin/ifconfig' ].select { |path| FileTest.executable?(path) }.first
  end
end

# Leave this as a seperate fact to make sure we never accidently select netstat on Linux/BSDlikes.
Facter.add(:ip_path) do
  confine :kernel => :"hp-ux"
  setcode do
    [ '/bin/netstat' ].select { |path| FileTest.executable?(path) }.first
  end
end

# Also special case windows because I suspect this'll need other magic with time.
Facter.add(:ip_path) do
  confine :kernel => :windows
  setcode do
    [ "#{ENV['SYSTEMROOT']}/system32/netsh.exe" ].select { |path| FileTest.executable?(path) }.first
  end
end
