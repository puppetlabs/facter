# frozen_string_literal: true

module Facter
  module Fedora
    class DmiChassisAssetTag
      FACT_NAME = 'dmi.chassis.asset_tag'

      def call_the_resolver
        fact_value = Resolvers::Linux::DmiBios.resolve(:chassis_asset_tag)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
