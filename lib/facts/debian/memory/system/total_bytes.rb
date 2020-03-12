# frozen_string_literal: true

module Facts
  module Debian
    module Memory
      module System
        class TotalBytes
          FACT_NAME = 'memory.system.total_bytes'
          ALIASES = 'memorysize_mb'

          def call_the_resolver
            fact_value = Facter::Resolvers::Linux::Memory.resolve(:total)
            [Facter::ResolvedFact.new(FACT_NAME, fact_value),
             Facter::ResolvedFact.new(ALIASES, Facter::FactsUtils::BytesConverter.to_mb(fact_value), :legacy)]
          end
        end
      end
    end
  end
end
