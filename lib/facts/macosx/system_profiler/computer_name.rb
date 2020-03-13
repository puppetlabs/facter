# frozen_string_literal: true

module Facts
  module Macosx
    module SystemProfiler
      class ComputerName
        FACT_NAME = 'system_profiler.computer_name'
        ALIASES = 'sp_local_host_name'

        def call_the_resolver
          fact_value = Facter::Resolvers::SystemProfiler.resolve(:computer_name)
          [Facter::ResolvedFact.new(FACT_NAME, fact_value), Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
        end
      end
    end
  end
end
