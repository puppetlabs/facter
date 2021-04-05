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
                  threads_per_core: 'machdep.cpu.thread_count' 
                }.freeze
                
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
            build_fact_list(output.split("\n"))
            @fact_list[fact_name]
          end

          def build_fact_list(processors_data)
            build_logical_count(processors_data[0])
            build_physical_count(processors_data[1])
            build_models(processors_data[2])
            build_speed(processors_data[3])
            build_cores_per_socket(processors_data[4])
            build_threads_per_core(processors_data[5], processors_data[4])
          end

          def build_logical_count(count)
            @fact_list[:logicalcount] = count.split(': ')[1].to_i
          end

          def build_physical_count(count)
            @fact_list[:physicalcount] = count.split(': ')[1].to_i
          end

          def build_models(model)
            brand = model.split(': ').fetch(1)
            @fact_list[:models] = Array.new(@fact_list[:logicalcount].to_i, brand)
          end

          def build_speed(value)
            @fact_list[:speed] = value.split(': ')[1].to_i
          end

          def build_cores_per_socket(count)
            @fact_list[:cores_per_socket] = count.split(': ')[1].to_i 
          end

          def build_threads_per_core(count, count2)
            @fact_list[:threads_per_core] = count.split(': ')[1].to_i / count2.split(': ')[1].to_i
          end
        end
      end
    end
  end
end
