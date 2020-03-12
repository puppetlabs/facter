# frozen_string_literal: true

module Facts
  module El
    module SystemUptime
      class Days
        FACT_NAME = 'system_uptime.days'
        ALIASES = 'uptime_days'

        def call_the_resolver
          fact_value = Facter::Resolvers::Uptime.resolve(:days)

          [Facter::ResolvedFact.new(FACT_NAME, fact_value), Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
        end
      end
    end
  end
end
