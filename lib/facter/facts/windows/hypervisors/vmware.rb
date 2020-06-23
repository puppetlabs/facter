# frozen_string_literal: true

module Facts
  module Windows
    module Hypervisors
      class Vmware
        FACT_NAME = 'hypervisors.vmware'

        def call_the_resolver
          fact_value = {} if vmware?

          Facter::ResolvedFact.new(FACT_NAME, fact_value)
        end

        private

        def vmware?
          Facter::Resolvers::Virtualization.resolve(:virtual) == 'vmware' ||
            Facter::Resolvers::DMIBios.resolve(:manufacturer) == 'VMware, Inc.'
        end
      end
    end
  end
end
