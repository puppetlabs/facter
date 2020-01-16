# frozen_string_literal: true

module Facter
  module El
    class DmiBiosReleaseDate
      FACT_NAME = 'dmi.bios.release_date'

      def call_the_resolver
        fact_value = Resolvers::Linux::DmiBios.resolve(:bios_date)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
