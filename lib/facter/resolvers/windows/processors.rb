# frozen_string_literal: true

module Facter
  module Resolvers
    class Processors < BaseResolver
      init_resolver

      class << self
        # Count
        # Isa
        # Models
        # PhysicalCount

        private

        def post_resolve(fact_name, _options)
          @fact_list.fetch(fact_name) { read_fact_from_win32_processor(fact_name) }
        end

        def read_fact_from_win32_processor(fact_name)
          win = Facter::Util::Windows::Win32Ole.new
          query_string = 'SELECT Name,'\
          'Architecture,'\
          'NumberOfLogicalProcessors,'\
          'NumberOfCores FROM Win32_Processor'
          proc = win.exec_query(query_string)
          unless proc
            log.debug 'WMI query returned no results'\
            'for Win32_Processor with values Name, Architecture and NumberOfLogicalProcessors.'
            return
          end
          result = iterate_proc(proc)
          cores_threads = calculate_cores_threads(proc, result)
          build_fact_list(result, cores_threads)
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

          { models: models,
            isa: isa,
            logical_count: logical_processors_count(logical_count, models.count) }
        end

        def calculate_cores_threads(result_proc, data_proc)
          cores = 0
          threads_per_core = 0
          result_proc.each do |proc|
            cores = proc.NumberOfCores
            threads_per_core = if check_hyperthreading(data_proc[:logical_count], cores) ||
                                  cores > data_proc[:logical_count]
                                 1
                               else
                                 data_proc[:logical_count] / (cores * data_proc[:models].size)
                               end
          end
          { cores_per_socket: cores,
            threads_per_core: threads_per_core }
        end

        def check_hyperthreading(cores, logical_processors)
          cores == logical_processors
        end

        def find_isa(arch)
          architecture_hash =
            { 0 => 'x86', 1 => 'MIPS', 2 => 'Alpha', 3 => 'PowerPC', 5 => 'ARM', 6 => 'Itanium', 9 => 'x64' }
          isa = architecture_hash[arch]
          return isa if isa

          log.debug 'Unable to determine processor type: unknown architecture'
        end

        def logical_processors_count(logical_count, models_count)
          if logical_count.zero?
            models_count
          else
            logical_count
          end
        end

        def build_fact_list(result, cores_threads)
          @fact_list[:count] = result[:logical_count]
          @fact_list[:isa] = result[:isa]
          @fact_list[:models] = result[:models]
          @fact_list[:physicalcount] = result[:models].size
          @fact_list[:cores_per_socket] = cores_threads[:cores_per_socket]
          @fact_list[:threads_per_core] = cores_threads[:threads_per_core]
        end
      end
    end
  end
end
