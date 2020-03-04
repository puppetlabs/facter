# frozen_string_literal: true

module Facts
  module Solaris
    module SolarisZones
      class Current
        FACT_NAME = 'solaris_zones.current'

        def call_the_resolver
          fact_value = Facter::Resolvers::SolarisZoneName.resolve(:current_zone_name)
          Facter::ResolvedFact.new(FACT_NAME, fact_value)
        end
      end
    end
  end
end
