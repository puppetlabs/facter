# frozen_string_literal: true

module Facts
  module Macosx
    module SystemProfiler
      class KernelVersion
        FACT_NAME = 'system_profiler.kernel_version'
        ALIASES = 'sp_kernel_version'

        def call_the_resolver
          fact_value = Facter::Resolvers::Macosx::SystemProfiler.resolve(:kernel_version)
          [Facter::ResolvedFact.new(FACT_NAME, fact_value), Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
        end
      end
    end
  end
end
