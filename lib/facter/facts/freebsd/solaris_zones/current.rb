# frozen_string_literal: true

module Facts
  module Freebsd
    module SolarisZones
      class Current
        FACT_NAME = 'solaris_zones.current'

        def call_the_resolver
          []
        end
      end
    end
  end
end
