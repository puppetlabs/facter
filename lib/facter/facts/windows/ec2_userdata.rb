# frozen_string_literal: true

module Facts
  module Windows
    class Ec2Userdata
      FACT_NAME = 'ec2_userdata'

      def call_the_resolver
        return Facter::ResolvedFact.new(FACT_NAME, nil) unless aws?

        fact_value = Facter::Resolvers::Ec2.resolve(:userdata)

        Facter::ResolvedFact.new(FACT_NAME, fact_value.empty? ? nil : fact_value)
      end

      def aws?
        virtual = Facter::Resolvers::Virtualization.resolve(:virtual)

        virtual == 'kvm' || virtual =~ /xen/
      end
    end
  end
end
