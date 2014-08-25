# Fact: uptime_days
#
# Purpose: Return just the number of days of uptime.
#
# Resolution: Uses the "days" key of the system_uptime fact, which divides
#   its own "hours" key by 24
#
# Caveats:
#

Facter.add(:uptime_days) do
  setcode { Facter.value(:system_uptime)['days'] }
end
