# frozen_string_literal: true

module Facter
  module Debian
    class DmiManufacturer
      FACT_NAME = 'dmi.manufacturer'

      def call_the_resolver
        fact_value = Resolvers::Linux::DmiBios.resolve(:sys_vendor)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
