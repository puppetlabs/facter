# frozen_string_literal: true

module Facts
  module El
    module Dmi
      module Chassis
        class AssetTag
          FACT_NAME = 'dmi.chassis.asset_tag'

          def call_the_resolver
            fact_value = Facter::Resolvers::Linux::DmiBios.resolve(:chassis_asset_tag)
            Facter::ResolvedFact.new(FACT_NAME, fact_value)
          end
        end
      end
    end
  end
end
