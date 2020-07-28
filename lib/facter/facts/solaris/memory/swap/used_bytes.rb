# frozen_string_literal: true

module Facts
  module Solaris
    module Memory
      module Swap
        class UsedBytes
          FACT_NAME = 'memory.swap.used_bytes'

          def call_the_resolver
            fact_value = Facter::Resolvers::Solaris::Memory.resolve(:swap)
            fact_value = fact_value[:used_bytes] if fact_value
            Facter::ResolvedFact.new(FACT_NAME, fact_value)
          end
        end
      end
    end
  end
end
