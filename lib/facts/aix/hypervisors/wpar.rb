# frozen_string_literal: true

module Facter
  module Aix
    class HypervisorsWpar
      FACT_NAME = 'hypervisors.wpar'

      def call_the_resolver
        wpar_key = Resolvers::Wpar.resolve(:wpar_key)
        return ResolvedFact.new(FACT_NAME, nil) unless wpar_key&.positive?

        ResolvedFact.new(FACT_NAME, key: wpar_key, configured_id: Resolvers::Wpar.resolve(:wpar_configured_id))
      end
    end
  end
end
