# frozen_string_literal: true

module Facts
  module Aix
    module Memory
      module System
        class UsedBytes
          FACT_NAME = 'memory.system.used_bytes'

          def call_the_resolver
            fact_value = Facter::Resolvers::Aix::Memory.resolve(:system)
            fact_value = fact_value[:used_bytes] if fact_value
            Facter::ResolvedFact.new(FACT_NAME, fact_value)
          end
        end
      end
    end
  end
end
