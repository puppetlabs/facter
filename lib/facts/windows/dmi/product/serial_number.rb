# frozen_string_literal: true

module Facter
  module Windows
    class DmiProductSerialNumber
      FACT_NAME = 'dmi.product.serial_number'

      def call_the_resolver
        fact_value = Resolvers::DMIBiosResolver.resolve(:serial_number)

        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
