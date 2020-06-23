# frozen_string_literal: true

module Facts
  module Windows
    class Ec2Metadata
      FACT_NAME = 'ec2_metadata'

      def call_the_resolver
        return Facter::ResolvedFact.new(FACT_NAME, nil) unless aws?

        fact_value = Facter::Resolvers::Ec2.resolve(:metadata)

        Facter::ResolvedFact.new(FACT_NAME, fact_value.empty? ? nil : fact_value)
      end

      def aws?
        virtual = Facter::Resolvers::Virtualization.resolve(:virtual)

        virtual == 'kvm' || virtual =~ /xen/
      end
    end
  end
end
