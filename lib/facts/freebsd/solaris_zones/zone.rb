# frozen_string_literal: true

module Facts
  module Freebsd
    module SolarisZones
      class Zone
        FACT_NAME = 'solaris_zones.zones'

        def call_the_resolver
          []
        end
      end
    end
  end
end
