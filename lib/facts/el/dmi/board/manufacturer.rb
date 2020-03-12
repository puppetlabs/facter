# frozen_string_literal: true

module Facts
  module El
    module Dmi
      module Board
        class Manufacturer
          FACT_NAME = 'dmi.board.manufacturer'
          ALIASES = 'boardmanufacturer'

          def call_the_resolver
            fact_value = Facter::Resolvers::Linux::DmiBios.resolve(:board_vendor)
            [Facter::ResolvedFact.new(FACT_NAME, fact_value), Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
          end
        end
      end
    end
  end
end
