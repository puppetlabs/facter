# frozen_string_literal: true

module Facts
  module Linux
    module Dmi
      module Product
        class Version
          FACT_NAME = 'dmi.product.version'
          ALIASES = 'productversion'

          def call_the_resolver
            fact_value = Facter::Resolvers::Linux::DmiBios.resolve(:product_version)
            [Facter::ResolvedFact.new(FACT_NAME, fact_value), Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
          end
        end
      end
    end
  end
end
