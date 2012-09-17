require 'facter'
require 'puppet/face'
Facter.add("certname") do
  setcode do
    Puppet.settings[:certname]
  end
end
