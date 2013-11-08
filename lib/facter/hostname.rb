# Fact: hostname
#
# Purpose: Return the system's short hostname.
#
# Resolution:
#   On all system bar Darwin, parses the output of the "hostname" system command
#   to everything before the first period.
#   On Darwin, uses the system configuration util to get the LocalHostName
#   variable.
#
# Caveats:
#

Facter.add(:hostname, :ldapname => "cn") do
  setcode do

  basic_hostname = 'hostname 2> /dev/null'
  windows_hostname = 'hostname > NUL'
  full_hostname = 'hostname -f 2> /dev/null'
  can_do_hostname_f = Regexp.union /Linux/i, /FreeBSD/i, /Darwin/i

  hostname_command = if Facter.value(:kernel) =~ can_do_hostname_f
          full_hostname
        elsif Facter.value(:kernel) == "windows"
          windows_hostname
        else
          basic_hostname
        end

    hostname = nil
    if name = Facter::Util::Resolution.exec(hostname_command)
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
