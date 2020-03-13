# frozen_string_literal: true

module Facts
  module Macosx
    module SystemProfiler
      class Cores
        FACT_NAME = 'system_profiler.cores'
        ALIASES = 'sp_number_processors'

        def call_the_resolver
          fact_value = Facter::Resolvers::SystemProfiler.resolve(:total_number_of_cores)
          [Facter::ResolvedFact.new(FACT_NAME, fact_value), Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
        end
      end
    end
  end
end
