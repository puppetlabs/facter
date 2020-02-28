# frozen_string_literal: true

module Facter
  module Debian
    class DmiBoardSerialNumber
      FACT_NAME = 'dmi.board.serial_number'

      def call_the_resolver
        fact_value = Resolvers::Linux::DmiBios.resolve(:board_serial)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
