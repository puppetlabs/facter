# frozen_string_literal: true

module Facts
  module El
    module Memory
      module System
        class UsedBytes
          FACT_NAME = 'memory.system.used_bytes'

          def call_the_resolver
            fact_value = Facter::Resolvers::Linux::Memory.resolve(:used_bytes)
            Facter::ResolvedFact.new(FACT_NAME, fact_value)
          end
        end
      end
    end
  end
end
