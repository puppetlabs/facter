# frozen_string_literal: true

module Facter
  module Windows
    class MemorySystemCapacity
      FACT_NAME = 'memory.system.capacity'

      def call_the_resolver
        fact_value = Resolvers::Memory.resolve(:capacity)

        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
