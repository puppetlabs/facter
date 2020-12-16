# frozen_string_literal: true

module Facter
  module Resolvers
    module Macosx
      class LoadAverages < BaseResolver
        init_resolver

        class << self
          private

          def post_resolve(fact_name)
            @fact_list.fetch(fact_name) { read_load_averages_file(fact_name) }
          end

          def read_load_averages_file(fact_name)
            output = Facter::Core::Execution.execute('sysctl -n vm.loadavg', logger: log)
            @fact_list[:load_averages] = {}.tap { |h| _, h['1m'], h['5m'], h['15m'], = output.split.map(&:to_f) }

            @fact_list[fact_name]
          end
        end
      end
    end
  end
end
