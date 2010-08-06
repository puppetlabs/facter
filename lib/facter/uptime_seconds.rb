require 'facter/util/uptime'

Facter.add(:uptime_seconds) do
  setcode { Facter::Util::Uptime.get_uptime_seconds_unix }
end

Facter.add(:uptime_seconds) do
  confine :kernel => :windows
  setcode { Facter::Util::Uptime.get_uptime_seconds_win }
end
