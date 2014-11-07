# Fact: system_uptime
#
# Purpose:
#   Return the system uptime in a hash in the forms of
#   seconds, hours, days and a general, human
#   readable uptime.
#
#   This fact is structured. These values are returned as a group of key-value pairs.
#
# Resolution:
#   Does basic math on the get_uptime_seconds utility
#   to calculate seconds, hours and days.
#
# Caveats:
#

require 'facter/util/uptime'

Facter.add(:system_uptime) do
  setcode do
    system_uptime = {}
    if Facter.value(:kernel) == 'windows'
      seconds = Facter::Util::Uptime.get_uptime_seconds_win
    else
      seconds = Facter::Util::Uptime.get_uptime_seconds_unix
    end

    if seconds
      system_uptime['seconds'] = seconds
      minutes                  = seconds / 60 % 60
      system_uptime['hours']   = seconds / (60 * 60)
      system_uptime['days']    = system_uptime['hours'] / 24

      case system_uptime['days']
      when 0 then system_uptime['uptime'] = "#{system_uptime['hours']}:#{"%02d" % minutes} hours"
      when 1 then system_uptime['uptime'] = "1 day"
      else system_uptime['uptime']        = "#{system_uptime['days']} days"
      end
    else
      system_uptime['uptime']  = 'unknown'
    end
    system_uptime
  end
end
