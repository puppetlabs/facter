# frozen_string_literal: true

module Facter
  module Windows
    class SystemUptimeHours
      FACT_NAME = 'system_uptime.hours'
      ALIASES = 'uptime_hours'

      def call_the_resolver
        fact_value = Resolvers::Windows::Uptime.resolve(:hours)

        [ResolvedFact.new(FACT_NAME, fact_value), ResolvedFact.new(ALIASES, fact_value, :legacy)]
      end
    end
  end
end
