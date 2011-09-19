# Fact: facterversion
#
# Purpose: returns the version of the facter module.
#
# Resolution: Uses the version constant.
#
# Caveats:
#

Facter.add(:facterversion) do
  setcode { Facter::FACTERVERSION.to_s }
end
