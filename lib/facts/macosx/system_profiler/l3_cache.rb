# frozen_string_literal: true

module Facts
  module Macosx
    module SystemProfiler
      class L3Cache
        FACT_NAME = 'system_profiler.l3_cache'
        ALIASES = 'sp_l3_cache'

        def call_the_resolver
          fact_value = Facter::Resolvers::SystemProfiler.resolve(:l3_cache)
          [Facter::ResolvedFact.new(FACT_NAME, fact_value), Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
        end
      end
    end
  end
end
