# frozen_string_literal: true

module Facts
  module Debian
    module Processors
      class Models
        FACT_NAME = 'processors.models'

        def call_the_resolver
          fact_value = Facter::Resolvers::Linux::Processors.resolve(:models)
          Facter::ResolvedFact.new(FACT_NAME, fact_value)
        end
      end
    end
  end
end
