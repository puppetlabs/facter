# frozen_string_literal: true

module Facter
  module Windows
    class HypervisorsKvm
      FACT_NAME = 'hypervisors.kvm'

      def call_the_resolver
        fact_value = discover_provider || {} if kvm?

        ResolvedFact.new(FACT_NAME, fact_value)
      end

      private

      def kvm?
        product_name = Resolvers::DMIComputerSystem.resolve(:name)

        (Resolvers::Virtualization.resolve(:virtual) == 'kvm' || Resolvers::NetKVM.resolve(:kvm)) &&
          product_name != 'VirtualBox' && !product_name.match(/^Parallels/)
      end

      def discover_provider
        manufacturer = Resolvers::DMIBios.resolve(:manufacturer)

        return { google: true } if manufacturer == 'Google'

        return { openstack: true } if Resolvers::DMIComputerSystem.resolve(:name) =~ /^OpenStack/

        return { amazon: true } if manufacturer =~ /^Amazon/
      end
    end
  end
end
