# frozen_string_literal: true

module Facts
  module Openbsd
    class Facterversion
      FACT_NAME = 'facterversion'

      def call_the_resolver
        fact_value = Facter::Resolvers::Facterversion.resolve(:facterversion)
        Facter::ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
