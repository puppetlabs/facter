# frozen_string_literal: true

module Facts
  module Solaris
    module SystemUptime
      class Uptime
        FACT_NAME = 'system_uptime.uptime'

        def call_the_resolver
          fact_value = Facter::Resolvers::Uptime.resolve(:uptime)

          Facter::ResolvedFact.new(FACT_NAME, fact_value)
        end
      end
    end
  end
end
