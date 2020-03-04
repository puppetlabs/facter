# frozen_string_literal: true

module Facts
  module Aix
    module Hypervisors
      class Wpar
        FACT_NAME = 'hypervisors.wpar'

        def call_the_resolver
          wpar_key = Facter::Resolvers::Wpar.resolve(:wpar_key)
          return Facter::ResolvedFact.new(FACT_NAME, nil) unless wpar_key&.positive?

          Facter::ResolvedFact.new(FACT_NAME, key: wpar_key,
                                              configured_id: Facter::Resolvers::Wpar.resolve(:wpar_configured_id))
        end
      end
    end
  end
end
