# frozen_string_literal: true

module Facts
  module Openbsd
    module Dmi
      module Product
        class Uuid
          FACT_NAME = 'dmi.product.uuid'
          ALIASES = 'uuid'

          def call_the_resolver
            fact_value = Facter::Resolvers::Openbsd::DmiBios.resolve(:product_uuid)
            [Facter::ResolvedFact.new(FACT_NAME, fact_value), Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
          end
        end
      end
    end
  end
end
