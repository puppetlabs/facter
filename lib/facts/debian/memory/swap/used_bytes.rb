# frozen_string_literal: true

module Facts
  module Debian
    module Memory
      module Swap
        class UsedBytes
          FACT_NAME = 'memory.swap.used_bytes'

          def call_the_resolver
            fact_value = Facter::Resolvers::Linux::Memory.resolve(:swap_used_bytes)
            Facter::ResolvedFact.new(FACT_NAME, fact_value)
          end
        end
      end
    end
  end
end
