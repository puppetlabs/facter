# Fact: uptime_hours
#
# Purpose: Return purely number of hours of uptime.
#
# Resolution: Divides uptime_seconds fact by 3600.
#
# Caveats:
#

Facter.add(:uptime_hours) do
  setcode do
    seconds = Facter.value(:uptime_seconds)
    seconds && seconds / (60 * 60) # seconds in hour
  end
end

