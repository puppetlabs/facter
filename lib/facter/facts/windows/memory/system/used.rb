# frozen_string_literal: true

module Facts
  module Windows
    module Memory
      module System
        class Used
          FACT_NAME = 'memory.system.used'

          def call_the_resolver
            fact_value = Facter::Resolvers::Memory.resolve(:used_bytes)
            fact_value = Facter::FactsUtils::UnitConverter.bytes_to_human_readable(fact_value)

            Facter::ResolvedFact.new(FACT_NAME, fact_value)
          end
        end
      end
    end
  end
end
