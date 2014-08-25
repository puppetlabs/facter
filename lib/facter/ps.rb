# Fact: ps
#
# Purpose: 
#   Internal fact for what to use to list all processes. Used by
#   the Service type in Puppet.
#
# Resolution:
#   Assumes `ps -ef` for all operating systems other than BSD derivatives, where
#   it uses `ps auxwww`.
#
# Caveats:
#

Facter.add(:ps) do
  setcode do 'ps -ef' end
end

Facter.add(:ps) do
  confine :operatingsystem => :OpenWrt
  setcode do 'ps www' end
end

Facter.add(:ps) do
  confine :operatingsystem => %w{FreeBSD NetBSD OpenBSD Darwin DragonFly}
  setcode do 'ps auxwww' end
end

Facter.add(:ps) do
  confine :operatingsystem => :windows
  setcode do 'tasklist.exe' end
end
