# frozen_string_literal: true

module Facts
  module Macosx
    module SystemProfiler
      class Processors
        FACT_NAME = 'system_profiler.processors'
        ALIASES = 'sp_packages'

        def call_the_resolver
          fact_value = Facter::Resolvers::Macosx::SystemProfiler.resolve(:number_of_processors)
          [Facter::ResolvedFact.new(FACT_NAME, fact_value), Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
        end
      end
    end
  end
end
