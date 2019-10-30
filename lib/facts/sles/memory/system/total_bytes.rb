# frozen_string_literal: true

module Facter
  module Sles
    class MemorySystemTotalBytes
      FACT_NAME = 'memory.system.total_bytes'

      def call_the_resolver
        fact_value = Resolvers::Linux::Memory.resolve(:total)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
