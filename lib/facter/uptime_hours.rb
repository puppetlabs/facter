# Fact: uptime_hours
#
# Purpose: Return just the number of hours of uptime.
#
# Resolution: Divides the uptime_seconds fact by 3600.
#
# Caveats:
#

Facter.add(:uptime_hours) do
  setcode do
    seconds = Facter.value(:uptime_seconds)
    seconds && seconds / (60 * 60) # seconds in hour
  end
end
