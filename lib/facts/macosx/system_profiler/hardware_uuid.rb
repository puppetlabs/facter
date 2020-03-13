# frozen_string_literal: true

module Facts
  module Macosx
    module SystemProfiler
      class HardwareUuid
        FACT_NAME = 'system_profiler.hardware_uuid'
        ALIASES = 'sp_hardware_uuid'

        def call_the_resolver
          fact_value = Facter::Resolvers::SystemProfiler.resolve(:hardware_uuid)
          [Facter::ResolvedFact.new(FACT_NAME, fact_value), Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
        end
      end
    end
  end
end
