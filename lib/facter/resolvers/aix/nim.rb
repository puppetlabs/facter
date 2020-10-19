# frozen_string_literal: true

module Facter
  module Resolvers
    module Aix
      class Nim < BaseResolver
        @fact_list ||= {}

        class << self
          private

          def post_resolve(fact_name)
            @fact_list.fetch(fact_name) { read_niminfo(fact_name) }
          end

          def read_niminfo(fact_name)
            output = Facter::Util::FileHelper.safe_read('/etc/niminfo', nil)

            return unless output

            type = /NIM_CONFIGURATION=(.*)/.match(output)
            @fact_list[:type] = type[1] if type[1] && /master|standalone/.match?(type[1])

            @fact_list[fact_name]
          end
        end
      end
    end
  end
end
