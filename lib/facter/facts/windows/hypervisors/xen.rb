# frozen_string_literal: true

module Facts
  module Windows
    module Hypervisors
      class Xen
        FACT_NAME = 'hypervisors.xen'

        def call_the_resolver
          if Facter::Resolvers::Windows::Virtualization.resolve(:virtual) == 'xen'
            fact_value = { context: hvm? ? 'hvm' : 'pv' }
          end

          Facter::ResolvedFact.new(FACT_NAME, fact_value)
        end

        private

        def hvm?
          Facter::Resolvers::DMIComputerSystem.resolve(:name) =~ /^HVM/
        end
      end
    end
  end
end
