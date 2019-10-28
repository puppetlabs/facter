# frozen_string_literal: true

module Facter
  module Fedora
    class MemorySystemUsedBytes
      FACT_NAME = 'memory.system.used_bytes'

      def call_the_resolver
        fact_value = Resolvers::Linux::Memory.resolve(:used_bytes)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
