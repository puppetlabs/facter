# frozen_string_literal: true

module Facts
  module Windows
    class FipsEnabled
      FACT_NAME = 'fips_enabled'

      def call_the_resolver
        fact_value = Facter::Resolvers::Windows::Fips.resolve(:fips_enabled)

        Facter::ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
