# frozen_string_literal: true

module Facts
  module Macosx
    module SystemProfiler
      class BootRomVersion
        FACT_NAME = 'system_profiler.boot_rom_version'

        def call_the_resolver
          fact_value = Facter::Resolvers::SystemProfiler.resolve(:boot_rom_version)
          Facter::ResolvedFact.new(FACT_NAME, fact_value)
        end
      end
    end
  end
end
