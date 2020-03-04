# frozen_string_literal: true

module Facts
  module Macosx
    module SystemProfiler
      class Cores
        FACT_NAME = 'system_profiler.cores'

        def call_the_resolver
          fact_value = Facter::Resolvers::SystemProfiler.resolve(:total_number_of_cores)
          Facter::ResolvedFact.new(FACT_NAME, fact_value)
        end
      end
    end
  end
end
