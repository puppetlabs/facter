# Fact: facterversion
#
# Purpose: 
#    Returns the version of the facter module.
#
# Resolution: 
#    Uses the version constant.
#
Facter.add(:facterversion) do
  setcode { Facter::FACTERVERSION.to_s }
end
