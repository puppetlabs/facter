# frozen_string_literal: true

module Facter
  module Macosx
    class SystemProfilerCores
      FACT_NAME = 'system_profiler.cores'

      def call_the_resolver
        fact_value = Facter::Resolvers::SystemProfiler.resolve(:total_number_of_cores)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
