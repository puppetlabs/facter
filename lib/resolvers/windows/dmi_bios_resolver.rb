# frozen_string_literal: true

class DMIBiosResolver < BaseResolver
  @log = Facter::Log.new
  @semaphore = Mutex.new
  @fact_list ||= {}

  class << self
    # Manufacturer
    # SerialNumber

    def resolve(fact_name)
      @semaphore.synchronize do
        result ||= @fact_list[fact_name]
        result || read_fact_from_bios(fact_name)
      end
    end

    def invalidate_cache
      @fact_list = {}
    end

    private

    def read_fact_from_bios(fact_name)
      win = Win32Ole.new

      bios = win.return_first('SELECT Manufacturer,SerialNumber from Win32_BIOS')
      unless bios
        @log.debug 'WMI query returned no results for Win32_BIOS with values Manufacturer and SerialNumber.'
        return
      end

      build_fact_list(bios)

      @fact_list[fact_name]
    end

    def build_fact_list(bios)
      @fact_list[:manufacturer] = bios.Manufacturer
      @fact_list[:serial_number] = bios.SerialNumber
    end
  end
end
