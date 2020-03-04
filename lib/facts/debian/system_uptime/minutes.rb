# frozen_string_literal: true

module Facts
  module Debian
    module SystemUptime
      class Minutes
        FACT_NAME = 'system_uptime.minutes'

        def call_the_resolver
          fact_value = Facter::Resolvers::Uptime.resolve(:minutes)

          Facter::ResolvedFact.new(FACT_NAME, fact_value)
        end
      end
    end
  end
end
