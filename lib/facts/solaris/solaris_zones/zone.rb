# frozen_string_literal: true

module Facts
  module Solaris
    module SolarisZones
      class Zone
        FACT_NAME = 'solaris_zones.zones'
        ALIASES = %w[
          zone_.*_brand
          zone_.*_iptype
          zone_.*_name
          zone_.*_uuid
          zone_.*_id
          zone_.*_path
          zone_.*_status
          zones
        ].freeze

        def call_the_resolver
          resolved_facts = []
          zones = {}

          results = Facter::Resolvers::SolarisZone.resolve(:zone)
          results&.each do |result|
            zones.merge!(parse_result(result))
            resolved_facts << create_legacy_zone_facts(result)
          end

          resolved_facts << Facter::ResolvedFact.new('solaris_zones.zones', zones)
          resolved_facts << Facter::ResolvedFact.new('zones', results.count, :legacy)

          resolved_facts.flatten
        end

        private

        def parse_result(result)
          {
            result[:name].to_sym => {
              brand: result[:brand],
              id: result[:id],
              ip_type: result[:iptype],
              path: result[:path],
              status: result[:status]
            }
          }
        end

        def create_legacy_zone_facts(zone)
          legacy_facts = []
          %w[brand iptype name uuid id path status].each do |key|
            legacy_facts << Facter::ResolvedFact.new("zone_#{zone[:name]}_#{key}", zone[key.to_sym], :legacy)
          end

          legacy_facts
        end
      end
    end
  end
end
