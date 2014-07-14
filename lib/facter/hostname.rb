# Fact: hostname
#
# Purpose: Return the system's short hostname.
#
# Resolution:
#   On all systems but Darwin, parses the output of the `hostname` system command
#   to everything before the first period.
#   On Darwin, uses the system configuration util to get the LocalHostName
#   variable.
#
# Caveats:
#

Facter.add(:hostname) do
  setcode do
    hostname = nil
    if name = Facter::Core::Execution.execute('hostname')
      if name =~ /(.*?)\./
        hostname = $1
      else
        hostname = name
      end
    end
    hostname
  end
end

Facter.add(:hostname) do
  confine :kernel => :darwin, :kernelrelease => "R7"
  setcode '/usr/sbin/scutil --get LocalHostName'
end
