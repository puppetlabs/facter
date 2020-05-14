# frozen_string_literal: true

module Facts
  module Aix
    class NimType
      FACT_NAME = 'nim_type'

      def call_the_resolver
        fact_value = Facter::Resolvers::Aix::Nim.resolve(:type)

        Facter::ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
