# frozen_string_literal: true

class IdentityResolver < BaseResolver
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

    def read_fact_from_bios(fact_name)
      win = Win32Ole.new

      bios = win.exec_query('SELECT Manufacturer,SerialNumber from Win32_BIOS').to_enum.first

      build_fact_list(bios)

      @@fact_list[fact_name]
    end

    def build_fact_list(bios)
      @@fact_list[:manufacturer] = bios.Manufacturer
      @@fact_list[:serial_number] = bios.SerialNumber
    end
  end
end
