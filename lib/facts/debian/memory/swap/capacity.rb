# frozen_string_literal: true

module Facts
  module Debian
    module Memory
      module Swap
        class Capacity
          FACT_NAME = 'memory.swap.capacity'

          def call_the_resolver
            fact_value = Facter::Resolvers::Linux::Memory.resolve(:swap_capacity)
            Facter::ResolvedFact.new(FACT_NAME, fact_value)
          end
        end
      end
    end
  end
end
