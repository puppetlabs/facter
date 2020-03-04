# frozen_string_literal: true

module Facts
  module Macosx
    module Memory
      module System
        class TotalBytes
          FACT_NAME = 'memory.system.total_bytes'

          def call_the_resolver
            fact_value = Facter::Resolvers::Macosx::SystemMemory.resolve(:total_bytes)
            Facter::ResolvedFact.new(FACT_NAME, fact_value)
          end
        end
      end
    end
  end
end
