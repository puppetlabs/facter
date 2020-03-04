# frozen_string_literal: true

module Facts
  module Macosx
    module Dmi
      module Product
        class Name
          FACT_NAME = 'dmi.product.name'

          def call_the_resolver
            fact_value = Facter::Resolvers::Macosx::DmiBios.resolve(:macosx_model)
            Facter::ResolvedFact.new(FACT_NAME, fact_value)
          end
        end
      end
    end
  end
end
