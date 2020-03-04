# frozen_string_literal: true

module Facts
  module Macosx
    module Memory
      module System
        class AvailableBytes
          FACT_NAME = 'memory.system.available_bytes'

          def call_the_resolver
            fact_value = Facter::Resolvers::Macosx::SystemMemory.resolve(:available_bytes)
            Facter::ResolvedFact.new(FACT_NAME, fact_value)
          end
        end
      end
    end
  end
end
