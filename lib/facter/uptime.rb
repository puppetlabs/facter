# Fact: uptime
#
# Purpose: return the system uptime in a human readable format.
#
# Resolution:
#   Uses the structured "uptime_hash" fact, which does basic maths
#   on the number of seconds of uptime to return a count of days,
#   hours and minutes of uptime
#
# Caveats:
#

Facter.add(:uptime) do
  setcode { Facter.value(:system_uptime)['uptime'] }
end

