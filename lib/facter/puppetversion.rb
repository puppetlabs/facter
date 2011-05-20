# Fact: puppetversion
#
# Purpose: Return the version of puppet installed.
#
# Resolution:
#   Requres puppet via Ruby and returns it's version constant.
#
# Caveats:
#

Facter.add(:puppetversion) do
    setcode do
        begin
            require 'puppet'
            Puppet::PUPPETVERSION.to_s
        rescue LoadError
            nil
        end
    end
end
