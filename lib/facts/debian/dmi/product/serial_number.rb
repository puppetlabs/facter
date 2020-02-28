# frozen_string_literal: true

module Facter
  module Debian
    class DmiProductSerialNumber
      FACT_NAME = 'dmi.product.serial_number'

      def call_the_resolver
        fact_value = Resolvers::Linux::DmiBios.resolve(:product_serial)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
