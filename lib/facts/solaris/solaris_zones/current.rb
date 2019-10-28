# frozen_string_literal: true

module Facter
  module Solaris
    class SolarisZonesCurrent
      FACT_NAME = 'solaris_zones.current'

      def call_the_resolver
        fact_value = Resolvers::SolarisZoneName.resolve(:current_zone_name)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
