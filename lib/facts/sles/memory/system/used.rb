# frozen_string_literal: true

module Facter
  module Sles
    class MemorySystemUsed
      FACT_NAME = 'memory.system.used'

      def call_the_resolver
        fact_value = Resolvers::Linux::Memory.resolve(:used_bytes)
        fact_value = BytesToHumanReadable.convert(fact_value)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
