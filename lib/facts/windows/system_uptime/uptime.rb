# frozen_string_literal: true

module Facts
  module Windows
    module SystemUptime
      class Uptime
        FACT_NAME = 'system_uptime.uptime'
        ALIASES = 'uptime'

        def call_the_resolver
          fact_value = Facter::Resolvers::Windows::Uptime.resolve(:uptime)

          [Facter::ResolvedFact.new(FACT_NAME, fact_value), Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
        end
      end
    end
  end
end
