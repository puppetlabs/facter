# frozen_string_literal: true

module Facter
  module Fedora
    class DmiBiosVendor
      FACT_NAME = 'dmi.bios.vendor'

      def call_the_resolver
        fact_value = Resolvers::Linux::DmiBios.resolve(:bios_vendor)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
