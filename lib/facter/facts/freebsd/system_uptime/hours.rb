# frozen_string_literal: true

module Facts
  module Freebsd
    module SystemUptime
      class Hours
        FACT_NAME = 'system_uptime.hours'
        ALIASES = 'uptime_hours'

        def call_the_resolver
          fact_value = Facter::Resolvers::Uptime.resolve(:hours)

          [Facter::ResolvedFact.new(FACT_NAME, fact_value), Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
        end
      end
    end
  end
end
