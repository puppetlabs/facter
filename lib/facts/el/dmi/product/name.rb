# frozen_string_literal: true

module Facter
  module El
    class DmiProductName
      FACT_NAME = 'dmi.product.name'

      def call_the_resolver
        fact_value = Resolvers::Linux::DmiBios.resolve(:product_name)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
