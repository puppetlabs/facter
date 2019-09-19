# frozen_string_literal: true

module Facter
  module Windows
    class SystemUptimeDays
      FACT_NAME = 'system_uptime.days'

      def call_the_resolver
        fact_value = Resolvers::UptimeResolver.resolve(:days)

        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
