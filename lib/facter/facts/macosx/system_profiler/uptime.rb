# frozen_string_literal: true

module Facts
  module Macosx
    module SystemProfiler
      class Uptime
        FACT_NAME = 'system_profiler.uptime'
        ALIASES = 'sp_uptime'

        def call_the_resolver
          fact_value = Facter::Resolvers::Macosx::SystemProfiler.resolve(:time_since_boot)
          [Facter::ResolvedFact.new(FACT_NAME, fact_value), Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
        end
      end
    end
  end
end
