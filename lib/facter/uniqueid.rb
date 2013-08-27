# Fact: uniqueid
#
# Purpose: Return a unique numeric identifier for the given system.
#
# Resolution:
#
# On platforms that have a `hostid` command, use the output of that command.
#
# On FreeBSD, use the kernel's hostid value, which is the first four bytes of
# the host UUID.

Facter.add(:uniqueid) do
  setcode 'hostid'
  confine :kernel => %w{SunOS Linux AIX GNU/kFreeBSD}
end

Facter.add(:uniqueid) do
  confine :kernel => :freebsd
  setcode do
    Facter::Util::POSIX.sysctl('kern.hostid')
  end
end
