# frozen_string_literal: true

module Facter
  module Windows
    class DmiProductUUID
      FACT_NAME = 'dmi.product.uuid'

      def call_the_resolver
        fact_value = Resolver::DMIComputerSystemResolver.resolve(:uuid)

        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
