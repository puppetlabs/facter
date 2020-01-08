# frozen_string_literal: true

module Facter
  module Macosx
    class SystemProfilerProcessorSpeed
      FACT_NAME = 'system_profiler.processor_speed'

      def call_the_resolver
        fact_value = Facter::Resolvers::SystemProfiler.resolve(:processor_speed)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
