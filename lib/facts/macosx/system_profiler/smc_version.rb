# frozen_string_literal: true

module Facter
  module Macosx
    class SystemProfilerSmcVersion
      FACT_NAME = 'system_profiler.smc_version'

      def call_the_resolver
        fact_value = Facter::Resolvers::SystemProfiler.resolve(:smc_version_system)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
