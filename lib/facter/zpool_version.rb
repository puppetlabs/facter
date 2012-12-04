require 'facter'

Facter.add('zpool_version') do
  setcode do
    if Facter::Util::Resolution.which('zpool')
      zpool_v = Facter::Util::Resolution.exec('zpool upgrade -v')
      zpool_version = zpool_v.match(/ZFS pool version (\d+)./).captures.first unless zpool_v.nil?
    end
  end
end
