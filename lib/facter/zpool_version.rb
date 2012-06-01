require 'facter'

Facter.add('zpool_version') do
  confine :kernel => %w(SunOS FreeBSD GNU/kFreeBSD)

  setcode do
    zpool_v = Facter::Util::Resolution.exec('zpool upgrade -v')
    zpool_version = zpool_v.match(/ZFS pool version (\d+)./).captures.first unless zpool_v.nil?
  end
end
