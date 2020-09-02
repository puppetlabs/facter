# frozen_string_literal: true

module Facts
  module Linux
    module Dmi
      module Board
        class AssetTag
          FACT_NAME = 'dmi.board.asset_tag'
          ALIASES = 'boardassettag'

          def call_the_resolver
            fact_value = Facter::Resolvers::Linux::DmiBios.resolve(:board_asset_tag)
            [Facter::ResolvedFact.new(FACT_NAME, fact_value), Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
          end
        end
      end
    end
  end
end
