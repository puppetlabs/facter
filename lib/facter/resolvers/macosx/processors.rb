# frozen_string_literal: true

module Facter
  module Resolvers
    module Macosx
      class Processors < BaseResolver
        init_resolver

        ITEMS = { logical_count: 'hw.logicalcpu_max',
                  physical_count: 'hw.physicalcpu_max',
                  brand: 'machdep.cpu.brand_string',
                  speed: 'hw.cpufrequency_max',
                  cores_per_socket: 'machdep.cpu.core_count',
                  threads_per_core: 'machdep.cpu.thread_count' }.freeze

        class << self
          # :logicalcount
          # :models
          # :physicalcount
          # :speed
          # :cores_per_socket
          # :threads_per_core

          private

          def post_resolve(fact_name, _options)
            @fact_list.fetch(fact_name) { read_processor_data(fact_name) }
          end

          def read_processor_data(fact_name)
            output = Facter::Core::Execution.execute("sysctl #{ITEMS.values.join(' ')}", logger: log)
            processors_hash = Hash[*output.split("\n").collect { |v| [v.split(': ')[0], v.split(': ')[1]] }.flatten]
            build_fact_list(processors_hash)
            @fact_list[fact_name]
          end

          def build_fact_list(hash)
            build_logical_count(hash)
            build_physical_count(hash)
            build_models(hash)
            build_speed(hash)
            build_cores_per_socket(hash)
            build_threads_per_core(hash)
          end

          def build_logical_count(hash)
            @fact_list[:logicalcount] = hash[ITEMS[:logical_count]].to_i
          end

          def build_physical_count(hash)
            @fact_list[:physicalcount] = hash[ITEMS[:physical_count]].to_i
          end

          def build_models(hash)
            @fact_list[:models] = Array.new(@fact_list[:logicalcount].to_i, hash[ITEMS[:brand]])
          end

          def build_speed(hash)
            @fact_list[:speed] = hash[ITEMS[:speed]].to_i
          end

          def build_cores_per_socket(hash)
            @fact_list[:cores_per_socket] = hash[ITEMS[:cores_per_socket]].to_i
          end

          def build_threads_per_core(hash)
            @fact_list[:threads_per_core] = hash[ITEMS[:threads_per_core]].to_i / hash[ITEMS[:cores_per_socket]].to_i
          end
        end
      end
    end
  end
end
