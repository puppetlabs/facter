# frozen_string_literal: true

module Facts
  module Macosx
    module SystemProfiler
      class ComputerName
        FACT_NAME = 'system_profiler.computer_name'

        def call_the_resolver
          fact_value = Facter::Resolvers::SystemProfiler.resolve(:computer_name)
          Facter::ResolvedFact.new(FACT_NAME, fact_value)
        end
      end
    end
  end
end
