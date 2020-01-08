# frozen_string_literal: true

module Facter
  module Macosx
    class SystemProfilerSystemVersion
      FACT_NAME = 'system_profiler.system_version'

      def call_the_resolver
        fact_value = Facter::Resolvers::SystemProfiler.resolve(:system_version)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
