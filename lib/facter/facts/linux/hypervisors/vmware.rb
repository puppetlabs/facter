# frozen_string_literal: true

module Facts
  module Linux
    module Hypervisors
      class Vmware
        FACT_NAME = 'hypervisors.vmware'

        def initialize
          @log = Facter::Log.new(self)
        end

        def call_the_resolver
          if vmware?
            @log.debug('Vmware hypervisor detected')
            fact_value = {}

            fact_value[:version] = Facter::Resolvers::DmiDecode.resolve(:vmware_version) || ''

            return Facter::ResolvedFact.new(FACT_NAME, fact_value)
          end

          @log.debug('No Vmware hypervisor detected.')
          []
        end

        private

        def vmware?
          Facter::Resolvers::VirtWhat.resolve(:vm) == 'vmware' ||
            Facter::Resolvers::Linux::DmiBios.resolve(:product_name) == 'VMware' ||
            Facter::Resolvers::Lspci.resolve(:vm) == 'vmware' ||
            Facter::Resolvers::Linux::DmiBios.resolve(:sys_vendor) == 'VMware, Inc.'
        end
      end
    end
  end
end
