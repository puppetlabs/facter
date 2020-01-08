# frozen_string_literal: true

module Facter
  module Macosx
    class SystemProfilerHardwareUuid
      FACT_NAME = 'system_profiler.hardware_uuid'

      def call_the_resolver
        fact_value = Facter::Resolvers::SystemProfiler.resolve(:hardware_uuid)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
