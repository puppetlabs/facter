# frozen_string_literal: true

module Facter
  module Windows
    class SystemUptimeSeconds
      FACT_NAME = 'system_uptime.seconds'

      def call_the_resolver
        fact_value = UptimeResolver.resolve(:seconds)

        Fact.new(FACT_NAME, fact_value)
      end
    end
  end
end
