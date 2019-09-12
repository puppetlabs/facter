# frozen_string_literal: true

module Facter
  module Windows
    class SystemUptimeUptime
      FACT_NAME = 'system_uptime.uptime'

      def call_the_resolver
        fact_value = UptimeResolver.resolve(:uptime)

        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
