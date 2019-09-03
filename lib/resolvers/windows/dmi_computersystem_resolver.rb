# frozen_string_literal: true

class DMIComputerSystemResolver < BaseResolver
  @log = Facter::Log.new

  class << self
    # Name
    # UUID
    @@semaphore = Mutex.new
    @@fact_list ||= {}

    def resolve(fact_name)
      @@semaphore.synchronize do
        result ||= @@fact_list[fact_name]
        return result if result

        result || read_fact_from_computer_system(fact_name)
      end
    end

    def invalidate_cache
      @@fact_list = {}
    end

    private

    def read_fact_from_computer_system(fact_name)
      win = Win32Ole.new
      computersystem = win.return_first('SELECT Name,UUID FROM Win32_ComputerSystemProduct')
      unless computersystem
        @log.debug 'WMI query returned no results for Win32_ComputerSystemProduct with values Name and UUID.'
        return
      end

      build_fact_list(computersystem)

      @@fact_list[fact_name]
    end

    def build_fact_list(computersys)
      @@fact_list[:name] = computersys.Name
      @@fact_list[:uuid] = computersys.UUID
    end
  end
end
