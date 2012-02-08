require 'facter'

Facter.add('zfs_version') do
  confine :kernel => :sunos

  setcode do
    zfs_v = Facter::Util::Resolution.exec('zfs upgrade -v')
    zfs_version = zfs_v.scan(/^\s+(\d+)\s+/m).flatten.last unless zfs_v.nil?
  end
end
