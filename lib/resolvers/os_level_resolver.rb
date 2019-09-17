# frozen_string_literal: true

class OsLevelResolver < BaseResolver
  # build

  class << self
    @@semaphore = Mutex.new
    @@fact_list ||= {}

    def resolve(fact_name)
      @@semaphore.synchronize do
        result ||= @@fact_list[fact_name]
        result || read_oslevel(fact_name)
      end
    end

    def read_oslevel(fact_name)
      output, _status = Open3.capture2('oslevel -s')
      @@fact_list[:build] = output

      @@fact_list[fact_name]
    end
  end
end
