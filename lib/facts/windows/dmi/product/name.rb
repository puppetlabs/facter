# frozen_string_literal: true

module Facter
  module Windows
    class DmiProductName
      FACT_NAME = 'dmi.product.name'

      def call_the_resolver
        fact_value = Resolvers::DMIComputerSystemResolver.resolve(:name)

        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
