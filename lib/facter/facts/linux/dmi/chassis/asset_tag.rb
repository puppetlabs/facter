# frozen_string_literal: true

module Facts
  module Linux
    module Dmi
      module Chassis
        class AssetTag
          FACT_NAME = 'dmi.chassis.asset_tag'
          ALIASES = 'chassisassettag'

          def call_the_resolver
            fact_value = Facter::Resolvers::Linux::DmiBios.resolve(:chassis_asset_tag)
            [Facter::ResolvedFact.new(FACT_NAME, fact_value), Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
          end
        end
      end
    end
  end
end
