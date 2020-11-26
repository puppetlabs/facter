# frozen_string_literal: true

module Facts
  module Aix
    module Memory
      module System
        class AvailableBytes
          FACT_NAME = 'memory.system.available_bytes'
          ALIASES = 'memoryfree_mb'

          def call_the_resolver
            fact_value = Facter::Resolvers::Aix::Memory.resolve(:system)
            fact_value = fact_value[:available_bytes] if fact_value

            [Facter::ResolvedFact.new(FACT_NAME, fact_value),
             Facter::ResolvedFact.new(ALIASES, Facter::Util::Facts::UnitConverter.bytes_to_mb(fact_value), :legacy)]
          end
        end
      end
    end
  end
end
