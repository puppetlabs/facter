# frozen_string_literal: true

module Facter
  module Macosx
    class SystemProfilerProcessors
      FACT_NAME = 'system_profiler.processors'

      def call_the_resolver
        fact_value = Facter::Resolvers::SystemProfiler.resolve(:processors)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
