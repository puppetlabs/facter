# frozen_string_literal: true

module Facter
  module Debian
    class DmiBoardProduct
      FACT_NAME = 'dmi.board.product'

      def call_the_resolver
        fact_value = Resolvers::Linux::DmiBios.resolve(:board_name)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
