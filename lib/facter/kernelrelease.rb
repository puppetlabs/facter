# Fact: kernelrelease
#
# Purpose: Return the operating system's release number.
#
# Resolution:
#   On AIX, returns the output from the `oslevel -s` system command.
#   On Windows-based systems, uses the win32ole gem to query Windows Management
#   for the `Win32_OperatingSystem` value.
#   Otherwise uses the output of `uname -r` system command.
#
# Caveats:
#
require 'facter/util/posix'
require 'facter/util/windows'

Facter.add(:kernelrelease) do
  setcode 'uname -r'
end

Facter.add(:kernelrelease) do
  confine :kernel => "aix"
  setcode 'oslevel -s'
end

Facter.add("kernelrelease") do
  confine :kernel => :openbsd
  setcode do
    Facter::Util::POSIX.sysctl("kern.version").split(' ')[1]
  end
end

Facter.add(:kernelrelease) do
  confine :kernel => "hp-ux"
  setcode do
    version = Facter::Core::Execution.execute('uname -r')
    version[2..-1]
  end
end

Facter.add(:kernelrelease) do
  confine :kernel => "windows"
  setcode do
    Facter::Util::Windows::Process.os_version_string
  end
end
