# frozen_string_literal: true

module Facter
  module Macosx
    class MemorySystemUsedBytes
      FACT_NAME = 'memory.system.used_bytes'

      def call_the_resolver
        fact_value = Resolvers::Macosx::SystemMemory.resolve(:used_bytes)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
