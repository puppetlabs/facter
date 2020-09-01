# frozen_string_literal: true

module Facts
  module Freebsd
    module Memory
      module Swap
        class UsedBytes
          FACT_NAME = 'memory.swap.used_bytes'

          def call_the_resolver
            fact_value = Facter::Resolvers::Freebsd::SwapMemory.resolve(:used_bytes)
            Facter::ResolvedFact.new(FACT_NAME, fact_value)
          end
        end
      end
    end
  end
end
