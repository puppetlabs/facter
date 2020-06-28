# frozen_string_literal: true

module Facts
  module Macosx
    module SystemProfiler
      class SerialNumber
        FACT_NAME = 'system_profiler.serial_number'
        ALIASES = 'sp_serial_number'

        def call_the_resolver
          fact_value = Facter::Resolvers::Macosx::SystemProfiler.resolve(:serial_number_system)
          [Facter::ResolvedFact.new(FACT_NAME, fact_value), Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
        end
      end
    end
  end
end
