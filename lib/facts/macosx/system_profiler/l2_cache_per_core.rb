# frozen_string_literal: true

module Facts
  module Macosx
    module SystemProfiler
      class L2CachePerCore
        FACT_NAME = 'system_profiler.l2_cache_per_core'

        def call_the_resolver
          fact_value = Facter::Resolvers::SystemProfiler.resolve(:l2_cache_per_core)
          Facter::ResolvedFact.new(FACT_NAME, fact_value)
        end
      end
    end
  end
end
