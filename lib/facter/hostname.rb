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
        hostname = nil
        name = Facter::Util::Resolution.exec('hostname') or nil
        if name
            if name =~ /^([\w-]+)\.(.+)$/
                hostname = $1
                # the Domain class uses this
                $domain = $2
            else
                hostname = name
            end
            hostname
        else
            nil
        end
    end
end

Facter.add(:hostname) do
    confine :kernel => :darwin, :kernelrelease => "R7"
    setcode do
        %x{/usr/sbin/scutil --get LocalHostName}
    end
end
