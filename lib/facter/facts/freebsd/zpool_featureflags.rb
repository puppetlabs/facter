# frozen_string_literal: true

module Facts
  module Freebsd
    class ZpoolFeatureflags
      FACT_NAME = 'zpool_featureflags'

      def call_the_resolver
        fact_value = Facter::Resolvers::Zpool.resolve(:zpool_featureflags)
        Facter::ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
