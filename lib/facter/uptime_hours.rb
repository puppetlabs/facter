Facter.add(:uptime_hours) do
  setcode do
    seconds = Facter.value(:uptime_seconds)
    seconds && seconds / (60 * 60) # seconds in hour
  end
end

