# frozen_string_literal: true

module Facts
  module Solaris
    module Memory
      module Swap
        class Capacity
          FACT_NAME = 'memory.swap.capacity'

          def call_the_resolver
            fact_value = Facter::Resolvers::Solaris::Memory.resolve(:swap)
            fact_value = fact_value[:capacity] if fact_value

            Facter::ResolvedFact.new(FACT_NAME, fact_value)
          end
        end
      end
    end
  end
end
