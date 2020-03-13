# frozen_string_literal: true

module Facts
  module Macosx
    module SystemProfiler
      class SmcVersion
        FACT_NAME = 'system_profiler.smc_version'
        ALIASES = 'sp_smc_version_system'

        def call_the_resolver
          fact_value = Facter::Resolvers::SystemProfiler.resolve(:smc_version_system)
          [Facter::ResolvedFact.new(FACT_NAME, fact_value), Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
        end
      end
    end
  end
end
