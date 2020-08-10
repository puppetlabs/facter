# frozen_string_literal: true

module Facts
  module Solaris
    module Dmi
      module Chassis
        class AssetTag
          FACT_NAME = 'dmi.chassis.asset_tag'
          ALIASES = 'chassisassettag'

          def call_the_resolver
            fact_value = nil
            fact_value = Facter::Resolvers::Solaris::Dmi.resolve(:chassis_asset_tag) if isa == 'i386'
            [Facter::ResolvedFact.new(FACT_NAME, fact_value), Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
          end

          def isa
            Facter::Resolvers::Uname.resolve(:processor)
          end
        end
      end
    end
  end
end
