# frozen_string_literal: true

module Facts
  module Solaris
    module SystemUptime
      class Hours
        FACT_NAME = 'system_uptime.hours'

        def call_the_resolver
          fact_value = Facter::Resolvers::Uptime.resolve(:hours)

          Facter::ResolvedFact.new(FACT_NAME, fact_value)
        end
      end
    end
  end
end
