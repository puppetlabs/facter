# frozen_string_literal: true

module Facter
  module Macosx
    class SystemProfilerModelName
      FACT_NAME = 'system_profiler.model_name'

      def call_the_resolver
        fact_value = Facter::Resolvers::SystemProfiler.resolve(:model_name)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
