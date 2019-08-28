# frozen_string_literal: true

class DMIBiosResolver < BaseResolver
  class << self
    # Manufacturer
    # SerialNumber
    @@semaphore = Mutex.new
    @@fact_list ||= {}

    def resolve(fact_name)
      @@semaphore.synchronize do
        result ||= @@fact_list[fact_name]

        return result if result

        win = Win32Ole.new
        bios = win.exec_query('SELECT Manufacturer,SerialNumber from Win32_BIOS').to_enum.first

        build_fact_list(bios)

        @@fact_list[fact_name]
      end
    end

    private

    def build_fact_list(bios)
      @@fact_list[:manufacturer] = bios.Manufacturer
      @@fact_list[:serial_number] = bios.SerialNumber
    end
  end
end
