require 'facter'

Facter.add('zfs_version') do
  setcode do
    if Facter::Util::Resolution.which('zfs')
      zfs_help = Facter::Util::Resolution.exec('zfs -?')
      zfs_has_upgrade = zfs_help.match(/^\s+upgrade/) unless zfs_help.nil?
      if zfs_has_upgrade
        zfs_v = Facter::Util::Resolution.exec('zfs upgrade -v')
        zfs_version = zfs_v.scan(/^\s+(\d+)\s+/m).flatten.last unless zfs_v.nil?
      end
    end
  end
end
