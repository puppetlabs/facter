# frozen_string_literal: true

module Facter
  module Resolvers
    module Linux
      class FipsEnabled < BaseResolver
        #:fips_enabled
        @semaphore = Mutex.new
        @fact_list ||= {}
        @log = Facter::Log.new
        class << self
          def resolve(fact_name)
            @semaphore.synchronize do
              result ||= @fact_list[fact_name]
              subscribe_to_manager
              result || read_fips_file(fact_name)
            end
          end

          def read_fips_file(fact_name)
            file_output = File.read('/proc/sys/crypto/fips_enabled')
            @fact_list[:fips_enabled] = file_output.strip == '1'
            @fact_list[fact_name]
          end
        end
      end
    end
  end
end
