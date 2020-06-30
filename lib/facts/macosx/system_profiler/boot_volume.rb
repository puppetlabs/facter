# frozen_string_literal: true

module Facts
  module Macosx
    module SystemProfiler
      class BootVolume
        FACT_NAME = 'system_profiler.boot_volume'
        ALIASES = 'sp_boot_volume'

        def call_the_resolver
          fact_value = Facter::Resolvers::Macosx::SystemProfiler.resolve(:boot_volume)
          [Facter::ResolvedFact.new(FACT_NAME, fact_value), Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
        end
      end
    end
  end
end
