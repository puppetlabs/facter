# frozen_string_literal: true

module Facter
  module Resolvers
    module Macosx
      class DmiBios < BaseResolver
        init_resolver

        class << self
          # :model

          private

          def post_resolve(fact_name, _options)
            @fact_list.fetch(fact_name) { read_facts }
          end

          def read_facts
            # OSX only supports the product name
            output = Facter::Core::Execution.execute('sysctl -n hw.model', logger: log)
            @fact_list[:macosx_model] = output&.strip
          end
        end
      end
    end
  end
end
