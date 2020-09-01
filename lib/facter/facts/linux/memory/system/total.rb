# frozen_string_literal: true

module Facts
  module Linux
    module Memory
      module System
        class Total
          FACT_NAME = 'memory.system.total'
          ALIASES = 'memorysize'

          def call_the_resolver
            fact_value = Facter::Resolvers::Linux::Memory.resolve(:total)
            fact_value = Facter::FactsUtils::UnitConverter.bytes_to_human_readable(fact_value)
            [Facter::ResolvedFact.new(FACT_NAME, fact_value), Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
          end
        end
      end
    end
  end
end
