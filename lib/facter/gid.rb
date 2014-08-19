# Fact: gid
#
# Purpose: Return the GID (group identifier) of the user running puppet.
#
# Resolution:
#
# Caveats:
#   Not supported in Windows yet.
#

Facter.add(:gid) do
  confine do
    Facter::Core::Execution.which('id')
  end
  setcode { Facter::Core::Execution.exec('id -ng') }
end
