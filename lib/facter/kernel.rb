# Fact: kernel
#
# Purpose: Returns the operating system's name.
#
# Resolution:
#   Uses Ruby's RbConfig to find host_os, if that is a Windows derivative, then
#   returns `windows`, otherwise returns the output of `uname -s` verbatim.
#
# Caveats:
#

Facter.add(:kernel) do
  setcode do
    require 'facter/util/config'

    if Facter::Util::Config.is_windows?
      'windows'
    else
      Facter::Core::Execution.exec("uname -s")
    end
  end
end
