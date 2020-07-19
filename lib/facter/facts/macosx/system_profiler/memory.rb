# frozen_string_literal: true

module Facts
  module Macosx
    module SystemProfiler
      class Memory
        FACT_NAME = 'system_profiler.memory'
        ALIASES = 'sp_physical_memory'

        def call_the_resolver
          fact_value = Facter::Resolvers::Macosx::SystemProfiler.resolve(:memory)
          [Facter::ResolvedFact.new(FACT_NAME, fact_value), Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
        end
      end
    end
  end
end
