# frozen_string_literal: true

module Facter
  module Fedora
    class DmiBoardManufacturer
      FACT_NAME = 'dmi.board.manufacturer'

      def call_the_resolver
        fact_value = Resolvers::Linux::DmiBios.resolve(:board_vendor)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
