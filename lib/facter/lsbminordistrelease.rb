# Fact: lsbminordistrelease
#
# Purpose: Returns the minor version of the operation system version as gleaned
# from the lsbdistrelease fact.
#
# Resolution:
#   Parses the lsbdistrelease fact for x.y and returns y. If y is not present,
#   the fact is not present.
#
#   For both values '1.2.3' and '1.2' of lsbdistrelease, lsbminordistrelease
#   would return '2'. For the value '1', no fact would be set for
#   lsbminordistrelease.
#
require 'facter'

Facter.add('lsbminordistrelease') do
  confine :kernel => %w{Linux GNU/kFreeBSD}
  setcode do
    if /(\d).(\d)/i =~ Facter.value(:lsbdistrelease)
      result=$2
    end
  end
end
