# frozen_string_literal: true

module Facter
  module Windows
    class SystemUptimeUptime
      FACT_NAME = 'system_uptime.uptime'
      ALIASES = 'uptime'

      def call_the_resolver
        fact_value = Resolvers::Windows::Uptime.resolve(:uptime)

        [ResolvedFact.new(FACT_NAME, fact_value), ResolvedFact.new(ALIASES, fact_value, :legacy)]
      end
    end
  end
end
