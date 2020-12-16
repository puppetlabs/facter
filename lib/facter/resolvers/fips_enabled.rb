# frozen_string_literal: true

module Facter
  module Resolvers
    module Linux
      class FipsEnabled < BaseResolver
        #:fips_enabled

        init_resolver

        @log = Facter::Log.new(self)

        class << self
          private

          def post_resolve(fact_name)
            @fact_list.fetch(fact_name) { read_fips_file(fact_name) }
          end

          def read_fips_file(fact_name)
            file_output = Facter::Util::FileHelper.safe_read('/proc/sys/crypto/fips_enabled')
            @fact_list[:fips_enabled] = file_output.strip == '1'
            @fact_list[fact_name]
          end
        end
      end
    end
  end
end
