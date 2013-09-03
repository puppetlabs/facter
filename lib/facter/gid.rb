# Fact: gid
#
# Purpose: Return the gid of the user running Puppet
#
# Resolution:
#
# Caveats:
# Not supported in windows yet.

Facter.add(:gid) do
  confine do
    Facter::Util::Resolution.which('id')
  end
  setcode 'id -ng'
end
