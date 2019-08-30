# frozen_string_literal: true

class UptimeResolver < BaseResolver
  class << self
    # Manufacturer
    # SerialNumber
    @@semaphore = Mutex.new
    @@fact_list ||= {}

    def resolve(fact_name)
      @@semaphore.synchronize do
        result ||= @@fact_list[fact_name]
        result || read_fact_from_bios(fact_name)
      end
    end

    private

    def read_fact_from_bios(_fact_name)
      count = Uptime.GetTickCount64()
      secs = (count / 1000)
      hours = (secs / 3600)
      result = {
        'days' => (hours / 24),
        'hours' => hours,
        'seconds' => secs,
        'uptime' => 'TBD'
      }

      @@fact_list[:system_uptime] = result
    end
  end
end
