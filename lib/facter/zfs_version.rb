require 'facter'

Facter.add('zfs_version') do
  setcode do
    if Facter::Core::Execution.which('zfs')
      zfs_v = Facter::Core::Execution.exec('zfs upgrade -v')
      zfs_version = zfs_v.scan(/^\s+(\d+)\s+/m).flatten.last unless zfs_v.empty?
    end
  end
end
