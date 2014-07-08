# Fact: uptime_hours
#
# Purpose: Return just the number of hours of uptime.
#
# Resolution: Uses the "hours" key of the system_uptime fact, which divides
#   its own 'seconds' key by 3600.
#
# Caveats:
#

Facter.add(:uptime_hours) do
  setcode { Facter.value(:system_uptime)['hours'] }
end
