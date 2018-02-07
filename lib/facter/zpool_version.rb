require 'facter'

Facter.add('zpool_version') do
  setcode do
    if Facter::Core::Execution.which('zpool')
      zpool_help = Facter::Core::Execution.exec('zpool -? 2> /dev/null')
      zpool_has_upgrade = zpool_help.match(/\A.*upgrade.*\z/m) unless zpool_help.nil?
      if zpool_has_upgrade
        zpool_v = Facter::Core::Execution.exec('zpool upgrade -v')
        zpool_version = zpool_v.scan(/^\s+(\d+)\s+/m).flatten.last unless zpool_v.nil?
      end
    end
  end
end
