# frozen_string_literal: true

module Facter
  module Resolvers
    module Linux
      class Lscpu < BaseResolver
        init_resolver

        ITEMS = { threads_per_core: "-e 'Thread(s)'",
                  cores_per_socket: "-e 'Core(s)'" }.freeze

        class << self
          #:cores_per_socket
          #:threads_per_core

          private

          def post_resolve(fact_name, _options)
            @fact_list.fetch(fact_name) { read_cpuinfo(fact_name) }
          end

          def read_cpuinfo(fact_name)
            lscpu_output = Facter::Core::Execution.execute("lscpu | grep #{ITEMS.values.join(' ')}", logger: log)
            build_fact_list(lscpu_output.split("\n"))
            @fact_list[fact_name]
          end

          def build_fact_list(processors_data)
            build_threads_per_core(processors_data[0])
            build_cores_per_socket(processors_data[1])
          end

          def build_threads_per_core(index)
            @fact_list[:threads_per_core] = index.split(': ')[1].to_i
          end

          def build_cores_per_socket(index)
            @fact_list[:cores_per_socket] = index.split(': ')[1].to_i
          end
        end
      end
    end
  end
end
