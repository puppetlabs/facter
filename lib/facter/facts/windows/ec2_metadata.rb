# frozen_string_literal: true

module Facts
  module Windows
    class Ec2Metadata
      FACT_NAME = 'ec2_metadata'

      def call_the_resolver
        return Facter::ResolvedFact.new(FACT_NAME, nil) unless aws_hypervisors?

        fact_value = Facter::Resolvers::Ec2.resolve(:metadata)

        Facter::ResolvedFact.new(FACT_NAME, fact_value&.empty? ? nil : fact_value)
      end

      private

      def aws_hypervisors?
        virtual = Facter::Resolvers::Windows::Virtualization.resolve(:virtual)

        virtual == 'kvm' || virtual =~ /xen/
      end
    end
  end
end
