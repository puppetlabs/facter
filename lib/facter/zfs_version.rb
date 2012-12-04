require 'facter'

Facter.add('zfs_version') do
  setcode do
    if Facter::Util::Resolution.which('zfs')
      zfs_v = Facter::Util::Resolution.exec('zfs upgrade -v')
      zfs_version = zfs_v.scan(/^\s+(\d+)\s+/m).flatten.last unless zfs_v.nil?
    end
  end
end
