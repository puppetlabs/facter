# frozen_string_literal: true

module Facter
  module Windows
    class SystemUptimeDays
      FACT_NAME = 'system_uptime.days'
      ALIASES = 'uptime_days'

      def call_the_resolver
        fact_value = Resolvers::Windows::Uptime.resolve(:days)

        [ResolvedFact.new(FACT_NAME, fact_value), ResolvedFact.new(ALIASES, fact_value, :legacy)]
      end
    end
  end
end
