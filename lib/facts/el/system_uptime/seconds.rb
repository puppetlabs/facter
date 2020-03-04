# frozen_string_literal: true

module Facts
  module El
    module SystemUptime
      class Seconds
        FACT_NAME = 'system_uptime.seconds'

        def call_the_resolver
          fact_value = Facter::Resolvers::Uptime.resolve(:seconds)
          Facter::ResolvedFact.new(FACT_NAME, fact_value)
        end
      end
    end
  end
end
