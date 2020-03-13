# frozen_string_literal: true

module Facts
  module Macosx
    module SystemProfiler
      class ProcessorSpeed
        FACT_NAME = 'system_profiler.processor_speed'
        ALIASES = 'sp_current_processor_speed'

        def call_the_resolver
          fact_value = Facter::Resolvers::SystemProfiler.resolve(:processor_speed)
          [Facter::ResolvedFact.new(FACT_NAME, fact_value), Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
        end
      end
    end
  end
end
