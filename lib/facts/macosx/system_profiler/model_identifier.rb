# frozen_string_literal: true

module Facts
  module Macosx
    module SystemProfiler
      class ModelIdentifier
        FACT_NAME = 'system_profiler.model_identifier'
        ALIASES = 'sp_machine_model'

        def call_the_resolver
          fact_value = Facter::Resolvers::SystemProfiler.resolve(:model_identifier)
          [Facter::ResolvedFact.new(FACT_NAME, fact_value), Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
        end
      end
    end
  end
end
