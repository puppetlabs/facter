# frozen_string_literal: true

module Facter
  module El
    class DmiProductUuid
      FACT_NAME = 'dmi.product.uuid'

      def call_the_resolver
        fact_value = Resolvers::Linux::DmiBios.resolve(:product_uuid)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
