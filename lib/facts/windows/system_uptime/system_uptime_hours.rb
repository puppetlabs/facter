# frozen_string_literal: true

module Facter
  module Windows
    class SystemUptimeHours
      FACT_NAME = 'system_uptime.hours'

      def call_the_resolver
        fact_value = Resolvers::Uptime.resolve(:hours)

        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
