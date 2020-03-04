# frozen_string_literal: true

module Facts
  module Debian
    module Memory
      module Swap
        class Used
          FACT_NAME = 'memory.swap.used'

          def call_the_resolver
            fact_value = Facter::Resolvers::Linux::Memory.resolve(:swap_used_bytes)
            fact_value = Facter::BytesToHumanReadable.convert(fact_value)
            Facter::ResolvedFact.new(FACT_NAME, fact_value)
          end
        end
      end
    end
  end
end
