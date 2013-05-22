# Fact: puppetparser
#
# Purpose: Returns the parser Puppet is running under.
#
# Resolution:
#   Requres puppet via Ruby and returns it's parser value.
#
# Caveats:
#

Facter.add(:puppetparser) do
  setcode do
    begin
      unless defined?(Puppet)
        require "puppet"
      end

      Puppet[:parser].to_s
    rescue LoadError
      nil
    end
  end
end

