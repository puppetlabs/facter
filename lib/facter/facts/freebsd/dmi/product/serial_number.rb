# frozen_string_literal: true

module Facts
  module Freebsd
    module Dmi
      module Product
        class SerialNumber
          FACT_NAME = 'dmi.product.serial_number'
          ALIASES = 'serialnumber'

          def call_the_resolver
            fact_value = Facter::Resolvers::Freebsd::DmiBios.resolve(:product_serial)
            [Facter::ResolvedFact.new(FACT_NAME, fact_value), Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
          end
        end
      end
    end
  end
end
