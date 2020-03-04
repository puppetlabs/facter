# frozen_string_literal: true

module Facts
  module Debian
    module Dmi
      module Board
        class Manufacturer
          FACT_NAME = 'dmi.board.manufacturer'

          def call_the_resolver
            fact_value = Facter::Resolvers::Linux::DmiBios.resolve(:board_vendor)
            Facter::ResolvedFact.new(FACT_NAME, fact_value)
          end
        end
      end
    end
  end
end
