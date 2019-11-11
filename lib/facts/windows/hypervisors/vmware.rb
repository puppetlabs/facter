# frozen_string_literal: true

module Facter
  module Windows
    class HypervisorsVmware
      FACT_NAME = 'hypervisors.vmware'

      def call_the_resolver
        fact_value = {} if vmware?

        ResolvedFact.new(FACT_NAME, fact_value)
      end

      private

      def vmware?
        Resolvers::CpuidSource.resolve(:vendor) == 'VMwareVMware' ||
          Resolvers::DMIBios.resolve(:manufacturer) == 'VMware, Inc.'
      end
    end
  end
end
