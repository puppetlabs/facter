require 'facter'

Facter.add('zpool_version') do
  setcode do
    if Facter::Util::Resolution.which('zpool')
      zpool_v = Facter::Util::Resolution.exec('zpool upgrade -v 2> /dev/null')
      zpool_version = zpool_v.scan(/^\s+(\d+)\s+/m).flatten.last unless zpool_v.nil?
    end
  end
end
