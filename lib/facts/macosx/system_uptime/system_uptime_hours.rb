# frozen_string_literal: true

module Facter
  module Macosx
    class SystemUptimeHours
      FACT_NAME = 'system_uptime.hours'

      def call_the_resolver
        fact_value = Facter::Resolvers::Uptime.resolve(:hours)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
