# frozen_string_literal: true

module Facts
  module Solaris
    class ZpoolFeaturenumbers
      FACT_NAME = 'zpool_featurenumbers'

      def call_the_resolver
        fact_value = Facter::Resolvers::Solaris::ZPool.resolve(:zpool_featurenumbers)
        Facter::ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
