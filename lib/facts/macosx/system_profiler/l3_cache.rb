# frozen_string_literal: true

module Facts
  module Macosx
    module SystemProfiler
      class L3Cache
        FACT_NAME = 'system_profiler.l3_cache'

        def call_the_resolver
          fact_value = Facter::Resolvers::SystemProfiler.resolve(:l3_cache)
          Facter::ResolvedFact.new(FACT_NAME, fact_value)
        end
      end
    end
  end
end
