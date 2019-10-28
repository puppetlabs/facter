# frozen_string_literal: true

module Facter
  module Solaris
    class Zone
      FACT_NAME = 'solaris_zones.zones'

      def call_the_resolver
        results = Facter::Resolvers::SolarisZone.resolve(:zone)
        zones_fact = {}
        results&.each do |result|
          fact_value = { result[:name].to_sym => {
            brand: result[:brand],
            id: result[:id],
            ip_type: result[:ip_type],
            path: result[:path],
            status: result[:status]
          } }
          zones_fact.merge!(fact_value)
        end
        ResolvedFact.new(FACT_NAME, zones_fact)
      end
    end
  end
end
