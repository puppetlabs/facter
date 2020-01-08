# frozen_string_literal: true

module Facter
  module Macosx
    class SystemProfilerBootVolume
      FACT_NAME = 'system_profiler.boot_volume'

      def call_the_resolver
        fact_value = Facter::Resolvers::SystemProfiler.resolve(:boot_volume)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
