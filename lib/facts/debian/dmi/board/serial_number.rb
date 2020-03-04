# frozen_string_literal: true

module Facts
  module Debian
    module Dmi
      module Board
        class SerialNumber
          FACT_NAME = 'dmi.board.serial_number'

          def call_the_resolver
            fact_value = Facter::Resolvers::Linux::DmiBios.resolve(:board_serial)
            Facter::ResolvedFact.new(FACT_NAME, fact_value)
          end
        end
      end
    end
  end
end
