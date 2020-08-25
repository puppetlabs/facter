# frozen_string_literal: true

module Facts
  module Solaris
    module Hypervisors
      class Zone
        FACT_NAME = 'hypervisors.zone'

        def initialize
          @log = Facter::Log.new(self)
        end

        def call_the_resolver
          fact_value = current_zone

          Facter::ResolvedFact.new(FACT_NAME, fact_value)
        end

        def current_zone
          current_zone_name = Facter::Resolvers::Solaris::ZoneName.resolve(:current_zone_name)
          return unless current_zone_name

          zones = Facter::Resolvers::Solaris::Zone.resolve(:zone)
          return nil unless zones

          current_zone = zones.find { |r| r[:name] == current_zone_name }

          {
            brand: current_zone[:brand],
            id: current_zone[:id],
            ip_type: current_zone[:iptype],
            name: current_zone[:name],
            uuid: current_zone[:uuid]
          }
        end
      end
    end
  end
end
