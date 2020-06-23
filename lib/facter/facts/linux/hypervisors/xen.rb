# frozen_string_literal: true

module Facts
  module Linux
    module Hypervisors
      class Xen
        FACT_NAME = 'hypervisors.xen'

        def initialize
          @log = Facter::Log.new(self)
        end

        def call_the_resolver
          if xen?
            @log.debug('Xen hypervisor detected')
            fact_value = {}

            fact_value[:context] = hvm? ? 'hvm' : 'pv'
            fact_value[:privileged] = Facter::Resolvers::Xen.resolve(:privileged)

            return Facter::ResolvedFact.new(FACT_NAME, fact_value)
          end

          @log.debug('No Xen hypervisor detected.')
          []
        end

        private

        def xen?
          Facter::Resolvers::VirtWhat.resolve(:vm) =~ /xen/ ||
            Facter::Resolvers::Xen.resolve(:vm) =~ /xen/ ||
            discover_hypervisor == 'xenhvm' ||
            Facter::Resolvers::Lspci.resolve(:vm) =~ /xen/
        end

        def hvm?
          discover_hypervisor == 'xenhvm' || Facter::Resolvers::Lspci.resolve(:vm) == 'xenhvm'
        end

        def discover_hypervisor
          product_name = Facter::Resolvers::Linux::DmiBios.resolve(:product_name)
          return unless product_name

          Facter::FactsUtils::HYPERVISORS_HASH.each { |key, value| return value if product_name.include?(key) }

          product_name
        end
      end
    end
  end
end
