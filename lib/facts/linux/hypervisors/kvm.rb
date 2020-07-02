# frozen_string_literal: true

module Facts
  module Linux
    module Hypervisors
      class Kvm
        FACT_NAME = 'hypervisors.kvm'

        def call_the_resolver
          product_name = check_other_facts

          if product_name == 'virtualbox' || product_name == 'parallels'
            return Facter::ResolvedFact.new(FACT_NAME, nil)
          end

          fact_value = discover_provider(product_name) || {} if kvm?(product_name)

          Facter::ResolvedFact.new(FACT_NAME, fact_value)
        end

        private

        def kvm?(product_name)
          Facter::Resolvers::VirtWhat.resolve(:vm) == 'kvm' ||
            product_name == 'kvm' ||
            Facter::Resolvers::Lspci.resolve(:vm) == 'kvm'
        end

        def check_other_facts
          product_name = Facter::Resolvers::Linux::DmiBios.resolve(:product_name)
          bios_vendor =  Facter::Resolvers::Linux::DmiBios.resolve(:bios_vendor)
          return 'kvm' if bios_vendor&.include?('Amazon EC2')
          return unless product_name

          Facter::FactsUtils::HYPERVISORS_HASH.each { |key, value| return value if product_name.include?(key) }

          product_name
        end

        def discover_provider(product_name)
          manufacturer = Facter::Resolvers::Linux::DmiBios.resolve(:sys_vendor)
          return { google: true } if manufacturer == 'Google'

          return { openstack: true } if product_name == /^OpenStack/

          return { amazon: true } if manufacturer =~ /^Amazon/
        end
      end
    end
  end
end
