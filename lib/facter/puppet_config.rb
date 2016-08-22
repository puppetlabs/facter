require 'facter'
require 'puppet/face'

Puppet.settings.each do |key, val|
  Facter.add("puppet_config_#{key}") do
    setcode do
      val.value
    end
  end
end
