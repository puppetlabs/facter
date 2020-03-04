# frozen_string_literal: true

module Facts
  module Macosx
    module SystemProfiler
      class BootVolume
        FACT_NAME = 'system_profiler.boot_volume'

        def call_the_resolver
          fact_value = Facter::Resolvers::SystemProfiler.resolve(:boot_volume)
          Facter::ResolvedFact.new(FACT_NAME, fact_value)
        end
      end
    end
  end
end
