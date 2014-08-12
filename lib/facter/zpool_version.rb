require 'facter'

Facter.add('zpool_version') do
  setcode do
    if Facter::Core::Execution.which('zpool')
      zpool_v = Facter::Core::Execution.exec('zpool upgrade -v')
      zpool_version = zpool_v.scan(/^\s+(\d+)\s+/m).flatten.last unless zpool_v.nil?
    end
  end
end
