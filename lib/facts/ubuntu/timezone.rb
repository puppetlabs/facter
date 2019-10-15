# frozen_string_literal: true

module Facter
  module Ubuntu
    class Timezone
      FACT_NAME = 'timezone'

      def call_the_resolver
        fact_value = Facter::Resolvers::Timezone.resolve(:timezone)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
