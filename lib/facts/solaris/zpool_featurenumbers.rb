# frozen_string_literal: true

module Facter
  module Solaris
    class ZPoolFeatureNumbers
      FACT_NAME = 'zpool_featurenumbers'

      def call_the_resolver
        fact_value = Resolvers::Solaris::ZPool.resolve(:zpool_featurenumbers)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
