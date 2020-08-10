# frozen_string_literal: true

module Facts
  module Freebsd
    module Memory
      module Swap
        class Encrypted
          FACT_NAME = 'memory.swap.encrypted'
          ALIASES = 'swapencrypted'

          def call_the_resolver
            fact_value = Facter::Resolvers::Freebsd::SwapMemory.resolve(:encrypted)
            [Facter::ResolvedFact.new(FACT_NAME, fact_value), Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
          end
        end
      end
    end
  end
end
