# frozen_string_literal: true

module Facter
  module El
    class MemorySystemTotal
      FACT_NAME = 'memory.system.total'

      def call_the_resolver
        fact_value = Resolvers::Linux::Memory.resolve(:total)
        fact_value = BytesToHumanReadable.convert(fact_value)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
