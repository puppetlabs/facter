# frozen_string_literal: true

module Facts
  module Windows
    module Processors
      class Threads
        FACT_NAME = 'processors.threads'

        def call_the_resolver
          fact_value = Facter::Resolvers::Processors.resolve(:threads_per_core)

          Facter::ResolvedFact.new(FACT_NAME, fact_value)
        end
      end
    end
  end
end
