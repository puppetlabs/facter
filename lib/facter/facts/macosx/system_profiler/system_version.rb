# frozen_string_literal: true

module Facts
  module Macosx
    module SystemProfiler
      class SystemVersion
        FACT_NAME = 'system_profiler.system_version'
        ALIASES = 'sp_os_version'

        def call_the_resolver
          fact_value = Facter::Resolvers::Macosx::SystemProfiler.resolve(:system_version)
          [Facter::ResolvedFact.new(FACT_NAME, fact_value), Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
        end
      end
    end
  end
end
