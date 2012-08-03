# Fact: kernel
#
# Purpose: Returns the operating system's name.
#
# Resolution:
#   Uses Ruby's rbconfig to find host_os, if that is a Windows derivative, the
#   returns 'windows', otherwise returns "uname -s" verbatim.
#
# Caveats:
#
require 'facter/util/config'

Facter.add(:kernel) do
  setcode do
    if Facter::Util::Config.is_windows?
      'windows'
    else
      Facter::Util::Resolution.exec("uname -s")
    end
  end
end
