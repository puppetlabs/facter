# frozen_string_literal: true

module Facts
  module Windows
    module Hypervisors
      class Xen
        FACT_NAME = 'hypervisors.xen'

        def call_the_resolver
          fact_value = { context: hvm? ? 'hvm' : 'pv' } if Facter::Resolvers::Virtualization.resolve(:virtual) == 'xen'

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
