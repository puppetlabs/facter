# Fact: lsbmajdistrelease
#
# Purpose: Returns the major version of the operation system version as gleaned
# from the lsbdistrelease fact.
#
# Resolution:
#   Uses the lsbmajdistrelease key of the os structured fact, which itself
#   parses the lsbdistrelease fact for numbers followed by a period and
#   returns those, or just the lsbdistrelease fact if none were found.
#
# Caveats:
#

require 'facter'

Facter.add(:lsbmajdistrelease) do
  confine do
    !Facter.value("os")["lsb"].nil?
  end

  setcode { Facter.value("os")["lsb"]["majdistrelease"] }
end
