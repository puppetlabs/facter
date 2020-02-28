# frozen_string_literal: true

module Facter
  module Debian
    class FipsEnabled
      FACT_NAME = 'fips_enabled'

      def call_the_resolver
        fact_value = Resolvers::Linux::FipsEnabled.resolve(:fips_enabled)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
