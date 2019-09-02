# frozen_string_literal: true

module Facter
  module Windows
    class DmiProductName
      FACT_NAME = 'dmi.product.name'

      def call_the_resolver
        fact_value = DMIComputerSystemResolver.resolve(:name)

        Fact.new(FACT_NAME, fact_value)
      end
    end
  end
end
