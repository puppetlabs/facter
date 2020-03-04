# frozen_string_literal: true

module Facts
  module Macosx
    module SystemProfiler
      class Memory
        FACT_NAME = 'system_profiler.memory'

        def call_the_resolver
          fact_value = Facter::Resolvers::SystemProfiler.resolve(:memory)
          Facter::ResolvedFact.new(FACT_NAME, fact_value)
        end
      end
    end
  end
end
