# frozen_string_literal: true

module Facts
  module Linux
    class Ec2Userdata
      FACT_NAME = 'ec2_userdata'

      def initialize
        @virtual = Facter::VirtualDetector.new
      end

      def call_the_resolver
        return Facter::ResolvedFact.new(FACT_NAME, nil) unless aws_hypervisors?

        fact_value = Facter::Resolvers::Ec2.resolve(:userdata)

        Facter::ResolvedFact.new(FACT_NAME, fact_value&.empty? ? nil : fact_value)
      end

      private

      def aws_hypervisors?
        @virtual.platform =~ /kvm|xen|aws/
      end
    end
  end
end
