# frozen_string_literal: true

module Facter
  module Macosx
    class SystemProfilerUptime
      FACT_NAME = 'system_profiler.uptime'

      def call_the_resolver
        fact_value = Facter::Resolvers::SystemProfiler.resolve(:uptime)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
