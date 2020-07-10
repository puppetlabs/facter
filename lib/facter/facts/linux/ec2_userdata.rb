# frozen_string_literal: true

module Facts
  module Linux
    class Ec2Userdata
      FACT_NAME = 'ec2_userdata'

      def call_the_resolver
        return Facter::ResolvedFact.new(FACT_NAME, nil) unless aws?

        fact_value = Facter::Resolvers::Ec2.resolve(:userdata)

        Facter::ResolvedFact.new(FACT_NAME, fact_value.empty? ? nil : fact_value)
      end

      def aws?
        virtual = check_virt_what || check_xen || check_product_name || check_bios_vendor || check_lspci

        virtual == 'kvm' || virtual =~ /xen/
      end

      def check_virt_what
        Facter::Resolvers::VirtWhat.resolve(:vm)
      end

      def check_xen
        Facter::Resolvers::Xen.resolve(:vm)
      end

      def check_product_name
        product_name = Facter::Resolvers::Linux::DmiBios.resolve(:product_name)
        return unless product_name

        Facter::FactsUtils::HYPERVISORS_HASH.each { |key, value| return value if product_name.include?(key) }
      end

      def check_bios_vendor
        bios_vendor = Facter::Resolvers::Linux::DmiBios.resolve(:bios_vendor)
        return 'kvm' if bios_vendor&.include?('Amazon EC2')
      end

      def check_lspci
        Facter::Resolvers::Lspci.resolve(:vm)
      end
    end
  end
end
