# frozen_string_literal: true

module Facts
  module Solaris
    class ZpoolFeatureflags
      FACT_NAME = 'zpool_featureflags'

      def call_the_resolver
        fact_value = Facter::Resolvers::Solaris::ZPool.resolve(:zpool_featureflags)
        Facter::ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
