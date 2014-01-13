require 'facter'

Facter.add('zfs_version') do
  setcode do
    if Facter::Util::Resolution.which('zfs')
      zfs_help = Facter::Util::Resolution.exec('zfs -? 2> /dev/null')
      zfs_has_upgrade = zfs_help.match(/\A.*upgrade.*\z/m) unless zfs_help.nil?
      if zfs_has_upgrade
        zfs_v = Facter::Util::Resolution.exec('zfs upgrade -v 2> /dev/null')
        zfs_version = zfs_v.scan(/^\s+(\d+)\s+/m).flatten.last unless zfs_v.nil?
      end
    end
  end
end
