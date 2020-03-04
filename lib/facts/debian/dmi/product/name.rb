# frozen_string_literal: true

module Facts
  module Debian
    module Dmi
      module Product
        class Name
          FACT_NAME = 'dmi.product.name'

          def call_the_resolver
            fact_value = Facter::Resolvers::Linux::DmiBios.resolve(:product_name)
            Facter::ResolvedFact.new(FACT_NAME, fact_value)
          end
        end
      end
    end
  end
end
