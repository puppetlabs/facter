# frozen_string_literal: true

module Facts
  module Debian
    module Dmi
      module Board
        class Product
          FACT_NAME = 'dmi.board.product'

          def call_the_resolver
            fact_value = Facter::Resolvers::Linux::DmiBios.resolve(:board_name)
            Facter::ResolvedFact.new(FACT_NAME, fact_value)
          end
        end
      end
    end
  end
end
