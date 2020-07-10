# frozen_string_literal: true

module Facts
  module Linux
    module Dmi
      module Board
        class Product
          FACT_NAME = 'dmi.board.product'
          ALIASES = 'boardproductname'

          def call_the_resolver
            fact_value = Facter::Resolvers::Linux::DmiBios.resolve(:board_name)
            [Facter::ResolvedFact.new(FACT_NAME, fact_value), Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
          end
        end
      end
    end
  end
end
