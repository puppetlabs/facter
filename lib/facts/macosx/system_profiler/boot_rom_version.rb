# frozen_string_literal: true

module Facter
  module Macosx
    class SystemProfilerBootRomVersion
      FACT_NAME = 'system_profiler.boot_rom_version'

      def call_the_resolver
        fact_value = Facter::Resolvers::SystemProfiler.resolve(:boot_rom_version)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
