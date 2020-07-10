# frozen_string_literal: true

module Facts
  module Macosx
    module Memory
      module System
        class Available
          FACT_NAME = 'memory.system.available'
          ALIASES = 'memoryfree'

          def call_the_resolver
            fact_value = Facter::Resolvers::Macosx::SystemMemory.resolve(:available_bytes)
            fact_value = Facter::FactsUtils::UnitConverter.bytes_to_human_readable(fact_value)

            [Facter::ResolvedFact.new(FACT_NAME, fact_value), Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
          end
        end
      end
    end
  end
end
