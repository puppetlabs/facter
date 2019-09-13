# frozen_string_literal: true

require 'date'

class UptimeResolver < BaseResolver
  @log = Facter::Log.new
  @semaphore = Mutex.new
  @fact_list ||= {}

  class << self
    def resolve(fact_name)
      @semaphore.synchronize do
        result ||= @fact_list[fact_name]
        result || calculate_system_uptime(fact_name)
      end
    end

    private

    def substract_system_uptime_from_ole
      win = Win32Ole.new
      opsystem = win.return_first('SELECT LocalDateTime,LastBootUpTime FROM Win32_OperatingSystem')
      unless opsystem
        @log.debug 'WMI query returned no results'\
        'for Win32_OperatingSystem with values LocalDateTime and LastBootUpTime.'
        return
      end

      local_time = opsystem.LocalDateTime
      last_bootup = opsystem.LastBootUpTime

      return DateTime.parse(local_time).to_time - DateTime.parse(last_bootup).to_time if local_time && last_bootup

      nil
    end

    def calculate_system_uptime(fact_name)
      seconds = substract_system_uptime_from_ole.to_i if substract_system_uptime_from_ole
      if !seconds || seconds.negative?
        @log.debug 'Unable to determine system uptime!'
        return
      end

      hours = seconds / 3600
      days = hours / 24

      result = { seconds: seconds, hours: hours, days: days }

      result[:uptime] = determine_uptime(result)
      build_fact_list(result)

      @fact_list[fact_name]
    end

    def determine_uptime(result_hash)
      minutes = (result_hash[:seconds] - result_hash[:hours] * 3600) / 60

      if result_hash[:days].zero?
        "#{result_hash[:hours]}:#{minutes} hours"
      elsif result_hash[:days] == 1
        "#{result_hash[:days]} day"
      else
        "#{result_hash[:days]} days"
      end
    end

    def build_fact_list(system_uptime)
      @fact_list[:days] = system_uptime[:days]
      @fact_list[:hours] = system_uptime[:hours]
      @fact_list[:seconds] = system_uptime[:seconds]
      @fact_list[:uptime] = system_uptime[:uptime]
    end
  end
end
