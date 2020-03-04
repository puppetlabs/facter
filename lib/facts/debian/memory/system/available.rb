# frozen_string_literal: true

module Facts
  module Debian
    module Memory
      module System
        class Available
          FACT_NAME = 'memory.system.available'

          def call_the_resolver
            fact_value = Facter::Resolvers::Linux::Memory.resolve(:memfree)
            fact_value = Facter::BytesToHumanReadable.convert(fact_value)
            Facter::ResolvedFact.new(FACT_NAME, fact_value)
          end
        end
      end
    end
  end
end
