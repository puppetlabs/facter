# frozen_string_literal: true

module Facter
  module El
    class DmiBiosVersion
      FACT_NAME = 'dmi.bios.version'

      def call_the_resolver
        fact_value = Resolvers::Linux::DmiBios.resolve(:bios_version)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
