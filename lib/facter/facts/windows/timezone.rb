# frozen_string_literal: true

module Facts
  module Windows
    class Timezone
      FACT_NAME = 'timezone'

      def call_the_resolver
        fact_value = Facter::Resolvers::Timezone.resolve(:timezone)

        Facter::ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
