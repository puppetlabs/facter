# frozen_string_literal: true

module Facts
  module Freebsd
    module SystemUptime
      class Seconds
        FACT_NAME = 'system_uptime.seconds'
        ALIASES = 'uptime_seconds'

        def call_the_resolver
          fact_value = Facter::Resolvers::Uptime.resolve(:seconds)

          [Facter::ResolvedFact.new(FACT_NAME, fact_value), Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
        end
      end
    end
  end
end
