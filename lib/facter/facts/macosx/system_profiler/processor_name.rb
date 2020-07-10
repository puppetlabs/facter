# frozen_string_literal: true

module Facts
  module Macosx
    module SystemProfiler
      class ProcessorName
        FACT_NAME = 'system_profiler.processor_name'
        ALIASES = 'sp_processor_name'

        def call_the_resolver
          fact_value = Facter::Resolvers::Macosx::SystemProfiler.resolve(:processor_name)
          [Facter::ResolvedFact.new(FACT_NAME, fact_value), Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
        end
      end
    end
  end
end
