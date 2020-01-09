# frozen_string_literal: true

module Facter
  module Macosx
    class MemorySystemCapacity
      FACT_NAME = 'memory.system.capacity'

      def call_the_resolver
        fact_value = Resolvers::Macosx::SystemMemory.resolve(:capacity)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
