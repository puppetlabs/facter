# Fact: puppetversion
#
# Purpose: Return the version of puppet installed.
#
# Resolution:
#   Requires puppet via Ruby and returns the value of its version constant.
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
