# frozen_string_literal: true

module Facter
  module Resolvers
    module Freebsd
      class FreebsdVersion < BaseResolver
        @fact_list ||= {}

        class << self
          private

          def post_resolve(fact_name)
            @fact_list.fetch(fact_name) { freebsd_version_system_call(fact_name) }
          end

          def freebsd_version_system_call(fact_name)
            output = Facter::Core::Execution.execute('/bin/freebsd-version -k', logger: log)

            @fact_list[:installed_kernel] = output.strip unless output.empty?

            output = Facter::Core::Execution.execute('/bin/freebsd-version -ru', logger: log)

            build_fact_list(output) unless output.empty?

            @fact_list[fact_name]
          end

          def build_fact_list(output)
            freebsd_version_results = output.split("\n")

            @fact_list[:running_kernel]     = freebsd_version_results[0].strip
            @fact_list[:installed_userland] = freebsd_version_results[1].strip
          end
        end
      end
    end
  end
end
