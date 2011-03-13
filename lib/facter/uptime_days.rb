# Fact: uptime_days
#
# Purpose: Return purely number of days of uptime.
#
# Resolution: Divides uptime_hours fact by 24.
#
# Caveats:
#

Facter.add(:uptime_days) do
  setcode do
    hours = Facter.value(:uptime_hours)
    hours && hours / 24 # hours in day
  end
end

