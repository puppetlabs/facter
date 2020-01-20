# frozen_string_literal: true

module Facter
  module Macosx
    class SystemProfilerSerialNumber
      FACT_NAME = 'system_profiler.serial_number'

      def call_the_resolver
        fact_value = Facter::Resolvers::SystemProfiler.resolve(:serial_number_system)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
