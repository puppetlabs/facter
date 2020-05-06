# frozen_string_literal: true

module Facter
  module Resolvers
    module Freebsd
      class FreebsdVersion < BaseResolver
        @semaphore = Mutex.new
        @fact_list ||= {}

        class << self
          private

          def post_resolve(fact_name)
            @fact_list.fetch(fact_name) { freebsd_version_system_call(fact_name) }
          end

          def freebsd_version_system_call(fact_name)
            output, _stderr, status = Open3.capture3('/bin/freebsd-version -kru')
            return nil unless status.success?

            build_fact_list(output)

            @fact_list[fact_name]
          rescue Errno::ENOENT
            nil
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
