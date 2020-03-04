# frozen_string_literal: true

module Facts
  module Macosx
    module SystemProfiler
      class ProcessorSpeed
        FACT_NAME = 'system_profiler.processor_speed'

        def call_the_resolver
          fact_value = Facter::Resolvers::SystemProfiler.resolve(:processor_speed)
          Facter::ResolvedFact.new(FACT_NAME, fact_value)
        end
      end
    end
  end
end
