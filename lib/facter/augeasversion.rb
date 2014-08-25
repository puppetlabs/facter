# Fact: augeasversion
#
# Purpose: Report the version of the Augeas library.
#
# Resolution:
#   Loads ruby-augeas and reports the value of `/augeas/version`, the version of
#   the underlying Augeas library.
#
# Caveats:
#   The library version may not indicate the presence of certain lenses,
#   depending on the system packages updated, nor the version of ruby-augeas
#   which may affect support for the Puppet Augeas provider.
#   Versions prior to 0.3.6 cannot be interrogated for their version.
#

Facter.add(:augeasversion) do
  setcode do
    begin
      require 'augeas'
      aug = Augeas::open('/', nil, Augeas::NO_MODL_AUTOLOAD)
      ver = aug.get('/augeas/version')
      aug.close
      ver
    rescue Exception
      Facter.debug('ruby-augeas not available')
    end
  end
end
