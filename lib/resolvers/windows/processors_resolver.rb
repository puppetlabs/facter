# frozen_string_literal: true

class ProcessorsResolver < BaseResolver
  class << self
    # Count
    # Isa
    # Models
    # PhysicalCount
    @@semaphore = Mutex.new
    @@fact_list ||= {}

    def resolve(fact_name)
      @@semaphore.synchronize do
        result ||= @@fact_list[fact_name]

        return result if result

        win = Win32Ole.new
        proc = win.exec_query('SELECT Name,Architecture,NumberOfLogicalProcessors FROM Win32_Processor')

        result = iterate_proc(proc)
        build_fact_list(result)

        @@fact_list[fact_name]
      end
    end

    def invalidate_cache
      @@fact_list = {}
    end

    private

    def iterate_proc(result)
      models = []
      isa = nil
      logical_count = 0

      result.each do |proc|
        models << proc.Name
        logical_count += proc.NumberOfLogicalProcessors

        next if isa

        isa = find_isa(proc.Architecture)
      end

      logical_count = models.count if logical_count.zero?
      { models: models, isa: isa, logical_count: logical_count }
    end

    def find_isa(arch)
      architecture_array = %w[x86 MIPS Alpha PowerPC ARM Itanium x64]
      isa = architecture_array[arch]

      return isa if isa

      raise 'Unable to determine processor type: unknown architecture'
    end

    def build_fact_list(result)
      @@fact_list[:count] = result[:logical_count]
      @@fact_list[:isa] = result[:isa]
      @@fact_list[:models] = result[:models]
      @@fact_list[:physicalcount] = result[:models].size
    end
  end
end
