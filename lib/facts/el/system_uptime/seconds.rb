# frozen_string_literal: true

module Facter
  module El
    class SystemUptimeSeconds
      FACT_NAME = 'system_uptime.seconds'

      def call_the_resolver
        fact_value = Resolvers::Uptime.resolve(:seconds)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
