# Fact: hostuuid
#
# Purpose: Return the hardware UUID value
#
# Resolution:
#
# On FreeBSD, use the kernel's UUID value, which is the result of the system's
# burned in UUID.

Facter.add(:hostuuid) do
  confine :kernel => :freebsd
  setcode do
    Facter::Util::Resolution.exec('sysctl -n kern.hostuuid')
  end
end
