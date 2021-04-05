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
          proc = win.exec_query('SELECT Name,Architecture,NumberOfLogicalProcessors,ThreadCount,NumberOfCores FROM Win32_Processor')
          unless proc
            log.debug 'WMI query returned no results'\
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
          cores = nil
          threads = 0
          threads_per_core = 0
          result.each do |proc|
            models << proc.Name
            logical_count += proc.NumberOfLogicalProcessors if proc.NumberOfLogicalProcessors
            isa ||= find_isa(proc.Architecture)
            cores = proc.NumberOfCores
            threads = thread_count(proc.ThreadCount)
            threads_per_core = threads.zero? ? 0 : (proc.ThreadCount / proc.NumberOfCores)
          end

          { models: models, isa: isa, logical_count: logical_count.zero? ? models.count : logical_count, cores_per_socket: cores, threads_per_core: threads_per_core }
        end

        def find_isa(arch)
          architecture_hash =
            { 0 => 'x86', 1 => 'MIPS', 2 => 'Alpha', 3 => 'PowerPC', 5 => 'ARM', 6 => 'Itanium', 9 => 'x64' }
          isa = architecture_hash[arch]
          return isa if isa

          log.debug 'Unable to determine processor type: unknown architecture'
        end

        def thread_count(thread)
          binding.pry
          if thread == nil or thread == 0 then
            return 0
          else
            return thread
          end
        end

        def build_fact_list(result)
          @fact_list[:count] = result[:logical_count]
          @fact_list[:isa] = result[:isa]
          @fact_list[:models] = result[:models]
          @fact_list[:physicalcount] = result[:models].size
          @fact_list[:cores_per_socket] = result[:cores_per_socket]
          @fact_list[:threads_per_core] = result[:threads_per_core]
        end
      end
    end
  end
end
