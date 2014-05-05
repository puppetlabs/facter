require 'facter'

Facter.add('zpool_version') do
  setcode do
    if Facter::Core::Execution.which('zpool')
      zpool_v = Facter::Core::Execution.exec('zpool upgrade -v')
      zpool_version = zpool_v.match(/ZFS pool version (\d+)./).captures.first unless zpool_v.empty?
    end
  end
end
