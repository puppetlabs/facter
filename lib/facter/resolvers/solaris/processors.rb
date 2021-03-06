# frozen_string_literal: true

module Facter
  module Resolvers
    module Solaris
      class Processors < BaseResolver
        init_resolver

        class << self
          private

          def post_resolve(fact_name, _options)
            @fact_list.fetch(fact_name) { collect_kstat_info(fact_name) }
          end

          def collect_kstat_info(fact_name)
            return unless File.executable?('/usr/bin/kstat')

            kstat_output = Facter::Core::Execution.execute('/usr/bin/kstat -m cpu_info', logger: log)
            return if kstat_output.empty?

            parse_output(kstat_output.chomp)
            @fact_list[fact_name]
          end

          def parse_output(output)
            @fact_list[:logical_count] = output.scan(/module/).size
            @fact_list[:physical_count] = output.scan(/chip_id .*/).uniq.size
            @fact_list[:speed] = output.scan(/current_clock_Hz .*/).first.gsub(/[a-zA-z\s]+/, '').to_i
            @fact_list[:models] = output.scan(/brand .*/).map { |elem| elem.gsub(/brand(\s+)/, '') }
            calculate_threads_cores(output)
          end

          def calculate_threads_cores(output)
            @fact_list[:core_count] = output.scan(/\score_id .*/).uniq.size
            @fact_list[:threads_per_core] = @fact_list[:logical_count] / @fact_list[:core_count]
            @fact_list[:cores_per_socket] = @fact_list[:core_count] / @fact_list[:physical_count]
          end
        end
      end
    end
  end
end
