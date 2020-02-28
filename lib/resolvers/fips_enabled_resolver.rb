# frozen_string_literal: true

module Facter
  module Resolvers
    module Linux
      class FipsEnabled < BaseResolver
        #:fips_enabled
        @semaphore = Mutex.new
        @fact_list ||= {}
        @log = Facter::Log.new(self)
        class << self
          private

          def post_resolve(fact_name)
            @fact_list.fetch(fact_name) { read_fips_file(fact_name) }
          end

          def read_fips_file(fact_name)
            return @fact_list[fact_name] = false unless File.directory?('/proc/sys/crypto')

            file_output = File.read('/proc/sys/crypto/fips_enabled')
            @fact_list[:fips_enabled] = file_output.strip == '1'
            @fact_list[fact_name]
          end
        end
      end
    end
  end
end
