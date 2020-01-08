# frozen_string_literal: true

module Facter
  module Macosx
    class SystemProfilerSecureVirtualMemory
      FACT_NAME = 'system_profiler.secure_virtual_memory'

      def call_the_resolver
        fact_value = Facter::Resolvers::SystemProfiler.resolve(:secure_virtual_memory)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
