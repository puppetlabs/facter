# frozen_string_literal: true

module Facts
  module Macosx
    module SystemProfiler
      class Uptime
        FACT_NAME = 'system_profiler.uptime'

        def call_the_resolver
          fact_value = Facter::Resolvers::SystemProfiler.resolve(:time_since_boot)
          Facter::ResolvedFact.new(FACT_NAME, fact_value)
        end
      end
    end
  end
end
