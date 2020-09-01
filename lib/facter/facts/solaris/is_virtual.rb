# frozen_string_literal: true

module Facts
  module Solaris
    class IsVirtual
      FACT_NAME = 'is_virtual'

      def initialize
        @log = Facter::Log.new(self)
      end

      def call_the_resolver
        @log.debug('Solaris Virtual Resolver')

        fact_value = check_ldom || check_zone || check_xen || check_other_facts || 'physical'

        @log.debug("Fact value is: #{fact_value}")

        Facter::ResolvedFact.new(FACT_NAME, check_if_virtual(fact_value))
      end

      def check_ldom
        @log.debug('Checking LDoms')
        return unless Facter::Resolvers::Solaris::Ldom.resolve(:role_control) == 'false'

        Facter::Resolvers::Solaris::Ldom.resolve(:role_impl)
      end

      def check_zone
        @log.debug('Checking LDoms')
        zone_name = Facter::Resolvers::Solaris::ZoneName.resolve(:current_zone_name)

        return if zone_name == 'global'

        'zone'
      end

      def check_xen
        @log.debug('Checking XEN')
        Facter::Resolvers::Xen.resolve(:vm)
      end

      def check_other_facts
        isa = Facter::Resolvers::Uname.resolve(:processor)
        klass = isa == 'sparc' ? 'DmiSparc' : 'Dmi'

        product_name = Facter::Resolvers::Solaris.const_get(klass).resolve(:product_name)
        bios_vendor = Facter::Resolvers::Solaris.const_get(klass).resolve(:bios_vendor)

        return 'kvm' if bios_vendor&.include?('Amazon EC2')

        return unless product_name

        Facter::FactsUtils::HYPERVISORS_HASH.each { |key, value| return value if product_name.include?(key) }

        nil
      end

      def check_if_virtual(found_vm)
        Facter::FactsUtils::PHYSICAL_HYPERVISORS.count(found_vm).zero?
      end
    end
  end
end
