# Fact: macaddress_path
#
# Purpose: Find an appropriate binary for checking ip information.
#
# Resolution: Returns the first working binary.
#
# Caveats:
#

Facter.add(:macaddress_path) do
  confine :kernel => [ :linux, :openbsd, :netbsd, :freebsd, :darwin,
                       :"gnu/kfreebsd", :dragonfly, :sunos ]
  setcode do
    [ '/sbin/ip', '/sbin/ifconfig', '/usr/sbin/ifconfig' ].select { |path| FileTest.executable?(path) }.first
  end
end

# Leave this as a seperate fact to make sure we never accidently select netstat on Linux/BSDlikes.
Facter.add(:macaddress_path) do
  confine :kernel => :"hp-ux"
  setcode do
    if FileTest.executable?('/sbin/lanscan')
      '/sbin/lanscan'
    end
  end
end

# Also special case windows because I suspect this'll need other magic with time.
Facter.add(:macaddress_path) do
  confine :kernel => :windows
  setcode do
    if FileTest.executable?("#{ENV['SYSTEMROOT']}/system32/netsh.exe")
      "#{ENV['SYSTEMROOT']}/system32/netsh.exe"
    end
  end
end
