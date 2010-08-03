Facter.add(:uptime_days) do
  setcode do
    hours = Facter.value(:uptime_hours)
    hours && hours / 24 # hours in day
  end
end

