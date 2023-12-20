# frozen_string_literal: true

module Facter
  module Resolvers
    module Amzn
      class OsReleaseRpm < BaseResolver
        init_resolver

        class << self
          private

          def post_resolve(fact_name, _options)
            @fact_list.fetch(fact_name) { rpm_system_call(fact_name) }
          end

          def rpm_system_call(fact_name)
            output = Facter::Core::Execution.execute(
              'rpm -q --qf \'%<NAME>s\n%<VERSION>s\n%<RELEASE>s\n%<VENDOR>s\' -f /etc/os-release',
              logger: log
            )
            build_fact_list(output)

            @fact_list[fact_name]
          end

          def build_fact_list(output)
            rpm_results = output.split("\n")

            return if rpm_results.empty?

            @fact_list[:package],
              @fact_list[:version],
              @fact_list[:release],
              @fact_list[:vendor] = rpm_results.map(&:strip)
          end
        end
      end
    end
  end
end
