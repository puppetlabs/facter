# frozen_string_literal: true

module Facts
  module Sles
    module Memory
      module System
        class Capacity
          FACT_NAME = 'memory.system.capacity'

          def call_the_resolver
            fact_value = Facter::Resolvers::Linux::Memory.resolve(:capacity)
            Facter::ResolvedFact.new(FACT_NAME, fact_value)
          end
        end
      end
    end
  end
end
