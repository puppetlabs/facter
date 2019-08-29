# frozen_string_literal: true

class DMIComputerSystemResolver < BaseResolver
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

    private

    def read_fact_from_computer_system(fact_name)
      win = Win32Ole.new
      computersystem = win.exec_query('SELECT Name,UUID FROM Win32_ComputerSystemProduct').to_enum.first

      build_fact_list(computersystem)

      @@fact_list[fact_name]
    end

    def build_fact_list(computersys)
      @@fact_list[:name] = computersys.Name
      @@fact_list[:uuid] = computersys.UUID
    end
  end
end
