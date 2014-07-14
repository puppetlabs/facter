# Fact: uptime
#
# Purpose: Return the system uptime in a human-readable format.
#
# Resolution:
#   Uses the structured system_uptime fact, which does basic math
#   on the number of seconds of uptime to return a count of days
#   and hours of uptime.
#
# Caveats:
#

Facter.add(:uptime) do
  setcode { Facter.value(:system_uptime)['uptime'] }
end

