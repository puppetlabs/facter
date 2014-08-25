require 'facter'

Facter.add('zfs_version') do
  setcode do
    if Facter::Core::Execution.which('zfs')
      zfs_help = Facter::Core::Execution.exec('zfs -? 2> /dev/null')
      zfs_has_upgrade = zfs_help.match(/\A.*upgrade.*\z/m) unless zfs_help.nil?
      if zfs_has_upgrade
        zfs_v = Facter::Core::Execution.exec('zfs upgrade -v')
        zfs_version = zfs_v.scan(/^\s+(\d+)\s+/m).flatten.last unless zfs_v.nil?
      end
    end
  end
end
