# frozen_string_literal: true

class TimezoneResolver < BaseResolver
  class << self
    @@semaphore = Mutex.new
    @@fact_list ||= {}

    def resolve(fact_name)
      @@semaphore.synchronize do
        result ||= @@fact_list[fact_name]
        result || determine_timezone
      end
    end

    private

    def determine_timezone
      @@fact_list[:timezone] = Time.now.localtime.strftime('%Z')
    end
  end
end
