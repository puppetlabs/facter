# frozen_string_literal: true

module Facts
  module El
    module Dmi
      module Product
        class Uuid
          FACT_NAME = 'dmi.product.uuid'

          def call_the_resolver
            fact_value = Facter::Resolvers::Linux::DmiBios.resolve(:product_uuid)
            Facter::ResolvedFact.new(FACT_NAME, fact_value)
          end
        end
      end
    end
  end
end
