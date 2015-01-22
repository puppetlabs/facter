# Fact: system32
#
# Purpose: Returns the directory of the native system32 directory.
# For 32-bit ruby on 32-bit Windows, typically: 'C:\Windows\system32'.
# For 32-bit ruby on 64-bit Windows, typically: 'C:\Windows\sysnative'.
# For 64-bit ruby on 64-bit Windows, typically: 'C:\Windows\system32'.
#
# Resolution: Checks for the existence of the `sysnative` directory, otherwise
# uses `system32`
#

Facter.add(:system32) do
  confine :kernel => :windows
  setcode do
    if File.exist?("#{ENV['SYSTEMROOT']}\\sysnative")
      "#{ENV['SYSTEMROOT']}\\sysnative"
    else
      "#{ENV['SYSTEMROOT']}\\system32"
    end
  end
end
