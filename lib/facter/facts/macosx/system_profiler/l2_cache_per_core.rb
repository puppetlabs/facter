# frozen_string_literal: true

module Facts
  module Macosx
    module SystemProfiler
      class L2CachePerCore
        FACT_NAME = 'system_profiler.l2_cache_per_core'
        ALIASES = 'sp_l2_cache_core'

        def call_the_resolver
          fact_value = Facter::Resolvers::Macosx::SystemProfiler.resolve(:l2_cache_per_core)
          [Facter::ResolvedFact.new(FACT_NAME, fact_value), Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
        end
      end
    end
  end
end
