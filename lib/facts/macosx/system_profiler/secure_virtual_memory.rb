# frozen_string_literal: true

module Facts
  module Macosx
    module SystemProfiler
      class SecureVirtualMemory
        FACT_NAME = 'system_profiler.secure_virtual_memory'
        ALIASES = 'sp_secure_vm'

        def call_the_resolver
          fact_value = Facter::Resolvers::Macosx::SystemProfiler.resolve(:secure_virtual_memory)
          [Facter::ResolvedFact.new(FACT_NAME, fact_value), Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
        end
      end
    end
  end
end
