# frozen_string_literal: true

module Facts
  module Aix
    module Memory
      module System
        class Capacity
          FACT_NAME = 'memory.system.capacity'

          def call_the_resolver
            fact_value = Facter::Resolvers::Aix::Memory.resolve(:system)
            fact_value = fact_value[:capacity] if fact_value

            Facter::ResolvedFact.new(FACT_NAME, fact_value)
          end
        end
      end
    end
  end
end
