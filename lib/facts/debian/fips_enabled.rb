# frozen_string_literal: true

module Facts
  module Debian
    class FipsEnabled
      FACT_NAME = 'fips_enabled'

      def call_the_resolver
        fact_value = Facter::Resolvers::Linux::FipsEnabled.resolve(:fips_enabled)
        Facter::ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
