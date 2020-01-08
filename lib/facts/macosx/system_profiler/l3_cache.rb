# frozen_string_literal: true

module Facter
  module Macosx
    class SystemProfilerL3Cache
      FACT_NAME = 'system_profiler.l3_cache'

      def call_the_resolver
        fact_value = Facter::Resolvers::SystemProfiler.resolve(:l3_cache)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
