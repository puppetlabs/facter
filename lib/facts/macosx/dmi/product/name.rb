# frozen_string_literal: true

module Facter
  module Macosx
    class DmiProductName
      FACT_NAME = 'dmi.product.name'

      def call_the_resolver
        fact_value = Resolvers::Macosx::DmiBios.resolve(:macosx_model)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
