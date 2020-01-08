# frozen_string_literal: true

module Facter
  module Macosx
    class SystemProfilerModelIdentifier
      FACT_NAME = 'system_profiler.model_identifier'

      def call_the_resolver
        fact_value = Facter::Resolvers::SystemProfiler.resolve(:model_identifier)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
