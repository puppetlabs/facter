# Fact: uptime_hours
#
# Purpose: Return purely number of hours of uptime.
#
# Resolution: Uses the 'hours' key of the uptime_hash fact, which divides
# its own 'seconds' key by 3600
#
# Caveats:
#

Facter.add(:uptime_hours) do
  setcode { Facter.value(:system_uptime)['hours'] }
end
