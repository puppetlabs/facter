# Fact: facterversion
#
# Purpose: Returns the version of the facter module.
#
# Resolution: Uses the `Facter.version` method.
#
# Caveats:
#

Facter.add(:facterversion) do
  setcode do
    require 'facter/version'
    Facter.version.to_s
  end
end
