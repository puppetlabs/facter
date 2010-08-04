require 'facter/util/uptime'

Facter.add(:uptime) do
  setcode do
    seconds = Facter.fact(:uptime_seconds).value

    unless seconds
      "unknown"
    else
      days    = seconds / (60 * 60 * 24)
      hours   = seconds / (60 * 60) % 24
      minutes = seconds / 60 % 60

      case days
      when 0 then "#{hours}:#{"%02d" % minutes} hours"
      when 1 then '1 day'
      else "#{days} days"
      end
    end

  end
end

