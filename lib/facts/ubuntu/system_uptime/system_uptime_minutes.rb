# frozen_string_literal: true

module Facter
  module Ubuntu
    class SystemUptimeMinutes
      FACT_NAME = 'system_uptime.minutes'

      def call_the_resolver
        fact_value = Facter::Resolvers::Uptime.resolve(:minutes)

        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
