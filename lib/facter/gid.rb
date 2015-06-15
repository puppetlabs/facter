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
    Facter::Core::Execution.which('id') && !["SunOS", "windows"].include?(Facter.value(:kernel))
  end
  setcode { Facter::Core::Execution.exec('id -ng') }
end

Facter.add(:gid) do
  confine :kernel => :SunOS
  setcode do
    if File.exist? '/usr/xpg4/bin/id'
      Facter::Core::Execution.exec('/usr/xpg4/bin/id -ng')
    end
  end
end
