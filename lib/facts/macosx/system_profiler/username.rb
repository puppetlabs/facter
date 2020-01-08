# frozen_string_literal: true

module Facter
  module Macosx
    class SystemProfilerUsername
      FACT_NAME = 'system_profiler.username'

      def call_the_resolver
        fact_value = Facter::Resolvers::SystemProfiler.resolve(:username)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
