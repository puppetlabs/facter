# frozen_string_literal: true

module Facter
  module Macosx
    class SystemProfilerKernelVersion
      FACT_NAME = 'system_profiler.kernel_version'

      def call_the_resolver
        fact_value = Facter::Resolvers::SystemProfiler.resolve(:kernel_version)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
