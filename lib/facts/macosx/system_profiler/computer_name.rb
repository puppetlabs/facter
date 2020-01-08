# frozen_string_literal: true

module Facter
  module Macosx
    class SystemProfilerComputerName
      FACT_NAME = 'system_profiler.computer_name'

      def call_the_resolver
        fact_value = Facter::Resolvers::SystemProfiler.resolve(:computer_name)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
