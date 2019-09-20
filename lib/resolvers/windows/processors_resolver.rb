# frozen_string_literal: true

module Facter
  module Resolvers
    class ProcessorsResolver < BaseResolver
      @log = Facter::Log.new
      @semaphore = Mutex.new
      @fact_list ||= {}
      class << self
        # Count
        # Isa
        # Models
        # PhysicalCount
        def resolve(fact_name)
          @semaphore.synchronize do
            result ||= @fact_list[fact_name]
            result || read_fact_from_win32_processor(fact_name)
          end
        end

        private

        def read_fact_from_win32_processor(fact_name)
          win = Win32Ole.new
          proc = win.exec_query('SELECT Name,Architecture,NumberOfLogicalProcessors FROM Win32_Processor')
          unless proc
            @log.debug 'WMI query returned no results'\
            'for Win32_Processor with values Name, Architecture and NumberOfLogicalProcessors.'
            return
          end
          result = iterate_proc(proc)
          build_fact_list(result)
          @fact_list[fact_name]
        end

        def iterate_proc(result)
          models = []
          isa = nil
          logical_count = 0
          result.each do |proc|
            models << proc.Name
            logical_count += proc.NumberOfLogicalProcessors if proc.NumberOfLogicalProcessors
            isa ||= find_isa(proc.Architecture)
          end

          { models: models, isa: isa, logical_count: logical_count.zero? ? models.count : logical_count }
        end

        def find_isa(arch)
          architecture_hash =
            { 0 => 'x86', 1 => 'MIPS', 2 => 'Alpha', 3 => 'PowerPC', 5 => 'ARM', 6 => 'Itanium', 9 => 'x64' }
          isa = architecture_hash[arch]
          return isa if isa

          @log.debug 'Unable to determine processor type: unknown architecture'
        end

        def build_fact_list(result)
          @fact_list[:count] = result[:logical_count]
          @fact_list[:isa] = result[:isa]
          @fact_list[:models] = result[:models]
          @fact_list[:physicalcount] = result[:models].size
        end
      end
    end
  end
end
