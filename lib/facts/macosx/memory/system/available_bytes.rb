# frozen_string_literal: true

module Facter
  module Macosx
    class MemorySystemAvailableBytes
      FACT_NAME = 'memory.system.available_bytes'

      def call_the_resolver
        fact_value = Resolvers::Macosx::SystemMemory.resolve(:available_bytes)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
