# frozen_string_literal: true

module Facts
  module Linux
    module Hypervisors
      class Kvm
        FACT_NAME = 'hypervisors.kvm'

        def initialize
          @log = Facter::Log.new(self)
        end

        def call_the_resolver
          hypervisor = discover_hypervisor
          @log.debug("Detected hypervisor #{hypervisor}")

          return Facter::ResolvedFact.new(FACT_NAME, nil) if %w[virtualbox parallels].include?(hypervisor)

          fact_value = discover_provider if kvm?

          Facter::ResolvedFact.new(FACT_NAME, fact_value)
        end

        private

        def kvm?
          bios_vendor = Facter::Resolvers::Linux::DmiBios.resolve(:bios_vendor)
          @log.debug("Detected bios vendor: #{bios_vendor}")

          Facter::Resolvers::VirtWhat.resolve(:vm) == 'kvm' ||
            Facter::Resolvers::Lspci.resolve(:vm) == 'kvm' ||
            bios_vendor&.include?('Amazon EC2') ||
            bios_vendor&.include?('Google')
        end

        def discover_hypervisor
          product_name = Facter::Resolvers::Linux::DmiBios.resolve(:product_name)
          @log.debug("Detected product name: #{product_name}")

          return unless product_name

          Facter::FactsUtils::HYPERVISORS_HASH.each { |key, value| return value if product_name.include?(key) }

          product_name
        end

        def discover_provider
          manufacturer = Facter::Resolvers::Linux::DmiBios.resolve(:sys_vendor)
          @log.debug("Detected manufacturer: #{manufacturer}")

          return { google: true } if manufacturer == 'Google'

          return { openstack: true } if manufacturer =~ /^OpenStack/

          return { amazon: true } if manufacturer =~ /^Amazon/

          {}
        end
      end
    end
  end
end
