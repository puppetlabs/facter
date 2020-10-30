# frozen_string_literal: true

module Facter
  module Resolvers
    module Freebsd
      class FreebsdVersion < BaseResolver
        init_resolver

        class << self
          private

          def post_resolve(fact_name)
            @fact_list.fetch(fact_name) { freebsd_version_system_call(fact_name) }
          end

          def freebsd_version_system_call(fact_name)
            output = Facter::Core::Execution.execute('/bin/freebsd-version -kru', logger: log)
            return if output.empty?

            build_fact_list(output)

            @fact_list[fact_name]
          end

          def build_fact_list(output)
            freebsd_version_results = output.split("\n")

            @fact_list[:installed_kernel]   = freebsd_version_results[0].strip
            @fact_list[:running_kernel]     = freebsd_version_results[1].strip
            @fact_list[:installed_userland] = freebsd_version_results[2].strip
          end
        end
      end
    end
  end
end
